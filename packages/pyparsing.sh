#!/bin/bash
#
# Build information for pyparsing
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pyparsing_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pyparsing_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPyparsingNonTriggerVars() {
  :
}
setPyparsingNonTriggerVars

######################################################################
#
# Launch pyparsing builds.
#
######################################################################

buildPyParsing() {

#
  if ! bilderUnpack pyparsing; then
    return
  fi

# Regularize name.  Already done by findContribPackage
  PYPARSING_ENV="$DISTUTILS_NOLV_ENV"
  PYPARSING_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/pyparsing.filelist'"
  case `uname`-$CC in
    CYGWIN*-cl)
      PYPARSING_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $PYPARSING_INSTALL_ARGS $BDIST_WININST_ARG"
      ;;
    CYGWIN*-mingw*)
      PYPARSING_ARGS="--compiler=mingw32 install $PYPARSING_INSTALL_ARGS --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
      PYPARSING_ENV="PATH=/MinGW/bin:'$PATH'"
      ;;
    Linux)
      # PYPARSING_ARGS="--lflags=${RPATH_FLAG}$PYPARSING_HDF5_DIR/lib"
      ;;
  esac
  bilderDuBuild pyparsing "$PYPARSING_ARGS" "$PYPARSING_ENV"

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
      bilderDuInstall pyparsing "$PYPARSING_INSTALL_ARGS" "$PYPARSING_ENV"
      ;;
  esac

}

