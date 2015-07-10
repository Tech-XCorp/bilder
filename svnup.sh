#!/bin/sh
# script for updating svn repos and git repos

updir=${1:-"."}
updir=`(cd $updir; pwd -P)`
mydir=`dirname $0`
mydir=`(cd $mydir; pwd -P)`
dirdir=`(cd $mydir/..; pwd -P)`
cmd="(cd $dirdir; svn up; $mydir/updategitrepos.sh)"
echo $cmd
eval "$cmd"

