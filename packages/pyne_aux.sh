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

setPyneTriggerVars() {
  PYNE_REPO_URL=https://github.com/Tech-XCorp/pyne.git
  PYNE_UPSTREAM_URL=https://github.com/pyne/pyne.git
  PYNE_REPO_BRANCH_STD=develop
  PYNE_REPO_BRANCH_EXP=develop
  PYNE_BUILDS=pycsh
# http://pyne.io/install.html
  PYNE_DEPS=moab,tables,hdf5,cython,scipy,numpy,cmake
# For docs, later...
  # PYNE_DEPS=prettytable,breathe,scisphinx,sphinx,$PYNE_DEPS
}
setPyneTriggerVars

######################################################################
#
# Find pyne
#
######################################################################

findPyne() {
  case `uname` in
    Darwin) addtopathvar DYLD_LIBRARY_PATH $CONTRIB_DIR/lib;;
    Linux) addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/lib;;
  esac
}

