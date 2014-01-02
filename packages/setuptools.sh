#!/bin/bash
#
# Version and build information for setuptools
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SETUPTOOLS_BLDRVERSION_STD=${SETUPTOOLS_BLDRVERSION_STD:-"0.6c11"}
SETUPTOOLS_BLDRVERSION_EXP=${SETUPTOOLS_BLDRVERSION_EXP:-"2.0.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

SETUPTOOLS_BUILDS=${SETUPTOOLS_BUILDS:-"cc4py"}
SETUPTOOLS_DEPS=Python
SETUPTOOLS_UMASK=002

#####################################################################
#
# Build setuptools
#
######################################################################

buildSetuptools() {

# Check for build need
  if ! bilderUnpack setuptools; then
    return 1
  fi

# Remove all old installations
# Is this necessary?
  # cmd="rmall ${PYTHON_SITEPKGSDIR}/setuptools*"
  # techo "$cmd"
  # $cmd

# Build away
  # SETUPTOOLS_ENV="$DISTUTILS_ENV $SETUPTOOLS_GFORTRAN"
# Does setuptools need gfortran?
  SETUPTOOLS_ENV="$DISTUTILS_ENV"
  techo -2 SETUPTOOLS_ENV = $SETUPTOOLS_ENV
  bilderDuBuild setuptools '-' "$SETUPTOOLS_ENV"

}

######################################################################
#
# Test setuptools
#
######################################################################

testSetuptools() {
  techo "Not testing setuptools."
}

######################################################################
#
# Install setuptools
#
######################################################################

installSetuptools() {
  local res=
  mkdir -p $PYTHON_SITEPKGSDIR
  case `uname` in
    CYGWIN*)
      # mkdir -p $CONTRIB_DIR/Lib/site-packages
      bilderDuInstall setuptools " " "$SETUPTOOLS_ENV"
      res=$?
      ;;
    *)
      # mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall setuptools "--install-purelib=$PYTHON_SITEPKGSDIR" "$SETUPTOOLS_ENV"
      res=$?
      ;;
  esac
  if test $res = 0; then
    chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}

