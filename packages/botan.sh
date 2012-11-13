#!/bin/bash
#
# Version and build information for Botan
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

BOTAN_BLDRVERSION=${BOTAN_BLDRVERSION:-"1.8.13"}

######################################################################
#
# Other values
#
######################################################################

BOTAN_BUILDS=${BOTAN_BUILDS:-"ser"}
BOTAN_UMASK=007
BOTAN_DEPS=${BOTAN_DEPS:-"cmake"}


######################################################################
#
# Launch botan builds.
#
######################################################################

buildBotan() {
  if bilderUnpack -i botan; then
    botaninstdir=$CONTRIB_DIR/botan-$BOTAN_BLDRVERSION-ser
    case `uname` in
      CYGWIN*)
        cygfullinstalldir=`cygpath -w $botaninstdir`
        BOTAN_CONFIG_ARGS="--cc=msvc --prefix=\"$cygfullinstalldir\""
        if bilderConfig -i -s -m "./configure.py" botan ser "$BOTAN_CONFIG_ARGS"; then
          BOTAN_MAKE_ARGS="-m nmake"
          bilderBuild $BOTAN_MAKE_ARGS botan ser
        fi
        ;;
      *)
        BOTAN_CONFIG_ARGS="--prefix=$botaninstdir"
        if bilderConfig -i -m "configure.py" botan ser "$BOTAN_CONFIG_ARGS"; then
          bilderBuild botan ser
        fi
	;;
    esac
  fi
}

######################################################################
#
# Test botan
#
######################################################################

testBotan() {
  techo "Not testing botan."
}

######################################################################
#
# Install botan
#
######################################################################

installBotan() {
  case `uname` in
    CYGWIN*)
      BOTAN_MAKE_ARGS="-m nmake"
      ;;
    *)
      BOTAN_MAKE_ARGS=""
      ;;
  esac
  bilderInstall $BOTAN_MAKE_ARGS botan ser
}

