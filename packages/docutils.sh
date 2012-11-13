#!/bin/bash
#
# Version and build information for docutils
# Pure Python package
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

DOCUTILS_BLDRVERSION=${DOCUTILS_BLDRVERSION:-"0.8.1"}

######################################################################
#
# Other values
#
######################################################################

DOCUTILS_BUILDS=${DOCUTILS_BUILDS:-"cc4py"}
DOCUTILS_DEPS=

######################################################################
#
# Launch docutils builds.
#
######################################################################

buildDocutils() {
# If cannot import roman, which comes with docutils, then reinstall
  if ! python -c "import roman" 2>/dev/null; then
    techo "Cannot import roman.  Will rebuild docutils."
    cmd="$BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR docutils,cc4py"
    techo "$cmd"
    $cmd
  fi
  if bilderUnpack docutils; then
# Must first remove any old installations
    cmd="rmall $CONTRIB_DIR/$PYTHON_LIBSUBDIR/python$PYTHON_MAJMIN/site-package/docutils*"
    techo "$cmd"
    $cmd
    techo "Running bilderDuBuild for docutils."
    bilderDuBuild docutils
  fi
}

######################################################################
#
# Test docutils
#
######################################################################

testDocutils() {
  techo "Not testing docutils."
}

######################################################################
#
# Install docutils
#
######################################################################

installDocutils() {
  if bilderDuInstall docutils "$DOCUTILS_ARGS" "$DOCUTILS_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/roman.py*
  fi
  # techo "WARNING: Quitting at end of docutils.sh."; exit
}

