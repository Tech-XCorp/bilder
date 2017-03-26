#!/bin/sh
######################################################################
#
# @file    votca_csg_tutorials.sh
#
# @brief   Version and build information for votca_csg.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# This is the revision number from the Mercurial repo
VOTCA_CSG_TUTORIALS_BLDRVERSION=${VOTCA_CSG_TUTORIALS_BLDRVERSION:-"r177"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VOTCA_CSG_TUTORIALS_BUILDS=${VOTCA_CSG_TUTORIALS_BUILDS:-"ser"}
VOTCA_CSG_TUTORIALS_DEPS=votca_csg

######################################################################
#
# Launch votca_csg_tutorials builds.
#
######################################################################
buildVotca_Csg_Tutorials() {

  if bilderUnpack votca_csg_tutorials; then
    echo "Unpacking csg tutorials only. No explicit build step"
  fi

  # Record build
  addActionToLists votca_csg_tutorials-ser '0000'
  echo "Recording build manually"
}

######################################################################
#
# Test votca_csg_tutorials
#
######################################################################

testVotca_Csg_Tutorials() {
  techo "Not testing votca_csg_tutorials."
}

######################################################################
#
# Install votca_csg_tutorials
#
######################################################################
installVotca_Csg_Tutorials() {

  # Only for 'ser' so far
  BLDTYPE='ser'
  techo -2 "Installing votca csg_tutorials for only $BLDTYPE type"

  # Set install/build dirs manually
  local builddir=$BUILD_DIR/votca_csg_tutorials-$VOTCA_CSG_TUTORIALS_BLDRVERSION
  local VOTCA_CSG_TUTORIALS_INSTALL_TAG=$CONTRIB_DIR/votca_csg_tutorials-$VOTCA_CSG_TUTORIALS_BLDRVERSION
  local VOTCA_CSG_TUTORIALS_INSTALL_DIR=${VOTCA_CSG_TUTORIALS_INSTALL_TAG}-$BLDTYPE
  techo -2 "VOTCA_CSG_TUTORIALS_INSTALL_DIR=$VOTCA_CSG_TUTORIALS_INSTALL_DIR"

  # Check/create install directory
  if ! test -d $VOTCA_CSG_TUTORIALS_INSTALL_DIR; then
    mkdir $VOTCA_CSG_TUTORIALS_INSTALL_DIR
  fi

  #
  # Copy files/directories manually
  #
  # VOTCA_CSG_TUTORIALS_INSTTARG="README hexane methanol propane spce urea-water"
  VOTCA_CSG_TUTORIALS_INSTTARG="README propane spce"
  for targ in $VOTCA_CSG_TUTORIALS_INSTTARG
  do
      cmd="cp -R $builddir/$targ $VOTCA_CSG_TUTORIALS_INSTALL_DIR"
      techo -2 "$cmd"
      $cmd
  done

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR votca_csg_tutorials,$BLDTYPE

  # Make default soft links
  if ! test -d $CONTRIB_DIR/votca_csg_tutorials-$BLDTYPE; then
    techo "creating soft link directory $CONTRIB_DIR/votca_csg_tutorials-$BLDTYPE"
    ln -s $VOTCA_CSG_TUTORIALS_INSTALL_DIR $CONTRIB_DIR/votca_csg_tutorials-$BLDTYPE
  fi

}
