#!/bin/sh
# script for updating svn repos and git repos

updir=${1:-"."}
updir=`(cd $updir; pwd -P)`
mydir=`dirname $0`
cmd="(cd $mydir/..; svn up; $mydir/updategitrepos.sh)"
echo $cmd

