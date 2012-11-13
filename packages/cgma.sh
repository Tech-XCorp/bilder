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
# Other values
#
######################################################################

CGMA_BUILDS=${CGMA_BUILDS:-"NONE"}
CGMA_DEPS=oce
CGMA_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

# addtopathvar PATH $CONTRIB_DIR/cgma/bin

######################################################################
#
# Launch cgma builds.
#
######################################################################

buildCgmaAT() {
# Configure and build
  if bilderUnpack cgma; then
# Seek oce in one of many places
    local i
    for i in volatile internal contrib; do
      if test -e /$i/oce; then
        break
      fi
    done
    if ! test -e /$i/oce; then
      techo "WARNING: cannot find oce."
      return 1
    elif ! test $i = contrib; then
      techo "WARNING: oce found in /$i."
    fi
# Configure and builds
    if bilderConfig cgma ser "--with-occ=/$i/oce --without-cubit"; then
      bilderBuild cgma ser
    fi
  fi
}

# This appears to be just starting
buildCgmaCM() {
# Configure and build
  if bilderUnpack cgma; then
    if bilderConfig -c cgma ser; then
      bilderBuild cgma ser
    fi
  fi
}

buildCgma() {
  buildCgmaAT
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
  # techo "WARNING: Quitting at end of cgma.sh."; exit
}

