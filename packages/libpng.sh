#!/bin/bash
#
# Build information for libpng
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in libpng_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/libpng_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLibpngNonTriggerVars() {
  LIBPNG_UMASK=002
}
setLibpngNonTriggerVars

######################################################################
#
# Launch libpng builds.
#
######################################################################

buildLibpng() {

  if ! bilderUnpack libpng; then
    return
  fi

# For cygwin, get zlib version
  local LIBPNG_SERSH_ADDL_ARGS=
  local LIBPNG_SERMD_ADDL_ARGS=
  case `uname` in
    CYGWIN*)
# on Win64, sersh exists, but pycsh does not
      LIBPNG_SERMD_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sermd/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sermd/lib/zlib.lib"
      LIBPNG_SERSH_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/lib/zlib.lib"
      if $IS_MINGW; then
        LIBPNG_SERSH_ADDL_ARGS="$LIBPNG_SERSH_ADDL_ARGS -DPNG_STATIC:BOOL=FALSE"
      fi
      ;;
  esac

  if bilderConfig -c libpng sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF -DPNG_STATIC:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $LIBPNG_SERMD_ADDL_ARGS $LIBPNG_SERMD_OTHER_ARGS" "" ""; then
    bilderBuild libpng sermd "" ""
  fi
  if bilderConfig -c libpng sersh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $LIBPNG_SERSH_ADDL_ARGS $LIBPNG_SERSH_OTHER_ARGS" "" ""; then
    bilderBuild libpng sersh "" ""
  fi
  if bilderConfig -c libpng pycsh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $LIBPNG_SERSH_ADDL_ARGS $LIBPNG_PYCSH_OTHER_ARGS" "" ""; then
    bilderBuild libpng pycsh "" ""
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

  for bld in `echo $LIBPNG_BUILDS | tr ',' ' '`; do
    if bilderInstall libpng $bld; then
      local instdir=$CONTRIB_DIR/libpng-${LIBPNG_BLDRVERSION}-$bld
      local LIBPNG_MAJMIN=`echo $LIBPNG_BLDRVERSION | sed -e 's/\.[0-9]*$//' -e 's/\.//g'`
      case `uname` in
        CYGWIN*) # Correct library names on Windows.  DLLs?
          if test -f $instdir/lib/libpng${LIBPNG_MAJMIN}.lib; then
            cp $instdir/lib/libpng${LIBPNG_MAJMIN}.lib $instdir/lib/libpng.lib
          elif test -f $instdir/lib/libpng${LIBPNG_MAJMIN}.dll.a; then
            cp $instdir/lib/libpng${LIBPNG_MAJMIN}.dll.a $instdir/lib/libpng.lib
          fi
          if test -f $instdir/lib/libpng${LIBPNG_MAJMIN}_static.lib; then
            cp $instdir/lib/libpng${LIBPNG_MAJMIN}_static.lib $instdir/lib/libpng_static.lib
          fi
          if test -f $instdir/bin/libpng${LIBPNG_MAJMIN}.dll; then
            cp $instdir/bin/libpng${LIBPNG_MAJMIN}.dll $instdir/bin/libpng.dll
          fi
          ;;
      esac
    fi
  done

}

