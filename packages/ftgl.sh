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
# if [[ `uname` =~ CYGWIN ]]; then
  # FTGL_BUILD=sermd
# else
  FTGL_BUILD=$FORPYTHON_BUILD
# fi
FTGL_BUILDS=${FTGL_BUILDS:-"$FTGL_BUILD"}
FTGL_DEPS=freetype
FTGL_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildFtgl() {
  if ! bilderUnpack ftgl; then
    return
  fi
# Moving to cmake all the time
  local ftconfigtype=-c
  case `uname` in
    CYGWIN*) ftconfigtype=-c
  esac
  local freetype_rootdir=`findFreetypeRootdir`
  if test -z "$freetype_rootdir"; then
    techo "NOTE: [ftgl.sh] Could not find a system freetype. Will look in $CONTRIB_DIR."
    if test -e $CONTRIB_DIR/freetype-sersh; then
      freetype_rootdir=`(cd $CONTRIB_DIR/freetype-sersh; pwd -P)`
    else
      techo "WARNING: [ftgl.sh] Could not find a freetype in $CONTRIB_DIR."
    fi
  fi
  techo "freetype_rootdir = $freetype_rootdir."
  local ftconfigargs=
  local ftconfigenv=
  if test -z "$ftconfigtype"; then
    ftconfigargs="--enable-shared --without-x"
    if test -n "$freetype_rootdir"; then
      ftconfigargs="$ftconfigargs --with-ft-prefix=$freetype_rootdir"
    fi
  else
    ftconfigargs="-DBUILD_SHARED_LIBS:BOOL=TRUE"
    ftconfigenv="FREETYPE_DIR=$freetype_rootdir"
  fi
  if bilderConfig $ftconfigtype ftgl $FTGL_BUILD "$ftconfigargs $FTGL_SER_OTHER_ARGS" "" "$ftconfigenv"; then
    bilderBuild ftgl $FTGL_BUILD "" "ECHO=echo"
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
  bilderInstall ftgl $FTGL_BUILD "" "" "ECHO=echo"
  # techo "Quitting at the end of ftgl.sh."; exit
}

######################################################################
#
# Find ftgl
#
######################################################################

findFtglRootdir() {
  local ftgldir=
  for bld in sersh sermd; do
    if test -e $CONTRIB_DIR/ftgl-$bld; then
      ftgldir=`(cd $CONTRIB_DIR/ftgl-$bld; pwd -P)`
      break
    fi
  done
# OSX puts ftgl under the X11 location, which may be in more than one place.
  for dir in /opt/X11 /usr/X11R6 /opt/homebrew; do
    if test -d $dir/include/FTGL; then
      ftgldir=$dir
      break
    fi
  done
  if test -n "$ftgldir" && [[ `uname` =~ CYGWIN ]]; then
    ftgldir=`cygpath -am $ftgldir`
  fi
  echo $ftgldir
}

