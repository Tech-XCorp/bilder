#!/bin/bash
#
# Build information for qt3d
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in qt3d_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/qt3d_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setQt3dNonTriggerVars() {
  QT3D_UMASK=002
}
setQt3dNonTriggerVars

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

# Patch qt3d with new camera params
  QT3D_PATCH=$BILDER_DIR/patches/qt3d-${QT3D_BLDRVERSION}.patch
  echo "QT3D_PATCH=${QT3D_PATCH}";
  if test -e $QT3D_PATCH; then
    cmd="(cd $PROJECT_DIR/qt3d; patch -N -p1 < ${QT3D_PATCH})"
    echo "$cmd"
    eval "$cmd"
  fi

# This is installed into qt, which is in the contrib dir
  QT3D_INSTALL_DIRS=$CONTRIB_DIR

  local makerargs=
  case `uname` in
    CYGWIN*)
      case `uname -m` in
        i686) makerargs="-m nmake";;
      esac
      ;;
  esac
  if bilderConfig $makerargs -q qt3d.pro qt3d $QT3D_BUILD "$QMAKESPECARG"; then
    local QT3D_PLATFORM_BUILD_ARGS=
    case `uname`-`uname -r` in
      Darwin-1[2-3].*) QT3D_PLATFORM_BUILD_ARGS="CXX=clang++";;
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
