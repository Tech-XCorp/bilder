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
# Other values
#
######################################################################

FTGL_BUILDS=${FTGL_BUILDS:-"ser"}
FTGL_DEPS=
FTGL_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

# addtopathvar PATH $CONTRIB_DIR/autotools/bin

######################################################################
#
# Launch ftgl builds.
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
    if bilderConfig ftgl ser "$ftargs $FTGL_SER_OTHER_ARGS"; then
      bilderBuild -m make ftgl ser "" "ECHO=echo"
    fi
  fi
}

######################################################################
#
# Test ftgl
#
######################################################################

testFtgl() {
  techo "Not testing ftgl."
}

######################################################################
#
# Install ftgl
#
######################################################################

installFtgl() {
  bilderInstall -m make ftgl ser "" "" "ECHO=echo"
  # techo "Quitting at the end of ftgl.sh."; exit
}

