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

buildCuda() {
    echo "Building cuda is not relevant"
}
testCuda() {
    echo "Testing cuda is not relevant"
}
installCuda() {
    echo "Installing cuda is not relevant"
}

