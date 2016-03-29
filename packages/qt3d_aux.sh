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
    local goodrepo=true
    local isgitorious=`(cd qt3d; git remote -v | grep gitorious)`
    if test -n "$isgitorious"; then
      goodrepo=false
    fi
    local isqtio=`(cd qt3d; git remote -v | grep code.qt.io)`
    if test -n "$isqtio"; then
      goodrepo=false
    fi
    if ! $goodrepo; then
      techo "WARNING: [$FUNCNAME] Qt3D repos absent from gitorius and qt.io."
      techo "WARNING: [$FUNCNAME] Using https://github.com/Tech-XCorp/qt3d.git."
      rm -rf qt3d-bad
      mv qt3d qt3d-bad
    fi
  fi
  QT3D_REPO_URL=https://github.com/Tech-XCorp/qt3d.git
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

