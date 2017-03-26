#!/bin/sh
######################################################################
#
# @file    tornado.sh
#
# @brief   Version and build information for tornado.
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

# TORNADO_BLDRVERSION_STD=${TORNADO_BLDRVERSION_STD:-"2.1.1"}
TORNADO_BLDRVERSION_STD=${TORNADO_BLDRVERSION_STD:-"3.2"}
TORNADO_BLDRVERSION_EXP=${TORNADO_BLDRVERSION_EXP:-"3.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setTornadoGlobalVars() {
  TORNADO_BUILDS=${TORNADO_BUILDS:-"pycsh"}
  TORNADO_DEPS=setuptools,Python
  TORNADO_UMASK=002
}
setTornadoGlobalVars

#####################################################################
#
# Launch builds
#
######################################################################

buildTornado() {
  if ! bilderUnpack tornado; then
    return 1
  fi
# Build away
  TORNADO_ENV="$DISTUTILS_ENV"
  techo -2 TORNADO_ENV = $TORNADO_ENV
  bilderDuBuild tornado "" "$TORNADO_ENV"
}

######################################################################
#
# Test
#
######################################################################

testTornado() {
  techo "Not testing tornado."
}

######################################################################
#
# Install
#
######################################################################

installTornado() {
  bilderDuInstall -r tornado tornado "" "$TORNADO_ENV"
}

