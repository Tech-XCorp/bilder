#!/bin/sh
######################################################################
#
# @file    updaterepos.sh
#
# @brief   script for updating svn repos and git repos
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

updir=${1:-"."}
updir=`(cd $updir; pwd -P)`
mydir=`dirname $0`
mydir=`(cd $mydir; pwd -P)`
dirdir=`(cd $mydir/..; pwd -P)`
cmd="(cd $dirdir; svn up; $mydir/updategitrepos.sh)"
echo $cmd
eval "$cmd"

