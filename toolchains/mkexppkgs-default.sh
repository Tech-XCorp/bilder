#!/bin/bash
#
# Build and install in places following our conventions for LCFs,
# clusters, and workstations.  Logic in bilder/mkall-default.sh.
#
# $Id$
#
######################################################################

# Get lcf variables
mydir=`dirname $0`
mydir=${mydir:-"."}
PROJECT_INSTSUBDIRNAME=mkexppkgs
source $mydir/bilder/mkall-default.sh

# Build the package
runBilderCmd mkexppkgs

