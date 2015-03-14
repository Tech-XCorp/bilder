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
  if test -d qt3d; then
    isgit=`(cd qt3d; git remote -v | grep git://)`
    if test -n "$isgit"; then
      techo "git protocol no longer working at gitorius.  Changing."
      mv qt3d qt3d-git
    fi
  fi
  QT3D_REPO_URL=https://gitorious.org/qt/qt3d.git
  QT3D_REPO_BRANCH_STD=qt4
  QT3D_REPO_BRANCH_EXP=qt4
  QT3D_UPSTREAM_URL=https://gitorious.org/qt/qt3d.git
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

