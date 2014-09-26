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

setValgrindTriggerVars() {
  VALGRIND_BLDRVERSION_STD=3.9.0
  VALGRIND_BLDRVERSION_EXP=3.9.0
  if [[ `uname` =~ Linux ]]; then
    VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"}
  fi
  if [[ `uname` =~ Darwin ]]; then
    case `uname -r` in
      1[3-9]*)
	VALGRIND_BLDRVERSION_STD=3.10.0
	VALGRIND_BLDRVERSION_EXP=3.10.0
	VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"}
	;;
    esac
  fi
  VALGRIND_DEPS=
}
setValgrindTriggerVars

######################################################################
#
# Find valgrind
#
######################################################################

findValgrind() {
  addtopathvar PATH $CONTRIB_DIR/valgrind/bin
}

