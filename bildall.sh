# $Id$
#
# Collecting the sourced files
#
######################################################################

######################################################################
#
# Sanity check
#
######################################################################

if test -z "$USER"; then
  echo -n "WARNING: USER is unknown."
  if test -n "$LOGNAME"; then
    echo "  Setting to LOGNAME = $LOGNAME."
    export USER=$LOGNAME
  else
    echo "  And neither is LOGNAME.  Quitting."
    exit
  fi
fi

######################################################################
#
# Get locations of main components: project, Bilder, Runnr, Confdir
#
######################################################################

# Store executable, top directory
me=$0
if test -z "$PROJECT_DIR"; then
  echo "WARNING: PROJECT_DIR not defined."
fi
PROJECT_DIR=`(cd $PROJECT_DIR; pwd -P)`
cd $PROJECT_DIR

# Get bilder and runnr functions
BILDER_DIR=`dirname $BASH_SOURCE`
BILDER_DIR=`(cd $BILDER_DIR; pwd -P)`
RUNNR_DIR=$BILDER_DIR/runnr
BILDER_CONFDIR=${BILDER_CONFDIR:-"$RUNNR_DIR"}

######################################################################
#
# Define all general functions used by Bilder.  Those in Runnr
# are the subset that have usefulness for ruuning in queues,
# determining hosts, etc., allow a use to grab just them.
#
######################################################################

if source $RUNNR_DIR/runnrfcns.sh; then
  echo "$RUNNR_DIR/runnrfcns.sh sourced."
# techo now available but cannot be used until log are rotated (in bildopts).
else
  echo "Error sourcing $RUNNR_CONFDIR/runnrfcns.sh.  Is your directory current?"
  exit 1
fi
source $BILDER_DIR/bildfcns.sh

######################################################################
#
# If there are no args, but an args file exists, set the args
# to those in the file.
#
######################################################################

if test -z "$1"; then
  argsfile=$PROJECT_DIR/${BILDER_NAME}.args
  techo "No args, so looking for $argsfile."
  if test -f $argsfile; then
    args=`cat $argsfile`
    set -- $args
    OPTIND=1
  else
    decho "No args file found.  Continuing."
  fi
fi

# Options
source $BILDER_DIR/bildopts.sh

# Common initializations
source $BILDER_DIR/bildinit.sh

# Build variables
source $BILDER_DIR/bildvars.sh

# Source trilinos.conf if present
conffile="./${WAIT_PACKAGE}.conf"
if [ -e "$conffile" ]
then
  echo "$conffile exists. sourcing..."
  source $conffile
fi


