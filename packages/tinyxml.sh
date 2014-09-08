#!/bin/bash
#
# Version and build information for TinyXML
#
# $Id$
#
######################################################################

TINYXML_BLDRVERSION=${TINYXML_BLDRVERSION:-"2.6.2"}
TINYXML_BUILDS=${TINYXML_BUILDS:-"ser"}
TINYXML_DEPS=
TINYXML_UMASK=002

buildTinyXml() {
  TINYXML_CONFIG_METHOD=none

  if bilderUnpack tinyxml; then
    for bld in ${TINYXML_BUILDS}; do
      bilderBuild tinyxml $bld
    done
  fi
}

testTinyXml() {
  techo "Not testing TinyXML."
}

installTinyXml() {
  for bld in ${TINYXML_BUILDS}; do
    bilderInstall tinyxml ${bld}
  done
}
