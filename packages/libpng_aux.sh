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

setLibpngTriggerVars() {
  LIBPNG_BLDRVERSION=${LIBPNG_BLDRVERSION:-"1.5.7"}
  case `uname`-`uname -r` in
    # CYGWIN*-* | Darwin-1[0-2].*)
    CYGWIN*-*) # libpng in /usr/X11 on Darwin
      LIBPNG_DESIRED_BUILDS=${LIBPNG_DESIRED_BUILDS:-"sersh"}
      ;;
  esac
  computeBuilds libpng
  addCc4pyBuild libpng
  LIBPNG_DEPS=zlib,cmake
}
setLibpngTriggerVars

######################################################################
#
# Find libpng
#
######################################################################

findLibpng() {
  :
}

