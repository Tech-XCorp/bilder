#!/bin/bash
#
# Build information for docutils
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in docutils_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/docutils_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setDocutilsNonTriggerVars() {
  DOCUTILS_UMASK=002
}
setDocutilsNonTriggerVars

######################################################################
#
# Launch docutils builds.
#
######################################################################

buildDocutils() {

  if ! bilderUnpack docutils; then
    return
  fi

# Must first remove any old installations
  cmd="rmall $CONTRIB_DIR/$PYTHON_LIBSUBDIR/python$PYTHON_MAJMIN/site-package/docutils*"
  techo "$cmd"
  $cmd
  techo "Running bilderDuBuild for docutils."
  bilderDuBuild docutils

}

######################################################################
#
# Test docutils
#
######################################################################

testDocutils() {
  techo "Not testing docutils."
}

######################################################################
#
# Install docutils
#
######################################################################

installDocutils() {
  bilderDuInstall docutils
}

