#!/bin/bash
#
# Version and build information for cuda
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# assume nvcc in PATH
CUDA_VERSION=`nvcc --version`
CUDA_VERSION=`echo $CUDA_VERSION | sed 's/.*release \([0-9]\)\.\([0-9]\).*/\1\.\2/'`
techo "CUDA_VERSION: $CUDA_VERSION"

buildCuda() {
	echo "Building cuda is not relevant"
}
testCuda() {
	echo "Testing cuda is not relevant"
}
installCuda() {
	echo "Installing cuda is not relevant"
}
