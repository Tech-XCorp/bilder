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
# PYSIDE_BLDRVERSION_EXP=${PYSIDE_BLDRVERSION_EXP:-"qt4.8+1.2.1"}
PYSIDE_BLDRVERSION_EXP=${PYSIDE_BLDRVERSION_EXP:-"1.1.2"}
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
  case $PYSIDE_BLDR_VERSION in
    1.1.*) PYSIDE_USE_DISTUTILS=true;;
    qt4.8+1.2*) PYSIDE_DEPS=shiboken;;
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

  if $PYSIDE_USE_DISTUTILS; then

    bilderDuBuild pyside "" "$DISTUTILS_ENV"

  else

# PYSIDE does not have all dependencies right, so needs nmake
    local buildargs=
    local makejargs=
    if [[ `uname` =~ CYGWIN ]]; then
       buildargs="-m nmake"
    else
       makejargs="$PYSIDE_MAKEJ_ARGS"
    fi
    PYSIDE_QTDIR=`(cd $QT_BINDIR/..; pwd -P)`
    PYSIDE_ADDL_ARGS="-DSITE_PACKAGE:PATH='$MIXED_PYTHON_SITEPKGSDIR' -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS -I${PYSIDE_QTDIR}/include' -DQT_HEADERS_DIR:PATH=${PYSIDE_QTDIR}/include"
    if test -d $CONTRIB_DIR/shiboken-$SHIBOKEN_BLDRVERSION-ser; then
      PYSIDE_ADDL_ARGS="$PYSIDE_ADDL_ARGS -DShiboken_DIR:PATH=$CONTRIB_DIR/shiboken-$SHIBOKEN_BLDRVERSION-ser/lib/cmake/Shiboken-$SHIBOKEN_BLDRVERSION"
    fi
    if ! [[ `uname` =~ CYGIN ]]; then
      PYSIDE_ENV="PATH=$QT_BINDIR:$PATH"
    fi

# Configure and build
    if bilderConfig -p - pyside $PYSIDE_BUILD "$CMAKE_COMPILERS_PYC $PYSIDE_ADDL_ARGS $PYSIDE_OTHER_ARGS" "" "$PYSIDE_ENV"; then
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
    bilderDuInstall pyside "-" "$DISTUTILS_ENV"
  else
    local subdir=`echo $PYTHON_SITEPKGSDIR | sed -d "s?^${CONTRIB_DIR}/??"`/PySide
    local subdirvar=`genbashvar pyside-${PYSIDE_BUILD}`_INSTALL_SUBDIR
    eval $subdirvar=$subdir
    bilderInstallAll pyside
  fi
}

