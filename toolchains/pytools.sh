#!/bin/bash
#
# Source this file to build python numerical tools
#
# $Id: pytools.sh 6191 2012-06-08 17:09:05Z benc $
#
######################################################################

# Numpy is fundamental to all packages
# Atlas is a pre-requesite.  We recommend linlibs.sh for the
# pre-requesite.
source $BILDER_DIR/packages/numpy.sh
buildNumpy
installNumpy

# Cython and numexpr needed for tables.
# Build
source $BILDER_DIR/packages/cython.sh
buildCython
source $BILDER_DIR/packages/numexpr.sh
buildNumexpr

# Install
installNumexpr
installCython

# Png needed for matplotlib.
# Build
source $BILDER_DIR/packages/libpng.sh
buildLibpng
source $BILDER_DIR/packages/scipy.sh
buildScipy
source $BILDER_DIR/packages/tables.sh
buildTables

# Install
installTables
installScipy
installLibpng

#
#  Can build matplotlib on top of qt
#
if $BUILD_OPTIONAL; then

# Sip
  source $BILDER_DIR/packages/sip.sh
  buildSip
  installSip

# PyQt
  source $BILDER_DIR/packages/pyqt.sh
  buildPyQt
  installPyQt

fi

# This depends on libpng
source $BILDER_DIR/packages/matplotlib.sh
buildMatplotlib
installMatplotlib
