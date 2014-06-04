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

setQt3dTriggerVars() {
# Qt is built the same way as python
  QT3D_BUILD=$FORPYTHON_BUILD
  QT3D_BUILDS=${QT3D_BUILDS:-"$FORPYTHON_BUILD"}
  QT3D_DEPS=qt
  QT3D_UMASK=002
  QT3D_REPO_URL=git://gitorious.org/qt/qt3d.git
  QT3D_UPSTREAM_URL=git://gitorious.org/qt/qt3d.git
  QT3D_REPO_BRANCH_STD=qt4
  QT3D_REPO_BRANCH_EXP=qt4  # The only choice
}
setQt3dTriggerVars

######################################################################
#
# Find oce
#
######################################################################

findQt3d() {
  :
}

