#!/bin/sh
######################################################################
#
# @file    zlib_aux.sh
#
# @brief   Trigger vars and find information for zlib.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
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

setZlibTriggerVars() {
  ZLIB_BLDRVERSION=${ZLIB_BLDRVERSION:-"1.2.6"}
  if test -z "$ZLIB_BUILDS"; then
# zlib needed only on windows
    if [[ `uname` =~ CYGWIN ]]; then
      ZLIB_DESIRED_BUILDS=${ZLIB_DESIRED_BUILDS:-"ser,sersh,sermd"}
      computeBuilds zlib
      addPycshBuild zlib
    fi
  fi
  ZLIB_DEPS=cmake
}
setZlibTriggerVars

######################################################################
#
# Find zlib
#
######################################################################

findZlib() {
# This is needed for Windows to get the right dll
  if [[ `uname` =~ CYGWIN ]]; then
    findContribPackage zlib zlib ser sermd sersh pycsh
    findPycshDir zlib
    addtopathvar PATH $CONTRIB_DIR/zlib-${FORPYTHON_SHARED_BUILD}/bin
  fi
}

