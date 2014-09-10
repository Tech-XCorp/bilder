#!/bin/bash
#
# Build information for boost
#
# ./bootstrap.sh -show-libraries
# ./b2 --build-dir=ser --stagedir=ser/stage link=static --without-python threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi stage
# ./b2 --prefix=/contrib/boost-1_50_0-ser --build-dir=ser --stagedir=ser/stage link=static --without-python threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi install
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in boost_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/boost_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setBoostNonTriggerVars() {
  :
}
setBoostNonTriggerVars

######################################################################
#
# Launch boost builds.
#
######################################################################

buildBoost() {

# Process
  if ! bilderUnpack -i boost; then
    return
  fi

# Look for needed packages
  if test `uname` = Linux && ! test -f /usr/include/bzlib.h; then
    techo "WARNING: [$FUNCNAME] May need to install bzip2-devel."
  fi

# Determine the toolset
  local toolsetarg_ser=
  local toolsetarg_cc4py=
  local stdlibargs=
  case `uname`-`uname -r` in
    CYGWIN*)
      if $IS_64BIT; then
        toolsetarg_ser="toolset=msvc-${VISUALSTUDIO_VERSION}.0"
      fi
      ;;
    Darwin-13.*)
      case $CXX in
	*clang++)
	  stdlibargs="cxxflags=-stdlib=libstdc++ linkflags=-stdlib=libstdc++"
          toolsetarg_ser="toolset=clang"
          jamfile=tools/build/v2/tools/clang-darwin.jam
	  ;;
      esac
      ;;
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
  local BOOST_ALL_ADDL_ARGS="threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi --abbreviate-paths ${stdlibargs}"
  local staticlinkargs="link=static"
  local sharedlinkargs="link=shared"
  local sermdlinkargs="link=static"  # Not yet used, but this should be right
  if [[ `uname` =~ CYGWIN ]]; then
    staticlinkargs="runtime-link=static $staticlinkargs"
    sharedlinkargs="runtime-link=shared $sharedlinkargs"
    sermdlinkargs="runtime-link=shared $sermdlinkargs"
    if $IS_64BIT; then
      BOOST_ALL_ADDL_ARGS="address-model=64 $BOOST_ALL_ADDL_ARGS"
    fi
  fi
# Only the shared and cc4py build boost python, as shared libs required.
# runtime-link=static gives the /MT flags, which does not work with python.
  BOOST_SER_ADDL_ARGS="$toolsetarg_ser $staticlinkargs --without-python $BOOST_ALL_ADDL_ARGS"
  BOOST_SERSH_ADDL_ARGS="$toolsetarg_ser $sharedlinkargs $BOOST_ALL_ADDL_ARGS"
  BOOST_SERMD_ADDL_ARGS="$toolsetarg_ser $sermdlinkargs $BOOST_ALL_ADDL_ARGS"
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
    bilderBuild -m ./b2 boost ser "$BOOST_SER_ADDL_ARGS $BOOST_SER_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost sermd; then
    bilderBuild -m ./b2 boost sermd "$BOOST_SERMD_ADDL_ARGS $BOOST_SERMD_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost sersh; then
# In-place build, so patch now
# Change install_name for osx to be an absolute path
# For more information, see https://svn.boost.org/trac/boost/ticket/9141
# (this is already being done in macports & homebrew):
    local BOOST_INSTALL_PREFIX=$CONTRIB_DIR/boost-$BOOST_BLDRVERSION-sersh
    if test -n "$jamfile"; then
      techo "Setting install_name to ${BOOST_INSTALL_PREFIX}/lib in $jamfile."
      sed -i .bak "s?-install_name \"?-install_name \"${BOOST_INSTALL_PREFIX}/lib/?" $jamfile
    elif test `uname` = Darwin; then
      techo "WARNING: [$FUNCNAME] jamfile not known."
    fi
    bilderBuild -m ./b2 boost sersh "$BOOST_SERSH_ADDL_ARGS $BOOST_SERSH_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost cc4py; then
    bilderBuild -m ./b2 boost cc4py "$BOOST_CC4PY_ADDL_ARGS $BOOST_CC4PY_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost ben; then
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
      ben) sfx=-ben; instargs="$BOOST_BEN_ADDL_ARGS $BOOST_BEN_OTHER_ARGS";;
    esac
    if bilderInstall -m ./b2 boost $bld boost${sfx} "$instargs --prefix=$boost_mixed_instdir"; then
      setOpenPerms $boost_instdir
    fi
  done
}

