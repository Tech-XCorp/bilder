#!/bin/bash
#
# Version and build information for paramiko
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PARAMIKO_BLDRVERSION=${PARAMIKO_BLDRVERSION:-"1.7.7.1"}

######################################################################
#
# Other values
#
######################################################################

PARAMIKO_BUILDS=${PARAMIKO_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
PARAMIKO_DEPS=setuptools,Python
PARAMIKO_UMASK=002

#####################################################################
#
# Launch paramiko builds.
#
######################################################################

buildParamiko() {

  if bilderUnpack paramiko; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/paramiko*"
    techo "$cmd"
    $cmd

# Build away
    PARAMIKO_ENV="$DISTUTILS_ENV"
    techo -2 PARAMIKO_ENV = $PARAMIKO_ENV
    bilderDuBuild -p paramiko paramiko '-' "$PARAMIKO_ENV"
  fi

}

######################################################################
#
# Test paramiko
#
######################################################################

testParamiko() {
  techo "Not testing paramiko."
}

######################################################################
#
# Install paramiko
#
######################################################################

installParamiko() {
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p paramiko paramiko '-' "$RPY_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p paramiko paramiko "--install-purelib=$PYTHON_SITEPKGSDIR" "$RPY_ENV"
      ;;
  esac
}

