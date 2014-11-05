#!/bin/bash
#
# Version and build information for boost
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# version 1_50_0 does not build with Intel compiler on windows (Pletzer)
# BOOSTDEVEL_BLDRVERSION_STD=1_53_0
BOOSTDEVEL_BLDRVERSION_STD=1_54_0

######################################################################
#
# Other values
#
######################################################################

if test -z "$BOOSTDEVEL_DESIRED_BUILDS"; then
#  BOOSTDEVEL_DESIRED_BUILDS=ser,parsh
  BOOSTDEVEL_DESIRED_BUILDS=parsh
  # No need for shared library unless that is the library for Python
  #  if isCcPyc; then
  #    BOOSTDEVEL_DESIRED_BUILDS=$BOOSTDEVEL_DESIRED_BUILDS,parsh
  # fi
fi

# computeBuilds boostdevel
# addCc4pyBuild boostdevel
BOOSTDEVEL_BUILDS=$BOOSTDEVEL_DESIRED_BUILDS

# It does not hurt to add deps that do not get built
# (e.g., Python on Darwin and CYGWIN)
# Only certain builds depend on Python
# BOOSTDEVEL_DEPS=Python,bzip2
BOOSTDEVEL_DEPS=bzip2

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
    local toolsetarg_pycsh=
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
        toolsetarg_pycsh="toolset=gcc"
        case $CXX in
          *g++) ;;
          *icc) toolsetarg_ser="toolset=intel-linux";;
          *pgCC) toolsetarg_ser="toolset=pgi";;
        esac
        ;;
    esac

    # These args are actually to bilderBuild
    # local BOOSTDEVEL_ALL_ADDL_ARGS="threading=multi variant=release -s NO_COMPRESSION=1 --layout=system"

    # Only the shared and pycsh build boostdevel python, as shared libs required.
    # runtime-link=static gives the /MT flags.  For simplicity, use for all.
    BOOSTDEVEL_SER_ADDL_ARGS="$toolsetarg_ser     link=static --without-python --without-mpi $BOOSTDEVEL_ALL_ADDL_ARGS"
    BOOSTDEVEL_SERSH_ADDL_ARGS="$toolsetarg_ser   link=shared                  --without-mpi $BOOSTDEVEL_ALL_ADDL_ARGS"

    # Parallel enabled through mpi flags to bootstrap... but MPI wrappers must be in path (?)
    # For now parallel only needed by python enabled. serial toolset same for par for now
    # BOOSTDEVEL_PARSH_ADDL_ARGS="$toolsetarg_ser link=shared   $BOOSTDEVEL_ALL_ADDL_ARGS"
    toolsetarg_parsh="$toolsetarg_ser"
    BOOSTDEVEL_PARSH_ADDL_ARGS=$toolsetarg_parsh

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

      # Selecting correct user-config.jam line
      # Adds 'using mpi ;" line to user-config.jam in parsh build dir
      DOMAIN_NAME=`hostname -d`
      case $DOMAIN_NAME in
	  hpc.nrel.gov )
	      techo "boostdevel.sh: Assuming Peregrine"
              # MPICXX should be set by module (intel too?)
	      jamCmd=`echo -e "\nusing mpi : $MPICXX ;" >> $BUILD_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION_STD/parsh/tools/build/v2/user-config.jam`
	      ;;
	  * )
	      techo "boostdevel.sh: Assuming default linux"
	      jamCmd=`echo -e "\nusing mpi ;" >> $BUILD_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION_STD/parsh/tools/build/v2/user-config.jam`
      esac

      techo " "
      techo "Will do $jamCmd"
      techo "Running edit on $BUILD_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION_STD/parsh/tools/build/v2/user-config.jam"
      techo " "
      $jamCmd
      bilderBuild -m ./b2 boostdevel parsh  "$BOOSTDEVEL_PARSH_ADDL_ARGS"
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
      pycsh) sfx=-pycsh; instargs="$BOOSTDEVEL_PYCSH_ADDL_ARGS";;
    esac
    if bilderInstall -m ./b2 boostdevel $bld boostdevel${sfx} "$instargs --prefix=$boostdevel_instdir"; then
      setOpenPerms $boostdevel_instdir
      findBoostdevel
    fi

    # Creates link in a 'boost' directory for backward compatibility eg 'import boost.mpi'
    # only for parsh version. Note: these paths are dependent for use on module settings
    case $bld in
      parsh) 
        local boostdevel_instdir=$CONTRIB_DIR/boostdevel-$BOOSTDEVEL_BLDRVERSION-$bld
	mkdir $boostdevel_instdir/lib/boost
	ln -s $boostdevel_instdir/lib/mpi.so $boostdevel_instdir/lib/boost
	touch $boostdevel_instdir/lib/boost/__init__.py
	;;
    esac

  done
}
