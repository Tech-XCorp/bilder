#!/bin/sh
######################################################################
#
# @file    glib2_aux.sh
#
# @brief   Trigger vars and find information for glib2.
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

setGlib2TriggerVars() {
  GLIB2_BLDRVERSION_STD=${GLIB2_BLDRVERSION_STD:-"2.38.2"}
  GLIB2_BLDRVERSION_EXP=${GLIB2_BLDRVERSION_EXP:-"2.38.2"}
  if test `uname` = Linux; then
    GLIB2_BUILDS=${GLIB2_BUILDS:-"${FORPYTHON_SHARED_BUILD},${FORPYTHON_STATIC_BUILD},sersh"}
  fi
  GLIB2_DEPS="libtool,pkgconfig,libffi"
}
setGlib2TriggerVars

######################################################################
#
# Find glib2
#
######################################################################

findGlib2() {
  findContribPackage Glib2 glib2 sersh pycsh
  findPycshDir Glib2
  addtopathvar -e PKG_CONFIG_PATH $CONTRIB_DIR/glib2-${GLIB2_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar -e LD_LIBRARY_PATH $CONTRIB_DIR/glib2-${GLIB2_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar -e LD_LIBRARY_PATH
  addtopathvar PATH $CONTRIB_DIR/glib2-${GLIB2_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/bin
  printvar PATH
  addtopathvar -e LD_RUN_PATH $CONTRIB_DIR/glib2-${GLIB2_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_RUN_PATH
}

