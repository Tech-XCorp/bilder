#!/bin/bash
#
# Version and build information for trilinos
#
# $Id$
#
######################################################################

######################################################################
#
# Version
# This is repacked to obey bilder conventions
# tar xzf trilinos-10.2.0-Source.tar.gz
# mv trilinos-10.2.0-Source trilinos-10.2.0
# tar czf trilinos-10.2.0.tar.gz trilinos-10.2.0
#
######################################################################

if test -z "$TRILINOS_BLDRVERSION"; then
  if $BUILD_EXPERIMENTAL; then
    case `uname`-`uname -r` in
      CYGWIN*-*) TRILINOS_BLDRVERSION=10.12.2;;
# 10.10.2 does not put lapack and blas in Trilinos_TPL_LIBRARIES on Lion.
      # Darwin-11.*) TRILINOS_BLDRVERSION=10.10.1;;
      *) TRILINOS_BLDRVERSION=10.12.2;;
    esac
  else
    case `uname`-`uname -r` in
      CYGWIN*WOW64-*) TRILINOS_BLDRVERSION=10.10.1;;
      CYGWIN*-*) TRILINOS_BLDRVERSION=10.10.1;;
      Darwin-11.*) TRILINOS_BLDRVERSION=10.10.1;;
      *) TRILINOS_BLDRVERSION=10.10.2;;
    esac
  fi
fi

######################################################################
#
# Builds, deps, mask, auxdata, paths
#
######################################################################

if test -z "$TRILINOS_BUILDS"; then
  TRILINOS_BUILDS="serfull,parfull"
  case `uname` in
    CYGWIN* | Darwin) ;;
    *) TRILINOS_BUILDS="${TRILINOS_BUILDS},serfullsh,parfullsh";;
  esac
fi

TRILINOS_DEPS=${TRILINOS_DEPS:-"numpy,swig,openmpi,boost,hdf5,atlas,lapack"}

# Add superlu/superlu_dist if this is a full or commercial build but not bare build
if (grep -q full <<<$TRILINOS_BUILDS) || (grep -q comm <<<$TRILINOS_BUILDS); then
  TRILINOS_DEPS="${TRILINOS_DEPS},superlu,superlu_dist"
fi

TRILINOS_UMASK=002

######################################################################
#
# Launch trilinos builds.
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

  if test $res = 0; then

# Check for install_dir installation
    if test $CONTRIB_DIR != $INSTALL_DIR -a -e $INSTALL_DIR/trilinos; then
      techo "WARNING: trilinos is installed in $INSTALL_DIR."
    fi

# Universal args
      #IS_MINGW=${IS_MINGW:-"false"}
    TRILINOS_ALL_OTHER_ARGS=${TRILINOS_ALL_OTHER_ARGS:-"-DTrilinos_ENABLE_ML:BOOL=ON -DTrilinos_ENABLE_AztecOO:BOOL=ON -DTrilinos_ENABLE_EpetraExt:BOOL=ON -DTrilinos_ENABLE_Epetra:BOOL=ON -DTrilinos_ENABLE_Triutils:BOOL=ON -DTrilinos_ENABLE_Teuchos:BOOL=ON -DTeuchos_ENABLE_LONG_LONG_INT:BOOL=ON -DTrilinos_ENABLE_Ifpack:BOOL=ON -DDART_TESTING_TIMEOUT:STRING=600 -DTPL_Boost_INCLUDE_DIRS:FILEPATH=$CONTRIB_DIR/boost-${BOOST_BLDRVERSION}/include -DTPL_ENABLE_BinUtils:BOOL=OFF"}
    if test -z "$FC"; then
      TRILINOS_ALL_OTHER_ARGS="$TRILINOS_ALL_OTHER_ARGS -DTrilinos_ENABLE_Fortran=OFF"
    fi
    if test -n "$MIXED_PYTHON"; then
# Needed to prevent use of python2.6 when both versions present
      TRILINOS_ALL_OTHER_ARGS="$TRILINOS_ALL_OTHER_ARGS -DPYTHON_EXECUTABLE:FILEPATH=$MIXED_PYTHON"
    fi
    TRILINOS_ADDL_STARGS="$TRILINOS_ALL_OTHER_ARGS"
    case `uname` in
      Linux)
        if test -n "$LIBFORTRAN_DIR"; then
          TRILINOS_ADDL_STARGS="$TRILINOS_ALL_OTHER_ARGS -DTrilinos_EXTRA_LINK_FLAGS:STRING='-L$LIBFORTRAN_DIR'"
          TRILINOS_ALL_OTHER_ARGS="$TRILINOS_ALL_OTHER_ARGS -DTrilinos_EXTRA_LINK_FLAGS:STRING='-L$LIBFORTRAN_DIR -Wl,-rpath,$LIBFORTRAN_DIR'"
        fi
        ;;
    esac

# Build the shared libs
    if bilderConfig -p trilinos-${TRILINOS_BLDRVERSION}-serbare trilinos serbaresh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
      bilderBuild trilinos serbaresh "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig -p trilinos-${TRILINOS_BLDRVERSION}-serfull trilinos serfullsh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
      bilderBuild trilinos serfullsh "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig -p trilinos-${TRILINOS_BLDRVERSION}-sercomm trilinos sercommsh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-sersh/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu -DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_SERSH_OTHER_ARGS"; then
      bilderBuild trilinos sercommsh "$TRILINOS_MAKEJ_ARGS"
    fi

    # Need to enable parmetis here and metis???
    if bilderConfig -p trilinos-${TRILINOS_BLDRVERSION}-parbare trilinos parbaresh "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_BLAS_LIB_ARG -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_PARSH_OTHER_ARGS"; then
      bilderBuild trilinos parbaresh "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig -p trilinos-${TRILINOS_BLDRVERSION}-parfull trilinos parfullsh "-DTPL_ENABLE_MPI:BOOL=ON -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parsh/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist  -DTPL_ENABLE_PARMETIS:BOOL=ON -DParMETIS_INCLUDE_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}}-par/include  -DParMETIS_LIBRARY_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}}-par/lib $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_BLAS_LIB_ARG -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_PARSH_OTHER_ARGS"; then
      bilderBuild trilinos parfullsh "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig -p trilinos-${TRILINOS_BLDRVERSION}-parcomm trilinos parcommsh "-DTPL_ENABLE_MPI:BOOL=ON -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcommsh/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcommsh/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_BLAS_LIB_ARG -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_LINLIB_SER_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_PARSH_OTHER_ARGS"; then
      bilderBuild trilinos parcommsh "$TRILINOS_MAKEJ_ARGS"
    fi

# Build the static libs.  This needs fixing.
    if test -n "$BLAS_STATIC_LIBRARIES" -a -n "$LAPACK_STATIC_LIBRARIES"; then
      TRILINOS_STATIC_LINLIB_ARGS="-DTPL_BLAS_LIBRARIES:FILEPATH='`echo $BLAS_STATIC_LIBRARIES | tr ' ' ';'`'"
      TRILINOS_STATIC_LINLIB_ARGS="$TRILINOS_STATIC_LINLIB_ARGS -DTPL_LAPACK_LIBRARIES:FILEPATH='`echo $LAPACK_STATIC_LIBRARIES | tr ' ' ';'`'"
    else
      TRILINOS_STATIC_LINLIB_ARGS="$CMAKE_LINLIB_SER_ARGS"
    fi
    if bilderConfig trilinos serbare "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_SER_OTHER_ARGS"; then
      bilderBuild trilinos serbare "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig trilinos serfull "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_SER_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu"; then
      bilderBuild trilinos serfull "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig trilinos sercomm "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_SER_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLU:BOOL=ON -DSuperLU_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include -DSuperLU_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib -DSuperLU_LIBRARY_NAMES:STRING=superlu"; then
      bilderBuild trilinos sercomm "$TRILINOS_MAKEJ_ARGS"
    fi

    if bilderConfig trilinos parbare "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_NODEFLIB_FLAGS $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_PAR_OTHER_ARGS"; then
      bilderBuild trilinos parbare "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig trilinos parfull "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_NODEFLIB_FLAGS $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_PAR_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist -DTPL_ENABLE_PARMETIS:BOOL=ON -DParMETIS_INCLUDE_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}}-par/include  -DParMETIS_LIBRARY_DIRS:PATH=$CONTRIB/parmetis-${PARMETIS_BLDRVERSION}}-par/lib"; then
      bilderBuild trilinos parfull "$TRILINOS_MAKEJ_ARGS"
    fi
    if bilderConfig trilinos parcomm "-DTPL_ENABLE_MPI:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_NODEFLIB_FLAGS $TRILINOS_STATIC_LINLIB_ARGS $TRILINOS_ALL_OTHER_ARGS $TRILINOS_PAR_OTHER_ARGS -DTrilinos_ENABLE_Amesos:BOOL=ON -DTrilinos_ENABLE_Galeri:BOOL=ON -DTrilinos_ENABLE_Shards:BOOL=ON -DTrilinos_ENABLE_Intrepid:BOOL=ON -DTrilinos_ENABLE_Komplex:BOOL=ON -DTrilinos_ENABLE_Phalanx:BOOL=ON -DTPL_ENABLE_SuperLUDist:BOOL=ON -DSuperLUDist_INCLUDE_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/include -DSuperLUDist_LIBRARY_DIRS:PATH=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/lib -DSuperLUDist_LIBRARY_NAMES:STRING=superlu_dist"; then
      bilderBuild trilinos parcomm "$TRILINOS_MAKEJ_ARGS"
    fi

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
  for bld in serbaresh parbaresh serfullsh parfullsh sercommsh parcommsh serbare parbare serfull parfull sercomm parcomm; do
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

