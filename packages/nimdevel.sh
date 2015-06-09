#!/bin/bash
#
# Version and build information for nimdevel
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Other values
#
######################################################################

NIMDEVEL_BUILDS=${NIMDEVEL_BUILDS:-"ser,par"}
# don't include autotools -- for testing only
NIMDEVEL_DEPS=$MPI_BUILD,fciowrappers,superlu,cmake
NIMDEVEL_UMASK=002
nimversion=nimdevel

######################################################################
#
# Add optional packages and builds
#
######################################################################

if $NIMDEVEL_WITH_OPENMP; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",superlu_dist4" # CUDA/OpenMP enabled
else
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",netlib_lite,superlu_dist3"
fi
if $BUILD_DEBUG; then
  NIMDEVEL_BUILDS=${NIMDEVEL_BUILDS}",serdbg,pardbg"
fi
if $NIMDEVEL_SURFORIG; then
  NIMDEVEL_BUILDS=${NIMDEVEL_BUILDS}",sersurf,parsurf"
fi
if $NIMDEVEL_WITH_GRIN; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",grin"
fi
if $NIMDEVEL_WITH_TAU; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",metatau"
fi
if $NIMDEVEL_WITH_OPENMP; then
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_OpenMP:BOOL=TRUE"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_OpenMP:BOOL=TRUE"
else 
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_OpenMP:BOOL=FALSE"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_OpenMP:BOOL=FALSE"
fi
if $NIMDEVEL_WITH_FFTW; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",fftw3"
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_FFTW:BOOL=TRUE"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_FFTW:BOOL=TRUE"
else
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_FFTW:BOOL=FALSE"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_FFTW:BOOL=FALSE"
fi
if $NIMDEVEL_NATIVE_ENDIAN; then
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_NATIVE_ENDIAN:BOOL=TRUE"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_NATIVE_ENDIAN:BOOL=TRUE"
fi
if $NIMDEVEL_WITH_PYTHON; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",Python,scipy,tables,matplotlib,numpy"
fi

######################################################################
#
# Build with the following options if installed or source is present
#
######################################################################

if test -d $BLDR_INSTALL_DIR/simyan; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",simyan"
fi
if test -d $PROJECT_DIR/plasma_state; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",plasma_state"
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_PlasmaState:BOOL=TRUE"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_PlasmaState:BOOL=TRUE"
fi
if test -d $PROJECT_DIR/genray; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",genray"
fi
if test -d $BLDR_INSTALL_DIR/pastix; then
  #NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",pastix"
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_Pastix:BOOL=TRUE"
fi

######################################################################
#
# Launch nimdevel builds.
#
######################################################################

buildNimdevel() {
  # Find tau here as it may have been built as a dependency by bilder. 
  if $NIMDEVEL_WITH_TAU; then
    NIMDEVEL_PARTAU_COMPILERS=${NIMDEVEL_PARTAU_COMPILERS:-"-DCMAKE_C_COMPILER:FILEPATH=`which taucc` -DCMAKE_CXX_COMPILER:FILEPATH=`which taucc` -DCMAKE_Fortran_COMPILER:FILEPATH=`which tauf90`"}
    if test -z "$TAU_MAKEFILE"; then
      techo "No tau makefile specified.  I'll try to find one, but it is best to specify one on the command line with -E TAU_MAKEFILE=\"</path-to-makefile/Makefile-*>\"."
      # Find an appropriate tau makefile.
      # Check the contrib and install directories but do not include python files, 
      # the awk statement puts everything on one line, an the sed statement trims 
      # down to the first acceptable file.
      TAU_MAKEFILE=`ls -m --hide=python /{${CONTRIB_DIR},${BLDR_INSTALL_DIR}}/tau/lib/Makefile.tau* 2> /dev/null |  awk '{ ORS="|"; print; }' | sed 's/,.*//'`
    fi
    if test -a $TAU_MAKEFILE; then
      techo "Using tau makefile ${TAU_MAKEFILE}"
      NIMDEVEL_PARTAU_BUILD_ENV=${NIMDEVEL_PARTAU_BUILD_ENV:-"TAU_MAKEFILE=\"${TAU_MAKEFILE}\" TAU_OPTIONS=\"-optCompInst -optVerbose\""}
      NIMDEVEL_BUILDS=${NIMDEVEL_BUILDS}",partau"
    else
      techo "Tau makefile not found, I tried TAU_MAKEFILE=${TAU_MAKEFILE}"
    fi
  fi

  getVersion $nimversion
  local NIMDEVEL_PAR_ARGS="-DENABLE_PARALLEL:BOOL=TRUE -DTRAP_FP_EXCEPTIONS:BOOL=FALSE -DENABLE_IOLibs:BOOL=TRUE -DENABLE_Lapack:BOOL=TRUE $NIMDEVEL_PAR_OTHER_ARGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_LINLIB_BEN_ARGS $CMAKE_SUPRA_SP_ARG"
  local NIMDEVEL_SER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DTRAP_FP_EXCEPTIONS:BOOL=FALSE -DENABLE_IOLibs:BOOL=TRUE -DENABLE_Lapack:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_LINLIB_SER_ARGS $CMAKE_SUPRA_SP_ARG"
  if bilderPreconfig -c $nimversion; then
    if bilderConfig $nimversion par "-DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_PAR_ARGS" $nimversion; then
      bilderBuild $nimversion par "$NIMDEVEL_MAKEJ_ARGS"
    fi
    if bilderConfig $nimversion ser "-DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_SER_ARGS" $nimversion; then
      bilderBuild $nimversion ser "$NIMDEVEL_MAKEJ_ARGS"
    fi
    if bilderConfig $nimversion partau "-DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_PARTAU_COMPILERS $CMAKE_COMPFLAGS_PAR $NIMDEVEL_PAR_OTHER_ARGS $CMAKE_LINLIB_BEN_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild $nimversion partau "$NIMDEVEL_PARTAU_BUILD_ENV" "$NIMDEVEL_MAKEJ_ARGS"
    fi
    if $BUILD_DEBUG; then
      if bilderConfig $nimversion pardbg "-DDEBUG:BOOL=TRUE -DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_PAR_ARGS" $nimversion-dbg; then
        bilderBuild $nimversion pardbg "$NIMDEVEL_MAKEJ_ARGS"
      fi
      if bilderConfig $nimversion serdbg "-DDEBUG:BOOL=TRUE -DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_SER_ARGS" $nimversion-dbg; then
        bilderBuild $nimversion serdbg "$NIMDEVEL_MAKEJ_ARGS"
      fi
    fi
    if $NIMDEVEL_SURFORIG; then
      if bilderConfig  $nimversion parsurf "-DUSE_LE_SURFACE:BOOL=FALSE $NIMDEVEL_PAR_ARGS" $nimversion-surf; then
        bilderBuild $nimversion parsurf "$NIMDEVEL_MAKEJ_ARGS"
      fi
      if bilderConfig $nimversion sersurf "-DUSE_LE_SURFACE:BOOL=FALSE $NIMDEVEL_SER_ARGS" $nimversion-surf; then
        bilderBuild $nimversion sersurf "$NIMDEVEL_MAKEJ_ARGS"
      fi
    fi
  fi
}

######################################################################
#
# Test nimdevel
#
######################################################################

testNimdevel() {
  bilderRunTests $nimversion NimTests
}

######################################################################
#
# Install nimdevel
#
######################################################################

installNimdevel() {
  local nim_builds=`echo "$NIMDEVEL_BUILDS" | sed 's/,/ /g'`
  for build in $nim_builds; do
    bilderInstall -p open $nimversion $build
  done

  addtopathvar PATH $BLDR_INSTALL_DIR/$nimversion/bin
  addtopathvar PATH $BLDR_INSTALL_DIR/$nimversion/scripts
}

