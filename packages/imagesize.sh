#!/bin/sh
######################################################################
#
# @file    imagesize.sh
#
# @brief   Build information for imagesize.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in imagesize_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/imagesize_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setImagesizeNonTriggerVars() {
  IMAGESIZE_UMASK=002
}
setImagesizeNonTriggerVars

#####################################################################
#
# Launch imagesize builds.
#
######################################################################

buildImagesize() {
  if ! bilderUnpack imagesize; then
    return
  fi
  IMAGESIZE_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/imagesize.files'"
  bilderDuBuild imagesize
}

######################################################################
#
# Test imagesize
#
######################################################################

testImagesize() {
  techo "Not testing imagesize."
}

######################################################################
#
# Install imagesize
#
######################################################################

installImagesize() {
  bilderDuInstall imagesize "$IMAGESIZE_INSTALL_ARGS"
}

