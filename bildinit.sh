#!/bin/sh
######################################################################
#
# @file    bildinit.sh
#
# @brief   Some of the initial setup that's common to the mk*.sh scripts
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

START_TIME=`date +%s`
START_DATE=`date '+%Y-%m-%d'`

# Set trapping for killing of running builds
unset PIDLIST
# On trap, exit with untrapped error code or else get infinite loop
trap 'TERMINATE_REQUESTED=true TERMINATE_ERROR_MSG=Killed. cleanup; exit 3' 1 2 15
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

# Set variables before sourcing machine file
REPLACE_COMPILERS=${REPLACE_COMPILERS:-"false"}

# Get machine specific variables
if test -n "$CC"; then
  techo "WARNING: [bildinit.sh] CC set to $CC before sourcing machine file"
fi
techo "MACHINE_FILE = \"$MACHINE_FILE\"."
machfile=${MACHINE_FILE:-"$FQMAILHOST"}
# Seek machfile
absmachfile=
if test -n "$BILDER_CONFDIR"; then
  if test -f $BILDER_CONFDIR/machines/$machfile; then
    absmachfile=$BILDER_CONFDIR/machines/$machfile
    techo "Sourcing $absmachfile."
    source $absmachfile
    techo "$absmachfile sourced."
  fi
else
  techo "WARNING: [bildinit.sh] BILDER_CONFDIR not defined."
fi
if test -f $BILDER_DIR/machines/$machfile; then
  absmachfile=$BILDER_DIR/machines/$machfile
  techo "Sourcing $absmachfile."
  source $absmachfile
  techo "$absmachfile sourced."
else
  test -n "$MACHINE_FILE" && techo "WARNING: [bildinit.sh] $machfile not found in $BILDER_DIR."
fi
if test -z "$absmachfile" -a -n "$MACHINE_FILE"; then
  techo -n "WARNING: [bildinit.sh] $machfile not found in $BILDER_DIR"
  if test -n "$BILDER_CONFDIR"; then
    techo " and not found in $BILDER_CONFDIR."
  else
    techo "."
  fi
fi
# techo "HDF5_BUILDS = $HDF5_BUILDS"; exit
# techo "Quitting in bildinit.sh."; exit

# Set BILDER_SVN before going further
BILDER_SVN=${BILDER_SVN:-"`which svn`"}
if test -z "$BILDER_SVN"; then
  TERMINATE_ERROR_MSG="ERROR: [bildinit.sh] svn not found."
  cleanup
fi
export BILDER_SVN # Needed for setinstald.sh

# The BEN build is an additional build for back end nodes.
# On BGP, the back end build uses a different, 32-bit serial
#   compiler for serial packages like txphysics.  The parallel
#   uses the (only) parallel (32-bit) compilers.
# One systems with outboard Phi nodes, the ben build is an
#   additional build using the extra parallel compilers, even
#   on serial only packages, like txphysics.
if test -z "$HAVE_BEN_BUILDS"; then
  HAVE_BEN_BUILDS=false
  if test "$CONFIG_COMPILERS_BEN" != "$CONFIG_COMPILERS_SER" -a "$CONFIG_COMPILERS_BEN" != "$CONFIG_COMPILERS_PAR"; then
    HAVE_BEN_BUILDS=true
  elif test "$CONFIG_COMPFLAGS_BEN" != "$CONFIG_COMPFLAGS_SER" -a \
      "$CONFIG_COMPFLAGS_BEN" != "$CONFIG_COMPFLAGS_PAR"; then
    HAVE_BEN_BUILDS=true
  fi
fi

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

# Get various URLs
PROJECT_SVN_URL=`bilderSvn info $PROJECT_DIR | grep ^URL: | sed -e 's/^URL: *//'`
BILDER_URL=`bilderSvn info $BILDER_DIR | grep ^URL: | sed -e 's/^URL: *//'`
BILDER_BRANCH=`echo $BILDER_URL | sed -e 's?^.*/bilder/??'`
# techo "NOTE: [bildinit.sh] BILDER_BRANCH = $BILDER_BRANCH."
BILDER_BRANCHSHORT=`echo $BILDER_BRANCH | sed -e 's?^.*/??'`
BILDER_CONFDIR=${BILDER_CONFDIR:-"$BILDER_DIR/runnr"}
techo "BILDER_CONFDIR = $BILDER_CONFDIR."
BILDERCONF_VERSION=`bilderSvnversion $BILDER_CONFDIR`
techo "BILDERCONF_VERSION = $BILDERCONF_VERSION."

# Determine the name of this package
if test -n "$BILDER_PACKAGE"; then
  techo "WARNING: BILDER_PACKAGE defined to be $BILDER_PACKAGE.  Will not be used."
fi
PROJECT_URL=`bilderSvn info $PROJECT_DIR | grep ^URL: | sed -e 's/^URL: *//'`
if test -z "$BILDER_PROJECT"; then
# Must allow for projects in a larger repo, like visitall
  BILDER_PROJECT=`echo $PROJECT_URL | sed -e 's?/trunk??' -e 's?/branches/.*$??' -e 's?/tags/.*$??' -e 's?^.*/??'`
fi
techo "BILDER_PROJECT = $BILDER_PROJECT."
export BILDER_PROJECT
PROJECT_BRANCH=`echo $PROJECT_URL | sed -e "s?^.*/$BILDER_PROJECT/??"`
techo "NOTE: [bildinit.sh] PROJECT_BRANCH = $PROJECT_BRANCH."

# Clean out artifacts
if test -n "$JENKINS_FSROOT"; then
  cmd="(cd $PROJECT_DIR; $PROJECT_DIR/bilder/jenkins/jenkinsclean.sh)"
  echo "$cmd"
  eval "$cmd"
fi

# Set default pkg topdir for jenkins.  All others use default.
SVNPKGS_TOPDIR=${SVNPKGS_TOPDIR:-"$JENKINS_FSROOT"}
techo "SVNPKGS_TOPDIR = ${SVNPKGS_TOPDIR}"

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
# Project specific paths should be put in the mk*all.sh file.
BILDER_ADDL_PATHS="$BILDER_ADDL_PATHS LD_LIBRARY_PATH DYLD_LIBRARY_PATH PYTHONPATH PKG_CONFIG_PATH"
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

