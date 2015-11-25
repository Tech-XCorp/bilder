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
  VALGRIND_BLDRVERSION_STD=3.10.1
  VALGRIND_BLDRVERSION_EXP=3.11.0
  case `uname` in
    Darwin)
      case `uname -r` in
# Does not build on El Capitan
        15*) VALGRIND_BUILDS=${VALGRIND_BUILDS:-"NONE"};;
# 3.10.1 does not build on Mavericks through Yosemite
        1[3-4]*)
          if $BUILD_EXPERIMENTAL; then
            VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"}
          else
            VALGRIND_BUILDS=${VALGRIND_BUILDS:-"NONE"}
          fi
          ;;
        *) VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"};;
      esac
      ;;
    Linux)
      VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"}
      ;;
  esac
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

