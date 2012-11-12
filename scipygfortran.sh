#!/bin/sh
#
# scipygfortran.sh
#
# Script to remove arch args before running gfortran
#
# $Id: scipygfortran.sh 5735 2012-04-08 14:09:02Z cary $

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

