#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
# To create the tarball, unzip, change first _ to -, tar up.
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
  MUPARSER_BLDRVERSION_STD=${MUPARSER_BLDRVERSION:-"v134"}
  MUPARSER_BLDRVERSION_EXP=${MUPARSER_BLDRVERSION:-"v2_2_3"}
  if test -z "$MUPARSER_BUILDS"; then
    MUPARSER_BUILDS=ser
    case `uname` in
      CYGWIN*) MUPARSER_BUILDS="${MUPARSER_BUILDS},sermd";;
      Darwin | Linux) MUPARSER_BUILDS="${MUPARSER_BUILDS},sersh";;
    esac
  fi
  MUPARSER_DEPS=m4
}
setMuparserTriggerVars

######################################################################
#
# Find muparser
#
######################################################################

findMuparser() {
  findContribPackage muparser muparser ser
}

