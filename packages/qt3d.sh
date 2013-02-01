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

QT3D_DESIRED_BUILDS=${QT3D_DESIRED_BUILDS:-"sersh"}
computeBuilds qt3d
QT3D_DEPS=qt
QT3D_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

#
# Get qt3d using git
#
getQt3d() {
  if ! which git 1>/dev/null 2>&1; then
    echo "WARNING: git not in path.  Cannot get qt3d."
  fi
  if ! test -d qt3d; then
    cmd="git clone git://gitorious.org/qt/qt3d.git qt3d"
    echo $cmd
    $cmd
    cmd="cd qt3d"
    echo $cmd
    $cmd
    cmd="git checkout --track -b qt4 origin/qt4"
    echo $cmd
    $cmd
  else
    cmd="cd qt3d"
    echo $cmd
    $cmd
  fi
  cmd="git pull"
  echo $cmd
  $cmd
  cd -
}

#
# Build
#
buildQt3d() {

# Try to get qt3d from repo
  (cd $PROJECT_DIR; getQt3d)

# If no subdir, done
  if ! test -d $PROJECT_DIR/qt3d; then
    return 1
  fi

# Get version and proceed
  getVersion qt3d

# This is installed into qmake, which is in the contrib dir
  QT3D_INSTALL_DIRS=$CONTRIB_DIR
# Configure and build
  if bilderPreconfig qt3d; then
    if bilderConfig -q qt3d.pro qt3d ser; then
      local QT3D_PLATFORM_BUILD_ARGS=
      case `uname`-`uname -r` in
        Darwin-10.*) QT3D_PLATFORM_BUILD_ARGS="CXX=g++";;
        *) QT3D_PLATFORM_BUILD_ARGS="CXX=clang++";;
      esac
# During testing, do not "make clean".
      bilderBuild -k qt3d ser "all docs $QT3D_PLATFORM_BUILD_ARGS"
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
# Qt3d in installed from just make, so no need to make install
# hence replace make with :.
  if bilderInstall -m : -L qt3d ser; then
    case `uname` in
      Darwin)
        local qtdir=/contrib/qt-${QT_BLDRVERSION}-ser
        for i in Qt3D Qt3DQuick; do
          mkdir -p ${qtdir}/include/$i
          cp ${qtdir}/lib/${i}.framework/Headers/* ${qtdir}/include/$i/
        done
        ;;
    esac
  fi
  # techo "WARNING: Quitting at end of installQt3d."; cleanup
}

