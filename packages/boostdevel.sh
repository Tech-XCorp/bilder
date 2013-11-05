#!/bin/bash
#
# Version and build information for boost
#
# $Id: boost.sh 337 2013-08-02 23:32:38Z swsides $
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
BOOSTDEVEL_BLDRVERSION_STD=1_53_0

######################################################################
#
# Other values
#
######################################################################

if test -z "$BOOSTDEVEL_DESIRED_BUILDS"; then
  BOOSTDEVEL_DESIRED_BUILDS=ser
  # No need for shared library unless that is the library for Python
  if isCcCc4py; then
      BOOSTDEVEL_DESIRED_BUILDS=$BOOSTDEVEL_DESIRED_BUILDS,parsh
  fi
fi

computeBuilds boostdevel
addCc4pyBuild boostdevel
# It does not hurt to add deps that do not get built
# (e.g., Python on Darwin and CYGWIN)
# Only certain builds depend on Python
BOOSTDEVEL_DEPS=Python,bzip2

######################################################################
#
# Launch boostdevel builds.
#
######################################################################

buildBoostdevel() {

# Look for needed packages
  case `uname` in
    Linux)
      if ! test -f /usr/include/bzlib.h; then
        techo "WARNING: May need to install bzip2-devel."
      fi
      ;;
  esac

# Process
  if bilderUnpack -i boostdevel; then

    # Determine the toolset
    local toolsetarg_ser=
    local toolsetarg_cc4py=
    case `uname`-`uname -r` in
      Darwin-12.*)
      # Clang works for g++ as well on Darwin-12
        toolsetarg_ser="toolset=clang"
        ;;
      Darwin-*)
        case $CXX in
          *clang++) toolsetarg_ser="toolset=clang";;
          *g++) ;;
        esac
        ;;
      Linux-*)
        toolsetarg_cc4py="toolset=gcc"
        case $CXX in
          *g++) ;;
          *icpc) toolsetarg_ser="toolset=intel";;
          *pgCC) toolsetarg_ser="toolset=pgi";;
        esac
        ;;
    esac

    # These args are actually to bilderBuild
    # local BOOSTDEVEL_ALL_ADDL_ARGS="threading=multi variant=release -s NO_COMPRESSION=1 --layout=system"

    # Only the shared and cc4py build boostdevel python, as shared libs required.
    # runtime-link=static gives the /MT flags.  For simplicity, use for all.
    BOOSTDEVEL_SER_ADDL_ARGS="$toolsetarg_ser     link=static --without-python --without-mpi $BOOSTDEVEL_ALL_ADDL_ARGS"
    BOOSTDEVEL_SERSH_ADDL_ARGS="$toolsetarg_ser   link=shared                  --without-mpi $BOOSTDEVEL_ALL_ADDL_ARGS"

    # Parallel enabled through mpi flags to bootstrap... but MPI wrappers must be in path (?)
    # For now parallel only needed by python enabled. serial toolset same for par for now
    toolsetarg_parsh="$toolsetarg_ser"
    # BOOSTDEVEL_PARSH_ADDL_ARGS="$toolsetarg_ser link=shared   $BOOSTDEVEL_ALL_ADDL_ARGS"
    BOOSTDEVEL_PARSH_ADDL_ARGS=

    if bilderConfig -i boostdevel ser; then
      # In-place build, so done now
      bilderBuild -m ./b2 boostdevel ser "$BOOSTDEVEL_SER_ADDL_ARGS"
    fi

    if bilderConfig -i boostdevel sersh; then
      bilderBuild -m ./b2 boostdevel sersh "$BOOSTDEVEL_SERSH_ADDL_ARGS"
    fi

    if bilderConfig -i boostdevel parsh; then
      # Redo bootstrap (config cmd above is hard-wired to do --show-libraries, which does nothing)
      $BUILD_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION_STD/parsh/bootstrap.sh
      # Adds 'using mpi ;" line to user-config.jam in parsh build dir
      echo "Running edit on $BUILD_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION_STD/parsh/tools/build/v2/user-config.jam"
      echo -e "\nusing mpi ;" >> $BUILD_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION_STD/parsh/tools/build/v2/user-config.jam
      bilderBuild -m ./b2 boostdevel parsh
      # bilderBuild -m ./b2 boostdevel parsh "$BOOSTDEVEL_PARSH_ADDL_ARGS"
    fi

  fi
}

######################################################################
#
# Test boostdevel
#
######################################################################
testBoostdevel() {
  techo "Not testing boostdevel."
}

######################################################################
#
# Install boostdevel
#
######################################################################

#
# Find the BOOST includes
#
findBoostdevel() {
  if test -z "$BOOSTDEVEL_BLDRVERSION"; then
    source $BILDER_DIR/packages/boostdevel.sh
  fi
  if test -L $CONTRIB_DIR/boostdevel -o -d $CONTRIB_DIR/boostdevel; then
    local boostdevelincdir=`(cd $CONTRIB_DIR/boostdevel/include; pwd -P)`
    BOOSTDEVEL_INCDIR_ARG="-DBoostdevel_INCLUDE_DIR='$boostdevelincdir'"
  fi
}


installBoostdevel() {
  for bld in `echo $BOOSTDEVEL_BUILDS | tr ',' ' '`; do
    local boostdevel_instdir=$CONTRIB_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION-$bld
    # local boostdevel_mixed_instdir=
    # For b2, installation directory must be added at install time,
    # and it is relative to the C: root.
    local sfx=
    local instargs=
    case $bld in
      ser) instargs="$BOOSTDEVEL_SER_ADDL_ARGS";;
      sersh) sfx=-sersh; instargs="$BOOSTDEVEL_SERSH_ADDL_ARGS";;
      parsh) sfx=-parsh; instargs="$BOOSTDEVEL_PARSH_ADDL_ARGS";;
      cc4py) sfx=-cc4py; instargs="$BOOSTDEVEL_CC4PY_ADDL_ARGS";;
    esac
    if bilderInstall -m ./b2 boostdevel $bld boostdevel${sfx} "$instargs --prefix=$boostdevel_instdir"; then
      setOpenPerms $boostdevel_instdir
      findBoostdevel
    fi
  done
}
