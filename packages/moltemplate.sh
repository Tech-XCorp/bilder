#!/bin/bash
#
# Version and build information for Moltemplate
#
# $Id: moltemplate.sh 290 2013-07-18 18:06:28Z swsides $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# This is the revision number from the Mercurial repo
MOLTEMPLATE_BLDRVERSION=${MOLTEMPLATE_BLDRVERSION:-"2013829"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

MOLTEMPLATE_BUILDS=${MOLTEMPLATE_BUILDS:-"ser"}
MOLTEMPLATE_DEPS=

######################################################################
#
# Launch moltemplate builds.
#
######################################################################
buildMoltemplate() {

  if bilderUnpack moltemplate; then
    echo "Unpacking csg tutorials only. No explicit build step"
  fi

  # Record build
  addActionToLists moltemplate-ser '0000'
  echo "Recording build manually"
}

######################################################################
#
# Test moltemplate
#
######################################################################

testMoltemplate() {
  techo "Not testing moltemplate."
}

######################################################################
#
# Install moltemplate
#
######################################################################
installMoltemplate() {

  # Only for 'ser' so far
  BLDTYPE='ser'
  techo -2 "Installing moltemplate for only $BLDTYPE type"

  # Set install/build dirs manually
  local builddir=$BUILD_DIR/moltemplate-$MOLTEMPLATE_BLDRVERSION
  local MOLTEMPLATE_INSTALL_TAG=$CONTRIB_DIR/moltemplate-$MOLTEMPLATE_BLDRVERSION
  local MOLTEMPLATE_INSTALL_DIR=${MOLTEMPLATE_INSTALL_TAG}-$BLDTYPE
  techo -2 "MOLTEMPLATE_INSTALL_DIR=$MOLTEMPLATE_INSTALL_DIR"

  # Check/create install directory
  if ! test -d $MOLTEMPLATE_INSTALL_DIR; then
    mkdir $MOLTEMPLATE_INSTALL_DIR
  fi

  # 
  # Copy files/directories manually
  #
  MOLTEMPLATE_INSTTARG="LICENSE.TXT README.TXT common examples_2013-8-29 moltemplate_manual.pdf	src"
  for targ in $MOLTEMPLATE_INSTTARG
  do
      cmd="cp -R $builddir/$targ $MOLTEMPLATE_INSTALL_DIR"
      techo -2 "$cmd"
      $cmd
  done

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR moltemplate,$BLDTYPE

  # Make default soft links
  if ! test -d $CONTRIB_DIR/moltemplate-$BLDTYPE; then
    techo "creating soft link directory $CONTRIB_DIR/moltemplate-$BLDTYPE"
    ln -s $MOLTEMPLATE_INSTALL_DIR $CONTRIB_DIR/moltemplate-$BLDTYPE
  fi

}
