#!/bin/sh
######################################################################
#
# @file    cython.sh
#
# @brief   Build information for cython.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in cython_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/cython_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCythonNonTriggerVars() {
  :
}
setCythonNonTriggerVars

######################################################################
#
# Launch cython builds.
#
######################################################################

buildCython() {

# Get Cython
  if ! bilderUnpack Cython; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/Cython*"
  techo "$cmd"
  $cmd
  CYTHON_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/numexpr.files'"
  case `uname`-"$CC" in
    CYGWIN*-*cl*)
      CYTHON_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $CYTHON_INSTALL_ARGS $BDIST_WININST_ARG"
      CYTHON_ENV_USED="$DISTUTILS_ENV"
      ;;
    CYGWIN*-mingw*)
# Have to install with build to get both prefix and compiler correct.
      CYTHON_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $CYTHON_INSTALL_ARGS $BDIST_WININST_ARG"
      local mingwgcc=`which mingw32-gcc`
      local mingwdir=`dirname $mingwgcc`
      CYTHON_ENV_USED="PATH=$mingwdir:'$PATH'"
      ;;
    *)
      CYTHON_ENV_USED="$DISTUTILS_ENV"
      ;;
  esac
  bilderDuBuild Cython "$CYTHON_ARGS" "$CYTHON_ENV_USED"

}

######################################################################
#
# Test cython
#
######################################################################

testCython() {
  techo "Not testing cython."
}

######################################################################
#
# Install cython
#
######################################################################

installCython() {
  local res=1
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n Cython "$CYTHON_ARGS" "$CYTHON_ENV_USED"
      res=$?
      ;;
    *)
      bilderDuInstall Cython "$CYTHON_INSTALL_ARGS" "$CYTHON_ENV_USED"
      res=$?
      ;;
  esac
  if test $res = 0; then
    chmod a+r $PYTHON_SITEPKGSDIR/cython.py*
    setOpenPerms $PYTHON_SITEPKGSDIR/pyximport
  fi
}

