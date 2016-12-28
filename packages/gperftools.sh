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

GPERFTOOLS_BUILDS=${GPERFTOOLS_BUILDS:-"ser,sersh"}
GPERFTOOLS_DEPS=autotools

######################################################################
#
# Launch gperftools builds.
#
######################################################################

buildgperftools() {
  if bilderUnpack gperftools; then
# Builds must be done separately
    if bilderConfig gperftools ser "--enable-shared=no --enable-minimal"; then
      bilderBuild gperftools ser
    fi
    if bilderConfig gperftools sersh "--enable-static=no --enable-minimal"; then
      bilderBuild gperftools sersh
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

