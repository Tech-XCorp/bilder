#!/bin/sh
######################################################################
#
# @file    cleaninstallers.sh
#
# @brief   Clean out installations
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

mydir=`dirname $0`
mydir=`(cd $mydir; pwd -P)`
swdir=$1
for i in open/facets open/swim proprietary/nautilus proprietary/polyswift proprietary/vorpal; do
  cmd="$mydir/cleaninstalls.sh -rk 36 $swdir/$i"
  echo $cmd
  $cmd
done
