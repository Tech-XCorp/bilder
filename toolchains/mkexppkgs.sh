#!/bin/sh
######################################################################
#
# @file    mkexppkgs.sh
#
# @brief   This is for compiling varioius experimental tarballs that may
#          or may not become part of the normal toolchain for other packages.
#          By keeping it separate but in bilder, we allow many people to
#          experiment with these packages.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# To use: it has to be run from a PROJECT_DIR.  The easiest method is
# to:
#      ln -sf bilder/toolchains/mkexppkgs.sh .
#      ./mkexppkgs.sh  <options>
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
BILDER_NAME=mkexppkgs           # Set since program name different under PBS
findBilderTopdir
#BILDER_DASHBOARD_URL=https://orbiter.txcorp.com/BilderDashboard/facets

# Source bilder stuff
source $BILDER_DIR/bildall.sh

# Set umask to allow group to modify
umask 002

######################################################################
#
# Launch numpy builds.
#
######################################################################

source $BILDER_DIR/packages/trilinos.sh
buildTrilinos

source $BILDER_DIR/packages/mako.sh
source $BILDER_DIR/packages/simplejson.sh
buildMako
buildSimplejson
installMako
installSimplejson

######################################################################
#
# Build and install dakota and associated dependencies.
# SEK: build of trilinos a bit too much so comment out for now.
#
######################################################################

installTrilinos

source $BILDER_DIR/packages/dakota.sh
source $BILDER_DIR/packages/qhull.sh
buildDakota
buildQhull
installDakota
installQhull

######################################################################
#
# Create configuration files.
#
######################################################################

createConfigFiles
rm -f $CONTRIB_DIR/exppkgsetup.sh $BUILD_DIR/exppkgsetup.sh
rm -f $CONTRIB_DIR/exppkgsetup.csh $BUILD_DIR/exppkgsetup.csh
installConfigFiles
finish
