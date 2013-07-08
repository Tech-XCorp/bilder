#!/bin/bash
#
# Version and build information for breathe
#
# $Id$
#
######################################################################

######################################################################
#
#  Breathe is a package for integrating doxygen with Sphinx.
#
######################################################################

BREATHE_BLDRVERSION=${BREATHE_BLDRVERSION:-"1.0.0"}

######################################################################
#
# Other values
#
######################################################################

BREATHE_BUILDS=ser
BREATHE_DEPS=docutils,sphinx,doxygen,Python

#####################################################################
#
# Launch cusp builds.
#
######################################################################

buildBreathe() {
  if bilderUnpack breathe; then
# Try twice for cygwin
    cmd="rmall $CONTRIB_DIR/breathe-${BREATHE_BLDRVERSION}"
    echo $cmd
    if ! $cmd; then
      echo $cmd
      $cmd
    fi
# Copy to get group correct, as top dir is setgid
    cmd="cp -R breathe-${BREATHE_BLDRVERSION} $CONTRIB_DIR"
    echo $cmd
    if ! $cmd; then
      techo "breathe failed to install"
      installFailures="$installFailures breathe"
      return
    fi
# Fix any perms
    if ! setOpenPerms $CONTRIB_DIR/breathe-${BREATHE_BLDRVERSION}; then
      installFailures="$installFailures breathe"
      return
    fi
    ln -sf $CONTRIB_DIR/breathe-${BREATHE_BLDRVERSION} $CONTRIB_DIR/breathe
    # SWS: link name with all lowercase to aid in cmake package find
    ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR breathe,ser
  fi
}

######################################################################
#
# Test breathe
#
######################################################################

testBreathe() {
  techo "Not testing breathe."
}

######################################################################
#
# Install breathe
#
######################################################################

installBreathe() {
  :
}

