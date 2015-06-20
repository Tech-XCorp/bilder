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
  PYTHON_BLDRVERSION_EXP=2.7.10
  case `uname` in
    CYGWIN*)
      if test "$VISUALSTUDIO_VERSION" -ge 12; then
        PYTHON_REPO_URL=https://github.com/Tech-XCorp/pythoncm.git
        PYTHON_REPO_BRANCH_STD=master
        PYTHON_REPO_BRANCH_EXP=master
        PYTHON_UPSTREAM_URL=https://github.com/davidsansome/python-cmake-buildsystem.git
        PYTHON_UPSTREAM_BRANCH_STD=master
        PYTHON_UPSTREAM_BRANCH_EXP=master
        PYTHON_BUILDS=$FORPYTHON_SHARED_BUILD
        # PYTHON_DEPS=sqlite,bzip2,zlib
        PYTHON_DEPS=bzip2,zlib,cmake
      fi
      ;;
    Linux)
      PYTHON_BUILDS=${PYTHON_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
      PYTHON_DEPS=chrpath,sqlite,bzip2
      ;;
  esac
  computeVersion Python
# Export so available to setinstald.sh
  export PYTHON_BLDRVERSION
}

setPythonTriggerVars

######################################################################
#
# Find python
#
######################################################################

findPython() {
  addtopathvar PATH $CONTRIB_DIR/python/bin
  source $BILDER_DIR/bilderpy.sh
  if test `uname` = Linux; then
    addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/python/lib
  fi
}

