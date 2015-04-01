#!/bin/bash
#
# Trigger vars and find information
#
# Using qt3d-1.0 now, but if we need to change:
# http://qt-project.org/wiki/Using_3D_engines_with_Qt
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
  if test -d qt3d; then
    isgitorious=`(cd qt3d; git remote -v | grep gitorious)`
    if test -n "$isgitorious"; then
      techo "WARNING: [$FUNCNAME] Official repo moved from gitorius to qt.io.  Moving qt3d directory to qt3d-gitorious and getting qt3d using https from code.qt.io."
      mv qt3d qt3d-gitorious
    fi
  fi
  QT3D_REPO_URL=https://code.qt.io/git/qt/qt3d.git
  QT3D_REPO_BRANCH_STD=qt4
  QT3D_REPO_BRANCH_EXP=qt4
  QT3D_UPSTREAM_URL=https://code.qt.io/git/qt/qt3d.git
  QT3D_UPSTREAM_BRANCH=qt4  # The only choice
# Qt is built the same way as python
  QT3D_BUILD=$FORPYTHON_SHARED_BUILD
  QT3D_BUILDS=${QT3D_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  QT3D_DEPS=qt
  QT3D_UMASK=002
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

