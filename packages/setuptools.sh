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

SETUPTOOLS_BLDRVERSION=${SETUPTOOLS_BLDRVERSION:-"0.6c11"}

######################################################################
#
# Other values
#
######################################################################

SETUPTOOLS_BUILDS=${SETUPTOOLS_BUILDS:-"cc4py"}
SETUPTOOLS_DEPS=Python
SETUPTOOLS_UMASK=002

#####################################################################
#
# Launch setuptools builds.
#
######################################################################

buildSetuptools() {

  if bilderUnpack setuptools; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/setuptools*"
    techo "$cmd"
    $cmd

# Build away
    SETUPTOOLS_ENV="$DISTUTILS_ENV $SETUPTOOLS_GFORTRAN"
    techo -2 SETUPTOOLS_ENV = $SETUPTOOLS_ENV
    bilderDuBuild setuptools '-' "$SETUPTOOLS_ENV"
  fi

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
  local res=1
  case `uname` in
    # Windows does not have a lib versus lib64 issue
    CYGWIN*)
      mkdir -p $CONTRIB_DIR/Lib/site-packages
      bilderDuInstall setuptools " " "$SETUPTOOLS_ENV"
      res=$?
      ;;
    *)
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall setuptools "--install-purelib=$PYTHON_SITEPKGSDIR" "$SETUPTOOLS_ENV"
      res=$?
      ;;
  esac
  if test $res = 0; then
    chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
  # echo "WARNING: Quitting at end of setuptools.sh."; exit
}

