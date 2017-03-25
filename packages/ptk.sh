#!/bin/sh
######################################################################
#
# @file    ptk.sh
#
# @brief   Version and build information for ptk.
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

PTK_BUILDS=${PTK_BUILDS:-"ser"}
PTK_DEPS=hdf5
PTK_UMASK=007

######################################################################
#
# Launch ptk builds
#
######################################################################
buildPtk() {
# Get version and see if anything needs building
  getVersion ptk
  if bilderPreconfig ptk; then
    local CMAKE_ENVVARS="CC='$CC' CXX='$CXX' CFLAGS='$CXXFLAGS' CXXFLAGS='$CXXFLAGS'"
    if bilderConfig -c ptk ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_INCDIR_ARG $CMAKE_SUPRA_SP_ARG $PTK_SER_OTHER_ARGS"; then
      bilderBuild ptk ser
    fi
  fi
}

######################################################################
#
# Install ptk
#
######################################################################
installPtk() {
  bilderInstall ptk ser
}
