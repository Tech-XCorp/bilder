#!/bin/sh
######################################################################
#
# @file    bzip2_aux.sh
#
# @brief   Trigger vars and find information for bzip2.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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

setBzip2TriggerVars() {
  BZIP2_BLDRVERSION=${BZIP2_BLDRVERSION:-"1.0.6"}
  if test -z "$BZIP2_BUILDS"; then
    if [[ `uname` =~ CYGWIN ]] || ! which bunzip2 1>/dev/null 2>&1; then
      BZIP2_BUILDS=ser
    fi
  fi
  BZIP2_DEPS=
}
setBzip2TriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

findBzip2() {
  if [[ `uname` =~ CYGWIN ]]; then
    findContribPackage bzip2 bzip2 ser sermd
    findPycshDir bzip2
    addtopathvar PATH $CONTRIB_DIR/bzip2/bin
  fi
}

