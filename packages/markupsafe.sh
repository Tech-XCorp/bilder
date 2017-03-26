#!/bin/sh
######################################################################
#
# @file    markupsafe.sh
#
# @brief   Build information for markupsafe.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in markupsafe_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/markupsafe_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMarkupSaveNonTriggerVars() {
  MARKUPSAFE_UMASK=002
}
setMarkupSaveNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildMarkupSafe() {
  if bilderUnpack MarkupSafe; then
    bilderDuBuild -p markupsafe MarkupSafe "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testMarkupSafe() {
  techo "Not testing MarkupSafe."
}

######################################################################
#
# Install
#
######################################################################

installMarkupSafe() {
  local MARKUPSAFE_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/markupsafe.files'"
  bilderDuInstall -r MarkupSafe -p markupsafe MarkupSafe "$MARKUPSAFE_INSTALL_ARGS" "$DISTUTILS_ENV"
}

