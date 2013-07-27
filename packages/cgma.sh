#!/bin/bash
#
# Version and build information for cgma
#
# $Id$
#
######################################################################

# For now, just recording what to get here
cat >/dev/null <<EOF
svn co https://svn.mcs.anl.gov/repos/ITAPS/cgm/trunk cgma
cd cgma
autoreconf -fi
mkdir ser && cd ser
../configure \
  --prefix=/contrib/cgma-12.2.0 \
  --with-occ=/internal/oce \
  --without-cubit
make
EOF

######################################################################
#
# Version
#
######################################################################

CGMA_BLDRVERSION=${CGMA_BLDRVERSION:-"12.3.0pre"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

CGMA_BUILDS=${CGMA_BUILDS:-"ser"}
# CGMA_DEPS=oce
CGMA_UMASK=002

# addtopathvar PATH $CONTRIB_DIR/cgma/bin

######################################################################
#
# Launch cgma builds.
#
######################################################################

buildCgma() {

# Determine whether to use cmake
  CGMA_USE_CMAKE=${CGMA_USE_CMAKE:-"false"}
  if $CGMA_USE_CMAKE; then
    CGMA_CMAKE_ARG=-c
  fi

# Preconfig or unpack
  if test -d $PROJECT_DIR/cgma; then
    getVersion cgma
    if ! bilderPreconfig $CGMA_CMAKE_ARG cgma; then
      return 1
    fi
  else
    if ! bilderUnpack cgma; then
      return 1
    fi
  fi

# Seek oce in one of many places
  local CGMA_OCE_DIR
  for i in volatile internal contrib; do
    if test -e /$i/oce; then
      CGMA_OCE_DIR=`(cd /$i/oce; pwd -P)`
      break
    fi
  done

# Set cgma configure args
  if $CGMA_USE_CMAKE; then
    CGMA_ALL_ADDL_ARGS=
  else
    CGMA_ALL_ADDL_ARGS="--without-cubit"
    if test -n "$CGMA_OCE_DIR"; then
      CGMA_ALL_ADDL_ARGS="$CGMA_ALL_ADDL_ARGS --with-occ=$CGMA_OCE_DIR"
    fi
  fi

# Configure and build
  if bilderConfig $CGMA_CMAKE_ARG cgma ser; then
    bilderBuild cgma ser
  fi

}

######################################################################
#
# Test cgma
#
######################################################################

testCgma() {
  techo "Not testing cgma."
}

######################################################################
#
# Install cgma
#
######################################################################

installCgma() {
  if bilderInstall cgma ser; then
    : # Fix rpaths, library references here.
  fi
}

