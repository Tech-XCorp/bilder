#!/bin/bash
#
# Version and build information for facetsifc
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

FACETSIFC_BLDRVERSION=${FACETSIFC_BLDRVERSION:-"1.0.0-r55"}

######################################################################
#
# Other values
#
######################################################################

FACETSIFC_BUILDS=${FACETSIFC_BUILDS:-"ser,par"}
# JRC: Does facetsifc depend on babel?  Why?
FACETSIFC_DEPS=automake,autoconf,m4
FACETSIFC_UMASK=002

######################################################################
#
# Launch facetsifc builds.
#
######################################################################

buildFacetsifc() {
# Check for svn repo or package
  if test -d $PROJECT_DIR/facetsifc; then
    getVersion facetsifc
    bilderPreconfig facetsifc
    res=$?
  else
    bilderUnpack facetsifc
    res=$?
  fi
  if test $res = 0; then
    bilderConfig -c facetsifc ser "$CMAKE_COMPILERS_SER $FACETSIFC_SER_OTHER_ARGS"
    bilderBuild facetsifc ser $1
  fi
  if test $res = 0; then
    bilderConfig -c facetsifc par "$CMAKE_COMPILERS_PAR $FACETSIFC_SER_OTHER_ARGS"
    bilderBuild facetsifc par $1
  fi

}

######################################################################
#
# Test FacetsIfc
#
######################################################################

testFacetsifc() {
  techo "Not testing facetsifc."
}

######################################################################
#
# Install FacetsIfc
#
######################################################################

installFacetsifc() {
  bilderInstall facetsifc ser facetsifc
}

