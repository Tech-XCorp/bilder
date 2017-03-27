#!/bin/sh
######################################################################
#
# @file    vsreader_aux.sh
#
# @brief   Trigger vars and find information for vsreader.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
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

setVsreaderTriggerVars() {
  if test -z "$VSREADER_BUILDS"; then
    VSREADER_BUILDS=${FORPYTHON_SHARED_BUILD}
    if [[ `uname` =~ CYGWIN ]]; then
      VSREADER_BUILDS="${VSREADER_BUILDS},sermd"
    fi
  fi
  VSREADER_DEPS=hdf5
}
setVsreaderTriggerVars

######################################################################
#
# Find vsreader
#
######################################################################

findVsreader() {
  :
}

