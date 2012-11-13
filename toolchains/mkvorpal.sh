#!/bin/bash
#
# $Id$
#
# Builds Vorpal only, in case a special build is needed for Vorpal but
# not dependent packages.  This is created for the case of Dirac,
# where linking to GPU libraries must be done on Dirac compute nodes,
# but the rest of the chain is built on a Carver login node.
#
######################################################################

######################################################################
#
# Determine the projects directory.  This can be copied into other scripts
# for the sanity check.  Assumes that BILDER_NAME has been set.
# $BILDER_NAME.sh is the name of the script.
#
# The main copy is in bilder/findProjectDir.sh
#
######################################################################

findProjectDir() {
  myname=`basename "$0"`
  if test $myname = $BILDER_NAME.sh; then
# If name matches, PROJECT_DIR is my dirname.
    PROJECT_DIR=`dirname $0`
  elif test -n "$PBS_O_WORKDIR"; then
# Can I find via PBS?
    if test -f $PBS_O_WORKDIR/$BILDER_NAME.sh; then
      PROJECT_DIR=$PBS_O_WORKDIR
    else
      cat <<EOF
PBS, with PBS_O_WORKDIR = $PBS_O_WORKDIR and $PWD for the
current directory, but $PBS_O_WORKDIR does not contain
$BILDER_NAME.sh.  Under PBS, execute this in the directory
of $BILDER_NAME.sh, or set the working directory to be the
directory of $BILDER_NAME.sh
EOF
      exit 1
    fi
  else
    echo "This is not $BILDER_NAME.sh, yet not under PBS? Bailing out."
    exit 1
  fi
  PROJECT_DIR=`(cd "$PROJECT_DIR"; pwd -P)`
  if echo "$PROJECT_DIR" | grep -q ' '; then
    cat <<_
ERROR: Working directory, '$PROJECT_DIR', contains a space.
Bilder will fail.
Please remove the spaces from the directory name and then re-run.
_
    exit 1
  fi
}

######################################################################
#
# Begin program
#
######################################################################

#
# Set names and determine top directory
#

# Name of script to look for in project dir
BILDER_NAME=mkvorpal
findProjectDir
# Where to find configuration info
BILDER_CONFDIR=$PROJECT_DIR/txcbilder
# Name of scripts to source to set environment for package use
BILDER_PACKAGE=vorpal
# Name of package that determines whether to wait before building
WAIT_PACKAGE=vorpal
# Name of package for Orbiter posting
ORBITER_NAME=Vorpal
# Set the installation umask
umask 007

#
# Get all bilder methods and variables
#
source $PROJECT_DIR/bilder/bildall.sh

######################################################################
#
# Build Vorpal only.  This assumes everything else is done.
#
######################################################################

source $BILDER_DIR/packages/vorpal.sh
buildVorpal
installVorpal

######################################################################
#
# Install configuration files
#
######################################################################

createConfigFiles $BLDR_INSTALL_DIR  # Create files with additions to environment
installConfigFiles $BLDR_INSTALL_DIR # Install those files

######################################################################
#
# Finish
#
######################################################################

finish $BLDR_INSTALL_DIR
