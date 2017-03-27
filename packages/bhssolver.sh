#!/bin/sh
######################################################################
#
# @file    bhssolver.sh
#
# @brief   Version and build information for bhssolver.
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

######################################################################
#
# Other values
#
######################################################################

BHSSOLVER_BUILDS=${BHSSOLVER_BUILDS:-"ser"}
addBenBuild bhssolver
BHSSOLVER_DEPS=
BHSSOLVER_UMASK=002

######################################################################
#
# Launch bhssolver builds.
#
######################################################################

buildBhssolver() {
  getVersion bhssolver
  if bilderPreconfig bhssolver; then
    if bilderConfig bhssolver ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $CONFIG_LDFLAGS $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild bhssolver ser "$BHSSOLVER_MAKEJ_ARGS"
    fi
    if bilderConfig bhssolver ben "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR $CONFIG_LDFLAGS $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild bhssolver ben "$BHSSOLVER_MAKEJ_ARGS"
    fi
  fi
}

######################################################################
#
# Test bhssolver
#
######################################################################

testBhssolver() {
  techo "Not testing bhssolver."
}

######################################################################
#
# Install bhssolver
#
######################################################################

installBhssolver() {
  bilderInstall bhssolver ser bhssolver
  bilderInstall bhssolver ben bhssolver-ben
}

