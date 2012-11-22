#!/bin/bash
#
# Version and build information for simplejson
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SIMPLEJSON_BLDRVERSION=${SIMPLEJSON_BLDRVERSION:-"2.1.3"}

######################################################################
#
# Other values
#
######################################################################

SIMPLEJSON_BUILDS=${SIMPLEJSON_BUILDS:-"cc4py"}
SIMPLEJSON_DEPS=Python
SIMPLEJSON_UMASK=002

#####################################################################
#
# Launch simplejson builds.
#
######################################################################

buildSimplejson() {

  if bilderUnpack simplejson; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/simplejson*"
    techo "$cmd"
    $cmd

# Build away
    SIMPLEJSON_ENV="$DISTUTILS_ENV"
    techo -2 SIMPLEJSON_ENV = $SIMPLEJSON_ENV
    bilderDuBuild -p simplejson simplejson '-' "$SIMPLEJSON_ENV"
  fi

}

######################################################################
#
# Test simplejson
#
######################################################################

testSimplejson() {
  techo "Not testing Simplejson."
}

######################################################################
#
# Install simplejson
#
######################################################################

installSimplejson() {
  case `uname` in
    # Windows does not have a lib versus lib64 issue
    CYGWIN*)
      bilderDuInstall -p simplejson simplejson " " "$SIMPLEJSON_ENV"
      ;;
    *)
      bilderDuInstall -p simplejson simplejson "--install-purelib=$PYTHON_SITEPKGSDIR" "$SIMPLEJSON_ENV"
      ;;
  esac
}
