#!/bin/bash
#
# Build and install in places following our conventions for LCFs,
# clusters, and workstations.  Logic in bilder/mkall-default.sh
#
# @version $Id: mktrilinos-default.sh 4901 2012-01-14 13:34:01Z cary $
#
######################################################################

# Get lcf variables
mydir=`dirname $0`
mydir=${mydir:-"."}
PROJECT_INSTSUBDIRNAME=facets
source $mydir/bilder/mkall-default.sh

# Build the package
runBilderCmd facets
