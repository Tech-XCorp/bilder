#!/bin/bash
#
# Build information for c2html
#
# $Id$
#
######################################################################

C2HTML_BLDRVERSION=${C2HTML_BLDRVERSION:-"0.9.4"}
C2HTML_BUILDS=${C2HTML_BUILDS:-"ser"}
C2HTML_DEPS=

######################################################################
#
# Launch c2html builds.
#
######################################################################

buildC2html() {
  if ! bilderUnpack -i c2html; then
    return
  fi
  for bld in ${C2HTML_BUILDS}; do
    if bilderConfig -i c2html $bld; then
      bilderBuild c2html $bld
    fi
  done
}

######################################################################
#
# Test c2html
#
######################################################################

testC2html() {
  techo "Not testing c2html"
}

######################################################################
#
# Install c2html
#
######################################################################

installC2html() {
  for bld in ${C2HTML_BUILDS}; do
    bilderInstall c2html ser 
  done
}

