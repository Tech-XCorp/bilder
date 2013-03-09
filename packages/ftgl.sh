#!/bin/bash
#
# Version and build information for ftgl
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

FTGL_BLDRVERSION=${FTGL_BLDRVERSION:-"2.1.3-rc5"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Only the python build needed.
FTGL_BUILDS=`getPythonBuild`
FTGL_BUILD=`getPythonBuild`
FTGL_DEPS=
FTGL_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildFtgl() {
  if bilderUnpack ftgl; then
    local ftargs=
# OSX puts freetype under the X11 location, which may be in more than
# one place.
    for dir in /opt/X11 /usr/X11R6; do
      if test -d $dir/include/freetype2; then
        ftargs="--with-ft-prefix=$dir"
        break
      fi
    done
    if bilderConfig ftgl $FTGL_BUILD "$ftargs $FTGL_SER_OTHER_ARGS"; then
      bilderBuild -m make ftgl $FTGL_BUILD "" "ECHO=echo"
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testFtgl() {
  techo "Not testing ftgl."
}

######################################################################
#
# Install
#
######################################################################

installFtgl() {
  bilderInstall -m make ftgl $FTGL_BUILD "" "" "ECHO=echo"
  # techo "Quitting at the end of ftgl.sh."; exit
}

