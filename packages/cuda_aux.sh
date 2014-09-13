#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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

setCudaTriggerVars() {
  :
}
setCudaTriggerVars

######################################################################
#
# Find hypre
#
######################################################################

findCuda() {
# Determine whether CUDA is in path.  If so, get version
  CUDA_VERSION=`nvcc --version 2> /dev/null `
  if test -n "$CUDA_VERSION"; then
    CUDA_VERSION=`echo $CUDA_VERSION | sed 's/.*release \([0-9]\)\.\([0-9]\).*/\1\.\2/'`
    techo "CUDA_VERSION: $CUDA_VERSION"
    BUILD_CUDA=true
  else
    echo "CUDA NOT found.  No nvcc in path."
    BUILD_CUDA=false
  fi
  techo "BUILD_CUDA = $BUILD_CUDA."
}

