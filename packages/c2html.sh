#!/bin/sh
######################################################################
#
# @file    c2html.sh
#
# @brief   Build and version information for c2html.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
######################################################################
#
# Find c2html
#
######################################################################

findSowing() {
  addtopathvar PATH $CONTRIB_DIR/c2html/bin
}

