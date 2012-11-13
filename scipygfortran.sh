#!/bin/sh
#
# scipygfortran.sh
#
# Script to remove arch args before running gfortran
#
# $Id$

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

