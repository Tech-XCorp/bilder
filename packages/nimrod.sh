#!/bin/bash
#
# Version and build information for nimrod
#
# $Id: nimrod.sh 6699 2012-09-19 19:04:13Z alexanda $
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
# It can build without anything but we may want to change it for now
NIMROD_DEPS=fluxgrid,petsc,autotools,openmpi #,simyan
# If -O flag is specified, build tau instrumented version
if $BUILD_OPTIONAL; then
  NIMROD_DEPS=${NIMROD_DEPS}",metatau"
  NIMROD_PARTAU_BUILD_ARG=${NIMROD_PARTAU_BUILD_ARG:-"CC=taucc FC=tauf90 F77=tau_f77.sh LC_LD=tauf90 CXXLD=taucc FC_LD=tauf90"}
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
if test -d $PROJECT_DIR/plasma_state; then
  NIMROD_DEPS=${NIMROD_DEPS}",plasma_state"
  NIMROD_PAR_OTHER_ARGS="$NIMROD_PAR_OTHER_ARGS --enable-plasmastate"
  NIMROD_SER_OTHER_ARGS="$NIMROD_SER_OTHER_ARGS --enable-plasmastate"
fi
if test -d $PROJECT_DIR/genray; then
  NIMROD_DEPS=${NIMROD_DEPS}",genray"
fi
if ${BUILD_SLEPC:=true}; then
  NIMROD_DEPS=${NIMROD_DEPS}",slepc"
fi


nimversion=nimdevel

# Modify NIMROD builds if doing a debug build
if $BUILD_DEBUG; then
  NIMROD_BUILDS=${NIMROD_BUILDS}",serdbg,pardbg"
fi
if $BUILD_SURFORIG; then
  NIMROD_BUILDS=${NIMROD_BUILDS}",sersurf,parsurf"
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
addtopathvar PYTHONPATH $PROJECT_DIR/nimdevel/bin
addtopathvar PATH $PROJECT_DIR/nimdevel/bin
addtopathvar PATH $BLDR_INSTALL_DIR/nimdevel-par/bin
addtopathvar PATH $BLDR_INSTALL_DIR/nimdevel/bin

######################################################################
#
# Launch nimrod builds.
#
######################################################################

# Do this by hand -- I'm not good enough to do this in bash
# Define $nimversion_BUILDS
NIMDEVEL_BUILDS=$NIMROD_BUILDS

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

#------------------------------------------------------------
#  Now write output
#------------------------------------------------------------
buildNimrod() {
  getVersion $nimversion
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

# Set umask to allow only group to modify
testNimrod() {
  bilderRunTests $nimversion NimTests
}


######################################################################
#
# Install nimrod
#
######################################################################

installNimrod() {
    bilderInstallTestedPkg $nimversion ser $nimversion
    bilderInstallTestedPkg $nimversion par $nimversion-par
    bilderInstallTestedPkg $nimversion serdbg $nimversion-serdbg
    bilderInstallTestedPkg $nimversion pardbg $nimversion-pardbg
    bilderInstallTestedPkg $nimversion partau $nimversion-partau
    bilderInstallTestedPkg $nimversion sersurforig $nimversion-sersurforig
    bilderInstallTestedPkg $nimversion parsurforig $nimversion-parsurforig
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
