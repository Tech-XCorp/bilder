#!/bin/bash
#
# Version and build information for lxml
#
# $Id$
#
######################################################################

######################################################################
#
# This is the best xml parser for python, but pretty big so not a
# standard python package
#
######################################################################

LXML_BLDRVERSION=${LXML_BLDRVERSION:-"3.3.0"}

######################################################################
#
# Other values
#
######################################################################

LXML_BUILDS=${LXML_BUILDS:-"pycsh"}
LXML_DEPS=
LXML_UMASK=002

######################################################################
#
# Launch lxml builds.
#
######################################################################

buildLxml() {
  if bilderUnpack lxml; then
    techo "Running bilderDuBuild for lxml."

# Regularize name.  Already done by findContribPackage
    LXML_ENV="$DISTUTILS_NOLV_ENV"
    case `uname`-$CC in
      CYGWIN*-cl)
        LXML_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        ;;
      CYGWIN*-mingw*)
        LXML_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        LXML_ENV="PATH=/MinGW/bin:'$PATH'"
        ;;
      Linux)
        LXML_ARGS="--lflags=${RPATH_FLAG}$LXML_HDF5_DIR/lib"
        ;;
    esac
    LXML_ARGS="$LXML_ARGS --with-xml2-config='$CONTRIB_DIR/libxml2/bin/xml2-config' --with-xslt-config='$CONTRIB_DIR/libxslt/bin/xslt-config' "
    bilderDuBuild -p lxml lxml "$LXML_ARGS" "$LXML_ENV"
  fi
}

######################################################################
#
# Test lxml
#
######################################################################

testLxml() {
  techo "Not testing lxml."
}

######################################################################
#
# Install lxml
#
######################################################################

installLxml() {

# On CYGWIN, no installation to do, just mark
  local anyinstalled=false
  case `uname`-`uname -r` in
    CYGWIN*)
      bilderDuInstall -n lxml
      ;;
    *)
      bilderDuInstall lxml "$LXML_ARGS" "$LXML_ENV"
      ;;
  esac

}

