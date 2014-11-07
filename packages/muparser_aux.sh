#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
# To create the tarball, unzip, change first _ to -, tar up.
# The patch is created by
# sed -i.bak -e 's?..\\lib\\??g' -e 's?..\\samples\\??g' build/makefile.vc
# rm build/makefile.vc.bak
# sed -e '/^EXAMPLE/s?/MD?/MT?' -e '/MUPARSER_LIB_CXXFLAGS/s?/MD?/MT?'  <build/makefile.vc >build/makefile.vcmt
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

setMuparserTriggerVars() {
  MUPARSER_BLDRVERSION_STD=${MUPARSER_BLDRVERSION:-"v2_2_3"}
  MUPARSER_BLDRVERSION_EXP=${MUPARSER_BLDRVERSION:-"v2_2_3"}
  if test -z "$MUPARSER_BUILDS"; then
    MUPARSER_BUILDS=ser,sersh
    case `uname` in
      CYGWIN*) MUPARSER_BUILDS="${MUPARSER_BUILDS},sermd";;
    esac
  fi
  MUPARSER_DEPS=cmake
}
setMuparserTriggerVars

######################################################################
#
# Find muparser
#
######################################################################

findMuparser() {
  findContribPackage muparser muparser ser sersh
  local builds="ser sersh"
  if [[ `uname` =~ CYGWIN ]]; then
      builds="$builds sermd"
  fi
  findContribPackage muparser muparser "$builds"

}

