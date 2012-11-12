#!/bin/bash
#
# Version and build information for xercesc.
#
# $Id: xercesc.sh 6127 2012-05-27 11:57:06Z cary $
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
# Other values
#
######################################################################

XERCESC_BUILDS=${XERCESC_BUILDS:-"ser"}
XERCESC_DEPS=

######################################################################
#
# Launch xercesc builds.
#
######################################################################

buildXercesc() {
  if bilderUnpack xercesc; then
    if bilderConfig xercesc ser; then
      bilderBuild xercesc ser
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
  if bilderInstall xercesc ser; then
    : # Nothing to do?
  fi
  # techo "WARNING: Quitting at end of xercesc.sh."; cleanup
}

