#!/bin/bash
#
# Version and build information for tornado
#
# $Id: tornado.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

TORNADO_BLDRVERSION=${TORNADO_BLDRVERSION:-"2.1.1"}

######################################################################
#
# Other values
#
######################################################################

TORNADO_BUILDS=${TORNADO_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
TORNADO_DEPS=setuptools,Python
TORNADO_UMASK=002

#####################################################################
#
# Launch tornado builds.
#
######################################################################

buildTornado() {

  if bilderUnpack tornado; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/tornado*"
    techo "$cmd"
    $cmd

# Build away
    TORNADO_ENV="$DISTUTILS_ENV"
    decho TORNADO_ENV = $TORNADO_ENV
    bilderDuBuild -p tornado tornado '-' "$TORNADO_ENV"
  fi

}

######################################################################
#
# Test tornado
#
######################################################################

testTornado() {
  techo "Not testing tornado."
}

######################################################################
#
# Install tornado
#
######################################################################

installTornado() {
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p tornado tornado '-' "$RPY_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p tornado tornado "--install-purelib=$PYTHON_SITEPKGSDIR" "$RPY_ENV"
      ;;
  esac
}

