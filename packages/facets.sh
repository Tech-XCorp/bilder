#!/bin/bash
#
# Version and build information for facets
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Other values
#
######################################################################

FACETS_DEPS=${FACETS_DEPS:-"muparser,ntcc_transport,gacode,uedge,nubeam,fmcfm,eqcodes,wallpsi,fluxgrid,facetsifc,fusion_machine,matplotlib,scipy,tables,lp_solve,muparser,txbase,fciowrappers,petsc,openmpi,babel,metatau,simyan,autotools"}

if test -z "$FACETS_BUILDS"; then
  FACETS_BUILDS=ser,par
  if $BUILD_OPTIONAL; then
    FACETS_BUILDS=$FACETS_BUILDS,partau
  fi
  if echo $DOCS_BUILDS | egrep -q "(^|,)develdocs($|,)"; then
    FACETS_BUILDS=$FACETS_BUILDS,develdocs
  fi
fi
FACETS_UMASK=002

######################################################################
#
# Launch facets builds.
#
######################################################################

# Build facets using cmake
buildFacets() {

# Get the version
  getVersion facets

# Determine whether to proceed
  if bilderPreconfig -c facets; then

# Args depending on system
    case `uname` in
      CYGWIN*)
        FACETS_ALL_ADDL_ARGS="$CMAKE_LINLIB_SER_ARGS"
        ;;
    esac

# Order is from longest to shortest to build
    if $BUILD_OPTIONAL; then

# set the TAU compiler for C++, the default for others
      CMAKE_COMPILERS_PARTAU="-DCMAKE_C_COMPILER:FILEPATH='$MPICC' -DCMAKE_CXX_COMPILER:FILEPATH='$CONTRIB_DIR/tau/bin/tau_cxx.sh' -DCMAKE_Fortran_COMPILER:FILEPATH='$MPIFC'"
# set the TAU makefile, use the default from the metatau build
      TAU_MAKEFILE=$CONTRIB_DIR/tau/include/Makefile
      # set the TAU options
      FACETS_TAU_ARGS="TAU_MAKEFILE=$TAU_MAKEFILE TAU_OPTIONS=\"-optVerbose -optPdtGnuFortranParser -optPreProcess -optNoCompInst -optRevert -optTauSelectFile=$PROJECT_DIR/facets/fcutils/select.tau -optTauMakefile=$TAU_MAKEFILE\""

      if bilderConfig -c facets partau "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PARTAU $CMAKE_COMPFLAGS_PAR $FACETS_ALL_ADDL_ARGS $FACETS_PARTAU_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG" "" "$FACETS_TAU_ARGS"; then
        bilderBuild facets partau "$FACETS_MAKEJ_ARGS" "$FACETS_TAU_ARGS"
      fi

    fi

# Parallel build
    if bilderConfig -c facets par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $FACETS_ALL_ADDL_ARGS $FACETS_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG" facets; then
      bilderBuild facets par "$FACETS_MAKEJ_ARGS"
    fi

# Serial build
    if bilderConfig -c facets ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $FACETS_ALL_ADDL_ARGS $FACETS_SER_OTHER_ARGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG" facets; then
      bilderBuild facets ser "$FACETS_MAKEJ_ARGS"
    fi

# Developer documentation build
    if bilderConfig -c -g facets develdocs "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $FACETS_ALL_ADDL_ARGS $FACETS_SER_OTHER_ARGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG -DENABLE_DEVELDOCS:BOOL=ON" facets; then
      bilderBuild facets develdocs "develdocs"
    fi

  fi

}

######################################################################
#
# Test facets
#
######################################################################

# Set umask to allow only group to modify
testFacets() {
  bilderRunTests facets FcTests
}

######################################################################
#
# Install facets
#
######################################################################

installFacets() {
  if bilderInstallTestedPkg -r -p open facets FcTests; then
    bilderInstall -r facets partau "" "" "$FACETS_TAU_ARGS"
  fi
}

