#!/bin/bash
#
# Version and build information for gelus
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################


######################################################################
#
# Other values
#
######################################################################

GELUS_BUILDS=${GELUS_BUILDS:-"ser"}
GELUS_DEPS=cuda,cmake
GELUS_UMASK=002

######################################################################
#
# Launch gelus builds.
#
######################################################################

buildGelus() {
  getVersion gelus
  if bilderPreconfig gelus; then
    if bilderConfig -c gelus ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $GELUS_SER_OTHER_ARGS"; then
      bilderBuild gelus ser "VERBOSE=1"
    fi
  fi
}

######################################################################
#
# Test gelus
#
######################################################################

testGelus() {
  # wait for build before testing it
  waitBuild gelus-${GELUS_BLDRVERSION}

  # find make commmand
  local cmvar=GELUS_CONFIG_METHOD
  local cmval=`deref $cmvar`
  bildermake="`getMaker $cmval`"
  # construct test execution command
  cd ${BUILD_DIR}/gelus/ser
  cmd="$bildermake test"
  $cmd

}

######################################################################
#
# Install gelus
#
######################################################################

installGelus() {
  bilderInstall gelus ser gelus
}
