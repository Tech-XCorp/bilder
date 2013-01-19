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
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$BOTAN_DESIRED_BUILDS"; then
  BOTAN_DESIRED_BUILDS=sersh
fi
computeBuilds botan
addCc4pyBuild botan

BOTAN_DEPS=
BOTAN_UMASK=007

######################################################################
#
# Launch botan builds.
#
######################################################################

buildBotan() {
  if bilderUnpack -i botan; then
# This configures with python configure.py but is not riverbank
# type because it uses --prefix= instead of --dist-dir.
  # if bilderUnpack botan; then
    local instdir="$CONTRIB_DIR/botan-$BOTAN_BLDRVERSION"
    local instdirser="${instdir}-ser"
    local instdirsersh="${instdir}-sersh"
    local instdircc4py="${instdir}-cc4py"
    case `uname` in
      CYGWIN*)
        instdirser=`cygpath -aw ${instdirser}`
        instdirsersh=`cygpath -aw ${instdirsersh}`
        instdircc4py=`cygpath -aw ${instdircc4py}`
        BOTAN_CONFIG_SER_ARGS="--cc=msvc"
        BOTAN_CONFIG_SERSH_ARGS="--cc=msvc"
        BOTAN_CONFIG_CC4PY_ARGS="--cc=msvc"
        BOTAN_MAKE_ARGS="-m nmake"
        ;;
    esac
# This is probably not giving the /MT flags build, so will disable at the
# builds definition.
    if bilderConfig -s -i -m "./configure.py" botan ser "--prefix='${instdirser}' $BOTAN_CONFIG_SER_ARGS $BOTAN_SER_OTHER_ARGS"; then
      bilderBuild $BOTAN_MAKE_ARGS botan ser
    fi
    if bilderConfig -s -i -m "./configure.py" botan sersh "--prefix='${instdirsersh}' $BOTAN_CONFIG_SERSH_ARGS $BOTAN_SERSH_OTHER_ARGS"; then
      bilderBuild $BOTAN_MAKE_ARGS botan sersh
    fi
    if bilderConfig -s -i -m "./configure.py" botan cc4py "--prefix='${instdircc4py}' $BOTAN_CONFIG_CC4PY_ARGS $BOTAN_CC4PY_OTHER_ARGS"; then
      bilderBuild $BOTAN_MAKE_ARGS botan cc4py
    fi
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
    CYGWIN*) BOTAN_MAKE_ARGS="-m nmake";;
  esac
  for bld in `echo $BOTAN_BUILDS | tr ',' ' '`; do
    bilderInstall $BOTAN_MAKE_ARGS botan $bld
  done
}

