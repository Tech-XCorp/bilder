#!/bin/sh
######################################################################
#
# @file    lammps.sh
#
# @brief   Version and build information for lammps.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Source common methods to fixup rpaths manually
#
######################################################################

source $PROJECT_DIR/bilder/rpathutils.sh


######################################################################
#
# Trigger variables and versions set in qmcpack_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/lammps_aux.sh


######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLammpsNonTriggerVars() {
  LAMMPS_UMASK=002
}
setLammpsNonTriggerVars



######################################################################
#
# Launch lammps builds.
#
######################################################################

buildLammps() {

  # These targets are not needed, but the flags below are
  # expecting the setup in these files, hardcoded Makefile-s use these
  # names as the ser/par executable targets
  SER_TARGET='mac'
  PAR_TARGET='mac_mpi'

  # NOTE: all variables for make cmd line need ' ' quotes so other
  # args in line are parsed correctly

  # Specific variables for LAMMPS 'by-hand' make files
  LAMMPS_OTHER_ARGS="LMP_INC='-DLAMMPS_GZIP' JPG_INC='' JPG_PATH='' JPG_LIB=''"

  #
  # Serial flags ( CC/LINK is defined by lammps make system)
  #
  LAMMPS_SER_COMP_ARGS="CC=$CXX LINK=$CXX"

  LAMMPS_SER_ARGS="\
    FFT_INC='-DFFT_FFTW -I$CONTRIB_DIR/fftw/include' \
    FFT_PATH='-L$CONTRIB_DIR/fftw/lib' \
    FFT_LIB='-lfftw -lrfftw'"

  LAMMPS_SER_ARGS="$LAMMPS_SER_COMP_ARGS $LAMMPS_SER_ARGS $LAMMPS_OTHER_ARGS"

  #
  # Par flags (check mpi version) ( CC/LINK is defined by lammps make system)
  #
  LAMMPS_PAR_COMP_ARGS="\
    CC=$MPICXX LINK=$MPICXX \
    CCFLAGS='-O3 -DMPICH_IGNORE_CXX_SEEK' \
    LINKFLAGS='-O3 -DMPICH_IGNORE_CXX_SEEK'"

  LAMMPS_PAR_ARGS="\
    FFT_INC='-DFFT_FFTW -I$CONTRIB_DIR/fftw-par/include' \
    FFT_PATH='-L$CONTRIB_DIR/fftw-par/lib' \
    FFT_LIB='-lfftw -lrfftw -lfftw_mpi -lrfftw_mpi' \
    MPI_INC='' MPI_PATH='' MPI_LIB='' "

  LAMMPS_PAR_ARGS="$LAMMPS_PAR_COMP_ARGS $LAMMPS_PAR_ARGS $LAMMPS_OTHER_ARGS"

  # Status
  techo "========================================================================================"
  techo "LAMMPS_SER_ARGS = $LAMMPS_SER_ARGS"
  techo "LAMMPS_PAR_ARGS = $LAMMPS_PAR_ARGS"
  techo "========================================================================================"

  # Builds
  if bilderUnpack lammps; then

    ARGS="$LAMMPS_SER_ARGS $SER_TARGET"
    makeLammps ser "$ARGS"

    ARGS="$LAMMPS_PAR_ARGS $PAR_TARGET"
    makeLammps par "$ARGS"

  fi
}


######################################################################
#
# Install lammps
#
######################################################################

installLammps() {
  putLammps ser
  putLammps par

  fixDynLammps ser
  fixDynLammps par

  # Clean out old tar files
  rm -rf $BLDR_INSTALL_DIR/lammpsInstall.tar.gz $BLDR_INSTALL_DIR/lammpsInstall.tar

  # Tar up the lammps pkg directory created by fixDynLammps
  echo ""
  echo "Creating an archive file for installer for Lammps"
  echo ""
  cmd1="tar -cvf $BLDR_INSTALL_DIR/lammpsInstall.tar -C $BLDR_INSTALL_DIR $LAMMPS_PKG_NAME"
  cmd2="gzip $BLDR_INSTALL_DIR/lammpsInstall.tar"
  echo "$cmd1 + $cmd2"
  $cmd1
  $cmd2
}



######################################################################
#
# Test Lammps
#
######################################################################

testLammps() {
  techo "Not testing LAMMPS."
}



######################################################################
#                                                                    #
#                      Helper script methods                         #
#                                                                    #
######################################################################


######################################################################
#
# Fix the dynamic links in executable (for packaging)
# * this is only for mpich-shared...
#   1. Creates a special lammps package directory
#   2. Copies all .so files to lib and executable to bin directory
#   3. Fixes RPATH manually with chrpath
#
######################################################################

fixDynLammps() {

  # First argument
  BLDTYPE=$1

  echo "====================================================================================="
  echo "                Running fixDynLammps on the executable to package                    "
  echo "                up libs and fix rpath settings for lammps-$BLDTYPE                   "
  echo "====================================================================================="

  # Select exectuable name
  if [ $BLDTYPE == "ser" ]; then
    LAMMPS_EXE_NAME="lammps_ser"
  elif [ $BLDTYPE == "par" ]; then
    LAMMPS_EXE_NAME="lammps"
  else
    echo "Build name not recognized"
  fi

  LAMMPS_PKG_NAME="lammps-pkg"
  MPIPKG='mpich-shared'
  LIB64_PKG_1='libgfortran'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_2='libquadmath'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_3='libstdc++'      # Located in LIBGFORTRAN_DIR

  # Find paths for BLDTYPE value
  local LAMMPS_INSTALL_TAG=$BLDR_INSTALL_DIR/lammps-$LAMMPS_BLDRVERSION
  local LAMMPS_INSTALL_DIR=${LAMMPS_INSTALL_TAG}-$BLDTYPE

  # Set lammps package directory
  PKG_DIR="$BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME"

  # Check/create LAMMPS pkg directory
  if ! test -d $PKG_DIR; then
      mkdir -p $PKG_DIR
  fi
  # Check/create LAMMPS pkg lib directory
  if ! test -d $PKG_DIR/lib; then
      mkdir -p $PKG_DIR/lib
  fi
  # Check/create LAMMPS pkg bin directory
  if ! test -d $PKG_DIR/bin; then
      mkdir -p $PKG_DIR/bin
  fi

  # Copy over executable to package-able executable bin location
  cmd="cp $LAMMPS_INSTALL_DIR/bin/$LAMMPS_EXE_NAME $BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME/bin"
  echo "$cmd"
  $cmd


  # Needed Only fixing up libs for parallel version (because of mpi and related)
  if [ $BLDTYPE == "par" ]; then

    # Copy over MPI libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$MPIPKG/lib/*.* $BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Copy over LIB64 libs to package-able lib location
    # NOTE: -a option must be used to maintain symbolic links
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_1.* $BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_2.* $BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_3.*so* $BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Syntax with $ORIGIN is very specific in order that correct format is
    # maintained through a bash script to the format expected by cmd line chrpath call

    # Uses helper method to run chrpath on executable(s)
    fixRpathForExec "$BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME/bin" "\$ORIGIN/../lib"

    # Uses helper method to run chrpath on all .so files in a directory
    fixRpathForSharedLibs "$BLDR_INSTALL_DIR/$LAMMPS_PKG_NAME/lib"  "\$ORIGIN/../lib"

  fi

  echo "====================================================================================="
}


######################################################################
#
# Local helper function to make a particular Lammps config
#
# Args:
#  1: build type (eg par2d ser3d ....)
#  2: args  (must have " " around script variable)
#
######################################################################

makeLammps() {

  techo -2 "---------- Calling makeLammps with $1 $2 --------"
  BLDTYPE=$1
  ARGS=$2

  if bilderConfig lammps $BLDTYPE; then

    # 'by-hand configure' by copying all files in src to LAMMPS_BUILD_DIR
    local BLDDIR=LAMMPS_`genbashvar ${BLDTYPE}`_BUILD_DIR
    eval LAMMPS_BUILD_DIR=\$$BLDDIR
    techo -2 "LAMMPS_BUILD_DIR=$LAMMPS_BUILD_DIR"
    LAMMPS_BUILD_TOPDIR=$LAMMPS_BUILD_DIR/..
    techo -2 "LAMMPS_BUILD_TOPDIR=$LAMMPS_BUILD_TOPDIR"
    techo -2 "------------ Watch this copy line --------------"
    cmd="cp -R $LAMMPS_BUILD_TOPDIR/src/* $LAMMPS_BUILD_DIR"
    techo -2 "$cmd"
    $cmd

    # Special make target for serial
    # Going to STUBS directly because stubs target not working
    if [ $BLDTYPE == "ser" ]; then
      techo -2 "-- Making stubs target by default"
      cd $LAMMPS_BUILD_DIR/STUBS
      echo "current directory `pwd`"
      make
      cd $LAMMPS_BUILD_TOPDIR
    fi

    # Build lammps (because of the bizarre make file structure
    # this build is in-place in the src subdirectory)
    bilderBuild lammps $BLDTYPE "$JMAKEARGS $ARGS"

  fi
}

######################################################################
#
# Local helper function to install a particular Lammps config
# and log installation
#
# Args:
#  1: build type (eg par2d ser3d ....)
#
######################################################################

putLammps() {

  techo -2 "Calling putLammps with $1"

  local builddir
  # If there was a build, the builddir was set
  local builddirvar=`genbashvar lammps-$1`_BUILD_DIR
  local builddir=`deref $builddirvar`
  local vervar=`genbashvar lammps`_BLDRVERSION
  local verval=`deref $vervar`
  local BLDTYPE=$1
  local LAMMPS_INSTALL_NAME=lammps-${LAMMPS_BLDRVERSION}-$BLDTYPE

  echo "putLammps: builddir=$builddir"

  # see if lammps build was attempted
  if test -z "$builddir"; then
    techo -2 "Not installing lammps-$verval-$1 since not built."
    # Check for previous installation
    if isInstalled -i $CONTRIB_DIR $LAMMPS_INSTALL_NAME; then
      # Still make lammps find-able
      # findContribPackage lammps lammps $BLDTYPE
      echo "Yes LAMMPS installed"
    else
      techo -2 "WARNING: $LAMMPS_INSTALL_NAME not found, and not installing"
    fi
    return 1
  fi

  # Install any patch
  echo "Installing no patches for lammps-$BLDTYPE"

  # wait for build to complete
  waitAction lammps-$1

  # if build was successful, then continue
  resvarname=`genbashvar lammps_$1`_RES
  local res=`deref $resvarname`
  if test "$res" != 0; then
    techo -2 "Not installing lammps-$verval-$1 since did not build."
    return 1
  fi

  # Generate install names
  echo "lammps-$verval-$1 was built."
  local LAMMPS_INSTALL_TAG=$BLDR_INSTALL_DIR/lammps-$LAMMPS_BLDRVERSION
  local LAMMPS_INSTALL_DIR=${LAMMPS_INSTALL_TAG}-$BLDTYPE

  # Check/create install directory
  if ! test -d $LAMMPS_INSTALL_DIR; then
    mkdir $LAMMPS_INSTALL_DIR
  fi

  # Check/create install bin directory
  if ! test -d $LAMMPS_INSTALL_DIR/bin; then
    mkdir $LAMMPS_INSTALL_DIR/bin
  fi

  # Install command (if not build this time LAMMPS_BUILD_DIR fails)
  if [ $BLDTYPE == "ser" ]; then
      LAMMPS_INSTTARG="lmp_mac"
      cmd="cp -R $builddir/$LAMMPS_INSTTARG $LAMMPS_INSTALL_DIR/bin/lammps_ser"
  else
      LAMMPS_INSTTARG="lmp_mac_mpi"
      cmd="cp -R $builddir/$LAMMPS_INSTTARG $LAMMPS_INSTALL_DIR/bin/lammps"
  fi
  techo -2 "$cmd"
  $cmd

  echo "Default is to copy executable into $LAMMPS_INSTALL_DIR/bin"

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $BLDR_INSTALL_DID lammps,$BLDTYPE
}
