#!/bin/bash
#
# $Id: mktrilinos.sh 6594 2012-09-01 15:12:46Z cary $
#
# Builds toolchain needed to get to Trilinos
#
######################################################################

######################################################################
#
# Determine the top directory.  This can be copied into other scripts
# for the sanity check.  Assumes that BILDER_NAME has been set.
# $BILDER_NAME.sh is the name of the script.
#
# The main copy is in bilder/findBilderTopdir.sh
#
######################################################################

findBilderTopdir() {
  myname=`basename $0`
  if test $myname = $BILDER_NAME.sh; then
    PROJECT_DIR=`dirname $0`
# My name has been changed.  Am I in PBS?
  elif test -n "$PBS_O_WORKDIR"; then
    if test -f $PBS_O_WORKDIR/$BILDER_NAME.sh; then
      PROJECT_DIR=$PBS_O_WORKDIR
    else
      echo "PBS, but the work directory is not the location of"
      echo "$BILDER_NAME.sh."
      echo "Under PBS, execute this in the directory of $BILDER_NAME.sh, or"
      echo "set the working directory to be the directory of $BILDER_NAME.sh"
      exit 1
    fi
  else
    echo "This is not $BILDER_NAME.sh, yet not under PBS? Bailing out."
    exit 1
  fi
  PROJECT_DIR=`(cd $PROJECT_DIR; pwd -P)`
}

######################################################################
#
# Begin program
#
######################################################################

#
# Set names and determine top directory
#
BILDER_NAME=mktrilinos		# Set since program name different under PBS
findBilderTopdir
BILDER_PACKAGE=trilinos
BILDER_DASHBOARD_URL=https://orbiter.txcorp.com/BilderDashboard/facets

# Source bilder stuff
source $BILDER_DIR/bildall.sh

# Set umask to allow group to modify
umask 002

######################################################################
#
# Need linear algebra libraries
#
######################################################################

source $BILDER_DIR/toolchains/linlibs.sh

######################################################################
# Need MPI for parallel Trilinos
######################################################################

source $BILDER_DIR/packages/openmpi.sh
buildOpenmpi
installOpenmpi

######################################################################
# Need swig, NumPy for PyTrilinos
######################################################################

source $BILDER_DIR/packages/swig.sh
buildSwig
installSwig

source $BILDER_DIR/packages/numpy.sh
buildNumpy
installNumpy

######################################################################
# Finally, the Trilinos main event
######################################################################

# export TRILINOS_BLDRVERSION=10.6.4
export TRILINOS_BUILDS="par"
source $BILDER_DIR/packages/trilinos.sh
buildTrilinos
# installTrilinos

######################################################################
#
# Create configuration files.  Backwards compatibility.
#
######################################################################

createConfigFiles $BLDR_INSTALL_DIR  # Create files with additions to environment
installConfigFiles $BLDR_INSTALL_DIR # Install those files
finish $BLDR_INSTALL_DIR
