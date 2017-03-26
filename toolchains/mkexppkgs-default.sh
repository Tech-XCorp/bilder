#!/bin/sh
######################################################################
#
# @file    mkexppkgs-default.sh
#
# @brief   Build and install in places following our conventions for LCFs,
#          clusters, and workstations.  Logic in bilder/mkall-default.sh.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

# Get lcf variables
mydir=`dirname $0`
mydir=${mydir:-"."}
PROJECT_INSTSUBDIRNAME=mkexppkgs
source $mydir/bilder/mkall-default.sh

# Build the package
runBilderCmd mkexppkgs

