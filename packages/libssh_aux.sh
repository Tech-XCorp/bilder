#!/bin/bash
#
# Trigger vars and find information for libssh
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setLibsshTriggerVars() {
  if test "$VISUALSTUDIO_VERSION" = 11; then
    LIBSSH_BLDRVERSION_STD=${LIBSSH_BLDRVERSION:-"0.6.0"}
  else
    LIBSSH_BLDRVERSION_STD=${LIBSSH_BLDRVERSION:-"0.5.5"}
  fi
  LIBSSH_BLDRVERSION_EXP=${LIBSSH_BLDRVERSION:-"0.5.5"}
# libssh always builds the shared libs.  With configuration below,
# it will also build the static library, so we call this build ser.
  LIBSSH_DESIRED_BUILDS=${LIBSSH_DESIRED_BUILDS:-"ser"}
  computeBuilds libssh
# Since libssh always builds the shared libs in ser, addCc4py logic
# not right.
  if ! isCcPyc; then
    addPycshBuild libssh
  fi
  LIBSSH_DEPS=openssl,cmake,zlib
}
setLibsshTriggerVars

######################################################################
#
# Find libssh if needed
#
######################################################################

findLibssh() {
  :
}

