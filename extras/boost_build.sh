#!/bin/bash
#
# Boost has no configure step, only the preconfig, which is
# done once for all builds
#
# Execute this via
#  boost_build.sh 2>&1 | tee ser/boost_build.out
#

# Determine args
CXX=pgCC
bld=ser
mydir=`dirname $BASH_SOURCE`
cmd="source $mydir/boostargs.sh"
echo $cmd
$cmd

# Run command
cmd="./b2 $BOOST_SER_ADDL_ARGS stage"
echo $cmd
$cmd
echo "Result is $?"

