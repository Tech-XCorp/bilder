#!/bin/bash
#
# $Id$
#
# Some of the initial setup that's common to the mk*.sh scripts
#
######################################################################

START_TIME=`date +%s`
START_DATE=`date '+%Y-%m-%d'`

# Set trapping for killing of running builds
unset PIDLIST
# On trap, exit with untrapped error code or else get infinite loop
trap 'echo trap caught; cleanup; exit 3' 1 2 15
trap -p >/tmp/traps$$.txt
traps=`sed 's/trap --//' </tmp/traps$$.txt | tr -d '\n'`
echo "Traps are $traps."
rm /tmp/traps$$.txt
export TERMINATE_REQUESTED=false
export TERMINATE_ERROR_MSG=

# Remove old indicators, provide new
rm -f $BILDER_LOGDIR/$BILDER_NAME.end
hostname >$BILDER_LOGDIR/$BILDER_NAME.host

######################################################################
#
# Allow systems first to set any flags.  Should not override option
# settings or environment.  May reset path, so must be done before
# svn invoked.
#
######################################################################

# Get machine hostname, directories, before, so machine files can
# host-specific cases in them
source $BILDER_DIR/runnr/runnrfcns.sh
runnrGetHostVars
techo "Working on $FQHOSTNAME of $BLDRHOSTID with RUNNRSYSTEM = $RUNNRSYSTEM."
techo "uname = `uname -a`."

# Make sure we have a machine file for Windows
if test -z "$MACHINE_FILE" && [[ `uname` =~ CYGWIN ]]; then
  MACHINE_FILE=cygwin.vs9
fi

# Get machine specific variables
if test -n "$CC"; then
  techo "WARNING: CC set to $CC before sourcing machine file"
fi
techo "MACHINE_FILE = \"$MACHINE_FILE\".  FQMAILHOST = \"$FQMAILHOST\"."
if test -n "$MACHINE_FILE"; then
  mfilefound=false
  if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/machines/$MACHINE_FILE; then
    absmachfile=$BILDER_CONFDIR/machines/$MACHINE_FILE
    techo "Sourcing $absmachfile."
    source $absmachfile
    techo "$absmachfile sourced."
    mfilefound=true
  fi
  if test -f $BILDER_DIR/machines/$MACHINE_FILE; then
    absmachfile=$BILDER_DIR/machines/$MACHINE_FILE
    techo "Sourcing $absmachfile."
    source $absmachfile
    techo "$absmachfile sourced."
    mfilefound=true
  fi
  if ! $mfilefound; then
    if test -n "$BILDER_CONFDIR"; then
      techo "WARNING: $MACHINE_FILE not found in $BILDER_CONFDIR or $BILDER_DIR."
    else
      techo "WARNING: $MACHINE_FILE not found in $BILDER_DIR."
    fi
  fi
elif test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/machines/$FQMAILHOST; then
  absmachfile=$BILDER_CONFDIR/machines/$FQMAILHOST
  techo "Sourcing $absmachfile."
  source $absmachfile
  techo "$absmachfile sourced."
elif test -f $BILDER_DIR/machines/$FQMAILHOST; then
  absmachfile=$BILDER_DIR/machines/$FQMAILHOST
  techo "Sourcing $absmachfile."
  source $absmachfile
  techo "$absmachfile sourced."
else
  techo "No host specific variables file to source."
fi
# techo "Quitting in bildinit.sh."; exit

# Set BILDER_SVN before going further
BILDER_SVN=${BILDER_SVN:-"`which svn`"}

######################################################################
#
# Update if requested
#
######################################################################

SVNUP=${SVNUP:-"false"}
if $SVNUP; then
  cmd="bilderSvn up --accept postpone $PROJECT_DIR"
  techo "$cmd" | tee $BILDER_LOGDIR/svnup.out
  $cmd 1>>$BILDER_LOGDIR/svnup.out 2>&1
  if test -x $PROJECT_DIR/updaterepos.sh; then
    cmd="(cd $PROJECT_DIR; ./updaterepos.sh)"
    techo "$cmd" | tee $BILDER_LOGDIR/svnup.out
    eval "$cmd" 1>>$BILDER_LOGDIR/svnup.out 2>&1
  fi
fi

######################################################################
#
# Check for versions
# Jenkins uses svnkit, which checks projects using the windows svn
# Subsequent use of the cygwin svn then says any directory with a
# link in it has been modified.  So unibild defines BLDR_SVNVERSION,
# which is the path to the windows subversion.
#
######################################################################

export USE_2ND_SVNAUTH=false
export BLDR_SVNVERSION=${BLDR_SVNVERSION:-"svnversion"}
techo "PATH = $PATH."
techo "svnversion = `which svnversion`."
BILDER_VERSION=`bilderSvnversion $BILDER_DIR`
SVN_BLDRVERSION=`bilderSvn -q --version --quiet | tr -d '\r'`
techo "Subversion version = $SVN_BLDRVERSION."
case $SVN_BLDRVERSION in
  1.[8-9].*)
    techo "WARNING: Subversion version $SVN_BLDRVERSION is too new to work with Jenkins.  Please have 1.6-7.x installed and fix your path."
    ;;
  1.[1-5].*)
    techo "WARNING: Subversion version $SVN_BLDRVERSION is too old.  Lacks --trust-server-cert.  Please have 1.6-7.x installed and fix your path."
    ;;
esac
# techo exit; exit

# Get various URLs
BILDER_URL=`bilderSvn info $BILDER_DIR | grep ^URL: | sed -e 's/^URL: *//'`
BILDER_BRANCH=`echo $BILDER_URL | sed -e 's?^.*/bilder/code/??'`
techo "NOTE: BILDER_BRANCH = $BILDER_BRANCH."
BILDER_BRANCHSHORT=`echo $BILDER_BRANCH | sed -e 's?^.*/??'`
BILDER_CONFDIR=${BILDER_CONFDIR:-"$BILDER_DIR/runnr"}
techo "BILDER_CONFDIR = $BILDER_CONFDIR."
BILDERCONF_VERSION=`bilderSvnversion $BILDER_CONFDIR`
techo "BILDERCONF_VERSION = $BILDERCONF_VERSION."

# Determine the name of this package
if test -z "$BILDER_PACKAGE"; then
  BILDER_PACKAGE=`bilderSvn info $PROJECT_DIR | grep '^Repository Root' | sed -e 's?^.*/??'`
fi
techo "BILDER_PACKAGE = $BILDER_PACKAGE."
export BILDER_PACKAGE

# Clean out old build files
if false; then
techo "Moving old bilder configure/build/... files."
for i in svnup preconfig config depend distclean build install; do
  cmd="find $BUILD_DIR -maxdepth 3 -name '*-$i.txt' -exec mv '{}' '{}'.bak \;"
  techo -2 "$cmd"
  eval "$cmd"
done
# JRC: not moving aside old .sh files.
for i in preconfig config build install; do
  cmd="find $BUILD_DIR -maxdepth 3 -name '*${i}.sh' -exec mv '{}' '{}'.bak \;"
  techo -2 "$cmd"
  eval "$cmd"
done
fi

# Move aside test logs
techo "Moving old test logs."
testdirs=`\ls -d $PROJECT_DIR/*tests 2>/dev/null`
if test -n "$testdirs"; then
  for i in $testdirs; do
    if test -d $i; then
      cmd="find $i -name '*-txtest.log' -exec mv '{}' '{}'.bak \;"
      techo -2 "$cmd"
      eval "$cmd"
    fi
  done
fi
# echo testdirs moved.

# Move log files
techo "Moving old bilder log files."
for i in summary patch; do
  eval ${i}files=`(cd $BUILD_DIR; \ls *-${i}.txt 2>/dev/null)`
  files=`deref ${i}files`
  if test -n "$files"; then
    for f in $files; do
      (cd $BUILD_DIR; mv $f ${f}.bak)
    done
  fi
done

# Get the packages repos
getPkgRepos

# Variables in which we record any failures
unset pidsKilled
unset actionsRunning
unset anyFailures
unset configFailures
unset configSuccesses
unset buildFailures
unset buildSuccesses
unset builtNotInstalled
unset installFailures
unset installations
unset pkgsandpatches
unset testFailures
unset testSuccesses

#
# Creating directories done by bildopts.sh
#
# Find various dirs
#
techo "PROJECT_DIR = $PROJECT_DIR"
techo "BLDR_INSTALL_DIR = $BLDR_INSTALL_DIR"
techo "CONTRIB_DIR = $CONTRIB_DIR"
techo "BUILD_DIR = $BUILD_DIR"
techo "BILDER_LOGDIR = $BILDER_LOGDIR"
techo "umask = `umask`"

#
# All paths other than PATH that might get affected.
BILDER_ADDL_PATHS="LD_LIBRARY_PATH PYTHONPATH SIDL_DLL_PATH POLYSWIFT_LOC POLYSWIFT_PYTHON DYLD_LIBRARY_PATH"
for i in PATH $BILDER_ADDL_PATHS; do
  unset BILDER_ADDED_${i}
done

#
# Print out the modules
if declare -f module 1>/dev/null; then
  modulesLoaded=`module list -t 2>&1 | sed -n -e '/1/p' | tr '\n\r' ' '`
  if test -n "$modulesLoaded"; then
    techo "Modules loaded: $modulesLoaded"
  fi
fi

