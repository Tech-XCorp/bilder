#!/bin/sh
######################################################################
#
# @file    qmcpack.sh
#
# @brief   Version and build information for qmcpack.
#
# @version $Rev: 3599 $ $Date: 2017-04-07 16:13:04 -0600 (Fri, 07 Apr 2017) $
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables and versions set in qmcpack_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/qmcpack_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setQmcpackNonTriggerVars() {
  QMCPACK_UMASK=002
}
setQmcpackNonTriggerVars


######################################################################
#
# Launch qmcpack builds.
#
######################################################################

buildQmcpack() {

  if bilderUnpack qmcpack; then

    LAPACK_LIB="lapack-sersh/lib64"
    XML_LIB="libxml2-sersh"

    # ================================================================
    # QMCPack needs specific environment variables set for packages
    # ================================================================

    local QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS"
    local QMCPACK_SER_OTHER_ARGS="$QMCPACK_SER_OTHER_ARGS"
    local QMCPACK_PAR_OTHER_ARGS="$QMCPACK_PAR_OTHER_ARGS"

    # Standard configure parameters
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS $TARBALL_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG"

    # Ensure correct linker picked up
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"

    # Adding compiler lib64 directory to rpath so initial
    # build good (this assumes -fPIC -pipe). The LD_LIBRARY_PATH is set during this session,
    # do NOT set for main environment. (Also try LIBGFORTRAN_DIR if this stops working)

    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS \
      -DCMAKE_CXX_FLAGS:STRING='-fPIC -pipe  -Wl,-rpath,$LD_LIBRARY_PATH'"

    echo "QMCPACK_OTHER_ARGS=$QMCPACK_OTHER_ARGS"

    # Add boost
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS -DBOOST_ROOT=$CONTRIB_DIR/boost"

    # Add lapack
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS \
     -DLAPACK_LIBRARIES='$CONTRIB_DIR/$LAPACK_LIB/liblapack.so;$CONTRIB_DIR/$LAPACK_LIB/libblas.so'"

    # Add xml (shared libs)
    # These parameters are broken and/or poorly documented even in the incl. cmake files
    # Had to use the following variables to get around these problems, and even still
    # the output from configure will be misleading (note setting LIBXML2_HOME does not work)
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS -DLibxml2_INCLUDE_DIRS=$CONTRIB_DIR/$XML_LIB/include"
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS -DLibxml2_LIBRARY_DIRS=$CONTRIB_DIR/$XML_LIB/lib"

    # Add compiler and compiler flags
    QMCPACK_SER_OTHER_ARGS="$QMCPACK_SER_OTHER_ARGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER"
    QMCPACK_PAR_OTHER_ARGS="$QMCPACK_PAR_OTHER_ARGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR"

    # Add fftw3
    QMCPACK_SER_OTHER_ARGS="$QMCPACK_SER_OTHER_ARGS -DFFTW_HOME=$CONTRIB_DIR/fftw3"
    QMCPACK_PAR_OTHER_ARGS="$QMCPACK_PAR_OTHER_ARGS -DFFTW_HOME=$CONTRIB_DIR/fftw3-par"

    # Add hdf5
    QMCPACK_SER_OTHER_ARGS="$QMCPACK_SER_OTHER_ARGS -DHDF5_ROOT=$CONTRIB_DIR/hdf5"
    QMCPACK_PAR_OTHER_ARGS="$QMCPACK_PAR_OTHER_ARGS -DHDF5_ROOT=$CONTRIB_DIR/hdf5-par"

    techo " "
    techo "========================================================================================"
    techo " QMCPACK arguments for bilder configure/build steps                                     "
    techo "                                                                                        "
    techo "   QMCPACK_OTHER_ARGS     = $QMCPACK_OTHER_ARGS                                         "
    techo "   QMCPACK_SER_OTHER_ARGS = $QMCPACK_SER_OTHER_ARGS                                     "
    techo "   QMCPACK_PAR_OTHER_ARGS = $QMCPACK_PAR_OTHER_ARGS                                     "
    techo "                                                                                        "
    techo "========================================================================================"
    techo " "

    # ================================================================
    # Run bilder configure/build
    # ================================================================

    if bilderConfig -c qmcpack ser "$QMCPACK_SER_OTHER_ARGS $QMCPACK_OTHER_ARGS"; then
      #bilderBuild qmcpack ser "$QMCPACK_MAKEJ_ARGS"
      echo""
    fi

    if bilderConfig -c qmcpack par "-DENABLE_PARALLEL:BOOL=TRUE $QMCPACK_PAR_OTHER_ARGS $QMCPACK_OTHER_ARGS"; then
      #bilderBuild qmcpack par "$QMCPACK_MAKEJ_ARGS"
      echo""
    fi

  fi
}


######################################################################
#
# Install qmcpack
#
######################################################################

installQmcpack() {

  techo "Will run bilder install steps for QMCPack (still needs work) ===== "

  # putQmcpack ser
  putQmcpack par

  # Only fix up libs for packaging on linux platform
  # fixDynQmcpack ser
  fixDynQmcpack par


  # Clean out old tar files
  rm -rf $CONTRIB_DIR/qmcpackInstall.tar.gz $CONTRIB_DIR/qmcpackInstall.tar

  # Tar up the qmcpack pkg directory created by fixDynQmcpack
  cmd1="tar -cvf $CONTRIB_DIR/qmcpackInstall.tar -C $CONTRIB_DIR $QMCPACK_PKG_NAME"
  cmd2="gzip $CONTRIB_DIR/qmcpackInstall.tar"
  echo "$cmd1 + $cmd2"
  $cmd1
  $cmd2
}


######################################################################
#
# Test Qmcpack
#
######################################################################

testQmcpack() {
  techo "Not testing QMCPACK."
}





######################################################################
#
# Local helper function to install a particular Qmcpack config
# and log installation
#
# Args:
#  1: build type (eg par2d ser3d ....)
#
######################################################################

putQmcpack() {

  techo -2 "Calling putQmcpack with $1"

  local builddir
  # If there was a build, the builddir was set
  local builddirvar=`genbashvar qmcpack-$1`_BUILD_DIR
  local builddir=`deref $builddirvar`
  local vervar=`genbashvar qmcpack`_BLDRVERSION
  local verval=`deref $vervar`
  local BLDTYPE=$1
  local QMCPACK_INSTALL_NAME=qmcpack-${QMCPACK_BLDRVERSION}-$BLDTYPE

  # see if qmcpack build was attempted
  if test -z "$builddir"; then
    techo -2 "Not installing qmcpack-$verval-$1 since not built."
    # Check for previous installation
    if isInstalled -i $CONTRIB_DIR $QMCPACK_INSTALL_NAME; then
      # Still make qmcpack find-able
      # findContribPackage qmcpack qmcpack $BLDTYPE
      echo "Yes QMCPACK installed"
    else
      techo -2 "WARNING: $QMCPACK_INSTALL_NAME not found, and not installing"
    fi
    return 1
  fi

  # Install any patch
  echo "Installing no patches for qmcpack-$BLDTYPE"

  # wait for build to complete
  waitAction qmcpack-$1

  # if build was successful, then continue
  resvarname=`genbashvar qmcpack_$1`_RES
  local res=`deref $resvarname`
  if test "$res" != 0; then
    techo -2 "Not installing qmcpack-$verval-$1 since did not build."
    return 1
  fi

  # Generate install names
  echo "qmcpack-$verval-$1 was built."
  local QMCPACK_INSTALL_TAG=$CONTRIB_DIR/qmcpack-$QMCPACK_BLDRVERSION
  local QMCPACK_INSTALL_DIR=${QMCPACK_INSTALL_TAG}-$BLDTYPE

  # Check/create install directory
  if ! test -d $QMCPACK_INSTALL_DIR; then
    mkdir $QMCPACK_INSTALL_DIR
  fi

  # Check/create install bin directory
  if ! test -d $QMCPACK_INSTALL_DIR/bin; then
    mkdir $QMCPACK_INSTALL_DIR/bin
  fi

  # Install command (if not build this time QMCPACK_BUILD_DIR fails)
  cmd="cp -R $builddir/bin $QMCPACK_INSTALL_DIR"
  techo -2 "$cmd"
  $cmd

  # Register install
  ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR qmcpack,$BLDTYPE
}




######################################################################
#
# Fix the dynamic links in executable (for packaging)
# this is only for mpich-shared...
#   1. Creates a special qmcpack package directory
#   2. Copies all .so files to lib and executable to bin directory
#   3. Fixes RPATH manually with chrpath
#
######################################################################

fixDynQmcpack() {

  # First argument
  BLDTYPE=$1

  echo "====================================================================================="
  echo "                Running fixDynQmcpack on the executable to package                    "
  echo "                up libs and fix rpath settings for qmcpack-$BLDTYPE                   "
  echo "====================================================================================="

  # Select exectuable name
  if [ $BLDTYPE == "ser" ]; then
    QMCPACK_EXE_NAME="qmcpack_ser"
  elif [ $BLDTYPE == "par" ]; then
    QMCPACK_EXE_NAME="qmcpack"
  else
    echo "Build name not recognized"
  fi

  QMCPACK_PKG_NAME="qmcpack-pkg"
  MPI_PKG='mpich-shared/lib'
  XML_PKG='libxml2-sersh/lib'
  LAPACK_PKG='lapack-sersh/lib64'

  LIB64_PKG_1='libgfortran'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_2='libquadmath'    # Located in LIBGFORTRAN_DIR
  LIB64_PKG_3='libgomp'        # Located in LIBGFORTRAN_DIR
  LIB64_PKG_4='libstdc++'      # Located in LIBGFORTRAN_DIR

  # Find paths for BLDTYPE value
  local QMCPACK_INSTALL_TAG=$CONTRIB_DIR/qmcpack-$QMCPACK_BLDRVERSION
  local QMCPACK_INSTALL_DIR=${QMCPACK_INSTALL_TAG}-$BLDTYPE


  # Set qmcpack package directory
  PKG_DIR="$CONTRIB_DIR/$QMCPACK_PKG_NAME"

  # Check/create QMCPACK pkg directory
  if ! test -d $PKG_DIR; then
      mkdir -p $PKG_DIR
  fi

  # Check/create QMCPACK pkg lib directory
  if ! test -d $PKG_DIR/lib; then
      mkdir -p $PKG_DIR/lib
  fi

  # Check/create QMCPACK pkg bin directory
  if ! test -d $PKG_DIR/bin; then
      mkdir -p $PKG_DIR/bin
  fi

  # Copy over executable to package-able executable bin location
  cmd="cp $QMCPACK_INSTALL_DIR/bin/$QMCPACK_EXE_NAME $CONTRIB_DIR/$QMCPACK_PKG_NAME/bin"
  echo "$cmd"
  $cmd


  # Needed Only fixing up libs for parallel version (because of mpi and related)
  if [ $BLDTYPE == "par" ]; then

    # Copy over MPI libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$MPI_PKG/*.so* $CONTRIB_DIR/$QMCPACK_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    # Copy over XML libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$XML_PKG/*.so* $CONTRIB_DIR/$QMCPACK_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    # Copy over LAPACK/BLAS libs to package-able lib location
    cmd="cp -R $CONTRIB_DIR/$LAPACK_PKG/*.so* $CONTRIB_DIR/$QMCPACK_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Copy over LIB64 libs to package-able lib location
    # NOTE: -a option must be used to maintain symbolic links
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_1.*so* $CONTRIB_DIR/$QMCPACK_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_2.*so* $CONTRIB_DIR/$QMCPACK_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_3.*so* $CONTRIB_DIR/$QMCPACK_PKG_NAME/lib"
    echo "$cmd"
    $cmd
    cmd="cp -a $LIBGFORTRAN_DIR/$LIB64_PKG_4.*so* $CONTRIB_DIR/$QMCPACK_PKG_NAME/lib"
    echo "$cmd"
    $cmd

    # Uses helper method to run chrpath on a single executable
    fixRpathForExec "$CONTRIB_DIR/$QMCPACK_PKG_NAME/bin/$QMCPACK_EXE_NAME" "\$ORIGIN/../lib"

    # Uses helper method to run chrpath on all .so files in a directory
    fixRpathForSharedLibs "$CONTRIB_DIR/$QMCPACK_PKG_NAME/lib" "\$ORIGIN/../lib"

  fi

  echo "====================================================================================="
}


######################################################################
#
# Local helper function:
# Takes a directory name/executable that needs its rpath edited.
#
# Args:
#  1. full path to directory/executable-name to be edited
#  2. location for rpath to be changed to
#
######################################################################

fixRpathForExec() {

  EXEC_PATH=$1
  RPATH=$2

  echo ""
  echo "fixRpathForExec: EXEC_PATH=$EXEC_PATH"
  echo "fixRpathForExec:     RPATH=$RPATH"

  # Fix rpath settings (using chrpath built in contrib)
  # Syntax with $ORIGIN is very specific in order that correct format is
  # maintained through a bash script to the format expected by cmd line chrpath call
  echo ""
  cmd="$CONTRIB_DIR/bin/chrpath -r $RPATH $EXEC_PATH"
  echo "$cmd"
  $cmd
}




######################################################################
#
# Local helper function:
# Takes a directory name to shared libs that need to have their
# rpath-s edited. Will check all files in directory and will run
# chrpath only on library files
#
# Args:
#  1. full path to directory with .so libs to be edited
#  2. location for rpath to be changed to
#
######################################################################

fixRpathForSharedLibs() {

  SHAREDLIB_PATH=$1
  RPATH=$2

  echo ""
  echo "fixRpathForSharedLibs: SHAREDLIB_PATH=$SHAREDLIB_PATH"
  echo "fixRpathForSharedLibs:          RPATH=$RPATH"

  # Find all .so libraries in pkg lib directory and run chrpath on those
  # as well. This skips running chrpath on symbolic links
  # SHAREDLIBS=`ls -1 $CONTRIB_DIR/$LAMMPS_PKG_NAME/lib/*.so*`
  local SHAREDLIBS=`ls -1 $SHAREDLIB_PATH/*.so*`

  for lib in $SHAREDLIBS; do
    if ! test -L $lib; then
      echo ""
      echo "*.so lib to fix rpath = $lib"
      cmd="$CONTRIB_DIR/bin/chrpath -r $RPATH  $lib"
      echo "$cmd"
      $cmd
    fi
  done
}
