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

XERCESC_DESIRED_BUILDS=${XERCESC_DESIRED_BUILDS:-"ser,sersh"}
computeBuilds xercesc
addPycshBuild xercesc
XERCESC_DEPS=
XERCESC_UMASK=002

######################################################################
#
# Launch xercesc builds.
#
######################################################################

buildXercesc() {
  if bilderUnpack xercesc; then
    for bld in `echo $XERCESC_BUILDS | tr ',' ' '`; do
      if bilderConfig xercesc $bld "--disable-network"; then
        bilderBuild xercesc $bld
      fi
    done
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
  bilderInstallAll xercesc
}

