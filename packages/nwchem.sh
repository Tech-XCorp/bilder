#!/bin/sh
######################################################################
#
# @file    nwchem.sh
#
# @brief   Version and build information for nwchem.
#
# @version $Rev: 3599 $ $Date: 2017-04-07 16:13:04 -0600 (Fri, 07 Apr 2017) $
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

  if bilderUnpack nwchem; then

    LAPACK_LIB="lapack-sersh/lib64"
    XML_LIB="libxml2-sersh"

    # ================================================================
    # Nwchem needs specific environment variables set for packages
    # ================================================================

    local NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS"
    local NWCHEM_SER_OTHER_ARGS="$NWCHEM_SER_OTHER_ARGS"
    local NWCHEM_PAR_OTHER_ARGS="$NWCHEM_PAR_OTHER_ARGS"

    # Standard configure parameters
    NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS $TARBALL_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG"

    # Ensure correct linker picked up
    NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"

    # Adding compiler lib64 directory to rpath so initial
    # build good (this assumes -fPIC -pipe). The LD_LIBRARY_PATH is set during this session,
    # do NOT set for main environment. (Also try LIBGFORTRAN_DIR if this stops working)

    NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS \
      -DCMAKE_CXX_FLAGS:STRING='-fPIC -pipe  -Wl,-rpath,$LD_LIBRARY_PATH'"

    echo "NWCHEM_OTHER_ARGS=$NWCHEM_OTHER_ARGS"

    # Add boost
    NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS -DBOOST_ROOT=$CONTRIB_DIR/boost"

    # Add lapack
    NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS \
     -DLAPACK_LIBRARIES='$CONTRIB_DIR/$LAPACK_LIB/liblapack.so;$CONTRIB_DIR/$LAPACK_LIB/libblas.so'"

    # Add xml (shared libs)
    # These parameters are broken and/or poorly documented even in the incl. cmake files
    # Had to use the following variables to get around these problems, and even still
    # the output from configure will be misleading (note setting LIBXML2_HOME does not work)
    NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS -DLibxml2_INCLUDE_DIRS=$CONTRIB_DIR/$XML_LIB/include"
    NWCHEM_OTHER_ARGS="$NWCHEM_OTHER_ARGS -DLibxml2_LIBRARY_DIRS=$CONTRIB_DIR/$XML_LIB/lib"

    # Add compiler and compiler flags
    NWCHEM_SER_OTHER_ARGS="$NWCHEM_SER_OTHER_ARGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER"
    NWCHEM_PAR_OTHER_ARGS="$NWCHEM_PAR_OTHER_ARGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR"

    # Add fftw3
    NWCHEM_SER_OTHER_ARGS="$NWCHEM_SER_OTHER_ARGS -DFFTW_HOME=$CONTRIB_DIR/fftw3"
    NWCHEM_PAR_OTHER_ARGS="$NWCHEM_PAR_OTHER_ARGS -DFFTW_HOME=$CONTRIB_DIR/fftw3-par"

    # Add hdf5
    NWCHEM_SER_OTHER_ARGS="$NWCHEM_SER_OTHER_ARGS -DHDF5_ROOT=$CONTRIB_DIR/hdf5"
    NWCHEM_PAR_OTHER_ARGS="$NWCHEM_PAR_OTHER_ARGS -DHDF5_ROOT=$CONTRIB_DIR/hdf5-par"

    techo " "
    techo "========================================================================================"
    techo " NWCHEM arguments for bilder configure/build steps                                     "
    techo "                                                                                        "
    techo "   NWCHEM_OTHER_ARGS     = $NWCHEM_OTHER_ARGS                                         "
    techo "   NWCHEM_SER_OTHER_ARGS = $NWCHEM_SER_OTHER_ARGS                                     "
    techo "   NWCHEM_PAR_OTHER_ARGS = $NWCHEM_PAR_OTHER_ARGS                                     "
    techo "                                                                                        "
    techo "========================================================================================"
    techo " "

    # ================================================================
    # Run bilder configure/build
    # ================================================================

    if bilderConfig -c nwchem ser "$NWCHEM_SER_OTHER_ARGS $NWCHEM_OTHER_ARGS"; then
      bilderBuild nwchem ser "$NWCHEM_MAKEJ_ARGS"
      echo""
    fi

    if bilderConfig -c nwchem par "-DENABLE_PARALLEL:BOOL=TRUE $NWCHEM_PAR_OTHER_ARGS $NWCHEM_OTHER_ARGS"; then
      bilderBuild nwchem par "$NWCHEM_MAKEJ_ARGS"
      echo""
    fi

  fi
}


######################################################################
#
# Install nwchem
#
######################################################################

installNwchem() {

  # putNwchem ser
  putNwchem par

  # Only fix up libs for packaging on linux platform
  # fixDynNwchem ser
  fixDynNwchem par

  # Clean out old tar files
  rm -rf $BLDR_INSTALL_DIR/nwchemInstall.tar.gz $BLDR_INSTALL_DIR/nwchemInstall.tar

  # Tar up the nwchem pkg directory created by fixDynNwchem
  echo ""
  echo "Creating an archive file for installer for Nwchem"
  echo ""
  cmd1="tar -cvf $BLDR_INSTALL_DIR/nwchemInstall.tar -C $BLDR_INSTALL_DIR $NWCHEM_PKG_NAME"
  cmd2="gzip $BLDR_INSTALL_DIR/nwchemInstall.tar"
  echo "$cmd1 + $cmd2"
  $cmd1
  $cmd2
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
  cmd="cp -R $builddir/bin $NWCHEM_INSTALL_DIR"
  techo -2 "$cmd"
  $cmd

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $BLDR_INSTALL_DIR nwchem,$BLDTYPE
}




######################################################################
#
# Fix the dynamic links in executable (for packaging)
# this is only for mpich-shared...
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
    exit
  fi

  NWCHEM_PKG_NAME="nwchem-pkg"
  MPI_PKG='mpich-shared/lib'
  XML_PKG='libxml2-sersh/lib'
  LAPACK_PKG='lapack-sersh/lib64'

  LIB64_PKG_1='libgfortran'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_2='libquadmath'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_3='libgomp'        # Located in LIBGFORTRAN_DIR
  LIB64_PKG_4='libstdc++'      # Located in LIBGFORTRAN_DIR

  # Find paths for BLDTYPE value
  local NWCHEM_INSTALL_TAG=$BLDR_INSTALL_DIR/nwchem-$NWCHEM_BLDRVERSION
  local NWCHEM_INSTALL_DIR=${NWCHEM_INSTALL_TAG}-$BLDTYPE

  # Set nwchem package directory (in volatile dir)
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

  # Copy over executables to package-able bin location
  cmd="cp -R $NWCHEM_INSTALL_DIR/bin $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME"
  echo "$cmd"
  $cmd

  # Needed Only fixing up libs for parallel version (because of mpi and related)
  if [ $BLDTYPE == "par" ]; then

    # Copy over MPI libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$MPI_PKG/*.so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    # Copy over XML libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$XML_PKG/*.so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
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
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_4.*so* $BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Uses helper method to run chrpath on a single executable
    fixRpathForExec "$BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/bin" "\$ORIGIN/../lib"

    # Uses helper method to run chrpath on all .so files in a directory
    fixRpathForSharedLibs "$BLDR_INSTALL_DIR/$NWCHEM_PKG_NAME/lib" "\$ORIGIN/../lib"
  fi

  echo "====================================================================================="
}
