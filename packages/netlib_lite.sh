#!/bin/bash
#
# Version and build information for netlib_lite
#
# $Id: netlib_lite.sh 6889 2012-10-25 14:10:23Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

NETLIB_LITE_BLDRVERSION=${NETLIB_LITE_BLDRVERSION:-"1.0.16-r64"}

######################################################################
#
# Builds, deps, mask, auxdata, paths
#
######################################################################

NETLIB_LITE_BUILDS=${NETLIB_LITE_BUILDS:-"ser"}
addBenBuild netlib_lite
NETLIB_LITE_DEPS=

######################################################################
#
# Launch netlib_lite builds.
#
######################################################################

buildNetlib_liteCM() {

# Check for svn version or package
  if test -d $PROJECT_DIR/netlib_lite; then
    getVersion netlib_lite
    bilderPreconfig -c netlib_lite
    res=$?
  else
    bilderUnpack netlib_lite
    res=$?
  fi

  if test $res = 0; then

# Check for install_dir installation
    if test $CONTRIB_DIR != $INSTALL_DIR -a -e $INSTALL_DIR/netlib_lite; then
      techo "WARNING: netlib_lite is installed in $INSTALL_DIR."
    fi

# Regular build
    if bilderConfig -c netlib_lite ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $NETLIB_LITE_SER_OTHER_ARGS"; then
      bilderBuild netlib_lite ser
    fi
# Special build for back end nodes
    if bilderConfig -c netlib_lite ben "$CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_PAR $NETLIB_LITE_BEN_OTHER_ARGS"; then
      bilderBuild netlib_lite ben
    fi
  fi

}

buildNetlib_lite() {
  buildNetlib_liteCM
}

######################################################################
#
# Test netlib_lite
#
######################################################################

testNetlib_lite() {
  techo "Not testing netlib_lite."
}

######################################################################
#
# Install netlib_lite
#
######################################################################

installNetlib_lite() {
  bilderInstall netlib_lite ser netlib_lite
  bilderInstall netlib_lite ben netlib_lite-ben
  # techo exit; exit
}

