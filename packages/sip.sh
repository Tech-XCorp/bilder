#!/bin/bash
#
# Automate the build of sip, required for PyQt4
#
# @version $Id$
#
########################################################################

########################################################################
#
# Version
#
########################################################################

SIP_BLDRVERSION=${SIP_BLDRVERSION:-"4.13.2"}

########################################################################
#
# Builds and deps
#
########################################################################

SIP_BUILDS=${PYQT_BUILDS:-"cc4py"}
SIP_DEPS=Python

########################################################################
#
# Launch sip builds
#
########################################################################

buildSip() {

# Unpack
  if bilderUnpack sip; then
    techo "Building sip."

# Remove old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/sip*"
    techo "$cmd"
    $cmd

    SIP_CONFIG_ARGS="--sipdir=$MIXED_CONTRIB_DIR/share/sip --incdir=$MIXED_CONTRIB_DIR/include/python2.6"
    case `uname`-`uname -r` in
      CYGWIN*) SIP_CONFIG_ARGS="$SIP_CONFIG_ARGS -p win32-msvc";;
      Darwin-1?.*) SIP_CONFIG_ARGS="$SIP_CONFIG_ARGS -p macx-g++";;
    esac

# Configure
    if bilderConfig -r sip cc4py "$SIP_CONFIG_ARGS"; then
      case `uname`-`uname -r` in
        CYGWIN*) SIP_BUILD_ARGS="-m nmake";;
      esac
      bilderBuild $SIP_BUILD_ARGS sip cc4py
    fi
  fi

}

########################################################################
#
# Test sip
#
########################################################################

testSip() {
  techo "Not testing sip."
}

########################################################################
#
# Install sip
#
########################################################################

installSip() {
# Do not create links as an executable only
  case `uname`-`uname -r` in
    CYGWIN*) SIP_INSTALL_ARGS="-m nmake";;
  esac
  bilderInstall $SIP_INSTALL_ARGS -L sip cc4py
  # techo "WARNING: Quitting at the end of sip.sh."; cleanup
}

