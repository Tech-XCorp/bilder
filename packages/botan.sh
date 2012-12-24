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
  BOTAN_DESIRED_BUILDS=cc4py
  case `uname` in
    CYGWIN*) addVals BOTAN_DESIRED_BUILDS sersh;; # Botan is built shared.
  esac
fi
computeBuilds botan
if ! [[ `uname` =~ CYGWIN ]]; then
  addCc4pyBuild botan
fi

BOTAN_DEPS=${BOTAN_DEPS:-"cmake"}
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
    case `uname` in
      CYGWIN*)
        instdirsersh=`cygpath -aw ${instdir}-sersh`
        BOTAN_CONFIG_SERSH_ARGS="--cc=msvc --prefix='$instdirsersh'"
        instdircc4py=`cygpath -aw ${instdir}-cc4py`
        BOTAN_CONFIG_CC4PY_ARGS="--cc=msvc --prefix='$instdircc4py'"
        BOTAN_MAKE_ARGS="-m nmake"
        ;;
      *)
        instdir=${instdir}-cc4py
        BOTAN_CONFIG_CC4PY_ARGS="--prefix='$instdir'"
        ;;
    esac
    if bilderConfig -s -i -m "./configure.py" botan sersh "$BOTAN_CONFIG_SERSH_ARGS $BOTAN_SERSH_OTHER_ARGS"; then
      bilderBuild $BOTAN_MAKE_ARGS botan sersh
    fi
    if bilderConfig -s -i -m "./configure.py" botan cc4py "$BOTAN_CONFIG_CC4PY_ARGS $BOTAN_CC4PY_OTHER_ARGS"; then
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
    CYGWIN*)
      BOTAN_MAKE_ARGS="-m nmake"
      ;;
  esac
  bilderInstall $BOTAN_MAKE_ARGS botan sersh

  # Create a link so txssh and composertoolkit can find botan easily
  if bilderInstall $BOTAN_MAKE_ARGS botan cc4py; then
    cmd="mkLink $CONTRIB_DIR botan-${BOTAN_BLDRVERSION}-cc4py botan"
    techo "$cmd"
    $cmd
  fi
}

