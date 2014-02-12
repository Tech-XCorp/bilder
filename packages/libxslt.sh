#!/bin/bash
#
# Version and build information for libxlst
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LIBXSLT_BLDRVERSION=${LIBXSLT_BLDRVERSION:-"1.1.28"}

######################################################################
#
# Other values
#
######################################################################

LIBXSLT_BUILDS=${LIBXSLT_BUILDS:-"sersh"}
LIBXSLT_DEPS=m4

######################################################################
#
# Launch libxslt builds.
#
######################################################################

buildLibxslt() {
  if bilderUnpack libxslt; then
    # libxslt needs shared libraries of libxml
    LIBXML4LIBXSLT=${LIBXML4LIBXSLT:-"$CONTRIB_DIR/libxml2-sersh"}
    if test -d "$LIBXML4LIBXSLT"; then
      local libxmlflag="--with-libxml-prefix=$LIBXML4LIBXSLT"
    else
      techo "Not building libxslt because could not find libxml2"
      return 1
    fi
    if bilderConfig libxslt sersh $libxmlflag; then
      bilderBuild libxslt sersh
    fi
  fi
}

######################################################################
#
# Test libxslt
#
######################################################################

testLibxslt() {
  techo "Not testing libxslt."
}

######################################################################
#
# Install libxslt
#
######################################################################

installLibxslt() {
  bilderInstall libxslt sersh
}

