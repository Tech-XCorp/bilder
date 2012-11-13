#!/bin/bash
#
# Version and build information for libpng
#
# $Id$
#
######################################################################

######################################################################
#
# Version:
#
# Look at http://gitorious.org/libpng/ for cmake progress
#
######################################################################

LIBPNG_BLDRVERSION=${LIBPNG_BLDRVERSION:-"1.5.7"}

######################################################################
#
# Other values
#
######################################################################

# libpng generally needed on windows
if test -z "$LIBPNG_BUILDS"; then
  if [[ `uname` =~ CYGWIN ]]; then
    LIBPNG_BUILDS=cc4py
  fi
fi
LIBPNG_DEPS=zlib
LIBPNG_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

# addtopathvar PATH $CONTRIB_DIR/libpng/bin

######################################################################
#
# Launch libpng builds.
#
######################################################################

buildLibpng() {

  if bilderUnpack libpng; then

# For cygwin, get zlib version
    local LIBPNG_PYC_ADDL_ARGS=
    case `uname` in
      CYGWIN*)
        if test -z "$ZLIB_BLDRVERSION"; then
          source $BILDER_DIR/packages/zlib.sh
        fi
# on Win64, sersh exists, but cc4py does not
        LIBPNG_PYC_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/lib/zlib.lib"
        if $IS_MINGW; then
          LIBPNG_PYC_ADDL_ARGS="$LIBPNG_PYC_ADDL_ARGS -DPNG_STATIC:BOOL=FALSE"
        fi
        ;;
    esac

# cc4py always built shared
    if bilderConfig -c libpng cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC -DBUILD_SHARED_LIBS:BOOL=ON $LIBPNG_PYC_ADDL_ARGS $LIBPNG_PYC_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
      bilderBuild libpng cc4py "" "$DISTUTILS_NOLV_ENV"
    fi

  fi

}

######################################################################
#
# Test libpng
#
######################################################################

testLibpng() {
  techo "Not testing libpng."
}

######################################################################
#
# Install libpng
#
######################################################################

installLibpng() {

  if bilderInstall libpng cc4py; then
    instdir=$CONTRIB_DIR/libpng-${LIBPNG_BLDRVERSION}-cc4py
    case `uname` in
      CYGWIN*) # Correct library names on Windows.  DLLs?
        if test -f $instdir/lib/libpng15.lib; then
          mv $instdir/lib/libpng15.lib $instdir/lib/png.lib
        elif test -f $instdir/lib/libpng15.dll.a; then
          mv $instdir/lib/libpng15.dll.a $instdir/lib/png.lib
        fi
        if test -f $instdir/bin/libpng15.dll; then
          mv $instdir/bin/libpng15.dll $instdir/bin/png.dll
        fi
        ;;
    esac
  fi
  # techo "Quitting at end of libpng.sh."; exit

}

