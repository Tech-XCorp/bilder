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
  echo -n "WARNING: [bildall.sh] USER is unknown."
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
  echo "WARNING: [bildall.sh] PROJECT_DIR not defined. Assuming current."
  PROJECT_DIR=$PWD
fi

case `uname` in
  CYGWIN*) PROJECT_DIR=`dirname $0`
      PROJECT_DIR=`(cd $PROJECT_DIR; pwd)`;;
  *)  PROJECT_DIR=`(cd $PROJECT_DIR; pwd)`;;
esac
cd $PROJECT_DIR
res=$?
if [ ! $res = 0 ]; then
  echo "cd to $PROJECT_DIR failed."
fi

# Get bilder and runnr functions
BILDER_DIR=`pwd`
BILDER_DIR="$BILDER_DIR/bilder"

RUNNR_DIR=$BILDER_DIR/runnr

######################################################################
#
# Define all general functions used by Bilder.  Those in Runnr
# are the subset that have usefulness for ruuning in queues,
# determining hosts, etc., allow a use to grab just them.
#
######################################################################

# Start with no verbosity so that techo is valid.  Changes at option time.
VERBOSITY=0
VERBOSE=${VERBOSE:-"false"}
$VERBOSE && echo "Sourcing $RUNNR_DIR/runnrfcns.sh."
if source $RUNNR_DIR/runnrfcns.sh; then
  : # echo "$RUNNR_DIR/runnrfcns.sh sourced."
# techo now available but cannot be used until log are rotated (in bildopts).
else
  echo "Error sourcing $RUNNR_CONFDIR/runnrfcns.sh.  Is your directory current?"
  exit 1
fi
$VERBOSE && echo "Sourcing $BILDER_DIR/bildfcns.sh."
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
    techo -2 "No args file found.  Continuing."
  fi
fi

# Options
$VERBOSE && echo "Sourcing $BILDER_DIR/bildopts.sh."
source $BILDER_DIR/bildopts.sh
# Trying to determine when numpy gets uninstalled
# printInstallationStatus numpy $CONTRIB_DIR post-bildopts

# Common initializations
techo -2 "Sourcing $BILDER_DIR/bildinit.sh."
source $BILDER_DIR/bildinit.sh

# Build variables
techo -2 "Sourcing $BILDER_DIR/bildvars.sh."
source $BILDER_DIR/bildvars.sh

# Source trilinos.conf if present
conffile="./${WAIT_PACKAGE}.conf"
if [ -e "$conffile" ]
then
  echo "$conffile exists. sourcing..."
  source $conffile
fi

