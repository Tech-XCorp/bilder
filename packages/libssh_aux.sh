#!/bin/sh
######################################################################
#
# @file    libssh_aux.sh
#
# @brief   Trigger vars and find information for libssh.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
  LIBSSH_BLDRVERSION_STD=${LIBSSH_BLDRVERSION_EXP:-"0.7.2"}
  LIBSSH_BLDRVERSION_EXP=${LIBSSH_BLDRVERSION_EXP:-"0.7.2"}
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

