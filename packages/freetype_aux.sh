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
  findPackage Freetype freetype "$CONTRIB_DIR" cc4py sersh
  findCc4pyDir Freetype

# OSX puts freetype under the X11 location, which may be in more than one place.
  if test -z "$FREETYPE_SERSH_DIR"; then
    for dir in /opt/homebrew /opt/X11 /usr/X11R6 /usr/X11; do
      if test -d $dir/include/freetype2; then
        FREETYPE_CC4PY_DIR=$dir
        break
      fi
    done
  fi
  if test -z "$FREETYPE_CC4PY_DIR"; then
    return
  fi
  if [[ `uname` =~ CYGWIN ]]; then
    FREETYPE_CC4PY_DIR=`cygpath -am $FREETYPE_CC4PY_DIR`
  fi
  CMAKE_FREETYPE_CC4PY_DIR_ARG="-DFreeType_ROOT_DIR:PATH='$FREETYPE_CC4PY_DIR'"
  CONFIG_FREETYPE_CC4PY_DIR_ARG="--with-freetype-dir='$FREETYPE_CC4PY_DIR'"
  printvar CMAKE_FREETYPE_CC4PY_DIR_ARG
  printvar CONFIG_FREETYPE_CC4PY_DIR_ARG
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
}
setFreetypeTriggerVars

######################################################################
#
# Find freetype root directory.  Deprecated.
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
    for dir in /opt/X11 /usr/X11R6 /usr /opt/homebrew /opt/local; do
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

