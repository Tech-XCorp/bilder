#!/bin/sh
######################################################################
#
# @file    nwchem.sh
#
# @brief   Version and build information for nwchem.
#
# @version $Rev: 3635 $ $Date: 2017-04-17 17:23:43 -0600 (Mon, 17 Apr 2017) $
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
source $mydir/nwchem_aux.sh


######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNwchemNonTriggerVars() {
  NWCHEM_UMASK=002
}
setNwchemNonTriggerVars



######################################################################
#
# Launch nwchem builds.
#
######################################################################

buildNwchem() {

  # NWChem not flexible enough for configure variables to be set, must
  # set a series of environment variables

  # Shared linking not working
  # MPI must be available (not sure why option is available)
  export USE_MPI="y"
  export MPI_LIB="/scr_haswell/swsides/opt/contrib-nwchem/mpich-3.1.4-static/lib"
  export MPI_INCLUDE="/scr_haswell/swsides/opt/contrib-nwchem/mpich-3.1.4-static/include"
  export LIBPMPI="-lmpifort -lmpi"

  # Python link currently broken in the 6.6 version. Leaving out for now
  #export PYTHONVERSION="2.7"
  #export PYTHONHOME="/scr_haswell/swsides/opt/contrib-qmcpack/Python-2.7.13-sersh"
  #export PYTHONLIBTYPE="so"
  #export PYTHONCONFIGDIR="config/../.."
  #export PYTHONHOME="/scr_haswell/swsides/opt/contrib-qmcpack/Python-2.7.13-sersh"
  #export PYTHONLIBTYPE="a"
  #export PYTHONCONFIGDIR="config"

  export BLASOPT="-L/scr_haswell/swsides/opt/contrib-nwchem/lapack/lib64  -llapack -lblas"
  export BLAS_SIZE="8"
  export USE_ARUR="n"

  export NWCHEM_TOP="/scr_haswell/swsides/directpkgs/nwchem-6.6"
  export NWCHEM_TARGET="LINUX64"


  # Status
  #  techo "========================================================================================"
  #  techo "NWCHEM_SER_ARGS = $NWCHEM_SER_ARGS"
  #  techo "NWCHEM_PAR_ARGS = $NWCHEM_PAR_ARGS"
  #  techo "========================================================================================"

  # Builds
  if bilderUnpack nwchem; then

    # ARGS="$NWCHEM_SER_ARGS $SER_TARGET"
    # makeNwchem ser "$ARGS"

    ARGS="$NWCHEM_PAR_ARGS $PAR_TARGET"
    makeNwchem par "$ARGS"

  fi
}


######################################################################
#
# Install nwchem
#
######################################################################

installNwchem() {

#  putNwchem ser
#  putNwchem par

#  fixDynNwchem ser
#  fixDynNwchem par

  # Clean out old tar files
#  rm -rf $BLDR_INSTALL_DIR/nwchemInstall.tar.gz $BLDR_INSTALL_DIR/nwchemInstall.tar

  # Tar up the nwchem pkg directory created by fixDynNwchem
#  echo ""
#  echo "Creating an archive file for installer for Nwchem"
#  echo ""
#  cmd1="tar -cvf $BLDR_INSTALL_DIR/nwchemInstall.tar -C $BLDR_INSTALL_DIR $NWCHEM_PKG_NAME"
#  cmd2="gzip $BLDR_INSTALL_DIR/nwchemInstall.tar"
#  echo "$cmd1 + $cmd2"
#  $cmd1
#  $cmd2
}



######################################################################
#
# Test Nwchem
#
######################################################################

testNwchem() {
  techo "Not testing NWCHEM."
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
#   1. Creates a special nwchem package directory
#   2. Copies all .so files to lib and executable to bin directory
#   3. Fixes RPATH manually with chrpath
#
######################################################################

fixDynNwchem() {

  # First argument
  BLDTYPE=$1

  echo "====================================================================================="
  echo "                Running fixDynNwchem on the executable to package                    "
  echo "                up libs and fix rpath settings for nwchem-$BLDTYPE                   "
  echo "====================================================================================="

  # Select exectuable name
  if [ $BLDTYPE == "ser" ]; then
    NWCHEM_EXE_NAME="nwchem_ser"
  elif [ $BLDTYPE == "par" ]; then
    NWCHEM_EXE_NAME="nwchem"
  else
    echo "Build name not recognized"
  fi

  NWCHEM_PKG_NAME="nwchem-pkg"
  MPIPKG='mpich-shared'
  LIB64_PKG_1='libgfortran'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_2='libquadmath'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_3='libstdc++'      # Located in LIBGFORTRAN_DIR

  # Find paths for BLDTYPE value
  local NWCHEM_INSTALL_TAG=$BLDR_INSTALL_DIR/nwchem-$NWCHEM_BLDRVERSION
  local NWCHEM_INSTALL_DIR=${NWCHEM_INSTALL_TAG}-$BLDTYPE

  # Set nwchem package directory
  PKG_DIR="$BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME"

  # Check/create NWCHEM pkg directory
  if ! test -d $PKG_DIR; then
      mkdir -p $PKG_DIR
  fi
  # Check/create NWCHEM pkg lib directory
  if ! test -d $PKG_DIR/lib; then
      mkdir -p $PKG_DIR/lib
  fi
  # Check/create NWCHEM pkg bin directory
  if ! test -d $PKG_DIR/bin; then
      mkdir -p $PKG_DIR/bin
  fi

  # Copy over executable to package-able executable bin location
  cmd="cp $NWCHEM_INSTALL_DIR/bin/$NWCHEM_EXE_NAME $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/bin"
  echo "$cmd"
  $cmd


  # Needed Only fixing up libs for parallel version (because of mpi and related)
  if [ $BLDTYPE == "par" ]; then

    # Copy over MPI libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$MPIPKG/lib/*.* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Copy over LIB64 libs to package-able lib location
    # NOTE: -a option must be used to maintain symbolic links
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_1.* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_2.* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_3.*so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Syntax with $ORIGIN is very specific in order that correct format is
    # maintained through a bash script to the format expected by cmd line chrpath call

    # Uses helper method to run chrpath on executable(s)
    fixRpathForExec "$BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/bin" "\$ORIGIN/../lib"

    # Uses helper method to run chrpath on all .so files in a directory
    fixRpathForSharedLibs "$BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"  "\$ORIGIN/../lib"

  fi

  echo "====================================================================================="
}


######################################################################
#
# Local helper function to make a particular Nwchem config
#
# Args:
#  1: build type (eg par2d ser3d ....)
#  2: args  (must have " " around script variable)
#
######################################################################

makeNwchem() {

  techo -2 "---------- Calling makeNwchem with $1 $2 --------"
  BLDTYPE=$1
  ARGS=$2

  if bilderConfig nwchem $BLDTYPE; then

    # 'by-hand configure' by copying all files in src to NWCHEM_BUILD_DIR
    #local BLDDIR=NWCHEM_`genbashvar ${BLDTYPE}`_BUILD_DIR
    #eval NWCHEM_BUILD_DIR=\$$BLDDIR
    #techo -2 "NWCHEM_BUILD_DIR=$NWCHEM_BUILD_DIR"
    #NWCHEM_BUILD_TOPDIR=$NWCHEM_BUILD_DIR/..
    #techo -2 "NWCHEM_BUILD_TOPDIR=$NWCHEM_BUILD_TOPDIR"
    #techo -2 "------------ Watch this copy line --------------"
    #cmd="cp -R $NWCHEM_BUILD_TOPDIR/src/* $NWCHEM_BUILD_DIR"
    #techo -2 "$cmd"
    #$cmd

    # Build nwchem (because of the bizarre make file structure
    # this build is in-place in the src subdirectory)
    # bilderBuild nwchem $BLDTYPE "$JMAKEARGS $ARGS"

  fi
}

######################################################################
#
# Local helper function to install a particular Nwchem config
# and log installation
#
# Args:
#  1: build type (eg par2d ser3d ....)
#
######################################################################

putNwchem() {

  techo -2 "Calling putNwchem with $1"

  local builddir
  # If there was a build, the builddir was set
  local builddirvar=`genbashvar nwchem-$1`_BUILD_DIR
  local builddir=`deref $builddirvar`
  local vervar=`genbashvar nwchem`_BLDRVERSION
  local verval=`deref $vervar`
  local BLDTYPE=$1
  local NWCHEM_INSTALL_NAME=nwchem-${NWCHEM_BLDRVERSION}-$BLDTYPE

  echo "putNwchem: builddir=$builddir"

  # see if nwchem build was attempted
  if test -z "$builddir"; then
    techo -2 "Not installing nwchem-$verval-$1 since not built."
    # Check for previous installation
    if isInstalled -i $CONTRIB_DIR $NWCHEM_INSTALL_NAME; then
      # Still make nwchem find-able
      # findContribPackage nwchem nwchem $BLDTYPE
      echo "Yes NWCHEM installed"
    else
      techo -2 "WARNING: $NWCHEM_INSTALL_NAME not found, and not installing"
    fi
    return 1
  fi

  # Install any patch
  echo "Installing no patches for nwchem-$BLDTYPE"

  # wait for build to complete
  waitAction nwchem-$1

  # if build was successful, then continue
  resvarname=`genbashvar nwchem_$1`_RES
  local res=`deref $resvarname`
  if test "$res" != 0; then
    techo -2 "Not installing nwchem-$verval-$1 since did not build."
    return 1
  fi

  # Generate install names
  echo "nwchem-$verval-$1 was built."
  local NWCHEM_INSTALL_TAG=$BLDR_INSTALL_DIR/nwchem-$NWCHEM_BLDRVERSION
  local NWCHEM_INSTALL_DIR=${NWCHEM_INSTALL_TAG}-$BLDTYPE

  # Check/create install directory
  if ! test -d $NWCHEM_INSTALL_DIR; then
    mkdir $NWCHEM_INSTALL_DIR
  fi

  # Check/create install bin directory
  if ! test -d $NWCHEM_INSTALL_DIR/bin; then
    mkdir $NWCHEM_INSTALL_DIR/bin
  fi

  # Install command (if not build this time NWCHEM_BUILD_DIR fails)
  if [ $BLDTYPE == "ser" ]; then
      NWCHEM_INSTTARG="lmp_mac"
      cmd="cp -R $builddir/$NWCHEM_INSTTARG $NWCHEM_INSTALL_DIR/bin/nwchem_ser"
  else
      NWCHEM_INSTTARG="lmp_mac_mpi"
      cmd="cp -R $builddir/$NWCHEM_INSTTARG $NWCHEM_INSTALL_DIR/bin/nwchem"
  fi
  techo -2 "$cmd"
  $cmd

  echo "Default is to copy executable into $NWCHEM_INSTALL_DIR/bin"

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $BLDR_INSTALL_DID nwchem,$BLDTYPE
}
