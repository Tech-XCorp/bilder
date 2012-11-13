#!/bin/bash
#
# Version and build information for pygments
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYGMENTS_BLDRVERSION=${PYGMENTS_BLDRVERSION:-"1.3.1"}

######################################################################
#
# Other values
#
######################################################################

PYGMENTS_BUILDS=${PYGMENTS_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
PYGMENTS_DEPS=setuptools,Python
PYGMENTS_UMASK=002

#####################################################################
#
# Launch pygments builds.
#
######################################################################

buildPygments() {

  if bilderUnpack Pygments; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/Pygments*"
    techo "$cmd"
    $cmd

# Build away
    PYGMENTS_ENV="$DISTUTILS_ENV $PYGMENTS_GFORTRAN"
    decho PYGMENTS_ENV = $PYGMENTS_ENV
    bilderDuBuild -p pygments Pygments '-' "$PYGMENTS_ENV"
  fi

}

######################################################################
#
# Test pygments
#
######################################################################

testPygments() {
  techo "Not testing Pygments."
}

######################################################################
#
# Install pygments
#
######################################################################

installPygments() {
  local res=1
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p pygments Pygments '-' "$PYGMENTS_ENV"
      res=0
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p pygments Pygments "--install-purelib=$PYTHON_SITEPKGSDIR" "$PYGMENTS_ENV"
      res=0
      ;;
  esac
  if test $res = 0; then
    setOpenPerms $PYTHON_SITEPKGSDIR/Pygments*.egg
  fi
  # echo "WARNING: Quitting at end of pygments.sh."; exit
}

