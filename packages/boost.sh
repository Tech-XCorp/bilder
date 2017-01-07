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
    py*) cxxbase=`basename $PYC_CXX`;;
    *) cxxbase=`basename $CXX`;;
  esac
  case $bld in
    pycsh | pycst) ;;
    *)
      local cxxversfx=
      if [[ "$cxxbase" =~ 'g++' ]]; then
        echo "Executing sed."
        cxxversfx=`echo $cxxbase | sed 's/^g\+\+-//'`
      fi
      if test -n "$cxxversfx"; then
        local exampconfigfile=
        local cmd=
        if test -f tools/build/v2/user-config.jam; then
          exampconfigfile=tools/build/v2/user-config.jam
# Need using darwin to get assembler correct.
# https://svn.boost.org/trac/boost/ticket/9306
          cmd="sed -i.bak 's/# using gcc : 3.*$/using darwin : $cxxversfx : $cxxbase ;/' $exampconfigfile"
        elif test -f tools/build/example/user-config.jam; then
          exampconfigfile=tools/build/example/user-config.jam
# Now config file must show up in directory below.
          local userconfigfile=tools/build/src/user-config.jam
          cmd="sed 's/# using gcc : 3.*$/using darwin : $cxxversfx : $cxxbase ;/' $exampconfigfile >$userconfigfile"
        fi
        if test -n "$cmd"; then
          techo "$cmd"
          eval "$cmd"
        fi
      fi
      ;;
  esac
  case $bld in
    sersh | pycsh)
      local jamdir=
      if test -d tools/build/v2/tools; then
        jamdir=tools/build/v2/tools
      elif test -d tools/build/src/tools; then
        jamdir=tools/build/src/tools
      fi
      local jamfile=
      if test -n "$jamdir"; then
        case $cxxbase in
          clang++ | g++) jamfile=$jamdir/clang-darwin.jam;;
          g++-*) jamfile=$jamdir/darwin.jam;;
          icpc) jamfile=$jamdir/icpc-darwin.jam;;
        esac
      fi
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
      ;;
  esac
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
  local toolsetarg_pycst=
  local toolsetarg_pycsh=
  local stdlibargs_ser=
  case `uname`-`uname -r` in
    CYGWIN*)
      if $IS_64BIT; then
# We can't just use a case statement on CXX because
# the Intel compiler is named icl and the Microsoft compiler
# is named cl. So leading wildcards will match. Instead search
# for Intel
        if echo "$CXX" | grep -q "Intel"; then
          toolsetarg_ser="toolset=intel-15.0-vc12"
        else
          toolsetarg_ser="toolset=msvc-${VISUALSTUDIO_VERSION}.0"
        fi
      fi
      ;;
    Darwin-*)
      stdlibargs_pycst="cxxflags='$PYC_CXXFLAGS' linkflags='$PYC_CXXFLAGS'"
      toolsetarg_pycst="toolset=clang"
      stdlibargs_pycsh="cxxflags='$PYC_CXXFLAGS' linkflags='$PYC_CXXFLAGS'"
      toolsetarg_pycsh="toolset=clang"
      stdlibargs_ser="cxxflags='$CXXFLAGS' linkflags='$CXXFLAGS'"
      case $CXX in
        *clang++ | *g++)
# g++ is clang++ on Darwin-11+
          toolsetarg_ser="toolset=clang"
	  ;;
        *g++-*)
# For the real g++ installations (ser, sersh using gcc from homebrew, e.g.)
# no toolset as have 'using' in user-config.jam
	  # toolsetarg_ser="toolset=darwin"
	  ;;
        *icpc) toolsetarg_ser="toolset=icpc";;
      esac
      ;;
    Linux-*)
      toolsetarg_pycsh="toolset=gcc"
      toolsetarg_pycst="toolset=gcc"
      case $CXX in
        *g++) ;;
        *icpc) toolsetarg_ser="toolset=intel";;
        *pgCC) toolsetarg_ser="toolset=pgi";;
        *xlC | *xlC_r) toolsetarg_ser="toolset=vacpp";;
      esac
      ;;
  esac
  toolsetarg_pycst=${toolsetarg_pycst:-"$toolsetarg_ser"}
  toolsetarg_pycsh=${toolsetarg_pycsh:-"$toolsetarg_ser"}
  techo "Boost toolsetarg_ser=${toolserarg_ser}"

# These args are actually to bilderBuild
  local BOOST_ALL_ADDL_ARGS="threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi --abbreviate-paths"
  local staticlinkargs="link=static"
  local sharedlinkargs="link=shared define=BOOST_TEST_DYN_LINK"
  local sermdlinkargs="link=static"  # Not yet used, but this should be right
  if [[ `uname` =~ CYGWIN ]]; then
    staticlinkargs="runtime-link=static $staticlinkargs"
    sharedlinkargs="runtime-link=shared $sharedlinkargs"
    sermdlinkargs="runtime-link=shared $sermdlinkargs"
    if $IS_64BIT; then
      BOOST_ALL_ADDL_ARGS="address-model=64 $BOOST_ALL_ADDL_ARGS"
    fi
  fi
# Only the shared and pycsh build boost python, as shared libs required.
# runtime-link=static gives the /MT flags, which does not work with python.
# boost_numpy fails to build with msvc in sersh so disable
  BOOST_SER_ADDL_ARGS="$toolsetarg_ser $staticlinkargs ${stdlibargs_ser} --without-python $BOOST_ALL_ADDL_ARGS"
  BOOST_SERSH_ADDL_ARGS="$toolsetarg_ser $sharedlinkargs ${stdlibargs_ser} --without-python $BOOST_ALL_ADDL_ARGS"
  BOOST_SERMD_ADDL_ARGS="$toolsetarg_ser $sermdlinkargs --without-python $BOOST_ALL_ADDL_ARGS"
  BOOST_PYCST_ADDL_ARGS="$toolsetarg_pycst $sermdlinkargs --without-python ${stdlibargs_pycst} $BOOST_ALL_ADDL_ARGS"
  BOOST_PYCSH_ADDL_ARGS="$toolsetarg_pycsh $sharedlinkargs ${stdlibargs_pycsh} $BOOST_ALL_ADDL_ARGS"
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

  if bilderConfig -i boost pycst; then
    fixBoost pycst
    bilderBuild -m ./b2 boost pycst "$BOOST_PYCST_ADDL_ARGS $BOOST_PYCST_OTHER_ARGS stage"
  fi

  if bilderConfig -i boost pycsh; then
    fixBoost pycsh
    bilderBuild -m ./b2 boost pycsh "$BOOST_PYCSH_ADDL_ARGS $BOOST_PYCSH_OTHER_ARGS stage"
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
# Fix installation name on Darwin
      echo "Working on `uname`-$bld."
      local lib=
      case `uname`-$bld in
        Darwin-sersh)
          techo "Fixing libraries in $CONTRIB_DIR/boost-${BOOST_BLDRVERSION}$sfx/lib."
          for lib in $CONTRIB_DIR/boost-${BOOST_BLDRVERSION}$sfx/lib/libboost*.dylib; do
            cmd="install_name_tool -id $lib $lib"
            techo "$cmd"
            $cmd
          done
          ;;
      esac
    fi
  done
}

