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

mydir=`dirname $BASH_SOURCE`
source $mydir/freetype_aux.sh

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setFreetypeGlobalVars() {
# freetype generally needed on windows
  case `uname` in
    CYGWIN*)
      findFreetype
      FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"}
      ;;
    Darwin | Linux)
# Build on Linux or Darwin only if not found in system
      findFreetype -s
      if test -z "$FREETYPE_CC4PY_DIR"; then
        techo "WARNING: System freetype not found.  Will build if out of date, but better to install system version and more contrib version to prevent incompatibility."
        FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"}
      else
        techo "System freetype found in $FREETYPE_CC4PY_DIR, will not build."
      fi
      ;;
  esac
  computeBuilds freetype
  if test -n "$FREETYPE_BUILDS"; then
    addCc4pyBuild freetype
  fi
  FREETYPE_DEPS=
  FREETYPE_UMASK=002
}
setFreetypeGlobalVars

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

# Find freetype
  findFreetype

}

