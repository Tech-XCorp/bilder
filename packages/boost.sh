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

# Fix boost post unpacking
fixBoost() {
  if test `uname` != Darwin; then
    return
  fi
  local bld=$1
  local cxxbase=
  case $bld in
    cc4py) cxxbase=`basename $PYC_CXX`;;
    *) cxxbase=`basename $CXX`;;
  esac
  local cxxversfx=
  if [[ "$cxxbase" =~ 'g++' ]]; then
    echo "Executing sed."
    cxxversfx=`echo $cxxbase | sed 's/^g\+\+-//'`
  fi
  if test -n "$cxxversfx"; then
    cmd="sed -i.bak 's/# using gcc : 3.*$/using darwin : $cxxversfx : g++-$cxxversfx ;/' tools/build/v2/user-config.jam"
    techo "$cmd"
    eval "$cmd"
  fi
  local jamfile=
  case $cxxbase in
    clang++ | g++) jamfile=tools/build/v2/tools/clang-darwin.jam;;
    g++-*) jamfile=tools/build/v2/tools/darwin.jam;;
    icpc) jamfile=tools/build/v2/tools/icpc-darwin.jam;;
  esac
  if test -n "$jamfile"; then
# Change install_name for osx to be an absolute path
# For more information, see https://svn.boost.org/trac/boost/ticket/9141
# (this is already being done in macports & homebrew):
    local boost_prefix=$CONTRIB_DIR/boost-$BOOST_BLDRVERSION-$bld
    techo "Setting install_name to ${boost_prefix}/lib in $jamfile."
    sed -i .bak "s?-install_name \"?-install_name \"${boost_prefix}/lib/?" $jamfile
  else
    techo "WARNING: [$FUNCNAME] jamfile not known."
  fi
}

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
    Darwin-*)
      toolsetarg_cc4py="toolset=clang"
      case $CXX in
        *clang++ | *g++)
# g++ is clang++ on Darwin-11+
          if [[ `uname -r` =~ '^1[3-9]' ]]; then
	    stdlibargs="cxxflags=-stdlib=libstdc++ linkflags=-stdlib=libstdc++"
          fi
          toolsetarg_ser="toolset=clang"
	  ;;
        # *g++-*) toolsetarg_ser="toolset=`basename $CXX`";;
        *icpc) toolsetarg_ser="toolset=icpc";;
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
  BOOST_SERMD_ADDL_ARGS="$toolsetarg_ser $sermdlinkargs --without-python $BOOST_ALL_ADDL_ARGS"
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
# In-place build, so make compiler/os modifications now
    fixBoost ser
    bilderBuild -m ./b2 boost ser "$BOOST_SER_ADDL_ARGS $BOOST_SER_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost sermd; then
    bilderBuild -m ./b2 boost sermd "$BOOST_SERMD_ADDL_ARGS $BOOST_SERMD_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost sersh; then
# In-place build, so make compiler/os modifications now
    fixBoost sersh
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
    if test $bld != ser; then
      sfx="-$bld"
    fi
    local BLD=`echo $bld | tr [a-z] [A-Z]`
    local instargs="`deref BOOST_${BLD}_ADDL_ARGS` `deref BOOST_${BLD}_OTHER_ARGS`"
    if bilderInstall -m ./b2 boost $bld boost${sfx} "$instargs --prefix=$boost_mixed_instdir"; then
      setOpenPerms $boost_instdir
    fi
  done
}

