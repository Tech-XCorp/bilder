#!/bin/bash
#
# Version and build information for jsmath
#
# $Id$
#
######################################################################

######################################################################
#
# Version -- we are installing TeXFonts as well.  This is kind of
# a hack but the way they are installed isn't a typical builder.
# These are like binary packages -- should probably figure out a
# way of handling binary packages more elegantly.
#
######################################################################

JSMATH_BLDRVERSION=${JSMATH_BLDRVERSION:-"3.6e"}

######################################################################
#
# Other values
#
######################################################################

JSMATH_BUILDS=${JSMATH_BUILDS:-"cc4py"}
JSMATH_DEPS=

#####################################################################
#
# Launch jsmath builds.
#
######################################################################

buildJsmath() {
  if bilderUnpack jsMath; then
# Try twice for cygwin
    cmd="rmall $CONTRIB_DIR/jsMath-${JSMATH_BLDRVERSION}"
    echo $cmd
    if ! $cmd; then
      echo $cmd
      $cmd
    fi
# Copy to get group correct, as top dir is setgid
    cmd="cp -R jsMath-${JSMATH_BLDRVERSION} $CONTRIB_DIR"
    echo $cmd
    if ! $cmd; then
      techo "jsMath failed to install"
      installFailures="$installFailures jsMath"
      return
    fi
# Fix any perms
    if ! setOpenPerms $CONTRIB_DIR/jsMath-${JSMATH_BLDRVERSION}; then
      installFailures="$installFailures jsMath"
      return
    fi
    ln -sf $CONTRIB_DIR/jsMath-${JSMATH_BLDRVERSION} $CONTRIB_DIR/jsMath
    # SWS: link name with all lowercase to aid in cmake package find
    ln -sf $CONTRIB_DIR/jsMath-${JSMATH_BLDRVERSION} $CONTRIB_DIR/jsmath
    ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR jsMath,cc4py
  fi
}

######################################################################
#
# Test jsmath
#
######################################################################

testJsmath() {
  techo "Not testing JSMATH."
}

######################################################################
#
# Install jsmath
#
######################################################################

installJsmath() {
  :
}

