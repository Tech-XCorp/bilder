#!/bin/bash
#
# Version information for and finding freetype
#
# $Id$
#
######################################################################

######################################################################
#
# Version:
#
######################################################################

getFreetypeVersion() {
  FREETYPE_BLDRVERSION_STD=${FREETYPE_BLDRVERSION_STD:-"2.5.2"}
  FREETYPE_BLDRVERSION_EXP=${FREETYPE_BLDRVERSION_EXP:-"2.5.2"}
}
getFreetypeVersion

######################################################################
#
# Find freetype.
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
    for dir in /opt/X11 /usr/X11R6 /usr /opt/homebrew /opt/local; do
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

#
# Finding Freetype at time of sourcing not needed as done when setting
# global vars.
#
# findFreetype

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

