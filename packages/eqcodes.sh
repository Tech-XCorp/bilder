#!/bin/bash
#
# Version and build information for Eqcodes
#
# $Id: eqcodes.sh 6889 2012-10-25 14:10:23Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

EQCODES_BLDRVERSION=${EQCODES_BLDRVERSION:-"2.7.0-r214"}

######################################################################
#
# Builds, deps, mask, auxdata, paths
#
######################################################################

EQCODES_BUILDS=${EQCODES_BUILDS:-"ser"}
addBenBuild eqcodes
EQCODES_DEPS=plasma_state

######################################################################
#
# Launch eqcodes builds.
#
######################################################################

buildEqcodes() {
  EQCODES_START_TIME=`date +%s`
# Check for svn version or package
  if test -d $PROJECT_DIR/eqcodes; then
    getVersion eqcodes
    bilderPreconfig eqcodes
    res=$?
  else
    bilderUnpack eqcodes
    res=$?
  fi
  if test $res = 0; then

# Check for install_dir installation
    if test $CONTRIB_DIR != $INSTALL_DIR -a -e $INSTALL_DIR/eqcodes; then
      techo "WARNING: eqcodes is installed in $INSTALL_DIR."
    fi

# Do builds
    if bilderConfig eqcodes ser "$CONFIG_COMPILERS_SER $EQCODES_SER_OTHER_ARGS $CONFIG_LINLIB_SER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild eqcodes ser "$CONFIG_COMPILERS_SER $EQCODES_MAKE_ARGS" $1
    fi
    if bilderConfig eqcodes ben "$CONFIG_COMPILERS_BEN $CONFIG_LINLIB_SER_ARGS $EQCODES_BEN_OTHER_ARGS"; then
      bilderBuild eqcodes ben "$CONFIG_COMPILERS_BEN $EQCODES_MAKE_ARGS" $1
    fi
  fi
}

######################################################################
#
# Test Eqcodes
#
######################################################################

testEqcodes() {
  techo "Not testing eqcodes."
}

######################################################################
#
# Install Eqcodes
#
######################################################################

installEqcodes() {
# Set umask to allow only group to modify
  umask 002
  bilderInstall eqcodes ser eqcodes
  bilderInstall eqcodes ben eqcodes-ben
  EQCODES_END_TIME=`date +%s`
  echo Total time for EQCODES build: `expr $EQCODES_END_TIME - $EQCODES_START_TIME` seconds >> $BUILD_DIR/timers.txt
}

