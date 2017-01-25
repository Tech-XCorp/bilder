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
FACETSIFC_DEPS=cmake,${MPI_BUILD},m4
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
    bilderConfig -c facetsifc ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $FACETSIFC_SER_OTHER_ARGS"
    bilderBuild facetsifc ser $1
  fi
  if test $res = 0; then
    bilderConfig -c facetsifc par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $FACETSIFC_SER_OTHER_ARGS"
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
  bilderInstall facetsifc par facetsifc
}

######################################################################
#
# Find Facets
#
######################################################################

findFacetsifc() {
  local srchbuilds="ser par"
  findPackage Facetsifc facetsifc "$BLDR_INSTALL_DIR" $srchbuilds
  techo
# Find cmake configuration directories
  for bld in $srcbuilds; do
    local blddirvar=`genbashvar FACETSIFC_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/lib/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar FACETSIFC_${bld}`_CMAKE_LIBDIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar FACETSIFC_${bld}`_CMAKE_LIBDIR_ARG
      eval $varname="\"-DFacetsIfc_ROOT_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}


