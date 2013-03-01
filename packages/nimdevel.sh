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

NIMDEVEL_DEPS=fluxgrid,openmpi

# Build nimrod against SuperLU if cmake is used, otherwise we get
# SuperLU from Petsc. 
if $PREFER_CMAKE; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",superlu_dist,superlu,cmake"
else
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",petsc,autotools"
fi

######################################################################
#
# Add optional packages and builds
#
######################################################################

if $BUILD_DEBUG; then
  NIMDEVEL_BUILDS=${NIMDEVEL_BUILDS}",serdbg,pardbg"
fi
if $NIMDEVEL_SURFORIG; then
  NIMDEVEL_BUILDS=${NIMDEVEL_BUILDS}",sersurf,parsurf"
fi
if $NIMDEVEL_WITH_TAU; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",metatau"
fi
if $NIMDEVEL_WITH_OPENMP; then
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_OpenMP:BOOL=TRUE"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_OpenMP:BOOL=TRUE"
fi
# JRK - change to test -d $PROJECT_DIR/simyan ?
# remove simyan as svn:externals and add to external repos script.
if $NIMDEVEL_WITH_SIMYAN; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",simyan"
fi
if test -d $PROJECT_DIR/plasma_state; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",plasma_state"
  # These need to be fixed for cmake (and implemented in CMakeLists.txt)
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS --enable-plasmastate"
  NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS --enable-plasmastate"
fi
if test -d $PROJECT_DIR/genray; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",genray"
fi
if $PREFER_CMAKE; then
  if $NIMDEVEL_WITH_PETSC; then
    NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",petsc"
    NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_Petsc:BOOL=TRUE"
    NIMDEVEL_SER_OTHER_ARGS="$NIMDEVEL_SER_OTHER_ARGS -DENABLE_Petsc:BOOL=TRUE"
  fi
fi
if $NIMDEVEL_WITH_PYTHON; then
  NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",Python,scipy,tables,matplotlib,numpy"
fi
# No bilderized pastix yet - key off pastix in install directory
# but change to $PROJECT_DIR when pastix is bilderized.
if test -d $BLDR_INSTALL_DIR/pastix; then
  #NIMDEVEL_DEPS=${NIMDEVEL_DEPS}",pastix"
  NIMDEVEL_PAR_OTHER_ARGS="$NIMDEVEL_PAR_OTHER_ARGS -DENABLE_Pastix:BOOL=TRUE"
fi

######################################################################
#
# Add to paths
#
######################################################################
nimversion=nimdevel
addtopathvar PYTHONPATH $PROJECT_DIR/$nimversion/bin
addtopathvar PATH $PROJECT_DIR/$nimversion/bin
addtopathvar PATH $BLDR_INSTALL_DIR/$nimversion-par/bin
addtopathvar PATH $BLDR_INSTALL_DIR/$nimversion/bin

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
  if $PREFER_CMAKE; then
    local NIMDEVEL_PAR_ARGS="-DENABLE_PARALLEL:BOOL=TRUE $NIMDEVEL_PAR_OTHER_ARGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_LINLIB_BEN_ARGS $CMAKE_SUPRA_SP_ARG"
    local NIMDEVEL_SER_ARGS="$NIMDEVEL_SER_OTHER_ARGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_LINLIB_SER_ARGS $CMAKE_SUPRA_SP_ARG"
    if bilderPreconfig -c $nimversion; then
      if bilderConfig $nimversion par "-DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_PAR_ARGS"; then
        bilderBuild $nimversion par "$NIMDEVEL_MAKEJ_ARGS"
      fi
      if bilderConfig $nimversion ser "-DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_SER_ARGS"; then
        bilderBuild $nimversion ser "$NIMDEVEL_MAKEJ_ARGS"
      fi
      if bilderConfig $nimversion partau "-DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_PARTAU_COMPILERS $CMAKE_COMPFLAGS_PAR $NIMDEVEL_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_LINLIB_BEN_ARGS $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild $nimversion partau "$NIMDEVEL_PARTAU_BUILD_ENV" "$NIMDEVEL_MAKEJ_ARGS"
      fi
      if $BUILD_DEBUG; then
        if bilderConfig $nimversion pardbg "-DDEBUG:BOOL=TRUE -DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_PAR_ARGS"; then
          bilderBuild $nimversion pardbg "$NIMDEVEL_MAKEJ_ARGS"
        fi
        if bilderConfig $nimversion serdbg "-DDEBUG:BOOL=TRUE -DUSE_LE_SURFACE:BOOL=TRUE $NIMDEVEL_SER_ARGS"; then
          bilderBuild $nimversion serdbg "$NIMDEVEL_MAKEJ_ARGS"
        fi
      fi
      if $NIMDEVEL_SURFORIG; then
        if bilderConfig  $nimversion parsurf "-DUSE_LE_SURFACE:BOOL=FALSE $NIMDEVEL_PAR_ARGS"; then
          bilderBuild $nimversion parsurf "$NIMDEVEL_MAKEJ_ARGS"
        fi
        if bilderConfig $nimversion sersurf "-DUSE_LE_SURFACE:BOOL=FALSE $NIMDEVEL_SER_ARGS"; then
          bilderBuild $nimversion sersurf "$NIMDEVEL_MAKEJ_ARGS"
        fi
      fi
    fi
  else # PREFER_CMAKE = false
    if bilderPreconfig $nimversion; then
      if bilderConfig  $nimversion par "--enable-parallel $CONFIG_COMPILERS_PAR $NIMDEVEL_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_LINLIB_BEN_ARGS $CONFIG_SUPRA_SP_ARG"; then
        bilderBuild $nimversion par
      fi
      if bilderConfig $nimversion ser "$CONFIG_COMPILERS_SER $NIMDEVEL_SER_OTHER_ARGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_SUPRA_SP_ARG $CONFIG_LINLIB_SER_ARGS"; then
        bilderBuild $nimversion ser
      fi
      if $BUILD_DEBUG; then
        if bilderConfig  $nimversion pardbg "--with-optimization=debug --enable-parallel $CONFIG_COMPILERS_PAR $NIMDEVEL_PAR_OTHER_ARGS $CONFIG_LINLIB_BEN_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG"; then
          bilderBuild $nimversion pardbg
        fi
        if bilderConfig $nimversion serdbg "--with-optimization=debug $CONFIG_COMPILERS_SER $NIMDEVEL_SER_OTHER_ARGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_LINLIB_SER_ARGS $CONFIG_SUPRA_SP_ARG"; then
          bilderBuild $nimversion serdbg
        fi
      fi
      if $NIMDEVEL_SURFORIG; then
        if bilderConfig  $nimversion parsurf "--enable-parallel $CONFIG_COMPILERS_PAR $NIMDEVEL_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG $CONFIG_LINLIB_SER_ARGS --enable-surforig"; then
          bilderBuild $nimversion parsurf
        fi
        if bilderConfig $nimversion sersurf "$CONFIG_COMPILERS_SER $NIMDEVEL_SER_OTHER_ARGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_SUPRA_SP_ARG $CONFIG_LINLIB_SER_ARGS --enable-surforig"; then
          bilderBuild $nimversion sersurf
        fi
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
  local NIMDEVEL_ALL_BUILDS="ser par serdbg pardbg partau sersurforig parsurforig"
  for bld in $NIMDEVEL_ALL_BUILDS; do
    if bilderInstall $nimversion $bld; then
      local instdir=$BLDR_INSTALL_DIR/$nimversion-${NIMDEVEL_BLDRVERSION}-${bld}
      setOpenPerms $instdir
    fi
  done
}
