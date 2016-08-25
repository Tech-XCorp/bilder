#!/bin/bash
#
# Build information for nuitka
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in nuitka_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/nuitka_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNuitkaNonTriggerVars() {
  NUITKA_UMASK=002
}
setNuitkaNonTriggerVars

#####################################################################
#
# Launch nuitka builds.
#
######################################################################

buildNuitka() {

# Get nuitka, check for build need
  if ! bilderUnpack Nuitka; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/Nuitka*"
  techo "$cmd"
# Do second time for cygwin
  if ! $cmd; then
    techo "$cmd"
    $cmd
  fi

# Build away
  NUITKA_ENV="$DISTUTILS_ENV"
  techo -2 NUITKA_ENV = $NUITKA_ENV
  local NUITKA_ARGS=
  case `uname` in
    CYGWIN*) NUITKA_ARGS='--compiler=msvc';;
  esac
  bilderDuBuild Nuitka "$NUITKA_ARGS" "$NUITKA_ENV"

}

######################################################################
#
# Test nuitka
#
######################################################################

testNuitka() {
  techo "Not testing Nuitka."
}

######################################################################
#
# Install nuitka
#
######################################################################

installNuitka() {
# Possible options: --single-version-externally-managed
  local NUITKA_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/nuitka.files'"
  if bilderDuInstall Nuitka "$NUITKA_INSTALL_ARGS" "$NUITKA_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/easy-install.pth
    setOpenPerms $PYTHON_SITEPKGSDIR/{N,n}uitka-*.egg
  fi
}

