#!/bin/bash
#
# Version and build information for ne7ssh
#
# $Id: ne7ssh.sh 6251 2012-06-20 15:52:56Z cary $
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
# Other values
#
######################################################################

NE7SSH_BUILDS=${NE7SSH_BUILDS:-"ser"}
NE7SSH_DEPS=${NE7SSH_DEPS:-"cmake,botan"}
NE7SSH_UMASK=002

######################################################################
#
# Launch ne7ssh builds
#
######################################################################

buildNe7ssh() {
  if bilderUnpack ne7ssh; then
    botaninstdir=$CONTRIB_DIR/botan-1.8.13-ser
    case `uname` in
      CYGWIN*)
        botaninstdir=`cygpath -am $botaninstdir`
        ;;
    esac
    BOTAN_ARGS="-DBOTAN_DIR:PATH=$botaninstdir"
    if bilderConfig -c ne7ssh ser "$CMAKE_SUPRA_SP_ARG $BOTAN_ARGS $NE7SSH_SER_OTHER_ARGS"; then
      bilderBuild ne7ssh ser
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
  bilderInstall -r ne7ssh ser
}

