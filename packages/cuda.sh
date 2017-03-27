#!/bin/sh
######################################################################
#
# @file    cuda.sh
#
# @brief   Build information for cuda.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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

