#!/bin/bash
#
# $Id: mksynergia2.sh 6594 2012-09-01 15:12:46Z cary $
#
# This file builds the Synergia2 toolchain.
# or may not become part of the normal toolchain for other packages.
# By keeping it separate but in bilder, we allow many people to
# experiment with these packages.
#
# To use: it has to be run from a PROJECT_DIR.  The easiest method is
# to:
#      ln -sf bilder/toolchains/mksynergia2.sh .
#      ./mksynergia2.sh  <options>
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
BILDER_NAME=mksynergia2		# Set since program name different under PBS
MKSYNERGIA2_DEPS=cmake,fftw3,python,openmpi
findBilderTopdir
#BILDER_DASHBOARD_URL=https://orbiter.txcorp.com/BilderDashboard/??

# Source bilder stuff
source $BILDER_DIR/bildall.sh
techo "VERBOSITY = $VERBOSITY."
echo "CC = ${CC}"

# Set umask to allow group to modify
umask 002

######################################################################
#
# Build and/or check the cmake and autotools chain, and doxygen.
#
######################################################################

source $BILDER_DIR/packages/cmake.sh
buildCmake
source $BILDER_DIR/packages/doxygen.sh
buildDoxygen
source $BILDER_DIR/toolchains/autotools.sh
installDoxygen
installCmake

######################################################################
#
# Linear algebra: Lapack and ATLAS.
#
######################################################################

source $BILDER_DIR/toolchains/linlibs.sh

######################################################################
#
# Valgrind must be built before openmpi.
# gtest must be built before txbase, after cmake
#
######################################################################

source $BILDER_DIR/packages/valgrind.sh
buildValgrind
source $BILDER_DIR/packages/zlib.sh
buildZlib
installZlib
# installGtest
installValgrind

######################################################################
#
# OpenMPI must be built before metatau
#
######################################################################

source $BILDER_DIR/packages/openmpi.sh
buildOpenmpi
installOpenmpi

######################################################################
#
# Boost needs to be built after mpi
#
######################################################################

source $BILDER_DIR/packages/boost.sh
BOOST_BUILDS=${BOOST_BUILDS:-"ser"}
buildBoost
installBoost

######################################################################
#
# Launch swig, hdf5 builds
#
######################################################################

source $BILDER_DIR/packages/hdf5.sh
buildHdf5

######################################################################
#
# Launch other package builds needed by Synergia2 and/or CHEF
#
######################################################################

source $BILDER_DIR/packages/fftw3.sh
buildFftw3
installFftw3

source $BILDER_DIR/packages/gsl.sh
buildGsl
installGsl

######################################################################
#
# Make sure we have python available
#
######################################################################

if [ ! -n "${PYTHON_BLDRVERSION}" ]
then
    source $BILDER_DIR/packages/python.sh
    buildPython
    installPython
else
    techo "Not building python, using version ${PYTHON_BLDRVERSION}"
fi

######################################################################
#
# Build and install numpy, then python analysis packages
#
######################################################################

source $BILDER_DIR/packages/numpy.sh
buildNumpy
installNumpy

source $BILDER_DIR/toolchains/pytools.sh

#mpi4py

#pygsl

#nose

#pyparsing

source $BILDER_DIR/packages/hdf5.sh
buildHdf5
installHdf5

source $BILDER_DIR/packages/boost.sh
buildBoost
installBoost

#flex

#gxx

#bison

#libtool

#miniglib

CHEF_LIBS_BLDRVERSION="StRel20080125-patches-git"
source $BILDER_DIR/packages/cheflibs.sh
buildCheflibs
installCheflibs

SYNERGIA2_BLDRVERSION="old_devel_1_0"
source $BILDER_DIR/packages/synergia2.sh
buildSynergia2
installSynergia2

createConfigFiles $BLDR_INSTALL_DIR
installConfigFiles $BLDR_INSTALL_DIR
finish $BLDR_INSTALL_DIR
