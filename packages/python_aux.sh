#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setPythonTriggerVars() {
  PYTHON_BLDRVERSION_STD=2.7.3
  PYTHON_BLDRVERSION_EXP=2.7.9
  case `uname` in
    CYGWIN*) if test $VISUALSTUDIO_VERSION = 12; then
               PYTHON_BLDRVERSION_STD=2.7.9.win64
	       PYTHON_BUILDS=$FORPYTHON_SHARED_BUILD
             fi
             ;;
          *) PYTHON_DEPS=chrpath,sqlite,bzip2
             ;;
  esac
  computeVersion Python
# Export so available to setinstald.sh
  export PYTHON_BLDRVERSION
# Needed?
  # PYTHON_MAJMIN=`echo $PYTHON_BLDRVERSION | sed 's/\([0-9]*\.[0-9]*\).*/\1/'`
  if test `uname` = Linux; then
    PYTHON_BUILDS=${PYTHON_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  fi
}

setPythonTriggerVars

######################################################################
#
# Find python
#
######################################################################

findPython() {
  source $BILDER_DIR/bilderpy.sh
  addtopathvar PATH $CONTRIB_DIR/python/bin
  if test `uname` = Linux; then
    addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/python/lib
  fi
}

