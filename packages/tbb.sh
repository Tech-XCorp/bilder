#!/bin/bash
#
# Version and build information for cmake
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -d $PROJECT_DIR/tbb; then
  TBB_BUILDS=${TBB_BUILDS:-"sersh"}
fi
TBB_DEPS=${TBB_DEPS:-""}
TBB_UMASK=002

######################################################################
#
# Launch tbb builds.
#
######################################################################

buildTbb() {

  if ! test -d $PROJECT_DIR/tbb; then
    return
  fi

# Configure and build
  if ! bilderPreconfig tbb; then
    return
  fi

# Configure and build
  if bilderConfig tbb sersh "$CMAKE_COMPILERS_SERSH $CMAKE_COMPFLAGS_SERSH $TBB_SERSH_OTHER_ARGS"; then
    bilderBuild tbb sersh
  fi

}

######################################################################
#
# Test cmake
#
######################################################################

testTbb() {
  techo "Not testing tbb."
}

######################################################################
#
# Install cmake
#
######################################################################

installTbb() {
  bilderInstall tbb sersh
}

