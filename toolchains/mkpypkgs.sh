#!/bin/bash
#
# $Id: mkpypkgs.sh 6661 2012-09-13 12:44:31Z cary $
#
# Builds python packages for postprocessing and plotting
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
BILDER_NAME=mkpypkgs
findProjectDir
# Where to find configuration info
BILDER_CONFDIR=$PROJECT_DIR/txcbilder
# Name of scripts to source to set environment for package use
BILDER_PACKAGE=pypkgs
# Name of package that determines whether to wait before building
WAIT_PACKAGE=pypkgs
# Name of package for Orbiter posting
ORBITER_NAME=Facets
# Set the installation umask
umask 007

#
# Get all bilder methods and variables
#
source $PROJECT_DIR/bilder/bildall.sh

######################################################################
#
# Build and/or check the cmake and autotools chain, and doxygen.
#
######################################################################

source $PROJECT_DIR/bilder/packages/cmake.sh
buildCmake
source $PROJECT_DIR/bilder/toolchains/autotools.sh
installCmake

######################################################################
#
# BUILD python -- natch
#
######################################################################

source $PROJECT_DIR/bilder/packages/python.sh
buildPython
installPython

source $BILDER_DIR/bilderpy.sh
# setupContribPython true

######################################################################
#
# Start qt for matplotlib backend -- it takes a long time.
#
######################################################################

if $BUILD_OPTIONAL; then
# Qt takes a long time so start it off early
  source $PROJECT_DIR/bilder/packages/qt.sh
  buildQt
fi

# Since numpy is being built on atlas, must have the full lapack, or
# we miss the fortran symbols, and the shared library load fails.  So
# Atlas built only after some lapack is available
######################################################################
#
## Linear algebra: Lapack and ATLAS.
#
#######################################################################

source $PROJECT_DIR/bilder/packages/netcdf.sh
buildNetcdf
installNetcdf

source $PROJECT_DIR/bilder/packages/hdf5.sh
buildHdf5
installHdf5

if $BUILD_OPTIONAL; then
installQt
fi

source $PROJECT_DIR/bilder/toolchains/pytools.sh

source $PROJECT_DIR/bilder/packages/pynetcdf4.sh
buildPynetcdf4
installPynetcdf4

source $PROJECT_DIR/bilder/packages/idlsave.sh
buildIdlsave
installIdlsave

source $PROJECT_DIR/bilder/packages/ipython.sh
buildIpython
installIpython

source $PROJECT_DIR/bilder/packages/mako.sh
buildMako
installMako

source $PROJECT_DIR/bilder/packages/scitools.sh
buildScitools
installScitools

source $PROJECT_DIR/bilder/packages/tutorial_python.sh
buildTutorialpython
installTutorialpython

######################################################################
#
# Create configuration files.  Backwards compatibility.
#
######################################################################

createConfigFiles
rm -f $CONTRIB_DIR/pypkgsetup.sh $BUILD_DIR/pypkgsetup.sh
rm -f $CONTRIB_DIR/pypkgsetup.csh $BUILD_DIR/pypkgsetup.csh
installConfigFiles
finish

