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
# Trigger variables and versions set in nwchem_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/nwchem_aux.sh


######################################################################
#
# Local common variables
#
######################################################################

MPI_NAME="mpich-shared"
NWCHEM_PKG_NAME="nwchem-pkg"


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
# Local helper function to make a particular Nwchem config
#
# Args:
#  1: build type (eg par2d ser3d ....)
#  2: args  (must have " " around script variable)
#
######################################################################

makeNwchem() {

  BLDTYPE=$1
  ARGS=$2

  echo "USE_MPI      =$USE_MPI"
  echo "MPI_LIB      =$MPI_LIB"
  echo "MPI_INCLUDE  =$MPI_INCLUDE"
  echo "BLASOPT      =$BLASOPT"
  echo "BLAS_SIZE    =$BLAS_SIZE"
  echo "USE_ARUR     =$USE_ARUR"
  echo "NWCHEM_TOP   =$NWCHEM_TOP"
  echo "NWCHEM_TARGET=$NWCHEM_TARGET"

  # Must set so compilers are found
  export PATH="$CONTRIB_DIR/$MPI_NAME/bin:$PATH"


  if bilderConfig nwchem $BLDTYPE; then

    # 'by-hand configure' by using nwchem manual script (its not very good)
    local BLDDIR=NWCHEM_`genbashvar ${BLDTYPE}`_BUILD_DIR
    eval NWCHEM_BUILD_DIR=\$$BLDDIR
    NWCHEM_BUILD_TOPDIR=$NWCHEM_BUILD_DIR/..
    echo "NWCHEM_BUILD_DIR=$NWCHEM_BUILD_DIR"
    echo "NWCHEM_BUILD_TOPDIR=$NWCHEM_BUILD_TOPDIR"

    export NWCHEM_TOP=$NWCHEM_BUILD_TOPDIR
    export NWCHEM_TARGET="LINUX64"
    #export NWCHEM_MODULES="all python"

    echo ""
    echo "======================================================================================"
    echo "Manual configure steups"
    echo "======================================================================================"
    echo ""

    echo "Removing $NWCHEM_BUILD_TOPDIR/src/tools/build and running make nwchem_config..."
    rm -rf $NWCHEM_BUILD_TOPDIR/src/tools/build

    echo "Current src build directory before executing nwchem_config $PWD"
    cd $NWCHEM_BUILD_TOPDIR/src

    # Manual configure steps
    local configOutput=$FQMAILHOST-nwchem-$BLDTYPE-config.txt
    make nwchem_config NWCHEM_MODULES="all" > $NWCHEM_BUILD_TOPDIR/src/$configOutput 2>&1

    echo ""
    echo "======================================================================================"
    echo "Building in-place in src directory will copy build to $NWCHEM_BUILD_DIR after make"
    echo "======================================================================================"
    echo ""

    # Manual build steps
    echo "NOTE: no bilder *.sh script written out because NWChem not consistent with bilder"
    local buildOutput=$FQMAILHOST-nwchem-$BLDTYPE-build.txt
    make -j $JMAKE > $NWCHEM_BUILD_TOPDIR/src/$buildOutput 2>&1

    #SWS: fake build
    #echo "================== fake build "
    #cmd="cp -R /home/research/swsides/bin $NWCHEM_BUILD_TOPDIR"
    #echo $cmd
    #$cmd

    # Check/create NWCHEM build bin directory
    if ! test -d $NWCHEM_BUILD_DIR/bin; then
      mkdir -p $NWCHEM_BUILD_DIR/bin
    fi

    # Copy in-place src build binaries to bilder-named bin directory
    cmd="cp $NWCHEM_BUILD_TOPDIR/bin/$NWCHEM_TARGET/* $NWCHEM_BUILD_DIR/bin"
    echo "Copy in-place src build binaries to bilder-named directory"
    echo "$cmd"
    $cmd

    # Move output .txt files to bilder-named directory
    cmd="mv $NWCHEM_BUILD_TOPDIR/src/*nwchem*.txt $NWCHEM_BUILD_DIR"
    echo "Move output .txt files to bilder-named directory"
    echo "$cmd"
    $cmd

  fi

  echo ""
}


######################################################################
#
# Launch nwchem builds.
#
######################################################################

buildNwchem() {

  # NWChem not flexible enough for configure variables to be set, must
  # set a series of environment variables

  #
  # Shared linking not working, MPI must be available (not sure why option is available)
  # Specifying LIBMPI is problematic when static is specified. Moving back to shared
  #
  export USE_MPI="y"
  export MPI_LIB="$CONTRIB_DIR/$MPI_NAME/lib"
  export MPI_INCLUDE="$CONTRIB_DIR/$MPI_NAME/include"
  export LIBMPI="-lmpifort -lmpi -Wl,-rpath,$CONTRIB_DIR/$MPI_NAME/lib"
  export BLASOPT="-L$CONTRIB_DIR/lapack-sersh/lib64 -llapack -lblas -Wl,-rpath,$CONTRIB_DIR/lapack-sersh/lib64"
  export BLAS_SIZE="8"
  export USE_ARUR="n"

  techo ""
  techo "USE_MPI     =$USE_MPI"
  techo "MPI_LIB     =$MPI_LIB"
  techo "MPI_INCLUDE =$MPI_INCLUDE"
  techo "BLASOPT     =$BLASOPT"
  techo "BLAS_SIZE   =$BLAS_SIZE"
  techo "USE_ARUR    =$USE_ARUR"
  techo "MPI_NAME    =$MPI_NAME"
  techo ""

  # Builds
  if bilderUnpack nwchem; then

    ARGS="$NWCHEM_PAR_ARGS $PAR_TARGET"
    # makeNwchem par "$ARGS"

  fi
}



######################################################################
#
# Install nwchem
#
######################################################################

installNwchem() {

  putNwchem     par
  fixDynNwchem  par

  tarBldrInstallPkg nwchem $NWCHEM_PKG_NAME
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
# * this is only for $MPI_NAME...
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
  NWCHEM_EXE_NAME="nwchem"

  LAPACK_PKG='lapack-sersh/lib64'
  MPI_PKG="$MPI_NAME/lib"

  LIB64_PKG_1='libgfortran'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_2='libquadmath'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_3='libgcc_s'       # Located in LIBGFORTRAN_DIR

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

  # Copy over executables to package-able executable bin location
  cmd="cp -R $NWCHEM_INSTALL_DIR/bin $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME"
  echo "fixDynNwchem will call"
  echo "$cmd"
  $cmd


  # Needed Only fixing up libs for parallel version (because of mpi and related)
  if [ $BLDTYPE == "par" ]; then

    # Copy over MPI libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$MPI_PKG/*.so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    # Copy over LAPACK/BLAS libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$LAPACK_PKG/*.so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Copy over LIB64 libs to package-able lib location
    # NOTE: -a option must be used to maintain symbolic links
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_1.*so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_2.*so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
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
# Local helper function to install a particular Nwchem config
# and log installation
#
# Args:
#  1: build type (eg par2d ser3d ....)
#
######################################################################

putNwchem() {

  echo "Calling putNwchem with $1"

  local builddir
  # If there was a build, the builddir was set
  local builddirvar=`genbashvar nwchem-$1`_BUILD_DIR
  local builddir=`deref $builddirvar`
  local vervar=`genbashvar nwchem`_BLDRVERSION
  local verval=`deref $vervar`
  local BLDTYPE=$1
  local NWCHEM_INSTALL_NAME=nwchem-${NWCHEM_BLDRVERSION}-$BLDTYPE


  # see if nwchem build was attempted
  if test -z "$builddir"; then
    echo "Not installing nwchem-$verval-$1 since not built."
    # Check for previous installation
    if isInstalled -i $BLDR_INSTALL_DIR $NWCHEM_INSTALL_NAME; then
      # Still make nwchem find-able
      # findContribPackage nwchem nwchem $BLDTYPE
      echo "Yes NWCHEM installed"
    else
      echo "WARNING: $NWCHEM_INSTALL_NAME not found, and not installing"
    fi
    return 1
  fi

  # Install any patch
  echo "Installing no patches for nwchem-$BLDTYPE"

  # wait for build to complete
  waitAction nwchem-$1

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

  # Install command
  cmd="cp -R $builddir/bin $NWCHEM_INSTALL_DIR"
  echo "$cmd"
  $cmd

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $BLDR_INSTALL_DIR nwchem,$BLDTYPE
}
