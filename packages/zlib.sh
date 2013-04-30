#!/bin/bash
#
# Version and build information for zlib
#
# $Id$
#
######################################################################

######################################################################
#
# Version:
#
# Look at http://gitorious.org/zlib/ for cmake progress
#
######################################################################

ZLIB_BLDRVERSION=${ZLIB_BLDRVERSION:-"1.2.6"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$ZLIB_BUILDS"; then
# zlib needed only on windows
  if [[ `uname` =~ CYGWIN ]]; then
    ZLIB_DESIRED_BUILDS=${ZLIB_DESIRED_BUILDS:-"ser,sersh,sermd"}
    computeBuilds zlib
    addCc4pyBuild zlib
  fi
fi
ZLIB_DEPS=cmake
ZLIB_UMASK=002
# This is needed for Windows to get the right dll
addtopathvar PATH $CONTRIB_DIR/zlib-${FORPYTHON_BUILD}/bin

######################################################################
#
# Launch zlib builds.
#
######################################################################

buildZlib() {

# Make sure libs installed correctly.  Put into place on 20111225.
  if [[ `uname` =~ CYGWIN ]]; then
    if ! test -f $CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-ser/lib/z.lib; then
      $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR zlib,ser
    fi
  fi

  if bilderUnpack zlib; then

# The zlib package has this, but it needs to be removed
    cmd="rm -f $BUILD_DIR/zlib-${ZLIB_BLDRVERSION}/zconf.h"
    techo "$cmd"
    $cmd

# MINGW_RC_COMPILER_ARG is empty except where needed
# ser for hdf5
    if bilderConfig -c zlib ser "-DBUILD_SHARED_LIBS:BOOL=OFF $MINGW_RC_COMPILER_ARG $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $ZLIB_SER_OTHER_ARGS"; then
      bilderBuild zlib ser
    fi

# sersh never used.  Keeping for legacy
    if bilderConfig -c zlib sersh "-DBUILD_SHARED_LIBS:BOOL=ON $MINGW_RC_COMPILER_ARG $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $ZLIB_SERSH_OTHER_ARGS"; then
      bilderBuild zlib sersh
    fi

    if bilderConfig -c zlib sermd "-DBUILD_SHARED_LIBS:BOOL=OFF -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $MINGW_RC_COMPILER_ARG $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $ZLIB_SER_OTHER_ARGS"; then
      bilderBuild zlib sermd
    fi
  fi

}

######################################################################
#
# Test zlib
#
######################################################################

testZlib() {
  techo "Not testing zlib."
}

######################################################################
#
# Install zlib
#
######################################################################

installZlib() {

  local instdir
# Correct ser lib to static name on CYGWIN
  for build in ser sermd; do
    if bilderInstall zlib $build; then
      instdir=$CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-$build
      techo "instdir = $instdir."
      case `uname` in
        CYGWIN*) # Correct library names on Windows
          unset oldlib
          if test -f $instdir/lib/libzlib.a; then
            oldlib=libzlib.a
          elif test -f $instdir/lib/zlib.lib; then
            oldlib=zlib.lib
          fi
# libpng needs zlib.lib
# matplotlib needs z.lib
          if test -n "$oldlib"; then
            cmd="cp $instdir/lib/$oldlib $instdir/lib/z.lib"
            techo "$cmd"
            $cmd
          fi
          ;;
      esac
    fi
  done
  if bilderInstall zlib sersh; then
    instdir=$CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh
    techo "instdir = $instdir."
    case `uname` in
      CYGWIN*) # Correct library names on Windows
        unset oldlib
        if test -f $instdir/lib/libzlib.dll.a; then
          oldlib=libzlib.dll.a
        elif test -f $instdir/lib/zlib.lib; then
          oldlib=zlib.lib
        fi
# libpng needs zlib.lib
# matplotlib needs z.lib
        if test -n "$oldlib"; then
          cmd="cp $instdir/lib/$oldlib $instdir/lib/z.lib"
          techo "$cmd"
          $cmd
          if test $oldlib != zlib.lib; then
            cmd="cp $instdir/lib/$oldlib $instdir/lib/zlib.lib"
            techo "$cmd"
            $cmd
          fi
        fi
        unset olddll
        if test -f $instdir/bin/libzlib1.dll; then
          olddll=libzlib1.dll
        fi
        if test -n "$olddll"; then
          cmd="cp $instdir/bin/$olddll $instdir/bin/zlib1.dll"
          techo "$cmd"
          $cmd
        fi
        ;;
    esac
  fi
  # techo "Quitting at end of zlib.sh."; exit

}

