#!/bin/bash
#
# Build information for repo version of trilinos
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in trilinosgit_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/trilinosgit_aux.sh
# Need to source the tarball package file to get helper functions

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTrilinosgitNonTriggerVars() {
  TRILINOSGIT_UMASK=002
}
setTrilinosgitNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildTrilinosgit() {

# Try to get trilinos from repo
  updateRepo trilinosgit

# Check on failure in updating git repo
  if ! test -d $PROJECT_DIR/trilinos; then
    techo -2 "WARNING: Unable to get trilinos repo. Need to clone by hand?"
    return 1
  fi

# Get the repo version from the git hash and the run preconfig
  getVersion trilinosgit
  if ! bilderPreconfig -c trilinosgit; then
    techo -2 "WARNING: Unable to pre-configure trilinosgit."
    return 1
  fi




# Get major version for setting some vars
  local TRILINOSGIT_MAJORVER=`echo $TRILINOSGIT_BLDRVERSION | sed 's/\..*$//'`
  techo "TRILINOSGIT_MAJORVER = $TRILINOSGIT_MAJORVER."

# Universal args
  local TRILINOSGIT_ALL_ADDL_ARGS=
  TRILINOSGIT_ALL_ADDL_ARGS=${TRILINOSGIT_ALL_ADDL_ARGS:-"-DDART_TESTING_TIMEOUT:STRING=600"}
  if test -n "$MIXED_PYTHON"; then
# Needed to prevent use of python2.6 when both versions present
    TRILINOSGIT_ALL_ADDL_ARGS="$TRILINOSGIT_ALL_ADDL_ARGS -DPYTHON_EXECUTABLE:FILEPATH=$MIXED_PYTHON"
  fi

# Determine Fortran flags, fortran-c interface, fortran extra link flags
  if test -z "$FC" -o -z "$LIBFORTRAN_DIR"; then
    TRILINOSGIT_ALL_ADDL_ARGS="$TRILINOSGIT_ALL_ADDL_ARGS -DTrilinos_ENABLE_Fortran=OFF"
  else
    local extralinkflags=
    extralinkflags="-L$LIBFORTRAN_DIR"
    case `uname` in
      Linux*)
        extralinkflags="$extralinkflags -Wl,-rpath,$LIBFORTRAN_DIR"
        ;;
      *)
        techo -2 "WARNING: The trilinosgit package only setup to build on linux."
        ;;
    esac
    TRILINOSGIT_ALL_ADDL_ARGS="$TRILINOSGIT_ALL_ADDL_ARGS -DTrilinos_EXTRA_LINK_FLAGS:STRING='$extralinkflags'"
  fi

#
# The per-build additional args give locations of boost and linear
# algebra libraries.
#

# Collect the locations of static or shared serial libraries
  for bld in ser sersh ben; do
    local BLD=`echo $bld | tr [a-z] [A-Z]`
    local oldval=`deref TRILINOSGIT_${BLD}_ADDL_ARGS`
    local incdir=`deref CMAKE_BOOST_${BLD}_INCDIR`
# Build on a clean machine shows this to be the right arg.
    eval "TRILINOSGIT_${BLD}_ADDL_ARGS=\"$oldval -DBoost_INCLUDE_DIRS:FILEPATH='$incdir'\""
  done

# Determine best choice for linalg libraries for static builds and add to vars
#
# Static linear algebra libraries
  if test -n "$BLAS_SER_STATIC_LIBRARIES" -a -n "$LAPACK_SER_STATIC_LIBRARIES"; then
    TRILINOSGIT_STATIC_LINLIB_ARGS="-DTPL_BLAS_LIBRARIES:FILEPATH='`echo $BLAS_SER_STATIC_LIBRARIES | tr ' ' ';'`'"
    TRILINOSGIT_STATIC_LINLIB_ARGS="$TRILINOSGIT_STATIC_LINLIB_ARGS -DTPL_LAPACK_LIBRARIES:FILEPATH='`echo $LAPACK_SER_STATIC_LIBRARIES | tr ' ' ';'`'"
  else
    TRILINOSGIT_STATIC_LINLIB_ARGS="$CMAKE_LINLIB_SER_ARGS"
  fi
  TRILINOSGIT_SER_ADDL_ARGS="$TRILINOSGIT_SER_ADDL_ARGS $TRILINOSGIT_STATIC_LINLIB_ARGS"
# JRC (20140905):TARBALL_NODEFLIB_FLAGS prevents /MD in trilinos-11.10.2 builds
  TRILINOSGIT_SER_ADDL_ARGS="$TRILINOSGIT_SER_ADDL_ARGS $TARBALL_NODEFLIB_FLAGS"
# Shared linear algebra libraries
  if test -n "$CMAKE_LINLIB_SERSH_ARGS"; then
    TRILINOSGIT_SERSH_ADDL_ARGS="$TRILINOSGIT_SERSH_ADDL_ARGS $CMAKE_LINLIB_SERSH_ARGS"
  else
    TRILINOSGIT_SERSH_ADDL_ARGS="$TRILINOSGIT_SERSH_ADDL_ARGS $CMAKE_LINLIB_SER_ARGS"
  fi
# Back-end node linear algebra libraries
  if test -n "$BLAS_BEN_LIBRARIES" -a -n "$LAPACK_BEN_LIBRARIES"; then
    TRILINOSGIT_BEN_LINLIB_ARGS="-DTPL_BLAS_LIBRARIES:FILEPATH='`echo $BLAS_BEN_LIBRARIES | tr ' ' ';'`'"
    TRILINOSGIT_BEN_LINLIB_ARGS="$TRILINOSGIT_BEN_LINLIB_ARGS -DTPL_LAPACK_LIBRARIES:FILEPATH='`echo $LAPACK_BEN_LIBRARIES | tr ' ' ';'`'"
  else
    TRILINOSGIT_BEN_LINLIB_ARGS="$CMAKE_LINLIB_SER_ARGS"
  fi
  TRILINOSGIT_BEN_ADDL_ARGS="$TRILINOSGIT_BEN_ADDL_ARGS $TRILINOSGIT_BEN_LINLIB_ARGS"
  TRILINOSGIT_BEN_ADDL_ARGS="$TRILINOSGIT_BEN_ADDL_ARGS $TARBALL_NODEFLIB_FLAGS"

# Complex number support in parallel builds of Trilinos 11.14.3 is BROKEN
# due to bad code in superlu_dist. Trilinos tried to hack its way around
# the superlu_dist code, but what they did is not robust and fails to
# compile in some cases.
#
# Given there are so many parallel builds, I started a new ALL_PAR_ADDL,
# which is for ALL parallel (but not serial) builds.

  TRILINOSGIT_ALL_PAR_ADDL_ARGS="-DHAVE_TEUCHOS_COMPLEX:BOOL=FALSE"
# For these serial packages, parallel analogs are the same
  TRILINOSGIT_PAR_ADDL_ARGS="$TRILINOSGIT_SER_ADDL_ARGS"
  TRILINOSGIT_PARSH_ADDL_ARGS="$TRILINOSGIT_SERSH_ADDL_ARGS"

# The bare builds are minimal: just compilers, linear libraries,
# args applicable to all and to the particular builds
#
  if bilderConfig trilinosgit serbare "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_SER_ADDL_ARGS $TRILINOSGIT_SER_OTHER_ARGS"; then
    bilderBuild trilinosgit serbare "$TRILINOSGIT_MAKEJ_ARGS"
  fi
# For shared, turn on BUILD_SHARED_LIBS and use shared linear libs
  if bilderConfig trilinosgit serbaresh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_SERSH_ADDL_ARGS $TRILINOSGIT_SERSH_OTHER_ARGS"; then
    bilderBuild trilinosgit serbaresh "$TRILINOSGIT_MAKEJ_ARGS"
  fi
# For parallel, turn on mpi
  if bilderConfig trilinosgit parbare "-DTPL_ENABLE_MPI:BOOL=ON $TARBALL_NODEFLIB_FLAGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_PAR_ADDL_ARGS $TRILINOSGIT_PAR_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit parbare "$TRILINOSGIT_MAKEJ_ARGS"
  fi
# For shared parallel, turn on mpi and shared libs
  if bilderConfig trilinosgit parbaresh "-DTPL_ENABLE_MPI:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_PARSH_ADDL_ARGS $TRILINOSGIT_PARSH_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit parbaresh "$TRILINOSGIT_MAKEJ_ARGS"
  fi

#
# The comm builds enable anything with a commercially acceptable license.
# This requires the parcomm builds of superlu, which then does not
# include parmetis.
#
# Generic configuration
  local triConfigArgs="-DTeuchos_ENABLE_LONG_LONG_INT:BOOL=ON -DTPL_ENABLE_BinUtils:BOOL=OFF -DTPL_ENABLE_Boost:STRING=ON"

# Internal packages
  local triPkgs="ML AztecOO Amesos Galeri Shards Intrepid Komplex NOX EpetraExt Epetra Triutils Teuchos Ifpack"
  if test `uname` = Linux; then
    triPkgs="$triPkgs Amesos2"
  fi
  BUILD_TRILINOSGIT_EXPERIMENTAL=${BUILD_TRILINOSGIT_EXPERIMENTAL:-"false"}
  if $BUILD_TRILINOSGIT_EXPERIMENTAL; then
    triPkgs="$triPkgs Phalanx SEACAS Zoltan"
  elif $TRILINOSGIT_MAJORVER -lt 12; then
    triPkgs="$triPkgs Phalanx"
  fi
  local triCommonArgs="`getTriPackages $triPkgs` $triConfigArgs"

# Potential external packages
  local TPL_PACKAGELIST=
  case `uname` in
     CYGWIN*)
       triCommonArgs="$triCommonArgs -DTrilinos_ENABLE_Kokkos:BOOL=OFF"
       TPL_PACKAGELIST="MUMPS SuperLU SuperLUDist"
       if $BUILD_TRILINOSGIT_EXPERIMENTAL; then
         TPL_PACKAGELIST="$TPL_PACKAGELIST Netcdf"
       fi
       ;;
     Darwin)
       local TPL_PACKAGELIST="SuperLU SuperLUDist"
       TPL_PACKAGELIST="$TPL_PACKAGELIST HYPRE"
# Mumps does not build on Darwin, so following has no effect
       TPL_PACKAGELIST="$TPL_PACKAGELIST MUMPS"
       ;;
     Linux)
       local TPL_PACKAGELIST="SuperLU SuperLUDist"
       # We don't want MUMPS in serial, but getTriTPLs knows that
       TPL_PACKAGELIST="$TPL_PACKAGELIST HYPRE MUMPS"
       ;;
  esac
  techo -2 "TPL_PACKAGELIST = $TPL_PACKAGELIST"

# Turn on external packages. getTriTPLs figures out which ones are
# par and which ones are ser
  triTplSerArgs=`getTriTPLs ser $TPL_PACKAGELIST`
  triTplParArgs=`getTriTPLs par $TPL_PACKAGELIST`

  techo -2 "triTplSerArgs = $triTplSerArgs."
  techo -2 "triTplParArgs = $triTplParArgs."

  TRILINOSGIT_SERCOMMSH_ADDL_ARGS="$TRILINOSGIT_SERCOMMSH_ADDL_ARGS -DTrilinos_ENABLE_PyTrilinos:STRING=ON"

# Add in the locations by build
  TRILINOSGIT_SERCOMM_ADDL_ARGS="$TRILINOSGIT_SER_ADDL_ARGS $triCommonArgs $triTplSerArgs"
  TRILINOSGIT_SERCOMMSH_ADDL_ARGS="$TRILINOSGIT_SERSH_ADDL_ARGS $triCommonArgs $triTplSerArgs"
  TRILINOSGIT_PARCOMM_ADDL_ARGS="$TRILINOSGIT_PAR_ADDL_ARGS $triCommonArgs $triTplParArgs"
  TRILINOSGIT_PARCOMMSH_ADDL_ARGS="$TRILINOSGIT_PARSH_ADDL_ARGS $triCommonArgs $triTplParArgs"
  TRILINOSGIT_BEN_ADDL_ARGS="$TRILINOSGIT_BEN_ADDL_ARGS $triCommonArgs $triTplParArgs"

# The builds
  if bilderConfig trilinosgit sercomm "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_SERCOMM_ADDL_ARGS $TRILINOSGIT_SERCOMM_OTHER_ARGS"; then
    bilderBuild trilinosgit sercomm "$TRILINOSGIT_MAKEJ_ARGS"
  fi
  if bilderConfig trilinosgit sercommsh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_SERCOMMSH_ADDL_ARGS $TRILINOSGIT_SERCOMMSH_OTHER_ARGS"; then
    bilderBuild trilinosgit sercommsh "$TRILINOSGIT_MAKEJ_ARGS"
  fi
  if bilderConfig trilinosgit parcomm "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_PARCOMM_ADDL_ARGS $TRILINOSGIT_PARCOMM_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit parcomm "$TRILINOSGIT_MAKEJ_ARGS"
  fi
  if bilderConfig trilinosgit parcommsh "-DTPL_ENABLE_MPI:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_PARCOMMSH_ADDL_ARGS $TRILINOSGIT_PARCOMMSH_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit parcommsh "$TRILINOSGIT_MAKEJ_ARGS"
  fi
# ben is comm for back end nodes
  if bilderConfig trilinosgit ben "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_BEN_ADDL_ARGS $TRILINOSGIT_BEN_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit ben "$TRILINOSGIT_MAKEJ_ARGS"
  fi

#
# The commio builds are static with more IO enabled
#
# The args
  local NETCDF_BASE_DIR=$MIXED_CONTRIB_DIR/netcdf-$NETCDF_BLDRVERSION-ser
  local HDF5_BASE_DIR=$MIXED_CONTRIB_DIR/hdf5-$HDF5_BLDRVERSION-ser
  local NETCDF_ARGS="-DTPL_ENABLE_Netcdf:STRING='ON' -DNetcdf_LIBRARY_DIRS:PATH='$NETCDF_BASE_DIR/lib;$HDF5_BASE_DIR/lib' -DNetcdf_LIBRARY_NAMES:STRING='netcdf;hdf5_hl;hdf5' -DNetcdf_INCLUDE_DIRS:PATH=$NETCDF_BASE_DIR/include"
  local SEACAS_ARGS="${SEACAS_ARGS} -DTrilinos_ENABLE_SECONDARY_STABLE_CODE:BOOL=ON -DTrilinos_ENABLE_SEACASExodus:BOOL=ON -DTrilinos_ENABLE_SEACASNemesis:BOOL=ON -DSEACASNemesis_ENABLE_TESTS:BOOL=OFF $NETCDF_ARGS -DTPL_ENABLE_MATLAB:BOOL=OFF"
  local NETCDF_PAR_BASE_DIR=$MIXED_CONTRIB_DIR/netcdf-$NETCDF_BLDRVERSION-par
  local HDF5_PAR_BASE_DIR=$MIXED_CONTRIB_DIR/hdf5-$HDF5_BLDRVERSION-par
  local NETCDF_PAR_ARGS="-DTPL_ENABLE_Netcdf:STRING='ON' -DNetcdf_LIBRARY_DIRS:PATH='$NETCDF_PAR_BASE_DIR/lib;$HDF5_PAR_BASE_DIR/lib' -DNetcdf_LIBRARY_NAMES:STRING='netcdf;hdf5_hl;hdf5' -DNetcdf_INCLUDE_DIRS:PATH=$NETCDF_PAR_BASE_DIR/include"
  local SEACAS_PAR_ARGS="${SEACAS_ARGS} -DTrilinos_ENABLE_SECONDARY_STABLE_CODE:BOOL=ON -DTrilinos_ENABLE_SEACASExodus:BOOL=ON -DTrilinos_ENABLE_SEACASNemesis:BOOL=ON $NETCDF_PAR_ARGS -DTPL_ENABLE_MATLAB:BOOL=OFF"
  TRILINOSGIT_SERCOMMIO_ADDL_ARGS="$TRILINOSGIT_SERCOMM_ADDL_ARGS $SEACAS_ARGS"
  TRILINOSGIT_PARCOMMIO_ADDL_ARGS="$TRILINOSGIT_PARCOMM_ADDL_ARGS $SEACAS_PAR_ARGS"
# The builds
  if bilderConfig trilinosgit sercommio "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_SERCOMMIO_ADDL_ARGS $TRILINOSGIT_SERCOMMIO_OTHER_ARGS"; then
    bilderBuild trilinosgit sercommio "$TRILINOSGIT_MAKEJ_ARGS"
  fi
  if bilderConfig trilinosgit parcommio "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_PARCOMMIO_ADDL_ARGS $TRILINOSGIT_PARCOMMIO_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit parcommio "$TRILINOSGIT_MAKEJ_ARGS"
  fi

#
# The full builds include non commercially licensable libraries.
# AFAICT, only parmetis, so the parmetis (par, parsh) builds of superlu
#
# The args
  local TRILINOSGIT_FULL_ARGS="-DTPL_ENABLE_PARMETIS:BOOL=ON"
  TRILINOSGIT_PARFULL_ADDL_ARGS="$TRILINOSGIT_PAR_ADDL_ARGS -DParMETIS_INCLUDE_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/include' -DParMETIS_LIBRARY_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/lib' -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/include' -DSuperLUDist_LIBRARY_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/lib' -DSuperLUDist_LIBRARY_NAMES:STRING='superlu_dist'"
  TRILINOSGIT_PARFULLSH_ADDL_ARGS="$TRILINOSGIT_PARCOMMSH_ADDL_ARGS -DParMETIS_INCLUDE_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/include' -DParMETIS_LIBRARY_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/lib' -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/include' -DSuperLUDist_LIBRARY_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/lib' -DSuperLUDist_LIBRARY_NAMES:STRING='superlu_dist'"

# The builds
if false; then # JRC: I see no difference between these and the comm builds
  if bilderConfig trilinosgit serfull "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOSGIT_STATIC_LINLIB_ARGS $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_SER_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu"; then
    bilderBuild trilinosgit serfull "$TRILINOSGIT_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos serfullsh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_SERSH_OTHER_ARGS"; then
    bilderBuild trilinosgit serfullsh "$TRILINOSGIT_MAKEJ_ARGS"
  fi
fi
  if bilderConfig trilinosgit parfull "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOSGIT_FULL_ARGS $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_PARFULL_ADDL_ARGS $TRILINOSGIT_PARFULL_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit parfull "$TRILINOSGIT_MAKEJ_ARGS"
  fi
  if bilderConfig trilinosgit parfullsh "-DBUILD_SHARED_LIBS:BOOL=ON -DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOSGIT_FULL_ARGS $TRILINOSGIT_ALL_ADDL_ARGS $TRILINOSGIT_PARFULLSH_ADDL_ARGS $TRILINOSGIT_PARFULLSH_OTHER_ARGS $TRILINOSGIT_ALL_PAR_ADDL_ARGS"; then
    bilderBuild trilinosgit parfullsh "$TRILINOSGIT_MAKEJ_ARGS"
  fi

}

######################################################################
#
# Test trilinosgit
#
######################################################################

testTrilinosgit() {
  techo "Not testing trilinosgit."
}

######################################################################
#
# Install trilinosgit
#
######################################################################

installTrilinosgit() {
  bilderInstallAll trilinosgit " -r -p open"
}

