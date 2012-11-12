#!/bin/bash
#
# $Id: diracSetup.sh 6193 2012-06-08 20:21:36Z benc $
#
# A script to set the correct modules for building on Dirac.
#
########################################################################

# Switch to gcc
if module list -t 2>&1 | grep pgi 2>&1 > /dev/null; then
  module swap pgi gcc/4.5.2
  module swap openmpi openmpi-gcc/1.4.2
fi

# Load CUDA and NVidia drivers; set environment variable to find
# libcuda.so in the NVidia driver directory
module load cuda/4.1
module load nvidia-driver-util/4.1.33
export CUDA_LIB_PATH=/usr/common/usg/nvidia-driver-util/4.1.33/lib64
