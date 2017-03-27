#!/bin/sh
######################################################################
#
# @file    pydap.sh
#
# @brief   Version and build information for pydap.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYDAP_BLDRVERSION=${PYDAP_BLDRVERSION:-"3.0.2"}

######################################################################
#
# Builds and deps
#
######################################################################

PYDAP_BUILDS=${PYDAP_BUILDS:-"pycsh"}
PYDAP_DEPS=Python,numpy,httplib2

######################################################################
#
# Launch pydap builds.
#
######################################################################

buildPydap() {
# arch flags now fixed in bildvars.sh

  if bilderUnpack pydap; then
# Remove all old installations
    local cmd="rmall ${PYTHON_SITEPKGSDIR}/pydap*"
    techo "$cmd"
    $cmd
# pydap must be built without compiler option, then installed
    cd $BUILD_DIR/pydap-${PYDAP_BLDRVERSION}

# Patch incorrect syntax
    local ptchfile=pydap/missing_posix_functions.inc
    cmd="sed -i.bak -e 's/inline static/inline/g' $ptchfile"
    techo "$cmd"
    sed -i.bak -e 's/inline static/inline/g' $ptchfile

    case `uname`-$CC in
      CYGWIN*-cl)
        PYDAP_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
        PYDAP_ENV_USED="$DISTUTILS_ENV"
        ;;
      CYGWIN*-*mingw*)
# Have to install with build to get both prefix and compiler correct.
        PYDAP_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        PYDAP_ENV_USED="PATH=$mingwdir:'$PATH'"
        ;;
      *)
        #PYDAP_ARGS="--fcompiler=gnu95"
        PYDAP_ENV_USED="$DISTUTILS_ENV"
        ;;
    esac
    bilderDuBuild pydap "$PYDAP_ARGS" "$PYDAP_ENV_USED"

  fi

}

######################################################################
#
# Test pydap
#
######################################################################

testPydap() {
  techo "Not testing pydap."
}

######################################################################
#
# Install pydap
#
######################################################################

installPydap() {
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n pydap "-" "$PYDAP_ENV_USED"
      ;;
    *)
      bilderDuInstall pydap "-" "$PYDAP_ENV_USED"
      ;;
  esac
  # techo "WARNING: Quitting at end of pydap.sh."; exit
}

