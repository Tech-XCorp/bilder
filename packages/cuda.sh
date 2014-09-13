#!/bin/bash
#
# Build information for cuda
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in cuda_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/cuda_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCudaNonTriggerVars() {
  :
}
setCudaNonTriggerVars

