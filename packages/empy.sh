#!/bin/bash
#
# Build information for EMpy Python module.
#
#    see http://lbolla.github.io/EMpy
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in EMpy_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/empy_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setEMpyNonTriggerVars() {
  :
}
setEMpyNonTriggerVars

######################################################################
#
# Launch EMpy builds.
#
######################################################################

buildEMpy() {

# Get EMpy
  if ! bilderUnpack EMpy; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/EMpy*"
  techo "$cmd"
  $cmd
  EMPY_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/EMpy.files'"
  case `uname`-"$CC" in
    CYGWIN*-*cl*)
      EMPY_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $EMPY_INSTALL_ARGS $BDIST_WININST_ARG"
      EMPY_ENV_USED="$DISTUTILS_ENV"
      ;;
    CYGWIN*-mingw*)
# Have to install with build to get both prefix and compiler correct.
      EMPY_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $EMPY_INSTALL_ARGS $BDIST_WININST_ARG"
      local mingwgcc=`which mingw32-gcc`
      local mingwdir=`dirname $mingwgcc`
      EMPY_ENV_USED="PATH=$mingwdir:'$PATH'"
      ;;
    *)
      EMPY_ENV_USED="$DISTUTILS_ENV"
      ;;
  esac
  bilderDuBuild EMpy "$EMPY_ARGS" "$EMPY_ENV_USED"

}

######################################################################
#
# Test EMpy
#
######################################################################

testEMpy() {
  techo "Not testing EMpy."
}

######################################################################
#
# Install EMpy
#
######################################################################

installEMpy() {
  local res=1
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n EMpy "$EMPY_ARGS" "$EMPY_ENV_USED"
      res=$?
      ;;
    *)
      bilderDuInstall EMpy "$EMPY_INSTALL_ARGS" "$EMPY_ENV_USED"
      res=$?
      ;;
  esac
#  if test $res = 0; then
#    chmod a+r $PYTHON_SITEPKGSDIR/EMpy.py*
#  fi
}

