#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
# This package was taken from bitbucket and put into sourceforge:
# https://svn.code.sf.net/p/numfig/code-0/trunk
#
# Create the tarball by running tarup.sh in the checked out repo.
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

setImagesizeTriggerVars() {
  IMAGESIZE_BLDRVERSION=${IMAGESIZE_BLDRVERSION:-"0.7.1"}
  IMAGESIZE_BUILDS=${IMAGESIZE_BUILDS:-"pycsh"}
  IMAGESIZE_DEPS=
}
setImagesizeTriggerVars

######################################################################
#
# Find xz
#
######################################################################

findImagesize() {
  :
}
