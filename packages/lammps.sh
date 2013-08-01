#!/bin/bash
#
# Version and build information for lammps
#
# $Id: lammps.sh 5767 2012-04-11 17:03:36Z pletzer $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LAMMPS_BLDRVERSION=${LAMMPS_BLDRVERSION:-"14Aug13"}

######################################################################
#
# Builds and deps
#
######################################################################

LAMMPS_BUILDS=${LAMMPS_BUILDS:-"ser,par"}
echo "LAMMPS_BUILDS=${LAMMPS_BUILDS}"
LAMMPS_DEPS=fftw,openmpi

######################################################################
#
# Launch lammps builds.
#
######################################################################

buildLammps() {

  # Specific variables for LAMMPS 'by-hand' make files
  LAMMPS_OTHER_ARGS="LMP_INC=-DLAMMPS_GZIP"

  LAMMPS_SER_ARGS="FFT_INC='-DFFT_FFTW -I$CONTRIB_DIR/fftw/include' FFT_PATH='-L$CONTRIB_DIR/fftw/lib' FFT_LIB='-lfftw -lrfftw'"
  echo "LAMMPS_SER_ARGS = $LAMMPS_SER_ARGS"

  LAMMPS_PAR_ARGS="FFT_INC='-DFFT_FFTW -I$CONTRIB_DIR/fftw-par/include' FFT_PATH='-L$CONTRIB_DIR/fftw-par/lib' FFT_LIB='-lfftw_mpi -lrfftw_mpi'"
  echo "LAMMPS_PAR_ARGS = $LAMMPS_PAR_ARGS"

  if bilderUnpack lammps; then

    ARGS="$LAMMPS_SER_ARGS mac"
    makeLammps ser "$ARGS"

    # ARGS="$LAMMPS_PAR_ARGS mac_mpi"
    # makeLammps par "$ARGS"

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

  echo "------------------ Must make stubs first -----------"

  # LAMMPS_SRC="GNUmakefile mk src util"
  # LICENSE README bench doc examples lib potentials python src tools
  # LAMMPS_SRC="LICENSE README bench doc examples lib potentials python src tools"
  # LAMMPS_SRC="src/*"
  # for targ in $LAMMPS_SRC; do
  #   cmd="cp -R $LAMMPS_BUILD_TOPDIR/$targ $LAMMPS_BUILD_DIR"
  #   echo "$cmd"
  #   $cmd
  # done

  echo "---------- Calling makeLammps with $1 $2 --------"
  BLDTYPE=$1
  ARGS=$2

  if bilderConfig lammps $BLDTYPE; then

    # 'by-hand configure' by copying all files in src to LAMMPS_BUILD_DIR
    local BLDDIR=LAMMPS_`genbashvar ${BLDTYPE}`_BUILD_DIR
    eval LAMMPS_BUILD_DIR=\$$BLDDIR
    echo "LAMMPS_BUILD_DIR=$LAMMPS_BUILD_DIR"
    LAMMPS_BUILD_TOPDIR=$LAMMPS_BUILD_DIR/..
    echo "LAMMPS_BUILD_TOPDIR=$LAMMPS_BUILD_TOPDIR"
    # !!!!!!!!!!!!!!!!!!! watch this line !!!!!!!!!!!!!!!!!!!
    cmd="cp -R $LAMMPS_BUILD_TOPDIR/src/* $LAMMPS_BUILD_DIR"
    echo "$cmd"
    $cmd

    # Special make target for serial
    echo "------ making stubs target by default -------"
    cd $LAMMPS_BUILD_DIR/STUBS
    make stubs
    cd $LAMMPS_BUILD_TOPDIR


    #
    # Build lammps (because of the bizarre make file structure
    # this build is in-place in the src subdirectory)
    # 
    echo "------ This is the current directory" `pwd`
    bilderBuild lammps $BLDTYPE "$JMAKEARGS $ARGS"

    # Wait for build, move lib*.a to /lib
#    waitBuild lammps-$BLDTYPE
#    if ! test -d $LAMMPS_BUILD_DIR/lib; then
#      echo "creating directory $LAMMPS_BUILD_DIR"
#      mkdir $LAMMPS_BUILD_DIR/lib
#    fi
#    mv $LAMMPS_BUILD_DIR/lib*.a $LAMMPS_BUILD_DIR/lib
#    techo "placeholder for findContribPackage" >> $LAMMPS_BUILD_DIR/lib/liblammps.a
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

  echo "Calling putLammps with $1"

  local builddir
  # If there was a build, the builddir was set
  local builddirvar=`genbashvar lammps-$1`_BUILD_DIR
  local builddir=`deref $builddirvar`
  local vervar=`genbashvar lammps`_BLDRVERSION
  local verval=`deref $vervar`
  local BLDTYPE=$1
  local LAMMPS_INSTALL_NAME=lammps-${LAMMPS_BLDRVERSION}-$BLDTYPE
  # see if lammps build was attempted
  if test -z "$builddir"; then
    techo "Not installing lammps-$verval-$1 since not built."
# Check for previous installation
    if isInstalled -i $CONTRIB_DIR $LAMMPS_INSTALL_NAME; then
# Still make lammps find-able
      findContribPackage lammps lammps $BLDTYPE
    else
      techo "WARNING: $LAMMPS_INSTALL_NAME not found, and not installing"
    fi
    return 1
  fi
# Install any patch
  local patchvar=`genbashvar lammps`_PATCH
  local patchval=`deref $patchvar`
  if test -n "$patchval"; then
    patchname=`basename $patchval`
    cmd="/usr/bin/install -m 664 $patchval $CONTRIB_DIR/$LAMMPS_INSTALL_NAME/$patchname"
    techo "$cmd"
    $cmd
  fi

# wait for build to complete
  waitBuild lammps-$1
# if build was successful, then continue
  resvarname=`genbashvar lammps_$1`_RES
  local res=`deref $resvarname`
  if test "$res" != 0; then
    techo "Not installing lammps-$verval-$1 since did not build."
    return 1
  fi
  echo "lammps-$verval-$1 was built."

  local LAMMPS_INSTALL_TAG=$CONTRIB_DIR/lammps-$LAMMPS_BLDRVERSION
  local LAMMPS_INSTALL_DIR=${LAMMPS_INSTALL_TAG}-$BLDTYPE
# Check/create install directory
  if ! test -d $LAMMPS_INSTALL_DIR; then
    mkdir $LAMMPS_INSTALL_DIR
  fi

# Make lammps includes user-writable. Not sure why this isn't being
#  done by Lammps GNUMakefile
  chmod -R u+w $builddir/include

# Install command (if not build this time LAMMPS_BUILD_DIR fails)
  LAMMPS_INSTTARG="lib util include"
  for targ in $LAMMPS_INSTTARG; do
    cmd="cp -R $builddir/$targ $LAMMPS_INSTALL_DIR"
    echo "$cmd"
    $cmd
  done

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR lammps,$BLDTYPE

  # Make default soft links and register install
  if ! test -d $CONTRIB_DIR/lammps-$BLDTYPE; then
    echo "creating soft link directory $CONTRIB_DIR/lammps-$BLDTYPE"
    ln -s $LAMMPS_INSTALL_DIR $CONTRIB_DIR/lammps-$BLDTYPE
  fi

  # Make lammps find-able
  findContribPackage lammps lammps $BLDTYPE

}
