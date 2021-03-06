#!/bin/sh
######################################################################
#
# @file    hdf5.sh
#
# @brief   Build information for hdf5.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# For mingw: http://www.swarm.org/index.php/Swarm_and_MinGW#HDF5_.28Optional.29
#
######################################################################

######################################################################
#
# Trigger variables set in hdf5_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/hdf5_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setHdf5NonTriggerVars() {
  HDF5_UMASK=002
}
setHdf5NonTriggerVars

######################################################################
#
# Launch hdf5 builds.
#
######################################################################

# Helper method to determine whether Fortran can compile hdf5
haveHdf5Fortran() {
# Check ability of compiler to compile hdf5
  techo "HdF5: Testing if we have Fortran"
  if $HAVE_SER_FORTRAN; then
    techo "Hdf5: We have Fortran"
    case "$FC" in
      *gfortran*)
        vertmp=`$FC --version | sed -e 's/^GNU Fortran ([^)]*)//'`
        gfortranversion=`echo $vertmp | sed 's/ .*//'`
        case "$gfortranversion" in
          4.3.2)
            techo "gfortran cannot compile hdf5."
            techo "See http://gcc.gnu.org/ml/gcc-bugs/2008-11/msg01510.html."
            return 1
            ;;
          4.3.* | 4.4.* | 4.5.* | 4.6.* )
            #techo "gfortran can compile hdf5."
            return 0
            ;;
        esac
        ;;
    esac
    return 0
  fi
  techo "Hdf5: We don't have Fortran"
  return 1
}

buildHdf5() {

  if ! bilderUnpack hdf5; then
    return
  fi

# Missing file in 1.8.7
  touch $BUILD_DIR/hdf5-$HDF5_BLDRVERSION/release_docs/INSTALL_parallel.txt

# Can we build fortran?
  local HDF5_STATIC_ENABLE_FORTRAN=
  local HDF5_SHARED_ENABLE_FORTRAN=
  if haveHdf5Fortran; then
    HDF5_STATIC_ENABLE_FORTRAN=-DHDF5_BUILD_FORTRAN:BOOL=ON
  fi
# Not with Darwin
  if test `uname` != Darwin; then
    HDF5_SHARED_ENABLE_FORTRAN=$HDF5_STATIC_ENABLE_FORTRAN
  fi
  techo "Hdf5: HDF5_STATIC_ENABLE_FORTRAN = ${HDF5_STATIC_ENABLE_FORTRAN}"

# Shared: For Linux, add origin to rpath, do not strip rpath
  local HDF5_SER_ADDL_ARGS=
  local HDF5_SERSH_ADDL_ARGS=
  local HDF5_PAR_ADDL_ARGS=
  local HDF5_SERSH_ADDL_ARGS=
  local HDF5_PARSH_ADDL_ARGS=
  local HDF5_PYCSH_ADDL_ARGS=
  case `uname` in
    CYGWIN*)
      HDF5_SER_ADDL_ARGS="$HDF5_SER_ADDL_ARGS -DBUILD_SHARED_LIBS:BOOL=FALSE"
      HDF5_PAR_ADDL_ARGS="$HDF5_PAR_ADDL_ARGS -DBUILD_SHARED_LIBS:BOOL=FALSE"
      ;;
    Darwin)
# Shared libs to know their installation names so that builds of
# dependents link to this for installation to work without DYLD_LIBRARY_PATH
      HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_ADDL_ARGS -DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      HDF5_PYCSH_ADDL_ARGS="$HDF5_PYCSH_ADDL_ARGS -DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      ;;
    Linux)
# Hasry: Works!  Ivy fails because non system compiler.
      HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH"
      HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH='XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH'"
      HDF5_PYCSH_ADDL_ARGS="$HDF5_PYCSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH"
      ;;
  esac
# 1.8.16 does now allow CXX library built in parallel
  HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_ADDL_ARGS -DHDF5_BUILD_CPP_LIB:BOOL='OFF'"
  HDF5_PAR_ADDL_ARGS="$HDF5_PAR_ADDL_ARGS -DHDF5_BUILD_CPP_LIB:BOOL='OFF'"

# Separating builds for all platforms as required on Windows and this
# gives simplification
  if bilderConfig -c hdf5 sersh "-DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_SHARED_ENABLE_FORTRAN $HDF5_SERSH_ADDL_ARGS $HDF5_SERSH_OTHER_ARGS"; then
    bilderBuild hdf5 sersh "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 parsh "-DHDF5_ENABLE_PARALLEL:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $HDF5_SHARED_ENABLE_FORTRAN $HDF5_PARSH_ADDL_ARGS $HDF5_PARSH_OTHER_ARGS"; then
    bilderBuild hdf5 parsh "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 ser "$TARBALL_NODEFLIB_FLAGS -DBUILD_SHARED_LIBS:BOOL=OFF -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_STATIC_ENABLE_FORTRAN $HDF5_SER_ADDL_ARGS $HDF5_SER_OTHER_ARGS"; then
    bilderBuild hdf5 ser "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 par "-DHDF5_ENABLE_PARALLEL:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF $TARBALL_NODEFLIB_FLAGS -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $HDF5_STATIC_ENABLE_FORTRAN $HDF5_PAR_ADDL_ARGS $HDF5_PAR_OTHER_ARGS"; then
    bilderBuild hdf5 par "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_STATIC_ENABLE_FORTRAN $HDF5_SER_ADDL_ARGS $HDF5_SER_OTHER_ARGS"; then
    bilderBuild hdf5 sermd "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 pycst "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $HDF5_SHARED_ENABLE_FORTRAN $HDF5_PYCST_ADDL_ARGS $HDF5_PYCST_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
    bilderBuild hdf5 pycst "$HDF5_MAKEJ_ARGS" "$DISTUTILS_NOLV_ENV"
  fi
  if bilderConfig -c hdf5 pycsh "-DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $HDF5_SHARED_ENABLE_FORTRAN $HDF5_PYCSH_ADDL_ARGS $HDF5_PYCSH_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
    bilderBuild hdf5 pycsh "$HDF5_MAKEJ_ARGS" "$DISTUTILS_NOLV_ENV"
  fi

}

######################################################################
#
# Test
#
######################################################################

testHdf5() {
  techo "Not testing hdf5."
}

######################################################################
#
# Install
#
######################################################################

# Move the static executables up to the bin dir
#
# 1: The bin directory
#
moveHdf5Tools() {
  if test -d $1/tools; then
    cmd="mv $1/tools/* $1"
    techo "$cmd"
    $cmd
  else
    techo "NOTE [moveHdf5Tools]: Tools already directly under $1."
  fi
}

# Fix the shared installations rpaths
#
# 1: The build
#
fixHdf5SharedInst() {

  bld=$1
  local instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld
  local libdir=$instdir/lib
  local bindir=$instdir/bin

# Fix the libraries
  if declare -f bilderFixRpath 1>/dev/null 2>&1; then
    bilderFixRpath $libdir
    for exe in `\ls $bindir | tr '\n' ' '`; do
      if test -x $bindir/$exe; then
        bilderFixRpath $bindir/$exe
      fi
    done
  fi

}

# Fix the HDF5 liblib problem
#
# 1: The build
#
fixHdf5StaticLibs() {

  bld=$1
  local instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld
  local libdir=$instdir/lib

# Fix erroneous library names
  local libs=`\ls $libdir/* 2>/dev/null`
  techo "Examining library names for hdf5-$HDF5_BLDRVERSION-$bld."
  for i in $libs; do
# The liblib error occurs in some versions between 1.8.7 and 1.8.9
    local newname=`echo $i | sed -e 's?/liblibhdf5?/libhdf5?'`
    case `uname` in
      CYGWIN*)
# As of 1.8.11, static libs have prepended lib on Windows.
        local newname=`echo $newname | sed -e 's?/libhdf5?/hdf5?' -e 's/\.a$/.lib/'`
        ;;
    esac
    if test "$i" != "$newname"; then
      cmd="cp $i $newname"
      techo "$cmd"
      $cmd
    else
      techo "NOTE [fixHdf5StaticLibs]: Library, $i, has correct name."
    fi
  done

}

#
# Fix hdf5 libraries by build
#
# Args
# 1: the name of the build
#
fixHdf5Libs() {
  bld=$1
  case $bld in
    ser | par | sermd | pycst) fixHdf5StaticLibs $bld;;
    *sh) fixHdf5SharedInst $bld;;
  esac
}

######################################################################
#
# Install hdf5
#
######################################################################

# Move the shared hdf5 libraries to their legacy names.
# Allows shared and static to be installed in same place.
#
# 1: The installation directory
#
installHdf5() {

# Install one by one and correct
  local instdir
  local hdf5installed=false

# Static installations first, so static tools can be moved up and saved
# just under bin.
# Remove (-r) old installations.  This assumee that the shared libs
# will subsequently be reinstalled if needed.
  for bld in `echo $HDF5_BUILDS | tr ',' ' '`; do
    if bilderInstall -p open -r hdf5 $bld; then
      hdf5installed=true
      instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld
      chmod -R g+w $instdir
      moveHdf5Tools $instdir/bin
      fixHdf5Libs $bld
      case `uname` in
        Darwin)
          local hdf5cmakefile=$instdir/share/cmake/hdf5-${HDF5_BLDRVERSION}/hdf5-config.cmake
          if test -f $hdf5cmakefile; then
            sed -i.bak -e '/SET (BUILD_SHARED_LIBS /s/^/# /' -e '/SET (HDF5_BUILD_SHARED_LIBS /s/^/# /' $hdf5cmakefile
          fi
          ;;
      esac
    fi
  done

}

