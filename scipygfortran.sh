#!/bin/sh
######################################################################
#
# @file    scipygfortran.sh
#
# @brief   Script to remove arch args before running gfortran
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

unset args
while test -n "$1"; do
  case $1 in
    -arch)
      shift
      shift
      ;;
    *)
      args="$args $1"
      shift
      ;;
  esac
done
cmd="gfortran $args"
echo $cmd
$cmd

