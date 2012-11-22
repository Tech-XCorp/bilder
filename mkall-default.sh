#!/bin/bash
#
# For setting the defaults for the mkxxxx-default.sh scripts.
#
# $Id$
#
# Also see defaultsfcns.sh for concomitant functions
#
# ---------------------------------------------------------------------

defaultsUsage() {
  script=`basename $SCRIPT_NAME -default.sh`.sh
  echo
# WRAPPER OPTIONS STYLE needs changing to be consistent with what
# is in bildopts
  cat >&2 <<_
Usage: $0 [WRAPPER OPTIONS] -- [BILDER OPTIONS]

This wrapper script calls the main Bilder script with arguments
to set default locations for build and installation directories
on a domainname basis.  It also handles launching the build in a
queue.  This script is also meant to ease the use of non-gfortran
compilers.  It uses these values to form arguments for the main
bilder script, $script, which it additionally sends the arguments
after the double dash, --.

WRAPPER OPTIONS
  -b <dir> .......... Set builds directory. If not used, bilder chooses a default.
  -c ................ Common installations: for non-LCFS, goes into /contrib,
                        /volatile or /internal, for LCFSs, goes into group areas
  -C ................ Install in separate tarball and repo install dirs
                        (internal/volatile) rather than in one area (software).
  -E <env pairs> .... Comma-delimited list of environment var=value pair
  -f <file> ......... File that contains extra arguments to pass
                        Default: .extra_args
  -F <compiler> ..... Specify fortran compiler on non-LCF systems
  -g ................ Label the gnu builds the same way other builds occur.
  -H <host name> .... Use rules for this hostname (carver, surveyor, intrepid)
  -h ................ Print this message
  -i <dir> .......... Software directory is labeled with "internal" if '\$USER'
                        is member of internal install list
  -I ................ Install in \$HOME instead of default location
                        (projects directory at LCFs, BUILD_ROOTDIR on non-LCFs)
  -j ................ Maximum allowed value of the arg of make -j
  -k <dir> .......... On non-LCFs: Try to find a tarball directory (/contrib)
                        On LCFs: Install tarballs (instead of using facetspkgs)
  -m ................ Force this machine file
  -n ................ Invoke with a nohup and a redirect output
  -p ................ just print the command
  -q <timelimit> .... Run in queue if possible, with limit of timelimit time
  -r <rootinst> ..... Use this directory as the root for the installation, under
                        which will be the contrib, volatile, and internal dirs
  -R <subdir> ....... Install both repo and tarball packages into
                        /internal/<subdir>. This used for releases builds.
  -t ................ Pass the -t flag to the  mk script (turn on testing)
  -v <file> ......... File containing a list (without commas) of declared
                        environment variables to be passed to mk*.sh script
  -w <file> ......... Specify the name of a file which has a comma-delimited
                        list of packages not to build (e.g.,
                        plasma_state,nubeam,uedge) Default: .nobuild
  -X                    build experimental versions of packages
  -- ................ End processing of args for mkall-default.sh, all remaining
                        args are passed to the script.
_
  if declare -f extraDefaultsUsage > /dev/null; then extraDefaultsUsage; fi
  SET_BILDER_OPTIONS=false
  source $BILDER_DIR/bildopts.sh
  bilderUsage -s
  exit $1
}

# Name of script, get hosts
SCRIPT_NAME=$0
PROJECT_DIR=`dirname $SCRIPT_NAME`
PROJECT_DIR=${PROJECT_DIR:-"."}
PROJECT_DIR=`(cd $PROJECT_DIR; pwd -P)`
export PROJECT_DIR
PROJECT_SUBDIR=`basename $PROJECT_DIR`
BILDER_PACKAGE=`basename $PROJECT_DIR`
BILDER_DIR=`dirname $BASH_SOURCE`
BILDER_DIR=`(cd $BILDER_DIR; pwd -P)`

# Save to print out later if rung
redoargs="$*"

# Get machine info
cmd="source $BILDER_DIR/runnr/runnrfcns.sh"
# echo $cmd
$cmd

#
# Command line arg parsing
#
# process a particular arg
processArg() {
  case "$arg" in
    b) BUILD_DIR=$OPTARG;;
    c) COMMON_INSTALL=true;;
    C) USE_COMMON_INSTDIRS=false;;
    E) EXTRA_ARGS="$EXTRA_ARGS $OPTARG";;
    f) EXTRA_ARG_FILE="$OPTARG";;
    g) COMPKEY="gnu";;
    H) hostnm=$OPTARG;;
    h) defaultsUsage 0;;
    i) INSTDIR_IS_INTERNAL=true;;
    j) MKJMAX=$OPTARG;;
    I) INSTALL_IN_HOME=true;;
    k) COMMON_CONTRIB=true;;
    m) MACHINEFILE=$OPTARG;;
    n) USE_NOHUP=true;;
    p) PRINTONLY=true;;
    q) QUEUE_TIME=$OPTARG;;
    r) ROOTDIR_CVI=$OPTARG;;
    R) FIXED_INSTALL_SUBDIR=$OPTARG;;
    t) EXTRA_ARGS="$EXTRA_ARGS -t";;
    v) ENV_VARS_FILE="$OPTARG";;
    w) BILDER_NOBUILD_FILE="$OPTARG";;
    X) BUILD_EXPERIMENTAL=true;;
    \?) defaultsUsage 1;;
  esac
}

# Defaults
BILDER_ARGS=
BILDER_NOBUILD_FILE=".nobuild"
COMMON_CONTRIB=false
COMMON_INSTALL=false
EXTRA_ARG_FILE=".extra_args"
INSTDIR_IS_INTERNAL=false
INSTALL_IN_HOME=false
unset MKJMAX
PRINTONLY=false
QUEUE_TIME=
USE_NOHUP=false
USE_COMMON_INSTDIRS=true
VERBOSITY=0
if test -f $HOME/.bilderrc; then
  cmd="source $HOME/.bilderrc"
  techo "$cmd"
  $cmd
fi

# Process all the args
args="b:cCE:f:F:gH:hiIj:km:npq:r:R:tv:w:X-"
if test -n $extraargs; then
  args=${args}${extraargs}
fi
while getopts $args arg; do
  if declare -f processExtraOpts > /dev/null; then
    processExtraOpts $arg
  fi
  processArg $arg
done

# Get additional args after --
shift $(($OPTIND - 1))
SCRIPT_ADDL_ARGS="$*"
# techo "SCRIPT_ADDL_ARGS = $SCRIPT_ADDL_ARGS."

# Script to show how to rerun.  Done here so not done for help request.
REDO_SCRIPT=`basename $SCRIPT_NAME -default.sh`-defredo.sh
cat >$REDO_SCRIPT <<END
#!/usr/bin/env bash
echo To redo this run, execute
echo "$0 $redoargs"
END
chmod a+x $REDO_SCRIPT

# Make consistent
if $COMMON_INSTALL; then
  COMMON_CONTRIB=true
fi
if $COMMON_CONTRIB || $INSTDIR_IS_INTERNAL; then
  USE_COMMON_INSTDIRS=false
fi

if test -n "$FIXED_INSTALL_SUBDIR"; then
  case `uname` in
    CYGWIN*)
      MACHINEFILE=${MACHINEFILE:-"cygwin.vs9"}
      machinesfx=`echo $MACHINEFILE | sed -e 's/^.*\.//'`
      if [[ $machinesfx =~ mingw ]]; then
        machinesfx=mingw
      fi
      CONTRIB_DIR="/winsame/internal-${machinesfx}/${FIXED_INSTALL_SUBDIR}"
      BLDR_INSTALL_DIR="/winsame/internal-${machinesfx}/${FIXED_INSTALL_SUBDIR}"
      ;;
    *)
      CONTRIB_DIR="/internal/${FIXED_INSTALL_SUBDIR}"
      BLDR_INSTALL_DIR="/internal/${FIXED_INSTALL_SUBDIR}"
      ;;
  esac
fi

# While could set, BUILD_DIR, MACHINEFILE, and BUILD_EXPERIMENTAL above,
# we allow the second set of args to set these as well but not override
# the above.
set -- $SCRIPT_ADDL_ARGS
# We must keep parsing at failure as an unrecognized non option causes
# getopts to stop
count=0
while test $count -lt 100; do
  OPTIND=1
  while getopts ":b:m:" arg; do
    case $arg in
      b) export BUILD_DIR=${BUILD_DIR:-"$OPTARG"};;
      m) export MACHINEFILE=${MACHINEFILE:-"$OPTARG"};;
      X) export BUILD_EXPERIMENTAL=${BUILD_EXPERIMENTAL:-"true"};;
     \?) ;; # The previous shifting on nonempty "$2" does not work
    esac
  done
  if ! shift $(($OPTIND)); then
# When this fails, there are no more command-line args
    break
  fi
  count=`expr $count + 1`
done

# Add/removed args to second set for consistency
# echo "SCRIPT_ADDL_ARGS = $SCRIPT_ADDL_ARGS."
if test -n "$BUILD_EXPERIMENTAL"; then
  if ! echo $SCRIPT_ADDL_ARGS | egrep -q -- "(^| )-[0-9a-zA-Z]*X"; then
    SCRIPT_ADDL_ARGS="$SCRIPT_ADDL_ARGS -X"
  fi
fi
# echo "SCRIPT_ADDL_ARGS = $SCRIPT_ADDL_ARGS."
if test -n "$BUILD_DIR"; then
  SCRIPT_ADDL_ARGS=`echo " $SCRIPT_ADDL_ARGS " | sed -e "s? -b *[^ ][^ ]* ? -b $BUILD_DIR ?" -e "s?\( -[0-9a-zA-Z]*b\) *[^ ][^ ]* ?\1 $BUILD_DIR ?"`
fi
# echo "SCRIPT_ADDL_ARGS = $SCRIPT_ADDL_ARGS."
if test -n "$MACHINEFILE"; then
  SCRIPT_ADDL_ARGS=`echo " $SCRIPT_ADDL_ARGS " | sed -e "s? -m *[^ ][^ ]* ? -m $MACHINEFILE ?" -e "s?\( -[0-9a-zA-Z]*m\) *[^ ][^ ]* ?\1 $MACHINEFILE ?"`
fi
# Trim spaces
# echo "SCRIPT_ADDL_ARGS = $SCRIPT_ADDL_ARGS."
SCRIPT_ADDL_ARGS=`echo -- $SCRIPT_ADDL_ARGS | sed "s?--??" `
# techo "WARNING: Quitting after arg parsing."; exit

#------------------------------------------------------
# Define the variables above for the various platforms
# Variables defined:
#   COMPKEY
#   COMPVER
#   BUILD_ROOTDIR, BUILD_SUBDIR
#   INSTALL_ROOTDIR, INSTALL_SUBDIR
#   CONTRIB_ROOTDIR, CONTRIB_SUBDIR
#------------------------------------------------------

if test -n "$ROOTDIR_CVI"; then
  export INSTALL_ROOTDIR=$ROOTDIR_CVI
  export CONTRIB_ROOTDIR=$ROOTDIR_CVI
  export USERINST_ROOTDIR=$ROOTDIR_CVI
fi
source $BILDER_DIR/defaultsfcns.sh
if test -n "$QUEUE_TIME"; then
  FORCE_NO_QUEUE=${FORCE_NO_QUEUE:-"false"}
fi
# Set all default args, based on directory existence, OS, ...
setAllBilderDefVars

