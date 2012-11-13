#!/bin/bash
#
# Version and build information for uedge
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################


######################################################################
#
# Other values
#
######################################################################

if test -z "$UEDGE_BUILDS"; then
  UEDGE_BUILDS=ser,par
  case `uname`-`uname -r` in
    Darwin-9.*)
# Cannot use tau for case of build substitution of CC
      ;;
    *)
      if $BUILD_OPTIONAL; then
        UEDGE_BUILDS=$UEDGE_BUILDS,nopetsc,partau
      fi
      ;;
  esac
fi
UEDGE_DEPS=facetsifc,txbase,fciowrappers,petsc,openmpi,metatau,babel,forthon,autotools
UEDGE_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/bin
addtopathvar PATH $CONTRIB_DIR/babel-shared/bin

######################################################################
#
# Launch uedge builds.
#
######################################################################

buildUedge() {

  getVersion uedge
  if bilderPreconfig uedge; then

# Disable shared on AIX and Darwin
    case `uname` in
      AIX )
        UEDGE_SER_OTHER_ARGS=${UEDGE_SER_OTHER_ARGS:-"--disable-shared --enable-static"}
        UEDGE_PAR_OTHER_ARGS=${UEDGE_PAR_OTHER_ARGS:-"--disable-shared --enable-static"}
        UEDGE_NOPETSC_OTHER_ARGS=${UEDGE_NOPETSC_OTHER_ARGS:-"--disable-shared --enable-static"}
        ;;
    esac

# Extra args for os x
    local UEDGE_BUILD_ARGS=
    if test -n "$MACHTYPE"; then
      UEDGE_BUILD_ARGS="MACHTYPE=$MACHTYPE"
    fi
    case `uname`-`uname -r` in
      Darwin-9.*)
        UEDGE_BUILD_ARGS="$UEDGE_BUILD_ARGS CC=gcc-4.0"
        ;;
    esac

# For BGP, need to add -I$CONTRIB_DIR/include to FFLAGS
   local UEDGE_COMPFLAGS_PAR
   if test -f $CONTRIB_DIR/include/mpi.mod; then
     UEDGE_COMPFLAGS_PAR=`echo $CONFIG_COMPFLAGS_PAR | sed "s?FFLAGS='?FFLAGS='-I$CONTRIB_DIR/include ?"`
   else
     UEDGE_COMPFLAGS_PAR="$CONFIG_COMPFLAGS_PAR"
   fi

# Order is longest to shortest to build
    if bilderConfig uedge partau "$CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR --enable-parallel $CPP_BABEL_ARG $CONFIG_LDFLAGS $UEDGE_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG --with-tau"; then
      rm -f $BUILD_DIR/uedge/partau/compfailures.txt	# File for debugging
bilderBuild uedge partau "$UEDGE_BUILD_ARGS"
    fi

    if bilderConfig uedge par "$CONFIG_COMPILERS_PAR $UEDGE_COMPFLAGS_PAR --enable-parallel $CPP_BABEL_ARG $CONFIG_LDFLAGS $UEDGE_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG"; then
      rm -f $BUILD_DIR/uedge/par/compfailures.txt	# File for debugging
      bilderBuild uedge par "$UEDGE_BUILD_ARGS FC=$BUILD_DIR/uedge/par/txutils/f90"
    fi

    if bilderConfig uedge ser "$CONFIG_COMPILERS_SER $CPP_BABEL_ARG FFLAGS='$FFLAGS' $CONFIG_LDFLAGS $UEDGE_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      rm -f $BUILD_DIR/uedge/ser/compfailures.txt
      bilderBuild uedge ser "$UEDGE_BUILD_ARGS FC=$BUILD_DIR/uedge/ser/txutils/f90"
    fi

    if bilderConfig uedge nopetsc "--disable-petsc $CONFIG_COMPILERS_SER $CPP_BABEL_ARG FFLAGS='$FFLAGS' $CONFIG_LDFLAGS $UEDGE_NOPETSC_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      rm -f $BUILD_DIR/uedge/nopetsc/compfailures.txt
      bilderBuild uedge nopetsc "$UEDGE_BUILD_ARGS FC=$BUILD_DIR/uedge/nopetsc/txutils/f90"
    fi

  fi

}

######################################################################
#
# Test uedge
#
######################################################################

testUedge() {
  bilderRunTests uedge UeTests
}

######################################################################
#
# Install uedge
#
######################################################################

installUedge() {
  bilderInstallTestedPkg -r -p open uedge UeTests
}

