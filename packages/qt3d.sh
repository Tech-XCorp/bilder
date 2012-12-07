#!/bin/bash
#
# Version and build information for qt3d
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from git repo only

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

QT3D_BUILDS=${QT3D_BUILDS:-"ser"}
QT3D_DEPS=qt
QT3D_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildQt3d() {
  if ! test -d $PROJECT_DIR/qt3d; then
    techo "WARNING: no qt3d subdir.  Must obtain through git."
  fi
  getVersion qt3d
# This is installed into qmake, which is in the contrib dir
  QT3D_INSTALL_DIRS=$CONTRIB_DIR
# Configure and build
  if bilderPreconfig qt3d; then
    if bilderConfig -q qt3d.pro qt3d ser; then
      local QT3D_PLATFORM_BUILD_ARGS=
      case `uname` in
        Darwin) QT3D_PLATFORM_BUILD_ARGS="CXX=clang++";;
      esac
# During testing, do not "make clean".
      bilderBuild -k qt3d ser "$QT3D_PLATFORM_BUILD_ARGS"
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testQt3d() {
  techo "Not testing qt3d."
}

######################################################################
#
# Install
#
######################################################################

installQt3d() {
  bilderInstall qt3d ser
  # techo "WARNING: Quitting at end of installQt3d."; cleanup
}

