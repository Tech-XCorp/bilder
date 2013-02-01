#!/bin/bash
#
# Version and build information for nimrod
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

NIMROD_BUILDS=${NIMROD_BUILDS:-"ser,par"}

# NIMROD is different in that I'm trying to get this script to support
# multiple versions and builds.  This means that nimrod.sh should be
# able to build nimuw, nimpsi, nimdevel.  These latter are referred to
# as nimversion.  Support is still ongoing.

# JRK -
# Bilder matches the package name to the script in bilder/packages/*.sh
# to determine the script version. Using nimrod.sh and 
# nimversion=nimdevel means bilder can't determine the script revision
# and will always rebuild nimrod. However bilder also checks for
# the svn repo named nimversion. Thus either we should change the package
# script name, or the repo. 
#
# One solution would be to link the repo
# we want to build as 'nimrod'. And then copy the install directory
# to the appropriate name after the install. For now, I'm just building
# nimdevel as nimrod.
#
# Another potential solution is to make two new scripts: nimdevel.sh
# and nimuw.sh that contain specific stuff for those builds. Those
# scripts would then source shared build stuff from nimrod.sh.
#
nimversion=nimrod

# Do this by hand -- I'm not good enough to do this in bash
# Define $nimversion_BUILDS
NIMDEVEL_BUILDS=$NIMROD_BUILDS

# Build nimrod against SuperLU if cmake is used, otherwise we get
# SuperLU from Petsc. Don't build with simyan by default as that
# brings Trilinos and Dakota into the build chain and most users
# do not require these packages.
NIMROD_DEPS=fluxgrid,openmpi #,simyan

if $PREFER_CMAKE; then
  NIMROD_DEPS=${NIMROD_DEPS}",superlu_dist,superlu,cmake"
else
  NIMROD_DEPS=${NIMROD_DEPS}",petsc,autotools"
fi

######################################################################
#
# Add optional packages and builds
#
######################################################################

if $BUILD_DEBUG; then
  NIMROD_BUILDS=${NIMROD_BUILDS}",serdbg,pardbg"
fi
if $BUILD_SURFORIG; then
  NIMROD_BUILDS=${NIMROD_BUILDS}",sersurf,parsurf"
fi
if $NIMROD_WITH_TAU; then
  NIMROD_DEPS=${NIMROD_DEPS}",metatau"
fi
if test -d $PROJECT_DIR/plasma_state; then
  NIMROD_DEPS=${NIMROD_DEPS}",plasma_state"
  # These need to be fixed for cmake (and implemented in CMakeLists.txt)
  NIMROD_PAR_OTHER_ARGS="$NIMROD_PAR_OTHER_ARGS --enable-plasmastate"
  NIMROD_SER_OTHER_ARGS="$NIMROD_SER_OTHER_ARGS --enable-plasmastate"
fi
if test -d $PROJECT_DIR/genray; then
  NIMROD_DEPS=${NIMROD_DEPS}",genray"
fi
if $PREFER_CMAKE; then
  if $NIMROD_WITH_PETSC; then
    NIMROD_DEPS=${NIMROD_DEPS}",petsc"
    NIMROD_PAR_OTHER_ARGS="$NIMROD_PAR_OTHER_ARGS -DENABLE_Petsc:BOOL=TRUE"
    NIMROD_SER_OTHER_ARGS="$NIMROD_SER_OTHER_ARGS -DENABLE_Petsc:BOOL=TRUE"
  fi
fi
if $BUILD_SLEPC; then
  NIMROD_DEPS=${NIMROD_DEPS}",slepc"
fi
if $NIMROD_WITH_PYTHON; then
  NIMROD_DEPS=${NIMROD_DEPS}",Python,scipy,tables,matplotlib,numpy"
fi

# No bilderized pastix yet - key off pastix in install directory
# but change to $PROJECT_DIR when pastix is bilderized.
if test -d $BLDR_INSTALL_DIR/pastix; then
  #NIMROD_DEPS=${NIMROD_DEPS}",pastix"
  NIMROD_PAR_OTHER_ARGS="$NIMROD_PAR_OTHER_ARGS -DENABLE_PASTIX"
fi

cd $PROJECT_DIR
if test -d nimfiles; then
  for dir in `ls -d nimfiles/*`; do
     label=`basename $dir`
     currentbuild="par"$label
     NIMROD_BUILDS=${NIMROD_BUILDS}","$currentbuild
     currentbuild="ser"$label
     NIMROD_BUILDS=${NIMROD_BUILDS}","$currentbuild
  done
fi

######################################################################
#
# Add to paths
#
######################################################################
addtopathvar PYTHONPATH $PROJECT_DIR/$nimversion/bin
addtopathvar PATH $PROJECT_DIR/$nimversion/bin
addtopathvar PATH $BLDR_INSTALL_DIR/$nimversion-par/bin
addtopathvar PATH $BLDR_INSTALL_DIR/$nimversion/bin

# JRK - is this function still needed?
nimrodCpfiles() {
  nimfile_dir=$1
  nimbld_dir=$2
  local this_bilder_startdir=$PWD
  cd $2
  # Copy files -- assuming max of two levels to avoid writing
  # recursion function.  Recall we are in builddir now.
  for cpfile_dir in `ls -d $nimfile_dir/*`; do
    if [ ! -d $cpfile_dir ]; then
      cp $cpfile_dir .
    else
      subdir1=`basename $cpfile_dir`
      for subfile_dir in `ls -d $nimfile_dir/$subdir1/*`; do
        if [ ! -d $subfile_dir ]; then
          ln -sf $subfile_dir $subdir1/
        else
          subdir2=`basename $subfile_dir`
          for subsubfile in `ls $subfile_dir/*`; do
            ln -sf $subsubfile $subdir1/$subdir2/
          done
        fi
      done
    fi
  done
  cd $this_bilder_startdir
}

######################################################################
#
# Launch nimrod builds.
#
######################################################################

buildNimrod() {
  # Find tau here as it may have been built as a dependency by bilder. 
  if $BUILD_OPTIONAL; then
    if $PREFER_CMAKE; then
      NIMROD_PARTAU_COMPILERS=${NIMROD_PARTAU_COMPILERS:-"-DCMAKE_C_COMPILER:FILEPATH=`which taucc` -DCMAKE_CXX_COMPILER:FILEPATH=`which taucc` -DCMAKE_Fortran_COMPILER:FILEPATH=`which tauf90`"}
    else
      NIMROD_PARTAU_BUILD_ARG=${NIMROD_PARTAU_BUILD_ARG:-"CC=taucc FC=tauf90 F77=tau_f77.sh LC_LD=tauf90 CXXLD=taucc FC_LD=tauf90"}
    fi
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
      NIMROD_PARTAU_BUILD_ENV=${NIMROD_PARTAU_BUILD_ENV:-"TAU_MAKEFILE=\"${TAU_MAKEFILE}\" TAU_OPTIONS=\"-optCompInst -optVerbose\""}
      NIMROD_BUILDS=${NIMROD_BUILDS}",partau"
    else
      techo "Tau makefile not found, I tried TAU_MAKEFILE=${TAU_MAKEFILE}"
    fi
  fi

  getVersion $nimversion
  if $PREFER_CMAKE; then
    local NIMROD_PAR_ARGS="-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $NIMROD_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_LINLIB_SER_ARGS $CMAKE_SUPRA_SP_ARG"
    local NIMROD_SER_ARGS="$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $NIMROD_SER_OTHER_ARGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $CMAKE_LINLIB_SER_ARGS"
    if bilderPreconfig -c $nimversion; then
      if bilderConfig $nimversion par "-DUSE_LE_SURFACE:BOOL=TRUE $NIMROD_PAR_ARGS"; then
        bilderBuild $nimversion par "$NIMROD_MAKEJ_ARGS"
      fi
      if bilderConfig $nimversion ser "-DUSE_LE_SURFACE:BOOL=TRUE $NIMROD_SER_ARGS"; then
        bilderBuild $nimversion ser "$NIMROD_MAKEJ_ARGS"
      fi
      if bilderConfig $nimversion partau "-DUSE_LE_SURFACE:BOOL=TRUE $NIMROD_PARTAU_COMPILERS $CMAKE_COMPFLAGS_PAR $NIMROD_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_LINLIB_SER_ARGS $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild $nimversion partau "$NIMROD_PARTAU_BUILD_ENV"
      fi
      if $BUILD_DEBUG; then
        if bilderConfig $nimversion pardbg "-DDEBUG:BOOL=TRUE -DUSE_LE_SURFACE:BOOL=TRUE $NIMROD_PAR_ARGS"; then
          bilderBuild $nimversion pardbg "$NIMROD_MAKEJ_ARGS"
        fi
        if bilderConfig $nimversion serdbg "-DDEBUG:BOOL=TRUE -DUSE_LE_SURFACE:BOOL=TRUE $NIMROD_SER_ARGS"; then
          bilderBuild $nimversion serdbg "$NIMROD_MAKEJ_ARGS"
        fi
      fi
      if $BUILD_SURFORIG; then
        if bilderConfig  $nimversion parsurf "-DUSE_LE_SURFACE:BOOL=FALSE $NIMROD_PAR_ARGS"; then
          bilderBuild $nimversion parsurf "$NIMROD_MAKEJ_ARGS"
        fi
        if bilderConfig $nimversion sersurf "-DUSE_LE_SURFACE:BOOL=FALSE $NIMROD_SER_ARGS"; then
          bilderBuild $nimversion sersurf "$NIMROD_MAKEJ_ARGS"
        fi
      fi
    fi
  else # PREFER_CMAKE = false
    if bilderPreconfig $nimversion; then
      if bilderConfig  $nimversion par "--enable-parallel $CONFIG_COMPILERS_PAR $NIMROD_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_LINLIB_SER_ARGS $CONFIG_SUPRA_SP_ARG"; then
        bilderBuild $nimversion par
      fi
      if bilderConfig $nimversion ser "$CONFIG_COMPILERS_SER $NIMROD_SER_OTHER_ARGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_SUPRA_SP_ARG $CONFIG_LINLIB_SER_ARGS"; then
        bilderBuild $nimversion ser
      fi
      if $BUILD_DEBUG; then
        if bilderConfig  $nimversion pardbg "--with-optimization=debug --enable-parallel $CONFIG_COMPILERS_PAR $NIMROD_PAR_OTHER_ARGS $CONFIG_LINLIB_SER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG"; then
          bilderBuild $nimversion pardbg
        fi
        if bilderConfig $nimversion serdbg "--with-optimization=debug $CONFIG_COMPILERS_SER $NIMROD_SER_OTHER_ARGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_LINLIB_SER_ARGS $CONFIG_SUPRA_SP_ARG"; then
          bilderBuild $nimversion serdbg
        fi
      fi
      if bilderConfig  $nimversion partau "--enable-parallel $CONFIG_COMPILERS_PAR $NIMROD_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_LINLIB_SER_ARGS $CONFIG_SUPRA_SP_ARG"; then
        bilderBuild $nimversion partau "$NIMROD_PARTAU_BUILD_ARG" "$NIMROD_PARTAU_BUILD_ENV"
      fi
      if $BUILD_SURFORIG; then
        if bilderConfig  $nimversion parsurf "--enable-parallel $CONFIG_COMPILERS_PAR $NIMROD_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG $CONFIG_LINLIB_SER_ARGS --enable-surforig"; then
          bilderBuild $nimversion parsurf
        fi
        if bilderConfig $nimversion sersurf "$CONFIG_COMPILERS_SER $NIMROD_SER_OTHER_ARGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_SUPRA_SP_ARG $CONFIG_LINLIB_SER_ARGS --enable-surforig"; then
          bilderBuild $nimversion sersurf
        fi
      fi
    fi
    cd $PROJECT_DIR
    if test -d nimfiles; then
      for dir in `ls -d nimfiles/*`; do
         label=`basename $dir`
         currentbuild="par"$label
         if bilderConfig  $nimversion $currentbuild "--enable-debug --enable-parallel $CONFIG_COMPILERS_PAR $NIMROD_PAR_OTHER_ARGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG"; then
           nimrodCpfiles $PROJECT_DIR/$dir $BUILD_DIR/$nimversion/$currentbuild
           bilderBuild $nimversion $currentbuild
         fi
         currentbuild="ser"$label
         if bilderConfig $nimversion $currentbuild "--enable-debug $CONFIG_COMPILERS_SER $NIMROD_SER_OTHER_ARGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_SUPRA_SP_ARG"; then
           nimrodCpfiles $PROJECT_DIR/$dir $BUILD_DIR/$nimversion/$currentbuild

           bilderBuild $nimversion $currentbuild
         fi
       done
    fi
  fi
}

######################################################################
#
# Test nimrod
#
######################################################################

testNimrod() {
  bilderRunTests $nimversion NimTests
}

######################################################################
#
# Install nimrod
#
######################################################################

installNimrod() {
  local NIMROD_ALL_BUILDS="ser par serdbg pardbg partau sersurforig parsurforig"
  for bld in $NIMROD_ALL_BUILDS; do
    if bilderInstall $nimversion $bld; then
      local instdir=$BLDR_INSTALL_DIR/$nimversion-${NIMROD_BLDRVERSION}-${bld}
      setOpenPerms $instdir
    fi
  done
  cd $PROJECT_DIR
  if test -d nimfiles; then
    for dir in `ls -d nimfiles/*`; do
      label=`basename $dir`
      currentbuild="par"$label
      bilderInstall $acceptArg $nimversion $currentbuild $nimversion-$currentbuild
      currentbuild="ser"$label
      bilderInstall $acceptArg $nimversion $currentbuild $nimversion-$currentbuild
    done
  fi
}
