#!/bin/bash
#
# Version and build information for cusp
#
# $Id: cusp.sh 6364 2012-07-15 09:04:57Z cary $
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

CUSP_BLDRVERSION=${CUSP_BLDRVERSION:-"0.3.0"}

######################################################################
#
# Other values
#
######################################################################

CUSP_BUILDS=${CUSP_BUILDS:-"gpu"}
CUSP_DEPS=

#####################################################################
#
# Launch cusp builds.
#
######################################################################

buildCusp() {
  if bilderUnpack cusp; then
# Try twice for cygwin
    cmd="rmall $CONTRIB_DIR/cusp-${CUSP_BLDRVERSION}"
    echo $cmd
    if ! $cmd; then
      echo $cmd
      $cmd
    fi
# Copy to get group correct, as top dir is setgid
    cmd="cp -R cusp-${CUSP_BLDRVERSION} $CONTRIB_DIR"
    echo $cmd
    if ! $cmd; then
      techo "cusp failed to install"
      installFailures="$installFailures cusp"
      return
    fi
# Fix any perms
    if ! setOpenPerms $CONTRIB_DIR/cusp-${CUSP_BLDRVERSION}; then
      installFailures="$installFailures cusp"
      return
    fi
    ln -sf $CONTRIB_DIR/cusp-${CUSP_BLDRVERSION} $CONTRIB_DIR/cusp
    # SWS: link name with all lowercase to aid in cmake package find
    ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR cusp,gpu
  fi
}

######################################################################
#
# Test cusp
#
######################################################################

testCusp() {
  techo "Not testing cusp."
}

######################################################################
#
# Install cusp
#
######################################################################

installCusp() {
  :
}

