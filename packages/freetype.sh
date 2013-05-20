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

FREETYPE_BLDRVERSION=${FREETYPE_BLDRVERSION:-"2.4.11"}

######################################################################
#
# Other values
#
######################################################################

# freetype generally needed on windows
if [[ `uname` =~ CYGWIN ]]; then
  FREETYPE_DESIRED_BUILDS=${FREETYPE_DESIRED_BUILDS:-"sersh"}
  computeBuilds freetype
  addCc4pyBuild freetype
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
    if bilderConfig -c freetype cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC -DBUILD_SHARED_LIBS:BOOL=ON $FREETYPE_ADDL_ARGS $FREETYPE_CC4PY_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
      bilderBuild $FREETYPE_MAKE_ARGS freetype cc4py "" "$DISTUTILS_NOLV_ENV"
    fi
    if bilderConfig -c freetype sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED_LIBS:BOOL=ON $FREETYPE_ADDL_ARGS $FREETYPE_SERSH_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
      bilderBuild $FREETYPE_MAKE_ARGS freetype sersh "" "$DISTUTILS_NOLV_ENV"
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
  # techo "Quitting at end of freetype.sh."; exit

}

######################################################################
#
# Find freetype
#
######################################################################

findFreetypeRootdir() {
  local ftdir=
  for bld in sersh sermd; do
    if test -e $CONTRIB_DIR/freetype-$bld; then
      ftdir=`(cd $CONTRIB_DIR/freetype-$bld; pwd -P)`
      break
    fi
  done
# OSX puts freetype under the X11 location, which may be in more than one place.
  if test -z "$ftdir"; then
    for dir in /opt/X11 /usr/X11R6 /opt/homebrew; do
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

