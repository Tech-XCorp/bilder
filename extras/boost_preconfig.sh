#!/bin/bash
#
# This is done once for all builds.
#

BOOST_BUILDS="ser"
for bld in `echo "$BOOST_BUILDS | tr ',' ' '`; do
  mkdir -p $bld
done
echo "Building b2."
cmd="./bootstrap.sh -show-libraries"
echo "$cmd"
$cmd
echo "Result is $?"

