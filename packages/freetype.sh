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

FREETYPE_BLDRVERSION=${FREETYPE_BLDRVERSION:-"2.4.8-r11"}

######################################################################
#
# Other values
#
######################################################################

# freetype generally needed on windows
if test -z "$FREETYPE_BUILDS"; then
  if [[ `uname` =~ CYGWIN ]]; then
    FREETYPE_BUILDS=cc4py
  fi
fi
FREETYPE_DEPS=
FREETYPE_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

# addtopathvar PATH $CONTRIB_DIR/freetype/bin

######################################################################
#
# Launch freetype builds.
#
######################################################################

buildFreetype() {

  if bilderUnpack freetype; then

# For cygwin, get zlib version
    local FREETYPE_PYC_ADDL_ARGS=
    local FREETYPE_PYC_MAKE_ARGS=
    case `uname` in
      CYGWIN*)
        if test -z "$ZLIB_BLDRVERSION"; then
          source $BILDER_DIR/packages/zlib.sh
        fi
        if test -z "$LIBPNG_BLDRVERSION"; then
          source $BILDER_DIR/packages/libpng.sh
        fi
        FREETYPE_PYC_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-cc4py/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-cc4py/lib/zlib.lib"
        FREETYPE_PYC_MAKE_ARGS="-m nmake"
        ;;
    esac

# cc4py always built shared
    if bilderConfig -c freetype cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC -DBUILD_SHARED_LIBS:BOOL=ON $FREETYPE_PYC_ADDL_ARGS $FREETYPE_PYC_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
      # bilderBuild -m nmake freetype cc4py "$DISTUTILS_NOLV_ENV"
      bilderBuild $FREETYPE_PYC_MAKE_ARGS freetype cc4py "" "$DISTUTILS_NOLV_ENV"
    fi

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

  if bilderInstall freetype cc4py; then
    instdir=$CONTRIB_DIR/freetype-${FREETYPE_BLDRVERSION}-cc4py
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
  # techo "Quitting at end of freetype.sh."; exit

}

