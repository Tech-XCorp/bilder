#!/bin/sh
######################################################################
#
# @file    uncrustify.sh
#
# @brief   Build information for uncrustify.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in uncrustify_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/uncrustify_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setUncrustifyNonTriggerVars() {
  HYPRE_UMASK=002
  UNCRUSTIFY_UMASK=002
}
setUncrustifyNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildUncrustify() {
  if ! bilderUnpack uncrustify; then
    return
  fi
  if bilderConfig uncrustify ser; then
    bilderBuild uncrustify ser
  fi
}

######################################################################
#
# Test
#
######################################################################

testUncrustify() {
  techo "Not testing uncrustify."
}

######################################################################
#
# Install
#
######################################################################

installUncrustify() {
  if bilderInstall uncrustify ser; then
    mkdir -p $CONTRIB_DIR/bin
    (cd $CONTRIB_DIR/bin; ln -sf ../uncrustify/bin/uncrustify .)
  fi
}

