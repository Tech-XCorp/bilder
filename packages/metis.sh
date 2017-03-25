#!/bin/sh
######################################################################
#
# @file    metis.sh
#
# @brief   Version and build information for metis.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

METIS_BLDRVERSION=${METIS_BLDRVERSION:-"4.0.3"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$METIS_BUILDS"; then
  METIS_BUILDS=ser,sersh
fi

METIS_DEPS=cmake
METIS_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch metis builds.
#
######################################################################

buildMetis() {
  if bilderUnpack metis; then
    if bilderConfig -c metis ser; then
      bilderBuild metis ser
    fi
    if bilderConfig metis sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TARBALL_NODEFLIB_FLAGS -DBUILD_SHARED_LIBS:BOOL=ON" ; then
      bilderBuild metis sersh
    fi

  fi
}

######################################################################
#
# Test metis
#
######################################################################

testMetis() {
  techo "Not testing metis."
}

######################################################################
#
# Install metis
#
######################################################################

installMetis() {
  bilderInstall metis ser
  bilderInstall metis sersh
}
