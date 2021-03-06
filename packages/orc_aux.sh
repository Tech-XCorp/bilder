#!/bin/sh
######################################################################
#
# @file    orc_aux.sh
#
# @brief   Trigger vars and find information for orc.
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

setOrcTriggerVars() {
  ORC_BLDRVERSION_STD=${ORC_BLDRVERSION_STD:-"0.4.16"}
  ORC_BLDRVERSION_EXP=${ORC_BLDRVERSION_EXP:-"0.4.16"}
  if test `uname` = Linux; then
    ORC_BUILDS=${ORC_BUILDS:-"$FORPYTHON_SHARED_BUILD","$FORPYTHON_STATIC_BUILD,ser"}
  fi
  ORC_DEPS="libtool,pkgconfig"
}
setOrcTriggerVars

######################################################################
#
# Find orc
#
######################################################################

findOrc() {
  findContribPackage Orc orc-0.4 sersh pycsh
  findPycshDir Orc
  addtopathvar -i PKG_CONFIG_PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar -e PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/bin
  printvar PATH
  addtopathvar -e LD_LIBRARY_PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_LIBRARY_PATH
  addtopathvar -e LD_RUN_PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_RUN_PATH
}

