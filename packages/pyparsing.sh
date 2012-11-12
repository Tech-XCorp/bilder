#!/bin/bash
#
# Version and build information for pyparsing
#
# $Id: pyparsing.sh 4587 2011-11-08 23:09:01Z alexanda $
#
######################################################################

######################################################################
#
# Version
# Windows from http://www.pypyparsing.org/download/stable
#
######################################################################

PYPARSING_BLDRVERSION=${PYPARSING_BLDRVERSION:-"2.2.1"}

######################################################################
#
# Other values
#
######################################################################

PYPARSING_BUILDS=${PYPARSING_BUILDS:-"cc4py"}
PYPARSING_DEPS=
PYPARSING_UMASK=002

######################################################################
#
# Launch pyparsing builds.
#
######################################################################

buildPyParsing() {
  if bilderUnpack pyparsing; then
    techo "Running bilderDuBuild for pyparsing."

# Regularize name.  Already done by findContribPackage
    PYPARSING_ENV="$DISTUTILS_NOLV_ENV"
    case `uname`-$CC in
      CYGWIN*-cl)
        PYPARSING_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        ;;
      CYGWIN*-mingw*)
        PYPARSING_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        PYPARSING_ENV="PATH=/MinGW/bin:'$PATH'"
        ;;
      Linux)
        PYPARSING_ARGS="--lflags=${RPATH_FLAG}$PYPARSING_HDF5_DIR/lib"
        ;;
    esac
    bilderDuBuild -p pyparsing pyparsing "$PYPARSING_ARGS" "$PYPARSING_ENV"
  fi
}

######################################################################
#
# Test pyparsing
#
######################################################################

testPyParsing() {
  techo "Not testing pyparsing."
}

######################################################################
#
# Install pyparsing
#
######################################################################

installPyParsing() {

# On CYGWIN, no installation to do, just mark
  local anyinstalled=false
  case `uname`-`uname -r` in
    CYGWIN*)
      bilderDuInstall -n pyparsing
      ;;
    *)
      bilderDuInstall pyparsing "$PYPARSING_ARGS" "$PYPARSING_ENV"
      ;;
  esac

}

