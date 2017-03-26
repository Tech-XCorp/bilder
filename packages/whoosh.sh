#!/bin/sh
######################################################################
#
# @file    whoosh.sh
#
# @brief   Version and build information for whoosh.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

WHOOSH_BLDRVERSION_STD=${WHOOSH_BLDRVERSION_STD:-"2.7.4"}
WHOOSH_BLDRVERSION=${WHOOSH_BLDRVERSION_STD:-"2.7.4"}

######################################################################
#
# Builds and deps
#
######################################################################

WHOOSH_BUILDS=${WHOOSH_BUILDS:-"pycsh"}
WHOOSH_DEPS=

######################################################################
#
# Launch whoosh builds.
#
######################################################################

buildWhoosh() {
  if ! bilderUnpack whoosh; then
W   return
  fi
  bilderDuBuild whoosh "$WHOOSH_ARGS" "$WHOOSH_ENV"
}

######################################################################
#
# Test whoosh
#
######################################################################

testWhoosh() {
  techo "Not testing whoosh."
}

######################################################################
#
# Install whoosh
#
######################################################################

installWhoosh() {
  case `uname` in
    CYGWIN*)
      bilderDuInstall -n whoosh "$WHOOSH_ARGS" "$WHOOSH_ENV"
      ;;
    *)
      bilderDuInstall -r whoosh whoosh "$WHOOSH_ARGS" "$WHOOSH_ENV"
      ;;
  esac
}
