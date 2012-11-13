#!/bin/bash
#
# Cron script to build vorpal and run tests, possibly in queue.
#
# $Id$
#
######################################################################

# Change to top directory and store it
RUNNR_TOPDIR=`dirname $0`
RUNNR_TOPDIR=`(cd $RUNNR_TOPDIR; pwd -P)`
PROJECT_DIR=${PROJECT_DIR:-"$RUNNR_TOPDIR"}
export PROJECT_DIR
cd $RUNNR_TOPDIR
RUNNR_NAME=`basename $0 .sh`

# How to use
usage() {
  cat >&2 <<_
Usage: $0 [options]"
  -h             print this message
  -m <args>      args to pass to the script.  Some args are parsed out of these.
  -N             do not use the queue for building and installing
  -n             the number of processors to run with
  -s script      specify script to run
  -T <runtime>   allowed run time in HH:MM:SS
_
  exit $1
}

# Defaults
TESTING=false
BUILDING=true
RUNNR_RUNTIME=01:00:00	# Default value
FORCE_NO_QUEUE=false
# Get args
while getopts "hm:Nn:s:T:" arg; do
  case "$arg" in
    h)
      usage 0
      ;;
    m)
      RUNNR_SCRIPT_ARGS="$OPTARG"
      args="$args -m \"$RUNNR_SCRIPT_ARGS\""
      ;;
    N)
      FORCE_NO_QUEUE=true
      ;;
    n)
      RUNNR_NUM_PROCS="$OPTARG"
      args="$args -n $RUNNR_NUM_PROCS"
      ;;
    s)
      RUNNR_SCRIPT=$OPTARG
      args="$args -s $OPTARG"
      ;;
    T)
      RUNNR_RUNTIME=$OPTARG
      args="$args -T $OPTARG"
      ;;
    \?)
      echo Option $arg not recognized.
      usage 1
      ;;
  esac
done
shift $(($OPTIND - 1))
args="$args $*"
# echo RUNNR_SCRIPT = $RUNNR_SCRIPT
if test -z "$RUNNR_SCRIPT"; then
  echo "Catastrophic error.  No script specified.  Quitting."
  exit 1
fi

# Extract the build directory from the script args
if test -n "$RUNNR_SCRIPT_ARGS"; then
  unset varname
  for i in $RUNNR_SCRIPT_ARGS; do
    if test -n "$varname"; then
      eval $varname=$i
    fi
    case $i in
      -b)
        varname=BUILD_DIR
        ;;
      -L)
        varname=BILDER_LOGDIR
        ;;
      *)
        unset varname
        ;;
    esac
  done
fi
# Not checking for writability of these directories
BUILD_DIR=${BUILD_DIR:-"$RUNNR_TOPDIR/builds"}
# Cannot check build dir now as may not exist on head node
# mkdir -p $BUILD_DIR
# BUILD_DIR=`(cd $BUILD_DIR; pwd -P)`
# But logdir must exist on head node
BILDER_LOGDIR=${BILDER_LOGDIR:-"$BUILD_DIR"}
mkdir -p $BILDER_LOGDIR
BILDER_LOGDIR=`(cd $BILDER_LOGDIR; pwd -P)`

# Update Bilder and top-level scripts
# JRC/JSD: We want the cron to control when bilder is updated, not do it automatically.
# If you want immediate update, add -u to the options passed to mk*all.sh.
# echo "(cd $RUNNR_TOPDIR; svn up --accept postpone *.sh bilder >$BILDER_LOGDIR/runnrsvnup.out 2>&1)"
# (cd $RUNNR_TOPDIR; svn up --accept postpone *.sh bilder >$BILDER_LOGDIR/runnrsvnup.out 2>&1)

# Get short and long hostnames
if test -d $RUNNR_TOPDIR/bilder/runnr; then
  BILDER_RUNNRDIR=$RUNNR_TOPDIR/bilder/runnr
elif test -d $RUNNR_TOPDIR/runnr; then
  BILDER_RUNNRDIR=$RUNNR_TOPDIR/runnr
else
  echo "runnr subdirectory not found!  Exiting."
  exit 1
fi

# Get functions
source $BILDER_RUNNRDIR/runnrfcns.sh

trap runnrRmQJob 1 2 15

# Get log file
LOGFILE=$BILDER_LOGDIR/${RUNNR_NAME}.log
rotateFile $LOGFILE
# If not present, see if in top directory
if test ! -f $RUNNR_SCRIPT -a -f $RUNNR_TOPDIR/$RUNNR_SCRIPT; then
  $RUNNR_SCRIPT=$RUNNR_TOPDIR/$RUNNR_SCRIPT
fi

# Can use trimvar, techo after above sourcing
# trimvar args ' '
args=`echo $args | sed -e 's/^ *//' -e 's/ *$//'`
techo "Executing $0 $args at `date`"
techo "BUILD_DIR = $BUILD_DIR"
techo "BILDER_LOGDIR = $BILDER_LOGDIR"

# Record invocation line for reuse
origcmd="$0 $args"
# echo "origcmd = '${origcmd}'"
if test -n "$RUNNR_NAME"; then
  echo '#!/bin/bash' >$RUNNR_TOPDIR/${RUNNR_NAME}-redo.sh
  echo "cmd='${origcmd}'" >>$RUNNR_TOPDIR/${RUNNR_NAME}-redo.sh
  echo "echo '# To redo the last runnr run, execute the following command in $RUNNR_TOPDIR'" >>$RUNNR_TOPDIR/${RUNNR_NAME}-redo.sh
  echo "echo \$cmd" >>$RUNNR_TOPDIR/${RUNNR_NAME}-redo.sh
  chmod a+x $RUNNR_TOPDIR/${RUNNR_NAME}-redo.sh
fi

