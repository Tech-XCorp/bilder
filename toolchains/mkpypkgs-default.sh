#!/bin/bash
#
# Build and install in places following our conventions for LCFs,
# clusters, and workstations.  Logic in bilder/mkall-default.sh
#
# @version $Id: mkpypkgs-default.sh 6537 2012-08-15 23:37:28Z alexanda $
#
######################################################################

# Get lcf variables
mydir=`dirname $0`
mydir=${mydir:-"."}
mydir=`(cd $mydir; pwd -P)`
# Where to find configuration info
BILDER_CONFDIR=$mydir/txcbilder
# Subdir under INSTALL_ROOTDIR where this package is installed
PROJECT_INSTSUBDIR=facets
source $mydir/bilder/mkall-default.sh

# Build the package
runBilderCmd
res=$?
exit $res
