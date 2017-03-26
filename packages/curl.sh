#!/bin/sh
######################################################################
#
# @file    curl.sh
#
# @brief   Version and build information for curl.
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

CURL_BLDRVERSION=${CURL_BLDRVERSION:-"7.19.7"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$CURL_BUILDS" && ! which curl-config 1>/dev/null 2>&1; then
  CURL_BUILDS=ser
fi
CURL_DEPS=
CURL_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/curl/bin

######################################################################
#
# Launch curl builds.
#
######################################################################

buildCurl() {
  if bilderUnpack curl; then
    if bilderConfig curl ser; then
      bilderBuild -m make curl ser
    fi
  fi
}

######################################################################
#
# Test curl
#
######################################################################

testCurl() {
  techo "Not testing curl."
}

######################################################################
#
# Install curl
#
######################################################################

installCurl() {
  if bilderInstall -m make curl ser; then
    (cd $CONTRIB_DIR/bin; ln -sf ../curl/bin/curl* .)
  fi
}

