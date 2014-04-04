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

setQt3dGlobalVars() {
# Qt is built $QT3D_BUILD if this is the python build, otherwise it is cc4py
  QT3D_BUILD=$FORPYTHON_BUILD
  QT3D_BUILDS=${QT3D_BUILDS:-"$FORPYTHON_BUILD"}
  QT3D_DEPS=qt
  QT3D_UMASK=002
  QT3D_REPO_URL=git://gitorious.org/qt/qt3d.git
  QT3D_UPSTREAM_URL=git://gitorious.org/qt/qt3d.git
  QT3D_REPO_TAG_STD=qt4
  QT3D_REPO_TAG_EXP=qt4  # The only choice
}
setQt3dGlobalVars

######################################################################
#
# Launch builds.
#
######################################################################

#
# Build
#
buildQt3d() {

# Try to get qt3d from repo
  updateRepo qt3d

# If no subdir, done
  if ! test -d $PROJECT_DIR/qt3d; then
    return 1
  fi

# Get version and proceed
  getVersion qt3d
  if ! bilderPreconfig qt3d; then
    return 1
  fi

# This is installed into qmake, which is in the contrib dir
  QT3D_INSTALL_DIRS=$CONTRIB_DIR
# Configure and build

  local makerargs=
  case `uname` in
    CYGWIN*) case `uname -m` in
               i686) makerargs="-m nmake";;
             esac;;
  esac

  if bilderConfig $makerargs -q qt3d.pro qt3d $QT3D_BUILD "$QMAKESPECARG"; then
    local QT3D_PLATFORM_BUILD_ARGS=
    case `uname`-`uname -r` in
      Darwin-12.*) QT3D_PLATFORM_BUILD_ARGS="CXX=clang++";;
      CYGWIN*)     QT3D_PLATFORM_BUILD_ARGS="CXX=$(basename "${CXX}")";;
      *)           QT3D_PLATFORM_BUILD_ARGS="CXX=g++";;
    esac
# During testing, do not "make clean".
    bilderBuild $makerargs -k qt3d $QT3D_BUILD "all docs $QT3D_PLATFORM_BUILD_ARGS"
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
# JRC 20130320: Qt3d is installed from just "make all".
  if bilderInstall -L -T all qt3d $QT3D_BUILD; then
    case `uname` in
      Darwin)
        local qtdir=$CONTRIB_DIR/qt-${QT_BLDRVERSION}-$QT3D_BUILD
        for i in Qt3D Qt3DQuick; do
          if ! test -d ${qtdir}/include/$i; then
            mkdir -p ${qtdir}/include/$i
            cp ${qtdir}/lib/${i}.framework/Headers/* ${qtdir}/include/$i/
          fi
        done
        ;;
    esac
  fi
}

