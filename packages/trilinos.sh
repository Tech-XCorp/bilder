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
  if test -z "$FC"; then
    TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DTrilinos_ENABLE_Fortran=OFF"
  fi
  if test -n "$MIXED_PYTHON"; then
# Needed to prevent use of python2.6 when both versions present
    TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DPYTHON_EXECUTABLE:FILEPATH=$MIXED_PYTHON"
  fi
  case `uname`-`uname -r` in
    Darwin-13.*)
      TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DTrilinos_SKIP_FORTRANCINTERFACE_VERIFY_TEST:BOOL=TRUE"
      ;;
  esac

# Packages plus associated paths for all builds
  local TRILINOS_BARE_PKGS="-DTrilinos_ENABLE_ML:BOOL=ON -DTrilinos_ENABLE_AztecOO:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_EpetraExt:BOOL=ON -DTrilinos_ENABLE_Epetra:BOOL=ON -DTrilinos_ENABLE_Triutils:BOOL=ON -DTrilinos_ENABLE_Teuchos:BOOL=ON -DTeuchos_ENABLE_LONG_LONG_INT:BOOL=ON -DTrilinos_ENABLE_Ifpack:BOOL=ON -DTPL_ENABLE_BinUtils:BOOL=OFF -DTPL_ENABLE_Boost:STRING=ON"

# Shared and static specific args
  TRILINOS_SERSH_ADDL_ARGS="$TRILINOS_SERSH_ADDL_ARGS -DTPL_Boost_INCLUDE_DIRS:FILEPATH=$CONTRIB_DIR/boost-sersh/include"
  TRILINOS_SER_ADDL_ARGS="$TRILINOS_SER_ADDL_ARGS -DTPL_Boost_INCLUDE_DIRS:FILEPATH=$CONTRIB_DIR/boost/include"
  TRILINOS_PARSH_ADDL_ARGS="$TRILINOS_PARSH_ADDL_ARGS -DTPL_Boost_INCLUDE_DIRS:FILEPATH=$CONTRIB_DIR/boost-sersh/include"
  TRILINOS_PAR_ADDL_ARGS="$TRILINOS_PAR_ADDL_ARGS -DTPL_Boost_INCLUDE_DIRS:FILEPATH=$CONTRIB_DIR/boost/include"
  TRILINOS_BEN_ADDL_ARGS="$TRILINOS_BEN_ADDL_ARGS -DTPL_Boost_INCLUDE_DIRS:FILEPATH=$CONTRIB_DIR/boost-ben/include"

  local NETCDF_BASE_DIR=$MIXED_CONTRIB_DIR/netcdf-$NETCDF_BLDRVERSION-ser
  local HDF5_BASE_DIR=$MIXED_CONTRIB_DIR/hdf5-$HDF5_BLDRVERSION-ser
  local NETCDF_ARGS="-DTPL_ENABLE_Netcdf:STRING='ON' -DNetcdf_LIBRARY_DIRS:PATH='$NETCDF_BASE_DIR/lib;$HDF5_BASE_DIR/lib' -DNetcdf_LIBRARY_NAMES:STRING='netcdf;hdf5_hl;hdf5' -DNetcdf_INCLUDE_DIRS:PATH=$NETCDF_BASE_DIR/include"

  local SEACAS_ARGS="${SEACAS_ARGS} -DTrilinos_ENABLE_SECONDARY_STABLE_CODE:BOOL=ON -DTrilinos_ENABLE_SEACASExodus:BOOL=ON -DTrilinos_ENABLE_SEACASNemesis:BOOL=ON $NETCDF_ARGS -DTPL_ENABLE_MATLAB:BOOL=OFF"

  if ! [[ `uname` =~ CYGWIN ]]; then
    if test -n "$LIBFORTRAN_DIR"; then
        TRILINOS_ALL_ADDL_ARGS="$TRILINOS_ALL_ADDL_ARGS -DTrilinos_ENABLE_Fortran=OFF -DTrilinos_EXTRA_LINK_FLAGS:STRING='-L$LIBFORTRAN_DIR -Wl,-rpath,$LIBFORTRAN_DIR'"
    fi

  fi


# Build the shared libs
  if bilderConfig trilinos serbaresh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
    bilderBuild trilinos serbaresh "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos serfullsh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
    bilderBuild trilinos serfullsh "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos sercommsh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_NOX:STRING=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
    bilderBuild trilinos sercommsh "$TRILINOS_MAKEJ_ARGS"
  fi

  # Need to enable parmetis here and metis???
  if bilderConfig trilinos parbaresh "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_BLAS_LIB_ARG -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARSH_OTHER_ARGS"; then
    bilderBuild trilinos parbaresh "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parfullsh "-DTPL_ENABLE_MPI:BOOL=ON -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist  -DTPL_ENABLE_PARMETIS:BOOL=ON -DParMETIS_INCLUDE_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/include  -DParMETIS_LIBRARY_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/lib $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_BLAS_LIB_ARG -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARSH_OTHER_ARGS"; then
    bilderBuild trilinos parfullsh "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parcommsh "-DTPL_ENABLE_MPI:BOOL=ON -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_NOX:STRING=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcommsh/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcommsh/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_BLAS_LIB_ARG -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PARCOMMSH_OTHER_ARGS"; then
    bilderBuild trilinos parcommsh "$TRILINOS_MAKEJ_ARGS"
  fi

# Build the static libs.  This needs fixing.
  if test -n "$BLAS_STATIC_LIBRARIES" -a -n "$LAPACK_STATIC_LIBRARIES"; then
    TRILINOS_STATIC_LINLIB_ARGS="-DTPL_BLAS_LIBRARIES:FILEPATH='`echo $BLAS_STATIC_LIBRARIES | tr ' ' ';'`'"
    TRILINOS_STATIC_LINLIB_ARGS="$TRILINOS_STATIC_LINLIB_ARGS -DTPL_LAPACK_LIBRARIES:FILEPATH='`echo $LAPACK_STATIC_LIBRARIES | tr ' ' ';'`'"
  else
    TRILINOS_STATIC_LINLIB_ARGS="$CMAKE_LINLIB_SER_ARGS"
  fi

# The non-ben builds
  if bilderConfig trilinos serbare "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SER_OTHER_ARGS"; then
    bilderBuild trilinos serbare "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos serfull "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SER_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu"; then
    bilderBuild trilinos serfull "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos sercomm "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SER_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_NOX:STRING=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu $TRILINOS_SERCOMM_OTHER_ARGS"; then
    bilderBuild trilinos sercomm "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos sercommio "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_SER_OTHER_ARGS ${SEACAS_ARGS} -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_NOX:STRING=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu"; then
    bilderBuild trilinos sercommio "$TRILINOS_MAKEJ_ARGS"
  fi

  if bilderConfig trilinos parbare "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PAR_OTHER_ARGS"; then
    bilderBuild trilinos parbare "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parfull "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PAR_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist -DTPL_ENABLE_PARMETIS:BOOL=ON -DParMETIS_INCLUDE_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/include  -DParMETIS_LIBRARY_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}-par/lib $$TRILINOS_PARFULL_OTHER_ARGS"; then
    bilderBuild trilinos parfull "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parcomm "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PAR_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_NOX:STRING=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist $TRILINOS_PARCOMM_OTHER_ARGS"; then
    bilderBuild trilinos parcomm "$TRILINOS_MAKEJ_ARGS"
  fi
  if bilderConfig trilinos parcommio "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_PAR_OTHER_ARGS ${SEACAS_ARGS} -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_NOX:STRING=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist $TRILINOS_PARCOMMIO_OTHER_ARGS"; then
    bilderBuild trilinos parcommio "$TRILINOS_MAKEJ_ARGS"
  fi

# Build the ben libs.  This needs fixing.
  if test -n "$BLAS_BEN_LIBRARIES" -a -n "$LAPACK_BEN_LIBRARIES"; then
    TRILINOS_BEN_LINLIB_ARGS="-DTPL_BLAS_LIBRARIES:FILEPATH='`echo $BLAS_BEN_LIBRARIES | tr ' ' ';'`'"
    TRILINOS_BEN_LINLIB_ARGS="$TRILINOS_BEN_LINLIB_ARGS -DTPL_LAPACK_LIBRARIES:FILEPATH='`echo $LAPACK_BEN_LIBRARIES | tr ' ' ';'`'"
  else
    TRILINOS_BEN_LINLIB_ARGS="$CMAKE_LINLIB_SER_ARGS"
  fi

# The ben build
  if bilderConfig trilinos ben "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $TRILINOS_BEN_LINLIB_ARGS $TRILINOS_ALL_ADDL_ARGS $TRILINOS_BEN_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTrilinos_ENABLE_NOX:STRING=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-ben/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-ben/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist $TRILINOS_BEN_OTHER_ARGS"; then
    bilderBuild trilinos ben "$TRILINOS_MAKEJ_ARGS"
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
# -DCMAKE_INSTALL_ALWAYS:BOOL=TRUE is not working, so add -r.
  for bld in serbaresh parbaresh serfullsh parfullsh sercommsh parcommsh serbare parbare serfull parfull sercomm sercommio parcomm parcommio ben; do
    # if bilderInstall -r trilinos $bld; then
    if bilderInstall -r trilinos $bld; then
# Group writable perms for trilinos
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/trilinos-$TRILINOS_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
  # techo "WARNING: Quitting at end of installTrilinos."; cleanup
}

