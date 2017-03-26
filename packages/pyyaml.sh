#!/bin/sh
######################################################################
#
# @file    pyyaml.sh
#
# @brief   Version and build information for pyyaml.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYYAML_BLDRVERSION_STD=${PYYAML_BLDRVERSION_STD:-"3.10.0"}
PYYAML_BLDRVERSION=${PYYAML_BLDRVERSION_STD:-"3.10.0"}

######################################################################
#
# Builds and deps
#
######################################################################

PYYAML_BUILDS=${PYYAML_BUILDS:-"pycsh"}
PYYAML_DEPS=yaml

######################################################################
#
# Launch pyyaml builds.
#
######################################################################

buildPyyaml() {
  if ! bilderUnpack pyyaml; then
    return
  fi
  bilderDuBuild pyyaml "$PYYAML_ARGS" "$PYYAML_ENV"
}

######################################################################
#
# Test pyyaml
#
######################################################################

testPyyaml() {
  techo "Not testing pyyaml."
}

######################################################################
#
# Install pyyaml
#
######################################################################

installPyyaml() {
  case `uname` in
    CYGWIN*)
      bilderDuInstall -n pyyaml "$PYYAML_ARGS" "$PYYAML_ENV"
      ;;
    *)
      bilderDuInstall -r pyyaml pyyaml "$PYYAML_ARGS" "$PYYAML_ENV"
      ;;
  esac
}
