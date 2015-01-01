#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Find freetype.  This is used below, so must be first.
#
# Named args (must come first):
# -s  Look in system directories only
#
######################################################################

findFreetype() {

  local CHECK_SYSTEM=false

# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "s" arg; do
    case $arg in
      s) CHECK_SYSTEM=true;;
    esac
  done
  shift $(($OPTIND - 1))

  if $CHECK_SYSTEM; then
    local freetypeconfig=`which freetype-config`
    local freetypedir=`$freetypeconfig --prefix`
    techo "Using freetype from $freetypedir."
    FREETYPE_PYCSH_DIR=$freetypedir
  fi

# Look for freetype in contrib
  if test -z "$FREETYPE_PYCSH_DIR"; then
    findPackage Freetype freetype "$CONTRIB_DIR" pycsh sersh
    findPycshDir Freetype
  fi

  if test -n "$FREETYPE_PYCSH_DIR"; then
    if [[ `uname` =~ CYGWIN ]]; then
      FREETYPE_PYCSH_DIR=`cygpath -am $FREETYPE_PYCSH_DIR`
    fi
    CMAKE_FREETYPE_PYCSH_DIR_ARG="-DFreeType_ROOT_DIR:PATH='$FREETYPE_PYCSH_DIR'"
    CONFIG_FREETYPE_PYCSH_DIR_ARG="--with-freetype-dir='$FREETYPE_PYCSH_DIR'"
    printvar CMAKE_FREETYPE_PYCSH_DIR_ARG
  fi

# If freetype has no builds, libpng_aux.sh will not be sourced, and
# findLibpng will not be called, so cover that possibility here.
  if test -z "$CMAKE_LIBPNG_PYCSH_DIR_ARG"; then
    if ! declare -f findLibpng 1>/dev/null; then
      source $BILDER_DIR/packages/libpng_aux.sh
    fi
    findLibpng
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

setFreetypeTriggerVars() {
  FREETYPE_BLDRVERSION_STD=${FREETYPE_BLDRVERSION_STD:-"2.5.2"}
  FREETYPE_BLDRVERSION_EXP=${FREETYPE_BLDRVERSION_EXP:-"2.5.2"}
# freetype generally needed on windows
  case `uname` in
    CYGWIN*)
      findFreetype
      FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"}
      ;;
    Darwin | Linux)
# Build on Linux or Darwin only if not found in system
      findFreetype -s
      if test -z "$FREETYPE_PYCSH_DIR"; then
        techo "WARNING: [$FUNCNAME] System freetype not found.  Will build if out of date, but better to install system version and remove contrib version to prevent incompatibility."
        FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"}
      elif [[ `freetype-config --ftversion` =~ '2.[0-2]' ]]; then
        techo "WARNING: [$FUNCNAME] System freetype found but too old.  Building."
        FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"}
      else
        techo "System freetype found in $FREETYPE_PYCSH_DIR, will not build."
      fi
      ;;
  esac
  computeBuilds freetype
  if test -n "$FREETYPE_BUILDS"; then
    addPycshBuild freetype
  fi
  FREETYPE_DEPS=libpng
}
setFreetypeTriggerVars

