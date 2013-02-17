#!/bin/bash
#
# Version and build information for muparser
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MUPARSER_BLDRVERSION=${MUPARSER_BLDRVERSION:-"v134"}

######################################################################
#
# Other values
#
######################################################################

case `uname` in
 CYGWIN*)
  MUPARSER_BUILDS=${MUPARSER_BUILDS:-"ser"}
  ;;
 Darwin | Linux)
  MUPARSER_BUILDS=${MUPARSER_BUILDS:-"ser,sersh"}
  ;;
esac

MUPARSER_DEPS=m4

######################################################################
#
# Launch muparser builds.
#
######################################################################

buildMuparser() {
  case `uname` in
   CYGWIN*)
    # The build on Windows is just an "nmake -fmakefile.vc" and then manually installing the includes and library
    if shouldInstall -i $CONTRIB_DIR muparser-${MUPARSER_BLDRVERSION} ser; then
      if bilderUnpack muparser; then
        cmd="cd $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/build"
        $cmd
        cmd="nmake -fmakefile.vcmt"
	    $cmd
	    cmd="mkdir $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-ser"
	    $cmd
	    cmd="cp -r $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/lib $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-ser"
	    $cmd
	    cmd="cp -r $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/include $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-ser"
	    $cmd
	    cmd="mkLink $CONTRIB_DIR muparser-${MUPARSER_BLDRVERSION}-ser muparser"
        $cmd
        cmd="$BILDER_DIR/setinstald.sh -i $CONTRIB_DIR muparser,ser"
        $cmd
        buildSuccesses="$buildSuccesses muparser"
      fi
	fi
    ;;
   Darwin | Linux)
    if bilderUnpack muparser; then
      if bilderConfig muparser ser "--enable-shared=no"; then
        bilderBuild muparser ser
      fi
      if bilderConfig muparser sersh "--enable-shared=yes"; then
        bilderBuild muparser sersh
      fi
    fi
    ;;
  esac
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
  case `uname` in
   Darwin | Linux)
    bilderInstall muparser ser
    bilderInstall muparser sersh
    findContribPackage muparser muparser ser
    ;;
  esac
}

