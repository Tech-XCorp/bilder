#!/bin/bash
#
# Version and build information for whooshindex
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

WHOOSHINDEX_BLDRVERSION_STD=${WHOOSHINDEX_BLDRVERSION_STD:-"0.1"}
WHOOSHINDEX_BLDRVERSION=${WHOOSHINDEX_BLDRVERSION_STD:-"0.1"}

######################################################################
#
# Builds and deps
#
######################################################################

WHOOSHINDEX_BUILDS=${WHOOSHINDEX_BUILDS:-"pycsh"}
WHOOSHINDEX_DEPS=whoosh,sphinx

######################################################################
#
# Launch whoosh builds.
#
######################################################################

buildWhooshindex() {
  if ! bilderUnpack whooshindex; then
W   return
  fi
  bilderDuBuild whooshindex "$WHOOSHINDEX_ARGS" "$WHOOSHINDEX_ENV"
}

######################################################################
#
# Test whooshindex
#
######################################################################

testWhooshindex() {
  techo "Not testing whooshindex."
}

######################################################################
#
# Install whooshindex
#
######################################################################

installWhooshindex() {
  case `uname` in
    CYGWIN*)
      bilderDuInstall -n whooshindex "$WHOOSHINDEX_ARGS" "$WHOOSHINDEX_ENV"
      ;;
    *)
      bilderDuInstall -r whooshindex whooshindex "$WHOOSHINDEX_ARGS" "$WHOOSHINDEX_ENV"
      ;;
  esac
}
