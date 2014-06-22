#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setLibpngTriggerVars() {
  LIBPNG_BLDRVERSION=${LIBPNG_BLDRVERSION:-"1.5.7"}
  if test -z "$LIBPNG_DESIRED_BUILDS"; then
    case `uname` in
      CYGWIN*)
        LIBPNG_DESIRED_BUILDS=sersh
        LIBPNG_DIRS=$CONTRIB_DIR/libpng-${LIBPNG_BLDRVERSION}-sersh
        ;;
      Darwin)
        LIBPNG_DIRS="/opt/homebrew/opt/freetype /opt/X11 /usr/X11R6 /usr/X11"
        if test -e $CONTRIB_DIR/libpng-sersh; then
          LIBPNG_DESIRED_BUILDS=sersh
        else
          LIBPNG_SERSH_DIR=
          for dir in $LIBPNG_DIRS; do
            if test -e $dir/lib/libpng.dylib; then
              LIBPNG_SERSH_DIR=`(cd $dir; pwd -P)`
              break
            fi
          done
        fi
        if test -n "$LIBPNG_SERSH_DIR"; then
          LIBPNG_DIRS="$CONTRIB_DIR/libpng-sersh"
        fi
        ;;
    esac
  fi
  computeBuilds libpng
# No need to add cc4py build, as pure C
  #  addCc4pyBuild libpng
  LIBPNG_DEPS=zlib,cmake

  if test -z "$LIBPNG_SERSH_DIR"; then
    CMAKE_LIBPNG_DIR_ARG="-DPng_ROOT_DIR:PATH='$LIBPNG_SERSH_DIR'"
    CONFIG_LIBPNG_DIR_ARG="--with-png-dir='$LIBPNG_SERSH_DIR'"
    printvar CMAKE_LIBPNG_DIR_ARG
    printvar CONFIG_LIBPNG_DIR_ARG
  fi
}
setLibpngTriggerVars

######################################################################
#
# Find libpng
#
######################################################################

findLibpng() {
  for dir in $LIBPNG_DIRS; do
    if test -e $dir/lib/libpng.dylib; then
      LIBPNG_SERSH_DIR=`(cd $dir; pwd -P)`
      break
    fi
  done
  if test -n "$LIBPNG_SERSH_DIR" && [[ `uname` =~ CYGWIN ]]; then
    LIBPNG_SERSH_DIR=`cygpath -am $LIBPNG_SERSH_DIR`
  fi
  printvar LIBPNG_SERSH_DIR
}

