#!/bin/bash
#
# Build information for trilinos
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in trilinos_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/trilinos_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTrilinosNonTriggerVars() {
  TRILINOS_UMASK=002
}
setTrilinosNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildTrilinos() {
   # Need the get functions
   source $mydir/trilinos_aux.sh

# Cannot disable fortran, as then trilinos cannot figure out fortran
# name mangling.
  if test -d $PROJECT_DIR/trilinos; then
    getVersion trilinos
    bilderPreconfig -c trilinos
    res=$?
  else
    bilderUnpack trilinos
    res=$?
  fi
  if test $res != 0; then
    return
  fi

# Check for install_dir installation
  if test $CONTRIB_DIR != $BLDR_INSTALL_DIR -a -e $BLDR_INSTALL_DIR/trilinos; then
    techo "WARNING: trilinos is installed in $BLDR_INSTALL_DIR."
  fi

# Universal args
  local TRILINOS_ALL_ADDL_ARGS=
  TRILINOS_ALL_ADDL_ARGS=${TRILINOS_ALL_ADDL_ARGS:-"-DDART_TESTING_TIMEOUT:STRING=600"}
  if test -n "$MIXED_PYTHON"; then
# Needed to prevent use of python2.6 when both versions present
    TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DPYTHON_EXECUTABLE:FILEPATH=$MIXED_PYTHON"
  fi

# Determine Fortran flags, fortran-c interface, fortran extra link flags
  if test -z "$FC" -o -z "$LIBFORTRAN_DIR"; then
    TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DTrilinos_ENABLE_Fortran=OFF"
  else
    local extralinkflags=
    extralinkflags="-L$LIBFORTRAN_DIR"
    case `uname`-`uname -r` in
      Darwin-13.*)
        TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DTrilinos_SKIP_FORTRANCINTERFACE_VERIFY_TEST:BOOL=TRUE"
        ;;
      Linux*)
        extralinkflags="$extralinkflags -Wl,-rpath,$LIBFORTRAN_DIR"
        ;;
    esac
    TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DTrilinos_EXTRA_LINK_FLAGS:STRING='$extralinkflags'"
  fi

#
# The per-build additional args give locations of boost and linear
# algebra libraries.
#

# Collect the locations of static or shared serial libraries
  for bld in ser sersh ben; do
    local BLD=`echo $bld | tr [a-z] [A-Z]`
    local oldval=`deref TRILINOS_${BLD}_ADDL_ARGS`
    local incdir=`deref CMAKE_BOOST_${BLD}_INCDIR`
# Build on a clean machine shows this to be the right arg.
    eval "TRILINOS_${BLD}_ADDL_ARGS=\"$oldval -DBoost_INCLUDE_DIRS:FILEPATH='$incdir'\""
  done

# Determine best choice for linalg libraries for static builds and add to vars
#
# Static linear algebra libraries
  if test -n "$BLAS_STATIC_LIBRARIES" -a -n "$LAPACK_STATIC_LIBRARIES"; then
    TRILINOS_STATIC_LINLIB_ARGS="-DTPL_BLAS_LIBRARIES:FILEPATH='`echo $BLAS_STATIC_LIBRARIES | tr ' ' ';'`'"
    TRILINOS_STATIC_LINLIB_ARGS="$TRILINOS_STATIC_LINLIB_ARGS -DTPL_LAPACK_LIBRARIES:FILEPATH='`echo $LAPACK_STATIC_LIBRARIES | tr ' ' ';'`'"
  else
    TRILINOS_STATIC_LINLIB_ARGS="$CMAKE_LINLIB_SER_ARGS"
  fi
  TRILINOS_SER_ADDL_ARGS="$TRILINOS_SER_ADDL_ARGS $TRILINOS_STATIC_LINLIB_ARGS"
# JRC (20140905):TARBALL_NODEFLIB_FLAGS prevents /MD in trilinos-11.10.2 builds
  TRILINOS_SER_ADDL_ARGS="$TRILINOS_SER_ADDL_ARGS $TARBALL_NODEFLIB_FLAGS"
# Shared linear algebra libraries
  if test -n "$CMAKE_LINLIB_SERSH_ARGS"; then
    TRILINOS_SERSH_ADDL_ARGS="$TRILINOS_SERSH_ADDL_ARGS $CMAKE_LINLIB_SERSH_ARGS"
  else
    TRILINOS_SERSH_ADDL_ARGS="$TRILINOS_SERSH_ADDL_ARGS $CMAKE_LINLIB_SER_ARGS"
  fi
# Back-end node linear algebra libraries
  if test -n "$BLAS_BEN_LIBRARIES" -a -n "$LAPACK_BEN_LIBRARIES"; then
    TRILINOS_BEN_LINLIB_ARGS="-DTPL_BLAS_LIBRARIES:FILEPATH='`echo $BLAS_BEN_LIBRARIES | tr ' ' ';'`'"
    TRILINOS_BEN_LINLIB_ARGS="$TRILINOS_BEN_LINLIB_ARGS -DTPL_LAPACK_LIBRARIES:FILEPATH='`echo $LAPACK_BEN_LIBRARIES | tr ' ' ';'`'"
  else
    TRILINOS_BEN_LINLIB_ARGS="$CMAKE_LINLIB_SER_ARGS"
  fi
  TRILINOS_BEN_ADDL_ARGS="$TRILINOS_BEN_ADDL_ARGS $TRILINOS_BEN_LINLIB_ARGS"
  TRILINOS_BEN_ADDL_ARGS="$TRILINOS_BEN_ADDL_ARGS $TARBALL_NODEFLIB_FLAGS"
# For these serial packages, parallel analogs are the same
  TRILINOS_PAR_ADDL_ARGS="$TRILINOS_SER_ADDL_ARGS"
  TRILINOS_PARSH_ADDL_ARGS="$TRILINOS_SERSH_ADDL_ARGS"

#
# The bare builds are minimal: just compilers, linear libraries,
# args applicable to all and to the particular builds
#
  if bilderConfig trilinos serbare "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SER_ADDL_ARGS $TRILINOS_SER_OTHER_ARGS"; then
    bilderBuild trilinos serbare "$TRILINOS_MAKEJ_ARGS"
  fi
# For shared, turn on BUILD_SHARED_LIBS and use shared linear libs
  if bilderConfig trilinos serbaresh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERSH_ADDL_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
    bilderBuild trilinos serbaresh "$TRILINOS_MAKEJ_ARGS"
  fi
# For parallel, turn on mpi
  if bilderConfig trilinos parbare "-DTPL_ENABLE_MPI:BOOL=ON $TARBALL_NODEFLIB_FLAGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PAR_ADDL_ARGS $TRILINOS_PAR_OTHER_ARGS"; then
    bilderBuild trilinos parbare "$TRILINOS_MAKEJ_ARGS"
  fi
# For shared parallel, turn on mpi and shared libs
  if bilderConfig trilinos parbaresh "-DTPL_ENABLE_MPI:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARSH_ADDL_ARGS $TRILINOS_PARSH_OTHER_ARGS"; then
    bilderBuild trilinos parbaresh "$TRILINOS_MAKEJ_ARGS"
  fi

#
# The comm builds enable anything with a commercially acceptable license.
# This requires the parcomm builds of superlu, which then does not
# include parmetis.
#
# Generic configuration
  local triConfigArgs="-DTeuchos_ENABLE_LONG_LONG_INT:BOOL=ON -DTPL_ENABLE_BinUtils:BOOL=OFF -DTPL_ENABLE_Boost:STRING=ON"

# Internal packages
  local triPkgs="ML AztecOO Amesos Galeri Shards Intrepid Komplex Phalanx NOX EpetraExt Epetra Triutils Teuchos Ifpack"
  if test `uname` = Linux; then
    triPkgs="$triPkgs Amesos2"
  fi
  local triCommonArgs="`getTriPackages $triPkgs` $triConfigArgs"

# Potential external packages
  case `uname` in
     CYGWIN*)
       local TPL_PACKAGELIST="MUMPS SuperLU SuperLUDist"
       ;;
     Darwin)
       local TPL_PACKAGELIST="SuperLU SuperLUDist"
       TPL_PACKAGELIST="$TPL_PACKAGELIST HYPRE"
# Mumps does not build on Darwin, so following has no effect
       TPL_PACKAGELIST="$TPL_PACKAGELIST MUMPS"
       ;;
     Linux)
       local TPL_PACKAGELIST="SuperLU SuperLUDist"
# 11.12.1 builds with hypre on Linux
       TPL_PACKAGELIST="$TPL_PACKAGELIST HYPRE"
# 11.12.1 does not build serial with mumps on Linux
       TPL_PACKAGELIST="$TPL_PACKAGELIST MUMPS"
       ;;
  esac
  techo -2 "TPL_PACKAGELIST = $TPL_PACKAGELIST"

# Turn on external packages.  getTriTPLs figures out which ones are
# par and which ones are ser
  triTplSerArgs=`getTriTPLs ser $TPL_PACKAGELIST`
  triTplParArgs=`getTriTPLs par $TPL_PACKAGELIST`
  techo -2 "triTplSerArgs = $triTplSerArgs."
  techo -2 "triTplParArgs = $triTplParArgs."

  TRILINOS_SERCOMMSH_ADDL_ARGS="$TRILINOS_SERCOMMSH_ADDL_ARGS -DTrilinos_ENABLE_PyTrilinos:STRING=ON"

# Add in the locations by build
  TRILINOS_SERCOMM_ADDL_ARGS="$TRILINOS_SER_ADDL_ARGS $triCommonArgs $triTplSerArgs"
  TRILINOS_SERCOMMSH_ADDL_ARGS="$TRILINOS_SERSH_ADDL_ARGS $triCommonArgs $triTplSerArgs"
  TRILINOS_PARCOMM_ADDL_ARGS="$TRILINOS_PAR_ADDL_ARGS $triCommonArgs $triTplParArgs"
  TRILINOS_PARCOMMSH_ADDL_ARGS="$TRILINOS_PARSH_ADDL_ARGS $triCommonArgs $triTplParArgs"
  TRILINOS_BEN_ADDL_ARGS="$TRILINOS_BEN_ADDL_ARGS $triCommonArgs $triTplParArgs"

# The builds
  if bilderConfig trilinos sercomm "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERCOMM_ADDL_ARGS $TRILINOS_SERCOMM_OTHER_ARGS"; then
    bilderBuild trilinos sercomm "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos sercommsh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERCOMMSH_ADDL_ARGS $TRILINOS_SERCOMMSH_OTHER_ARGS"; then
    bilderBuild trilinos sercommsh "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parcomm "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARCOMM_ADDL_ARGS $TRILINOS_PARCOMM_OTHER_ARGS"; then
    bilderBuild trilinos parcomm "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parcommsh "-DTPL_ENABLE_MPI:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARCOMMSH_ADDL_ARGS $TRILINOS_PARCOMMSH_OTHER_ARGS"; then
    bilderBuild trilinos parcommsh "$TRILINOS_MAKEJ_ARGS"
  fi
# ben is comm for back end nodes
  if bilderConfig trilinos ben "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $TRILINOS_ALL_ADDL_ARGS $TRILINOS_BEN_ADDL_ARGS $TRILINOS_BEN_OTHER_ARGS"; then
    bilderBuild trilinos ben "$TRILINOS_MAKEJ_ARGS"
  fi

#
# The commio builds are static with more IO enabled
#
# The args
  local NETCDF_BASE_DIR=$MIXED_CONTRIB_DIR/netcdf-$NETCDF_BLDRVERSION-ser
  local HDF5_BASE_DIR=$MIXED_CONTRIB_DIR/hdf5-$HDF5_BLDRVERSION-ser
  local NETCDF_ARGS="-DTPL_ENABLE_Netcdf:STRING='ON' -DNetcdf_LIBRARY_DIRS:PATH='$NETCDF_BASE_DIR/lib;$HDF5_BASE_DIR/lib' -DNetcdf_LIBRARY_NAMES:STRING='netcdf;hdf5_hl;hdf5' -DNetcdf_INCLUDE_DIRS:PATH=$NETCDF_BASE_DIR/include"
  local SEACAS_ARGS="${SEACAS_ARGS} -DTrilinos_ENABLE_SECONDARY_STABLE_CODE:BOOL=ON -DTrilinos_ENABLE_SEACASExodus:BOOL=ON -DTrilinos_ENABLE_SEACASNemesis:BOOL=ON $NETCDF_ARGS -DTPL_ENABLE_MATLAB:BOOL=OFF"
  local NETCDF_PAR_BASE_DIR=$MIXED_CONTRIB_DIR/netcdf-$NETCDF_BLDRVERSION-par
  local HDF5_PAR_BASE_DIR=$MIXED_CONTRIB_DIR/hdf5-$HDF5_BLDRVERSION-par
  local NETCDF_PAR_ARGS="-DTPL_ENABLE_Netcdf:STRING='ON' -DNetcdf_LIBRARY_DIRS:PATH='$NETCDF_PAR_BASE_DIR/lib;$HDF5_PAR_BASE_DIR/lib' -DNetcdf_LIBRARY_NAMES:STRING='netcdf;hdf5_hl;hdf5' -DNetcdf_INCLUDE_DIRS:PATH=$NETCDF_PAR_BASE_DIR/include"
  local SEACAS_PAR_ARGS="${SEACAS_ARGS} -DTrilinos_ENABLE_SECONDARY_STABLE_CODE:BOOL=ON -DTrilinos_ENABLE_SEACASExodus:BOOL=ON -DTrilinos_ENABLE_SEACASNemesis:BOOL=ON $NETCDF_PAR_ARGS -DTPL_ENABLE_MATLAB:BOOL=OFF"
  TRILINOS_SERCOMMIO_ADDL_ARGS="$TRILINOS_SERCOMM_ADDL_ARGS $SEACAS_ARGS"
  TRILINOS_PARCOMMIO_ADDL_ARGS="$TRILINOS_PARCOMM_ADDL_ARGS $SEACAS_PAR_ARGS"
# The builds
  if bilderConfig trilinos sercommio "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERCOMMIO_ADDL_ARGS $TRILINOS_SERCOMMIO_OTHER_ARGS"; then
    bilderBuild trilinos sercommio "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parcommio "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARCOMMIO_ADDL_ARGS $TRILINOS_PARCOMMIO_OTHER_ARGS"; then
    bilderBuild trilinos parcommio "$TRILINOS_MAKEJ_ARGS"
  fi

#
# The full builds include non commercially licensable libraries.
# AFAICT, only parmetis, so the parmetis (par, parsh) builds of superlu
#
# The args
  local TRILINOS_FULL_ARGS="-DTPL_ENABLE_PARMETIS:BOOL=ON"
  TRILINOS_PARFULL_ADDL_ARGS="$TRILINOS_PAR_ADDL_ARGS -DParMETIS_INCLUDE_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/include' -DParMETIS_LIBRARY_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/lib' -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/include' -DSuperLUDist_LIBRARY_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/lib' -DSuperLUDist_LIBRARY_NAMES:STRING='superlu_dist'"
  TRILINOS_PARFULLSH_ADDL_ARGS="$TRILINOS_PARCOMMSH_ADDL_ARGS -DParMETIS_INCLUDE_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/include' -DParMETIS_LIBRARY_DIRS:PATH='$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/lib' -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/include' -DSuperLUDist_LIBRARY_DIRS:PATH='$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/lib' -DSuperLUDist_LIBRARY_NAMES:STRING='superlu_dist'"

# The builds
if false; then # JRC: I see no difference between these and the comm builds
  if bilderConfig trilinos serfull "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SER_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu"; then
    bilderBuild trilinos serfull "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos serfullsh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
    bilderBuild trilinos serfullsh "$TRILINOS_MAKEJ_ARGS"
  fi
fi
  if bilderConfig trilinos parfull "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_FULL_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARFULL_ADDL_ARGS $TRILINOS_PARFULL_OTHER_ARGS"; then
    bilderBuild trilinos parfull "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parfullsh "-DBUILD_SHARED_LIBS:BOOL=ON -DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_FULL_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARFULLSH_ADDL_ARGS $TRILINOS_PARFULLSH_OTHER_ARGS"; then
    bilderBuild trilinos parfullsh "$TRILINOS_MAKEJ_ARGS"
  fi

}

######################################################################
#
# Test trilinos
#
######################################################################

testTrilinos() {
  techo "Not testing trilinos."
}

######################################################################
#
# Install trilinos
#
######################################################################

installTrilinos() {
  bilderInstallAll trilinos " -r -p open"
}

