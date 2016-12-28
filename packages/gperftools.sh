#!/bin/bash
#
# Version and build information for gperftool
#
# $Id:%
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GPERFTOOLS_BLDRVERSION=${GPERFTOOLS_BLDRVERSION:-"2.5"}

######################################################################
#
# Other values
#
######################################################################

GPERFTOOLS_BUILDS=${GPERFTOOLS_BUILDS:-"ser"}
GPERFTOOLS_DEPS=autotools

######################################################################
#
# Launch gperftools builds.
#
######################################################################

buildgperftools() {
  if bilderUnpack gperftools; then
    if bilderConfig gperftools ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAG --enable-shared=no --enable-minimal"; then
      bilderBuild gperftools ser
    fi
    if bilderConfig gperftools sersh "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAG --enable-static=no --enable-minimal"; then
      bilderBuild gperftools sersh
    fi
    if bilderConfig gperftools ben "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR $PAR_CONFIG_LDFLAG --enable-shared=no --enable-minimal"; then
      bilderBuild gperftools ben
    fi
  fi
}

######################################################################
#
# Test gperftools
#
######################################################################

testgperftools() {
  techo "Not testing gperftools."
}

######################################################################
#
# Install gperftools
#
######################################################################

installgperftools() {
  local gperftoolsbuilds=`echo "$GPERFTOOLS_BUILDS" | sed 's/,/ /g'`
  for build in $gperftoolsbuilds; do
    bilderInstall -p open gperftools $build
  done
}

