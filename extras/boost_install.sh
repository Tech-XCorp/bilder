#!/bin/bash
#
# Boost has no configure step, only the preconfig, which is
# done once for all builds
#
# Execute this via
#  boost_build.sh 2>&1 | tee ser/boost_install.out
#

# Determine args
CXX=pgCC
bld=ser
mydir=`dirname $BASH_SOURCE`
cmd="source $mydir/boostargs.sh"
echo $cmd
$cmd

# Run command
CONTRIB_DIR=/project/projectdirs/vorpal/vp5users/hopper/contrib-pgi-12.9
cmd="./b2 --prefix=$CONTRIB_DIR/boost-1_50_0-ser $BOOST_SER_ADDL_ARGS install"
echo $cmd
$cmd
echo "Result is $?"

