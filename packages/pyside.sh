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

PYSIDE_BLDRVERSION=${PYSIDE_BLDRVERSION:-"qt4.8+1.1.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Only the python build needed.
PYSIDE_BUILD=$FORPYTHON_BUILD
PYSIDE_BUILDS=${PYSIDE_BUILDS:-"$FORPYTHON_BUILD"}
PYSIDE_DEPS=qt,shiboken
PYSIDE_UMASK=002
# addtopathvar PATH $CONTRIB_DIR/pyside/bin

######################################################################
#
# Launch pyside builds.
#
######################################################################

buildPyside() {

  if ! bilderUnpack pyside; then
    return 1
  fi

# PYSIDE does not have all dependencies right, so needs nmake
  local buildargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
     buildargs="-m nmake"
  else
     makejargs="$PYSIDE_MAKEJ_ARGS"
  fi
  PYSIDE_ADDL_ARGS="-DShiboken_DIR:PATH=$CONTRIB_DIR/shiboken-$SHIBOKEN_BLDRVERSION-ser/lib/cmake/Shiboken-$SHIBOKEN_BLDRVERSION -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS -I$CONTRIB_DIR/qt-${QT_BLDRVERSION}-sersh/include' -DQT_HEADERS_DIR:PATH=$CONTRIB_DIR/qt-${QT_BLDRVERSION}-sersh/include"
  if ! [[ `uname` =~ CYGIN ]]; then
    PYSIDE_ENV="PATH=$CONTRIB_DIR/qt-${QT_BLDRVERSION}-sersh/bin:$PATH"
  fi

# Configure and build
  # if bilderConfig -p . pyside $PYSIDE_BUILD "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $PYSIDE_ADDL_ARGS $PYSIDE_OTHER_ARGS" "" "$PYSIDE_ENV"; then
  if bilderConfig -p - pyside $PYSIDE_BUILD "$CMAKE_COMPILERS_PYC $PYSIDE_ADDL_ARGS $PYSIDE_OTHER_ARGS" "" "$PYSIDE_ENV"; then
    bilderBuild $buildargs pyside $PYSIDE_BUILD "$makejargs" "$PYSIDE_ENV"
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
  bilderInstallAll pyside
}

