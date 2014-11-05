#!/bin/bash
#
# Version and build information for pytaps
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYTAPS_BLDRVERSION_STD=${PYTAPS_BLDRVERSION_STD:-"1.4"}

######################################################################
#
# Builds and deps
#
######################################################################

PYTAPS_BUILDS=${PYTAPS_BUILDS:-"pycsh"}
PYTAPS_DEPS=moab

######################################################################
#
# Launch pytaps builds.
#
######################################################################

buildPyTAPS() {
  if ! bilderUnpack pytaps; then
    return
  fi
  bilderDuBuild PyTAPS "$PYTAPS_ARGS" "$PYTAPS_ENV" "--iMesh-path=\"${MOAB_PYCSH_DIR}/lib\""
}

######################################################################
#
# Test pytaps
#
######################################################################

testPytaps() {
  techo "Not testing pytaps."
}

######################################################################
#
# Install pytaps
#
######################################################################

installPytaps() {
  case `uname` in
    CYGWIN*)
      bilderDuInstall -n PyTAPS "$PYTAPS_ARGS" "$PYTAPS_ENV"
      ;;
    *)
      bilderDuInstall -r PyTAPS PyTAPS "$PYTAPS_ARGS" "$PYTAPS_ENV"
      ;;
  esac
}
