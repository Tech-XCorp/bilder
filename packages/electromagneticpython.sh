#!/bin/bash
#
# Build information for ElectroMagneticPython Python module.
#
#    see http://lbolla.github.io/ElectroMagneticPython
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in ElectroMagneticPython_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/electromagneticpython_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setElectroMagneticPythonNonTriggerVars() {
  :
}
setElectroMagneticPythonNonTriggerVars

######################################################################
#
# Launch ElectroMagneticPython builds.
#
######################################################################

buildElectroMagneticPython() {

# Get ElectroMagneticPython
  if ! bilderUnpack ElectroMagneticPython; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/ElectroMagneticPython*"
  techo "$cmd"
  $cmd
  ELECTROMAGNETICPYTHON_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/ElectroMagneticPython.files'"
  case `uname`-"$CC" in
    CYGWIN*-*cl*)
      ELECTROMAGNETICPYTHON_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $ELECTROMAGNETICPYTHON_INSTALL_ARGS $BDIST_WININST_ARG"
      ELECTROMAGNETICPYTHON_ENV_USED="$DISTUTILS_ENV"
      ;;
    CYGWIN*-mingw*)
# Have to install with build to get both prefix and compiler correct.
      ELECTROMAGNETICPYTHON_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $ELECTROMAGNETICPYTHON_INSTALL_ARGS $BDIST_WININST_ARG"
      local mingwgcc=`which mingw32-gcc`
      local mingwdir=`dirname $mingwgcc`
      ELECTROMAGNETICPYTHON_ENV_USED="PATH=$mingwdir:'$PATH'"
      ;;
    *)
      ELECTROMAGNETICPYTHON_ENV_USED="$DISTUTILS_ENV"
      ;;
  esac
  bilderDuBuild ElectroMagneticPython "$ELECTROMAGNETICPYTHON_ARGS" "$ELECTROMAGNETICPYTHON_ENV_USED"

}

######################################################################
#
# Test ElectroMagneticPython
#
######################################################################

testElectroMagneticPython() {
  techo "Not testing ElectroMagneticPython."
}

######################################################################
#
# Install ElectroMagneticPython
#
######################################################################

installElectroMagneticPython() {
  local res=1
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n ElectroMagneticPython "$ELECTROMAGNETICPYTHON_ARGS" "$ELECTROMAGNETICPYTHON_ENV_USED"
      res=$?
      ;;
    *)
      bilderDuInstall ElectroMagneticPython "$ELECTROMAGNETICPYTHON_INSTALL_ARGS" "$ELECTROMAGNETICPYTHON_ENV_USED"
      res=$?
      ;;
  esac
#  if test $res = 0; then
#    chmod a+r $PYTHON_SITEPKGSDIR/ElectroMagneticPython.py*
#  fi
}

