#!/bin/bash
#
# Version and build information for freetype
#
# $Id$
#
######################################################################

######################################################################
#
# Version:
#
######################################################################

FREETYPE_BLDRVERSION_STD=${FREETYPE_BLDRVERSION_STD:-"2.5.0.1"}
FREETYPE_BLDRVERSION_EXP=${FREETYPE_BLDRVERSION_EXP:-"2.5.2"}

######################################################################
#
# Find freetype.
#
# Named args (must come first):
# -s  Look in system directories only
#
######################################################################

findFreetypeRootdir() {
# Parse options
  set -- "$@"
  OPTIND=1
  local SYSTEM_ONLY=false
  while getopts "s" arg; do
    case $arg in
      s) SYSTEM_ONLY=true;;
    esac
  done
  shift $(($OPTIND - 1))
# Look for freetype in contrib
  if ! $SYSTEM_ONLY; then
    local ftdir=
    for bld in sersh sermd; do
      if test -e $CONTRIB_DIR/freetype-$bld; then
        ftdir=`(cd $CONTRIB_DIR/freetype-$bld; pwd -P)`
        break
      fi
    done
  fi
# OSX puts freetype under the X11 location, which may be in more than one place.
  if test -z "$ftdir"; then
    for dir in /opt/homebrew /opt/X11 /usr/X11R6 /usr; do
      if test -d $dir/include/freetype2; then
        ftdir=$dir
        break
      fi
    done
  fi
  if test -n "$ftdir" && [[ `uname` =~ CYGWIN ]]; then
    ftdir=`cygpath -am $ftdir`
  fi
  echo $ftdir
}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# freetype generally needed on windows
case `uname` in
  CYGWIN*) FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"};;
  Darwin | Linux)
# Build on Linux or Darwin only if not found in system
    ftdir=`findFreetypeRootdir -s`
    if test -z "$ftdir"; then
      techo "WARNING: System freetype not found.  Will build if out of date, but better to install system version and more contrib version to prevent incompatibility."
      FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"}
    else
      techo "System freetype found, ftdir = $ftdir, will not build."
    fi
    ;;
esac
computeBuilds freetype
if test -n "$FREETYPE_BUILDS"; then
  addCc4pyBuild freetype
fi
FREETYPE_DEPS=
FREETYPE_UMASK=002

######################################################################
#
# Launch freetype builds.
#
######################################################################

buildFreetype() {

  if ! bilderUnpack freetype; then
    return
  fi

# For cygwin, get zlib version
  local FREETYPE_ADDL_ARGS=
  local FREETYPE_MAKE_ARGS=
  case `uname` in
    CYGWIN*)
      if test -z "$ZLIB_BLDRVERSION"; then
        source $BILDER_DIR/packages/zlib.sh
      fi
      if test -z "$LIBPNG_BLDRVERSION"; then
        source $BILDER_DIR/packages/libpng.sh
      fi
      FREETYPE_SERSH_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/lib/zlib.lib"
      FREETYPE_CC4PY_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-cc4py/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-cc4py/lib/zlib.lib"
      FREETYPE_MAKE_ARGS="-m nmake"
      ;;
  esac

# cc4py always built shared
  if bilderConfig -c freetype cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC -DBUILD_SHARED_LIBS:BOOL=ON $FREETYPE_ADDL_ARGS $FREETYPE_CC4PY_OTHER_ARGS"; then
    bilderBuild $FREETYPE_MAKE_ARGS freetype cc4py
  fi
  if bilderConfig -c freetype sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED_LIBS:BOOL=ON $FREETYPE_ADDL_ARGS $FREETYPE_SERSH_OTHER_ARGS"; then
    bilderBuild $FREETYPE_MAKE_ARGS freetype sersh
  fi

}

######################################################################
#
# Test freetype
#
######################################################################

testFreetype() {
  techo "Not testing freetype."
}

######################################################################
#
# Install freetype
#
######################################################################

installFreetype() {

  for bld in sersh cc4py; do
    if bilderInstall freetype $bld; then
      instdir=$CONTRIB_DIR/freetype-${FREETYPE_BLDRVERSION}-$bld
      case `uname` in
        CYGWIN*) # Correct library names on Windows.  DLLs?
          if test -f $instdir/lib/libfreetype.lib; then
            mv $instdir/lib/libfreetype.lib $instdir/lib/freetype.lib
          elif test -f $instdir/lib/libfreetype.dll.a; then
            mv $instdir/lib/libfreetype.dll.a $instdir/lib/freetype.lib
          fi
          if test -f $instdir/bin/libfreetype.dll; then
            mv $instdir/bin/libfreetype.dll $instdir/bin/freetype.dll
          fi
          ;;
      esac
    fi
  done
  # techo "Quitting at end of freetype.sh."; exit

}

