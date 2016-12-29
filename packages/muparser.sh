#!/bin/bash
#
# Build information for muparser
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in muparser_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/muparser_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMuparserNonTriggerVars() {
  MUPARSER_UMASK=002
}
setMuparserNonTriggerVars

######################################################################
#
# Launch muparser builds.
#
######################################################################

buildMuparser() {

# Unpack or return
  if ! bilderUnpack muparser; then
    return
  fi

# Set flags
  local MUPARSER_SER_MAKE_ARGS=
  local MUPARSER_SERMD_MAKE_ARGS=
  local MUPARSER_SERSH_MAKE_ARGS=
  local configargs=
  local makerargs=
  case `uname` in
    CYGWIN*)
# The build on Windows is just an "nmake -fmakefile.vc"
# and then manually installing the includes and library
      MUPARSER_SER_MAKE_ARGS="muparser.lib -f../build/makefile.vcmt"
      MUPARSER_SERMD_MAKE_ARGS="muparser.lib -f../build/makefile.vc"
      MUPARSER_PYCST_MAKE_ARGS="muparser.lib -f../build/makefile.vc"
      MUPARSER_SERSH_MAKE_ARGS="muparser.dll -f../build/makefile.vc SHARED=1"
      MUPARSER_PYCSH_MAKE_ARGS="muparser.dll -f../build/makefile.vc SHARED=1"
      configargs="-C :"  # Use no configure executable
      makerargs="-m nmake"
      cmd="mkdir -p $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/ser/obj/vc_static_rel"
      techo "$cmd"
      $cmd
      cmd="mkdir -p $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/sermd/obj/vc_static_rel"
      techo "$cmd"
      $cmd
      cmd="mkdir -p $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/pycst/obj/vc_static_rel"
      techo "$cmd"
      $cmd
      cmd="mkdir -p $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/sersh/obj/vc_shared_rel"
      techo "$cmd"
      $cmd
      cmd="mkdir -p $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/pycsh/obj/vc_shared_rel"
      techo "$cmd"
      $cmd
      ;;
    Darwin | Linux)
      ;;
  esac

# The builds
# Have to declare library in LDFLAGS on Darwin
  if bilderConfig $configargs muparser ser "--enable-shared=no CC=$CC CFLAGS='$CFLAGS' $MUPARSER_SER_OTHER_ARGS"; then
    bilderBuild $makerargs muparser ser "$MUPARSER_SER_MAKE_ARGS"
  fi
  if bilderConfig $configargs muparser sermd "--enable-shared=no CC=$CC CFLAGS='$CFLAGS' $MUPARSER_SERMD_OTHER_ARGS"; then
    bilderBuild $makerargs muparser sermd "$MUPARSER_SERMD_MAKE_ARGS"
  fi
  if bilderConfig $configargs muparser sersh "--enable-shared=yes CC=$CC CFLAGS='$CFLAGS' $MUPARSER_SERSH_OTHER_ARG"; then
    bilderBuild $makerargs muparser sersh "$MUPARSER_SERSH_MAKE_ARGS"
  fi
  if bilderConfig $configargs muparser pycsh  "--enable-shared=yes CC=$PYC_CC CFLAGS='$PYC_CFLAGS' $MUPARSER_PYCSH_OTHER_ARG"; then
    bilderBuild $makerargs muparser pycsh "$MUPARSER_PYCSH_MAKE_ARGS"
  fi
  if bilderConfig $configargs muparser pycst  "--enable-shared=no CC=$PYC_CC CFLAGS='$PYC_CFLAGS' $MUPARSER_PYCST_OTHER_ARG"; then
    bilderBuild $makerargs muparser pycst "$MUPARSER_PYCST_MAKE_ARGS"
  fi

}

######################################################################
#
# Test muparser
#
######################################################################

testMuparser() {
  techo "Not testing muparser."
}

######################################################################
#
# Install muparser
#
######################################################################

installMuparser() {
  local makerargs=
# No install target on Windows
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m :"
    for bld in `echo $MUPARSER_BUILDS | tr ',' ' '`; do
      cmd="mkdir -p $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/lib"
      techo "$cmd"
      $cmd
    done
  fi
  for bld in `echo $MUPARSER_BUILDS | tr ',' ' '`; do
    local sfx=
    test $bld != ser && sfx="-${bld}"
    if bilderInstall $makerargs muparser $bld; then
      if [[ `uname` =~ CYGWIN ]]; then
# Manual install on Windows
        for dir in bin include lib; do
          cmd="mkdir -p $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/$dir"
          techo "$cmd"
          $cmd
	done
        cmd="cd $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/build"
        techo "$cmd"
        $cmd
        cmd="cp $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/$bld/muparser.lib $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/lib"
        techo "$cmd"
        $cmd
        if test $bld = sersh; then
          cmd="cp $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/$bld/muparser.dll $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/bin"
          techo "$cmd"
          $cmd
        fi
        cmd="cp $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/include/* $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/include/"
        techo "$cmd"
        $cmd
      fi
    fi
  done
}

