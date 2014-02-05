#!/bin/bash
#
# Version and build information for boost
#
# $Id$
#
# ./bootstrap.sh -show-libraries
# ./b2 --build-dir=ser --stagedir=ser/stage link=static --without-python threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi stage
# ./b2 --prefix=/contrib/boost-1_50_0-ser --build-dir=ser --stagedir=ser/stage link=static --without-python threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi install
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# version 1_50_0 does not build with Intel compiler on windows (Pletzer)
# 1_55_0 must be patched to build with NO_COMPRESSION:
#   https://svn.boost.org/trac/boost/ticket/9156
BOOST_BLDRVERSION_STD=1_53_0

# Boost 1_55_0 does not build using gcc 4.1.2, nor does it seem to build
# on Lion and Snow Leopard.
#
# Ted will build gcc 4.2.4 on qalinux, and we'll perhaps install gcc on
# the Macs (instead of LLVM), but for now we're sticking with boost 1_53_0.

BOOST_BLDRVERSION_EXP=1_53_0
#BOOST_BLDRVERSION_EXP=1_55_0

######################################################################
#
# Other values
#
######################################################################

if test -z "$BOOST_DESIRED_BUILDS"; then
  BOOST_DESIRED_BUILDS=ser,sersh
fi
computeBuilds boost
addCc4pyBuild boost
# It does not hurt to add deps that do not get built
# (e.g., Python on Darwin and CYGWIN)
# Only certain builds depend on Python
BOOST_DEPS=Python,bzip2

######################################################################
#
# Launch boost builds.
#
######################################################################

buildBoost() {

# Look for needed packages
  case `uname` in
    Linux)
      if ! test -f /usr/include/bzlib.h; then
        techo "WARNING: May need to install bzip2-devel."
      fi
      ;;
  esac

# Process
  if ! bilderUnpack -i boost; then
    return
  fi

# Determine the toolset
  local toolsetarg_ser=
  local toolsetarg_cc4py=
  case `uname`-`uname -r` in
    CYGWIN*-WOW64*)
      toolsetarg_ser="toolset=msvc-${VISUALSTUDIO_VERSION}.0"
      ;;
    CYGWIN-*) ;;
    Darwin-12.*)
# Clang works for g++ as well on Darwin-12
      case $CXX in
        *clang++ | *g++)
          toolsetarg_ser="toolset=clang"
          jamfile=tools/build/v2/tools/clang-darwin.jam
          ;;
        *icpc)
          toolsetarg_ser="toolset=icpc"
          jamfile=tools/build/v2/tools/icpc-darwin.jam
          ;;
      esac
      ;;
    Darwin-*)
      case $CXX in
        *clang++)
          toolsetarg_ser="toolset=clang"
          jamfile=tools/build/v2/tools/clang-darwin.jam
          ;;
        *g++)
          jamfile=tools/build/v2/tools/darwin.jam
          ;;
        *icpc)
          toolsetarg_ser="toolset=icpc"
          jamfile=tools/build/v2/tools/icpc-darwin.jam
          ;;
      esac
      ;;
    Linux-*)
      toolsetarg_cc4py="toolset=gcc"
      case $CXX in
        *g++) ;;
        *icpc) toolsetarg_ser="toolset=intel";;
        *pgCC) toolsetarg_ser="toolset=pgi";;
        *xlC | *xlC_r) toolsetarg_ser="toolset=vacpp";;
      esac
      ;;
  esac
  toolsetarg_cc4py=${toolsetarg_cc4py:-"$toolsetarg_ser"}

# These args are actually to bilderBuild
  local BOOST_ALL_ADDL_ARGS="threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi --abbreviate-paths"
  local staticlinkargs="link=static"
  local sharedlinkargs="link=shared"
  local sermdlinkargs="link=static"  # Not yet used, but this should be right
  if [[ `uname` =~ CYGWIN ]]; then
    staticlinkargs="runtime-link=static $staticlinkargs"
    sharedlinkargs="runtime-link=shared $sharedlinkargs"
    sermdlinkargs="runtime-link=shared $sermdlinkargs"
  fi
  case `uname` in
    CYGWIN*-WOW64*)
      BOOST_ALL_ADDL_ARGS="address-model=64 $BOOST_ALL_ADDL_ARGS"
      ;;
  esac
# Only the shared and cc4py build boost python, as shared libs required.
# runtime-link=static gives the /MT flags.  For simplicity, use for all.
  BOOST_SER_ADDL_ARGS="$toolsetarg_ser $staticlinkargs --without-python $BOOST_ALL_ADDL_ARGS"
  BOOST_SERSH_ADDL_ARGS="$toolsetarg_ser $sharedlinkargs $BOOST_ALL_ADDL_ARGS"
  BOOST_CC4PY_ADDL_ARGS="$toolsetarg_cc4py $sharedlinkargs $BOOST_ALL_ADDL_ARGS"
  BOOST_BEN_ADDL_ARGS="$toolsetarg_ser $staticlinkargs --without-python $BOOST_ALL_ADDL_ARGS"
# Boost is meant to be built at the top, with different build and stage dirs.
# When that is done, the below will be needed.
if false; then
  for bld in `echo BOOST_BUILDS | sed 's/,/ /'`; do
    local addlargsvar=`genbashvar BOOST_$bld`_ADDL_ARGS
    local addlargsval=`deref $addlargsvar`
    eval $addlargsvar="--build-dir=$bld --stagedir=$bld/stage $addlargsval"
  done
fi

  if bilderConfig -i boost ser; then
# In-place build, so done now
    bilderBuild -m ./b2 boost ser "$BOOST_SER_ADDL_ARGS $BOOST_SER_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost sersh; then
    local BOOST_INSTALL_PREFIX=$CONTRIB_DIR/boost-$BOOST_BLDRVERSION-sersh
# In-place build, so done now
# Change install_name for osx to be an absolute path
# For more information, check out the following (this is already being done in macports & homebrew):
# https://svn.boost.org/trac/boost/ticket/9141
    if test -n "$jamfile"; then
# Escaping difficult here
      # cmd="sed -i .bak "s?-install_name \"?-install_name \"${BOOST_INSTALL_PREFIX}/lib/?" $jamfile
      # echo "$cmd"
      # eval "$cmd"
      techo "Setting install_name to ${BOOST_INSTALL_PREFIX}/lib in $jamfile."
      sed -i .bak "s?-install_name \"?-install_name \"${BOOST_INSTALL_PREFIX}/lib/?" $jamfile
    elif test `uname` = Darwin; then
      techo "WARNING [boost.sh]: jamfile not known."
    fi
    bilderBuild -m ./b2 boost sersh "$BOOST_SERSH_ADDL_ARGS $BOOST_SERSH_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost cc4py; then
# In-place build, so done now
    bilderBuild -m ./b2 boost cc4py "$BOOST_CC4PY_ADDL_ARGS $BOOST_CC4PY_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost ben; then
# In-place build, so done now
    bilderBuild -m ./b2 boost ben "$BOOST_BEN_ADDL_ARGS $BOOST_BEN_OTHER_ARGS stage"
  fi

}

######################################################################
#
# Test boost
#
######################################################################

testBoost() {
  techo "Not testing boost."
}

######################################################################
#
# Install boost
#
######################################################################

installBoost() {
  for bld in `echo $BOOST_BUILDS | tr ',' ' '`; do
    local boost_instdir=$CONTRIB_DIR/boost-$BOOST_BLDRVERSION-$bld
    local boost_mixed_instdir=
    case `uname` in
      CYGWIN*) boost_mixed_instdir=`cygpath -am $boost_instdir`;;
      *) boost_mixed_instdir=$boost_instdir;;
    esac
# For b2, installation directory must be added at install time,
# and it is relative to the C: root.
    local sfx=
    local instargs=
    case $bld in
      ser) instargs="$BOOST_SER_ADDL_ARGS $BOOST_SER_OTHER_ARGS";;
      sersh) sfx=-sersh; instargs="$BOOST_SERSH_ADDL_ARGS $BOOST_SERSH_OTHER_ARGS";;
      cc4py) sfx=-cc4py; instargs="$BOOST_CC4PY_ADDL_ARGS $BOOST_CC4PY_OTHER_ARGS";;
      ben) sfx=-cc4py; instargs="$BOOST_BEN_ADDL_ARGS $BOOST_BEN_OTHER_ARGS";;
    esac
    if bilderInstall -m ./b2 boost $bld boost${sfx} "$instargs --prefix=$boost_mixed_instdir"; then
      setOpenPerms $boost_instdir
      findBoost
    fi
  done
}

