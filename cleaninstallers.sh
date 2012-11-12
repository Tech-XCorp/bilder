#!/bin/bash
#
# Clean out installations
#
mydir=`dirname $0`
mydir=`(cd $mydir; pwd -P)`
swdir=$1
for i in open/facets open/swim proprietary/nautilus proprietary/polyswift proprietary/vorpal; do
  cmd="$mydir/cleaninstalls.sh -rk 36 $swdir/$i"
  echo $cmd
  $cmd
done
