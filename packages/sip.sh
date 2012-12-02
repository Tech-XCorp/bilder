#!/bin/bash
#
# Build and installation of sip
#
# $Id$
#
########################################################################

########################################################################
#
# Version
#
########################################################################

SIP_BLDRVERSION=${SIP_BLDRVERSION:-"4.14.1"}

########################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
########################################################################

SIP_BUILDS=${PYQT_BUILDS:-"cc4py"}
SIP_DEPS=Python
SIP_UMASK=002

########################################################################
#
# Launch builds
#
########################################################################

buildSip() {

# Unpack
  if bilderUnpack sip; then

# Find native sip interface and include directories
    local sipifcdir=$CONTRIB_DIR/share/sip
    local incdir=$CONTRIB_DIR/include/python${PYTHON_MAJMIN}
    if [[ `uname` = CYGWIN ]]; then
      sipifcdir=`cygpath -aw $sipifcdir`
      incdir=`cygpath -aw $incdir`
    fi

# Complete configuration args
    local SIP_CONFIG_ARGS="--sipdir='$sipifcdir' --incdir='$incdir'"
    case `uname`-`uname -r` in
      CYGWIN*) SIP_CONFIG_ARGS="$SIP_CONFIG_ARGS -p win32-msvc";;
      Darwin-1?.*) SIP_CONFIG_ARGS="$SIP_CONFIG_ARGS -p macx-g++";;
    esac

# Configure and build
    if bilderConfig -r sip cc4py "$SIP_CONFIG_ARGS"; then
      local SIP_BUILD_ARGS=
      case `uname`-`uname -r` in
        CYGWIN*) SIP_BUILD_ARGS="-m nmake";;
      esac
# Remove old installations
      cmd="rmall ${PYTHON_SITEPKGSDIR}/sip*"
      techo "$cmd"
      $cmd
      bilderBuild $SIP_BUILD_ARGS sip cc4py
    fi
  fi

}

########################################################################
#
# Test
#
########################################################################

testSip() {
  techo "Not testing sip."
}

########################################################################
#
# Install
#
########################################################################

installSip() {
  local SIP_INSTALL_ARGS=
  case `uname`-`uname -r` in
    CYGWIN*) SIP_INSTALL_ARGS="-m nmake";;
  esac
# Do not create links as an executable plus some libs for python
  bilderInstall $SIP_INSTALL_ARGS -L sip cc4py
}

