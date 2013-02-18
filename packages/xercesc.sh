#!/bin/bash
#
# Version and build information for xercesc.
#
# $Id$
#
######################################################################

# To repack recent versions
cat >/dev/null <<EOF
tar xzf ../numpkgs/xerces-c-3.1.1.tar.gz
mv xerces-c-3.1.1 xercesc-3.1.1
tar czf ../numpkgs/xercesc-3.1.1.tar.gz xercesc-3.1.1
EOF

######################################################################
#
# Version
#
######################################################################

XERCESC_BLDRVERSION=${XERCESC_BLDRVERSION:-"3.1.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# XERCESC_DESIRED_BUILDS=${XERCESC_DESIRED_BUILDS:-"sersh"}
computeBuilds xercesc
addCc4pyBuild xercesc
XERCESC_DEPS=

######################################################################
#
# Launch xercesc builds.
#
######################################################################

buildXercesc() {
  if bilderUnpack xercesc; then
    if bilderConfig xercesc cc4py; then
      bilderBuild xercesc cc4py
    fi
  fi
}

######################################################################
#
# Test xercesc
#
######################################################################

testXercesc() {
  techo "Not testing xerces."
}

######################################################################
#
# Install xercesc
#
######################################################################

installXercesc() {
  if bilderInstall xercesc cc4py; then
    : # Nothing to do?
  fi
  # techo "WARNING: Quitting at end of xercesc.sh."; cleanup
}

