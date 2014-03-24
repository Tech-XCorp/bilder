#!/bin/bash
#
# Version and build information for pyside
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Neither of these works on mtnlion
PYSIDE_BLDRVERSION_STD=${PYSIDE_BLDRVERSION_STD:-"1.1.2"}
# The versions with qt in the name use cmake, need a separate shiboken build,
# and are from http://download.qt-project.org/official_releases/pyside/
# These are crashing on OS X.
PYSIDE_BLDRVERSION_EXP=${PYSIDE_BLDRVERSION_EXP:-"qt4.8+1.2.1"}
# The versions without qt in the name use distutils and come from
# https://pypi.python.org/pypi/PySide
# PYSIDE_BLDRVERSION_EXP=${PYSIDE_BLDRVERSION_EXP:-"1.2.1"}
computeVersion pyside

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setPysideGlobalVars() {
# Only the python build needed.
  PYSIDE_BUILD=$FORPYTHON_BUILD
  PYSIDE_BUILDS=${PYSIDE_BUILDS:-"$FORPYTHON_BUILD"}
  PYSIDE_USE_DISTUTILS=false
  case $PYSIDE_BLDRVERSION in
    qt*) PYSIDE_DEPS=shiboken;;
    1.*) PYSIDE_USE_DISTUTILS=true;;
  esac
  PYSIDE_DEPS=${PYSIDE_DEPS},qt
  trimvar PYSIDE_DEPS ,
  PYSIDE_UMASK=002
}
setPysideGlobalVars

######################################################################
#
# Launch pyside builds.
#
######################################################################

buildPyside() {

  if ! bilderUnpack pyside; then
    return 1
  fi

  PYSIDE_QTDIR=`(cd $QT_BINDIR/..; pwd -P)`
  if [[ `uname` =~ CYGWIN ]]; then
    PYSIDE_QTDIR=`cygpath -aw $PYSIDE_QTDIR`
  fi
  if $PYSIDE_USE_DISTUTILS; then

    PYSIDE_ENV="QTDIR='$PYSIDE_QTDIR' $DISTUTILS_ENV"
    bilderDuBuild pyside "" "$PYSIDE_ENV"

  else

    # PYSIDE_ADDL_ARGS="-DSITE_PACKAGE:PATH='$MIXED_PYTHON_SITEPKGSDIR' -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS -I${PYSIDE_QTDIR}/include' -DALTERNATIVE_QT_INCLUDE_DIR='${PYSIDE_QTDIR}/include'"
    PYSIDE_ADDL_ARGS="-DSITE_PACKAGE:PATH='$MIXED_PYTHON_SITEPKGSDIR' -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS' -DALTERNATIVE_QT_INCLUDE_DIR='${PYSIDE_QTDIR}/include'"
    if test -d $CONTRIB_DIR/shiboken-$SHIBOKEN_BLDRVERSION-ser; then
      PYSIDE_ADDL_ARGS="$PYSIDE_ADDL_ARGS -DShiboken_DIR:PATH='$CONTRIB_DIR/shiboken-$SHIBOKEN_BLDRVERSION-ser/lib/cmake/Shiboken-$SHIBOKEN_BLDRVERSION'"
    fi
    PYSIDE_ENV="QTDIR='$PYSIDE_QTDIR' PATH='$QT_BINDIR:$PATH'"

# Configure and build
    if bilderConfig pyside $PYSIDE_BUILD "$CMAKE_COMPILERS_PYC $PYSIDE_ADDL_ARGS $PYSIDE_OTHER_ARGS" "" "$PYSIDE_ENV"; then
# pyside needs nmake on cygwin?
      local buildargs=
      local makejargs=
      if [[ `uname` =~ CYGWIN ]]; then
        buildargs="-m nmake"
      else
        makejargs="$PYSIDE_MAKEJ_ARGS"
      fi
      bilderBuild $buildargs pyside $PYSIDE_BUILD "$makejargs" "$PYSIDE_ENV"
    fi

  fi

}

######################################################################
#
# Test pyside
#
######################################################################

testPyside() {
  techo "Not testing pyside."
}

######################################################################
#
# Install pyside
#
######################################################################

installPyside() {
  if $PYSIDE_USE_DISTUTILS; then
    bilderDuInstall pyside "-" "$PYSIDE_ENV"
  else
    bilderInstallAll pyside
  fi
}

