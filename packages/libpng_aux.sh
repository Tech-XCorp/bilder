#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Find libpng.  This is used below, so must be first.
#
######################################################################

findLibpng() {

# Look for libpng-sersh in contrib directory on windows and linux, but
# on mac we look for it in certain system places
  case `uname` in
    CYGWIN*)
      findPackage Libpng libpng "$CONTRIB_DIR" sersh
      LIBPNG_SERSH_DIR=`cygpath -am $LIBPNG_SERSH_DIR`
      if test -z "$LIBPNG_SERSH_DIR"; then
        echo "WARNING: libpng not found. May have failed to build."
      fi
      ;;
    Darwin)
      local dirlist="/opt/homebrew /opt/homebrew/opt/libpng /opt/X11 /usr/X11R6 /usr/X11"
      for dir in $dirlist; do
echo "Trying $dir"
        if test -d $dir/include/libpng16; then
echo "     Found in $dir"
          LIBPNG_SERSH_DIR=$dir
          break
        fi
      done
      if test -z "$LIBPNG_SERSH_DIR"; then
        echo "WARNING: libpng16 not found. Please install on system."
      fi
      ;;
    Linux) 
      findPackage Libpng libpng "$CONTRIB_DIR" sersh
      if test -z "$LIBPNG_SERSH_DIR"; then
        echo "WARNING: libpng not found. May have failed to build."
      fi
      ;;
  esac 

# If found, we set some arguments that can be used in other package
# configures to make sure libpng is consistent in all pkgs that use the args. 
  if test -n "$LIBPNG_SERSH_DIR"; then
    echo "Setting configure args to use libpng in $LIBPNG_SERSH_DIR."
    CMAKE_LIBPNG_SERSH_DIR_ARG="-DPng_ROOT_DIR:PATH='$LIBPNG_SERSH_DIR'"
    CONFIG_LIBPNG_SERSH_DIR_ARG="--with-libpng-dir='$LIBPNG_SERSH_DIR'"
    printvar CMAKE_LIBPNG_SERSH_DIR_ARG
    printvar CONFIG_LIBPNG_SERSH_DIR_ARG
  fi
}

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
  findLibpng
  case `uname` in
    Darwin)
# Do not attempt to build on Darwin. Must be installed.
      ;;
    *)
      LIBPNG_DESIRED_BUILDS=${LIBPNG_DESIRED_BUILDS:-"sersh"}
      ;;
  esac
  computeBuilds libpng
# No need to add cc4py build, as pure C
  #  addCc4pyBuild libpng
  LIBPNG_DEPS=zlib,cmake
}
setLibpngTriggerVars

