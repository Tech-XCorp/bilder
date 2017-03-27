#!/bin/sh
######################################################################
#
# @file    subversion.sh
#
# @brief   Version and build information for subversion.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SUBVERSION_BLDRVERSION=${SUBVERSION_BLDRVERSION:-"1.6.17"}

######################################################################
#
# Other values
#
######################################################################

# For Jenkins, need subversion 1.6
if test -z "$SUBVERSION_BUILDS"; then
  if [[ `svn --version --quiet` =~ '1.7' ]]; then
    SUBVERSION_BUILDS="ser"
  fi
fi
SUBVERSION_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/subversion/bin

######################################################################
#
# Launch subversion builds.
#
######################################################################

buildSubversion() {
  if bilderUnpack subversion; then
# Must use cygwin python
    if [[ `uname` =~ CYGWIN ]]; then
      bilderConfig subversion ser "--disable-shared --enable-static" "" "PATH=\"/usr/bin:$PATH\""
      res=$?
    else
      bilderConfig subversion ser "--enable-all-static"
      res=$?
    fi
    if test $res = 0; then
      bilderBuild -m make subversion ser
    fi
  fi
}

######################################################################
#
# Test subversion
#
######################################################################

testSubversion() {
  techo "Not testing subversion."
}

######################################################################
#
# Install subversion
#
######################################################################

installSubversion() {
  if bilderInstall -m make subversion ser; then
    :
    techo "WARNING: If subversion failed to install, make sure that"
    techo "WARNING: libneon-devel openssl-devel libsqlite3-devel libuuid-devel openldap-devel"
    techo "WARNING: are all installed."
  fi
  techo exit; exit
}

