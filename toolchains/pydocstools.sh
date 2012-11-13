#!/bin/bash
#
# Source this file to build python numerical tools
#
# $Id$
#
######################################################################

# Do sphinx related packages
source $BILDER_DIR/packages/mathjax.sh
buildMathjax
installMathjax
source $BILDER_DIR/packages/setuptools.sh
buildSetuptools
# Install
installSetuptools
source $BILDER_DIR/packages/imaging.sh
buildImaging
installImaging
source $BILDER_DIR/packages/pygments.sh
buildPygments
installPygments
# This should allow direct sphinx to pdf, but it seems not to
# source $BILDER_DIR/packages/rst2pdf.sh
# buildRst2pdf
# installRst2pdf
source $BILDER_DIR/packages/sphinx.sh
buildSphinx
installSphinx
# techo exit; exit

