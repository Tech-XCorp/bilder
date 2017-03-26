#!/bin/sh
######################################################################
#
# @file    gstreamer_aux.sh
#
# @brief   Trigger vars and find information for gstreamer.
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

setGstreamerTriggerVars() {
  GSTREAMER_BLDRVERSION_STD=${GSTREAMER_BLDRVERSION_STD:-"0.10.36"}
  GSTREAMER_BLDRVERSION_EXP=${GSTREAMER_BLDRVERSION_EXP:-"0.10.36"}
  if test `uname` = Linux; then
#    GSTREAMER_BUILDS=${GSTREAMER_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
# forpython_shared_build is not always set. can't use JDAS 11th Feb16
#    GSTREAMER_BUILDS=${GSTREAMER_BUILDS:-"pycsh,sersh"}
    GSTREAMER_BUILDS=${GSTREAMER_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  fi
  GSTREAMER_DEPS=libtool,xz
# Probably shouldn't be just for linux, but this minimizes damage
# on other platforms where gstreamer building is currently untested
# JDAS 9th Feb 2016
  if test `uname` = Linux; then
    GSTREAMER_DEPS=${GSTREAMER_DEPS},libxml2,pkgconfig,orc,glib2
    if which flex; then
      techo "flex is installed, don't need to build"
    else
      GSTREAMER_DEPS=${GSTREAMER_DEPS},flex
    fi
    if which bison; then
      techo "bison is installed, don't need to build"
    else
      GSTREAMER_DEPS=${GSTREAMER_DEPS},bison
    fi
  fi
}
setGstreamerTriggerVars

######################################################################
#
# Find gstreamer
#
######################################################################

findGstreamer() {
  techo "findGstreamer..."
  printvar FORPYTHON_SHARED_BUILD
  findContribPackage Gstreamer gstreamer-0.10 sersh pycsh
  findPycshDir Gstreamer
  addtopathvar -e PKG_CONFIG_PATH $CONTRIB_DIR/gstreamer-${GSTREAMER_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar -e PATH $CONTRIB_DIR/gstreamer-${GSTREAMER_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/bin
  printvar PATH
  addtopathvar -e LD_LIBRARY_PATH $CONTRIB_DIR/gstreamer-${GSTREAMER_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_LIBRARY_PATH
  addtopathvar -e LD_RUN_PATH $CONTRIB_DIR/gstreamer-${GSTREAMER_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_RUN_PATH
}

