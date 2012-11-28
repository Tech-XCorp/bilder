#!/bin/bash
#
# Version and build information for ne7ssh
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

NE7SSH_BLDRVERSION=${NE7SSH_BLDRVERSION:-"1.3.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$NE7SSH_ADDBUILDS"; then
  case `uname` in
    CYGWIN*) addVals NE7SSH_ADDBUILDS sersh;; # Built shared only
  esac
fi
computeBuilds ne7ssh
if ! [[ `uname` =~ CYGWIN ]]; then
  addCc4pyBuild ne7ssh
fi
NE7SSH_DEPS=${NE7SSH_DEPS:-"cmake,botan"}
NE7SSH_UMASK=002

######################################################################
#
# Launch ne7ssh builds
#
######################################################################

buildNe7ssh() {
  if bilderUnpack ne7ssh; then
    botaninstdir=$CONTRIB_DIR/botan-${BOTAN_BLDRVERSION}
    case `uname` in
      CYGWIN*)
        botaninstdir=`cygpath -am ${botaninstdir}-sersh`
        ;;
      CYGWIN*)
        botaninstdir=${botaninstdir}-cc4py
        ;;
    esac
    BOTAN_ARGS="-DBOTAN_DIR:PATH='$botaninstdir'"
    if bilderConfig -c ne7ssh sersh "$BOTAN_ARGS $NE7SSH_SERSH_OTHER_ARGS"; then
      bilderBuild ne7ssh sersh
    fi
    if bilderConfig -c ne7ssh cc4py "$BOTAN_ARGS $NE7SSH_CC4PY_OTHER_ARGS"; then
      bilderBuild ne7ssh cc4py
    fi
  fi
}

######################################################################
#
# Test ne7ssh must be driven from top level qdstests
#
######################################################################

testNe7ssh() {
  techo "Not testing ne7ssh."
}


######################################################################
#
# Install ne7ssh
#
######################################################################

installNe7ssh() {
  bilderInstall -r ne7ssh sersh
  bilderInstall -r ne7ssh cc4py
}

