#!/bin/bash
#
# Trigger vars and find information
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

setQwtTriggerVars() {
  QWT_BLDRVERSION_STD=${QWT_BLDRVERSION_STD:-"6.1.3"}
  QWT_BLDRVERSION_EXP=${QWT_BLDRVERSION_EXP:-"6.1.3"}
# Qt is built the same way as python
  QWT_BUILD=$FORPYTHON_SHARED_BUILD
  QWT_BUILDS=${QWT_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  QWT_DEPS=qt
  QWT_UMASK=002
}
setQwtTriggerVars

######################################################################
#
# Find oce
#
######################################################################

findQwt() {
  findContribPackage qt qt sersh
  findPycshDir qt
  techo "QWT_PYCSH_DIR = $QT_PYCSH_DIR"
}

