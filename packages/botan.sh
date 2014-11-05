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

BOTAN_DESIRED_BUILDS=${BOTAN_DESIRED_BUILDS:-"sersh"}
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
    local instdirpycsh="${instdir}-pycsh"
    techo -2 "instdirsersh = '$instdirsersh'."
    case `uname` in
      CYGWIN*)
        instdirser=`cygpath -aw ${instdirser}`
        instdirsersh=`cygpath -aw ${instdirsersh}`
        instdirpycsh=`cygpath -aw ${instdirpycsh}`
        BOTAN_CONFIG_SER_ARGS="--cc=msvc"
        BOTAN_CONFIG_SERSH_ARGS="--cc=msvc"
        BOTAN_CONFIG_PYCSH_ARGS="--cc=msvc"
        BOTAN_MAKE_ARGS="-m nmake"
        ;;
    esac
    techo -2 "instdirsersh = '$instdirsersh'."
# This is probably not giving the /MT flags build, so will disable at the
# builds definition.
    if bilderConfig -s -i -C "./configure.py" botan ser "--prefix='${instdirser}' $BOTAN_CONFIG_SER_ARGS $BOTAN_SER_OTHER_ARGS"; then
      bilderBuild $BOTAN_MAKE_ARGS botan ser
    fi
    if bilderConfig -s -i -C "./configure.py" botan sersh "--prefix='${instdirsersh}' $BOTAN_CONFIG_SERSH_ARGS $BOTAN_SERSH_OTHER_ARGS"; then
      bilderBuild $BOTAN_MAKE_ARGS botan sersh
    fi
    if bilderConfig -s -i -C "./configure.py" botan pycsh "--prefix='${instdirpycsh}' $BOTAN_CONFIG_PYCSH_ARGS $BOTAN_PYCSH_OTHER_ARGS"; then
      bilderBuild $BOTAN_MAKE_ARGS botan pycsh
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

