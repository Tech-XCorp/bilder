#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setPkgconfigTriggerVars() {
  PKGCONFIG_BLDRVERSION_STD=${PKGCONFIG_BLDRVERSION_STD:-"0.28"}
  PKGCONFIG_BLDRVERSION_EXP=${PKGCONFIG_BLDRVERSION_EXP:-"0.28"}
  if ! [[ `uname` =~ CYGWIN ]]; then
    PKGCONFIG_BUILDS=${PKGCONFIG_BUILDS:-"ser"}
  fi
  PKGCONFIG_DEPS=autoconf,m4,xz
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
}
setPkgconfigTriggerVars

######################################################################
#
# Find pkgconfig
#
######################################################################

findPkgconfig() {
  addtopathvar PATH $CONTRIB_DIR/autotools/bin
}

