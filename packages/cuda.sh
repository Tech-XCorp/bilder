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

# Determine whether CUDA exists by whether it is path.  If so, determine
# version
CUDA_VERSION=`nvcc --version 2> /dev/null `
if test -n "$CUDA_VERSION"; then
  CUDA_VERSION=`echo $CUDA_VERSION | sed 's/.*release \([0-9]\)\.\([0-9]\).*/\1\.\2/'`
  techo "CUDA_VERSION: $CUDA_VERSION"
  BUILD_CUDA=true
else
  echo "CUDA NOT found.  No nvcc in path."
  BUILD_CUDA=false
fi
echo $BUILD_CUDA


buildCuda() {
	echo "Building cuda is not relevant"
}
testCuda() {
	echo "Testing cuda is not relevant"
}
installCuda() {
	echo "Installing cuda is not relevant"
}
