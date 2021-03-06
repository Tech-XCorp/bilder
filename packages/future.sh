#!/bin/sh
######################################################################
#
# @file    future.sh
#
# @brief   Build information for the future Python module.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
#    see https://pypi.python.org/pypi/future
#
######################################################################

######################################################################
#
# Trigger variables set in future_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/future_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setFutureNonTriggerVars() {
  :
}
setFutureNonTriggerVars

######################################################################
#
# Launch future builds.
#
######################################################################

buildFuture() {

# Get future
  if ! bilderUnpack future; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/future*"
  techo "$cmd"
  $cmd
  FUTURE_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/future.files'"
  case `uname`-"$CC" in
    CYGWIN*-*cl*)
      FUTURE_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $FUTURE_INSTALL_ARGS $BDIST_WININST_ARG"
      FUTURE_ENV_USED="$DISTUTILS_ENV"
      ;;
    CYGWIN*-mingw*)
# Have to install with build to get both prefix and compiler correct.
      FUTURE_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $FUTURE_INSTALL_ARGS $BDIST_WININST_ARG"
      local mingwgcc=`which mingw32-gcc`
      local mingwdir=`dirname $mingwgcc`
      FUTURE_ENV_USED="PATH=$mingwdir:'$PATH'"
      ;;
    *)
      FUTURE_ENV_USED="$DISTUTILS_ENV"
      ;;
  esac
  bilderDuBuild future "$FUTURE_ARGS" "$FUTURE_ENV_USED"

}

######################################################################
#
# Test future
#
######################################################################

testFuture() {
  techo "Not testing future."
}

######################################################################
#
# Install future
#
######################################################################

installFuture() {
  local res=1
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n future "$FUTURE_ARGS" "$FUTURE_ENV_USED"
      res=$?
      ;;
    *)
      bilderDuInstall future "$FUTURE_INSTALL_ARGS" "$FUTURE_ENV_USED"
      res=$?
      ;;
  esac
#  if test $res = 0; then
#    chmod a+r $PYTHON_SITEPKGSDIR/future.py*
#  fi
}

