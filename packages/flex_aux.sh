#!/bin/sh
######################################################################
#
# @file    flex_aux.sh
#
# @brief   Trigger vars and find information for flex.
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

setFlexTriggerVars() {
  FLEX_BLDRVERSION_STD=${FLEX_BLDRVERSION_STD:-"2.5.39"}
  FLEX_BLDRVERSION_EXP=${FLEX_BLDRVERSION_EXP:-"2.5.39"}
  if test `uname` = Linux; then
#    FLEX_BUILDS=${FLEX_BUILDS:-"$FORPYTHON_SHARED_BUILD","$FORPYTHON_STATIC_BUILD"}
    FLEX_BUILDS=${FLEX_BUILDS:-"ser,sersh"}
  fi
  FLEX_DEPS="libtool,pkgconfig"
}
setFlexTriggerVars

######################################################################
#
# Find flex
#
######################################################################

findFlex() {
  findContribPackage Flex flex-2.5 sersh pycsh
  findPycshDir Flex
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/flex-${FLEX_BLDRVERSION}-sersh/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/flex-${FLEX_BLDRVERSION}-sersh/lib
  printvar LD_LIBRARY_PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/flex-${FLEX_BLDRVERSION}-sersh/lib
  printvar LD_RUN_PATH
}

