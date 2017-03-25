#!/bin/sh
######################################################################
#
# @file    libffi_aux.sh
#
# @brief   Trigger vars and find information for libffi.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
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

setLibffiTriggerVars() {
  LIBFFI_BLDRVERSION_STD=${LIBFFI_BLDRVERSION_STD:-"3.2.1"}
  LIBFFI_BLDRVERSION_EXP=${LIBFFI_BLDRVERSION_EXP:-"3.2.1"}
  if test `uname` = Linux; then
    LIBFFI_BUILDS=${LIBFFI_BUILDS:-"$FORPYTHON_SHARED_BUILD","$FORPYTHON_STATIC_BUILD,ser,sersh"}
  fi
  LIBFFI_DEPS="libtool,pkgconfig"
}
setLibffiTriggerVars

######################################################################
#
# Find libffi
#
######################################################################

findLibffi() {
  findContribPackage Libffi libffi-3 sersh pycsh
  findPycshDir Libffi
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/libffi-${LIBFFI_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/libffi-${LIBFFI_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_LIBRARY_PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/libffi-${LIBFFI_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_RUN_PATH
}

