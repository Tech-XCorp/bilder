#!/bin/bash
#
# $Id$
#
# Define variables.
# Do not override existing definitions.
# Put any comments between the first block starting with '# KEEP THIS'
# and ending with '# END KEEP THIS'
#
######################################################################

# KEEP THIS

# Set defaults for when not run through Bilder
VERBOSITY=${VERBOSITY:-"0"}

# Do not build atlas by default on Windows.
# Trilinos has problems, but numpy is building.
BUILD_ATLAS=${BUILD_ATLAS:-"false"}

# Need to get runnrfcns if derefpath not known.
if ! declare -f derefpath 1>/dev/null 2>&1; then
  runnrdir=`dirname $BASH_SOURCE`/../runnr
  if test -d $runnrdir; then
    runnrdir=`(cd $runnrdir; pwd -P)`
    source $runnrdir/runnrfcns.sh
  else
    echo "ERROR: $runnrdir not found."
  fi
fi
if declare -f techo 1>/dev/null 2>&1; then
  TECHO=techo
  TECHO2="techo -2"
else
  TECHO=echo
  TECHO2=echo
fi

#
# Find mingw
#
MINGW_BINDIR=
for dr in /TDM-GCC-64 /MinGW64 /TDM-GCC-32; do
  bd=`ls -1d $dr/bin $dr/*/bin 2>/dev/null | tail -1`
  if test -n "${bd}"; then
    MINGW_BINDIR=${bd}
    break
  fi
done
if test -n "$MINGW_BINDIR"; then
  $TECHO "MinGW found: MINGW_BINDIR = $MINGW_BINDIR."
else
  $TECHO "NOTE: MinGW not found.  ATLAS and SciPy require installation of MinGW per instructions at http://sourceforge.net/p/bilder/wiki/Installing MinGW."
fi

# Find all the compilers if prefix known.
if test -n "$MINGW_BINDIR"; then

# Find the prefix for the compilers.
  MINGW_PREFIX=
  for pr in x86_64-w64-mingw32 i686-w64-mingw32 mingw32; do
    if test -x ${MINGW_BINDIR}/${pr}-gcc; then
      MINGW_PREFIX=$pr
      break
    fi
  done
  $TECHO "MINGW_PREFIX = $MINGW_PREFIX."

  if test -n "$MINGW_PREFIX"; then

# Find fortran compiler
    if test -x ${MINGW_BINDIR}/${MINGW_PREFIX}-gfortran.exe; then
      FC=${FC:-"${MINGW_BINDIR}/${MINGW_PREFIX}-gfortran.exe"}
    fi

# Atlas requires that the mingw compilers be linked into /usr/bin
# on Windows
    # for prog in gcc gfortran ar ranlib; do
    for prog in gcc gfortran; do
      if ! test -e /usr/bin/${MINGW_PREFIX}-${prog}.exe; then
        $TECHO "WARNING: [cygwin.vs] ${MINGW_PREFIX}-${prog}.exe not found."
        if test -n $MINGW_BINDIR/${MINGW_PREFIX}-${prog}.exe; then
          $TECHO "WARNING: [cygwin.vs] Execute 'ln -s $MINGW_BINDIR/${MINGW_PREFIX}-${prog}.exe /usr/bin/${MINGW_PREFIX}-${prog}.exe'."
        else
          $TECHO "NOTE: Cannot find MinGW installation of ${prog}."
        fi
      fi
    done

  fi

fi

# Set the fortran compiler
if test -n "$FC"; then
  FC=`cygpath -am $FC`
  F77="$FC"
  PYC_FC="$FC"
  PYC_F77="$FC"
else
  LAPACK_BUILDS=${LAPACK_BUILDS:-"NONE"}
fi
if test -n "$FC"; then
  HAVE_SER_FORTRAN=true
else
  HAVE_SER_FORTRAN=false
fi

# cygwin.vs{9,10} should define PROJECT_DIR, and we
# can go ahead and finish out cygwin defs.
if test -n "$VISUALSTUDIO_VERSION"; then
  source $BILDER_DIR/machines/cygwin.sh
fi

# END KEEP THIS

# Serial compilers
# FC should be a compiler that compiles F77 or F90 but takes free format.
# F77 should be a compiler that compiles F77 or F90 but takes fixed format.
# Typically this means that both are the F90 compiler, and they figure out the
# format from the file suffix.  The exception is the XL suite, where xlf
# compiles F77 or F90, and expects fixed format, while xlf9x ignores
# the suffix and looks for the -qfixed flag or else fails on fixed format.
# CC=${CC:-""}
# CXX=${CXX:-""}
# FC=${FC:-""}
# F77=${F77:-""}

# Python builds -- much use gcc for consistency.
PYC_CC=${PYC_CC:-"cl"}
PYC_CXX=${PYC_CXX:-"cl"}
# PYC_FC=${PYC_FC:-""}
# PYC_F77=${PYC_F77:-""}

# Backend compilers:
# BENCC=${BENCC:-""}
# BENCXX=${BENCXX:-""}
# BENFC=${BENFC:-""}
# BENF77=${BENF77:-""}

# Parallel compilers:
# MPICC=${MPICC:-""}
# MPICXX=${MPICXX:-""}
# MPIFC=${MPIFC:-""}
# MPIF77=${MPIF77:-""}

# Compilation flags:
# Do not set optimization flags as packages should add good defaults
# pic flags are added later

# Serial
CFLAGS=${CFLAGS:-"/DWIN32 /D_WINDOWS /W3"}
CXXFLAGS=${CXXFLAGS:-"/DWIN32 /D_WINDOWS /W3 /GR /EHsc"}
# FCFLAGS=${FCFLAGS:-""}
# FFLAGS=${FFLAGS:-""}

# PYC flags:
# PYC_LDFLAGS is for creating an executable.
# PYC_MODFLAGS is for creating a module.
PYC_CFLAGS=${PYC_CFLAGS:-"/DWIN32 /D_WINDOWS /W3"}
PYC_CXXFLAGS=${PYC_CXXFLAGS:-"/DWIN32 /D_WINDOWS /W3 /GR /EHsc"}
# PYC_FCFLAGS=${PYC_FCFLAGS:-""}
# PYC_FFLAGS=${PYC_FFLAGS:-""}
# PYC_LDFLAGS=${PYC_LDFLAGS:-""}
# PYC_MODFLAGS=${PYC_MODFLAGS:-""}
# PYC_LD_LIBRARY_PATH=${PYC_LD_LIBRARY_PATH:-""}
# PYC_LD_RUN_PATH=${PYC_LD_RUN_PATH:-""}

# Parallel
# MPI_CFLAGS=${MPI_CFLAGS:-""}
# MPI_CXXFLAGS=${MPI_CXXFLAGS:-""}
# MPI_FCFLAGS=${MPI_FCFLAGS:-""}
# MPI_FFLAGS=${MPI_FFLAGS:-""}

# Linear algebra libraries:
# All should be a full path to the library.
# SER versions are for front-end nodes.
# BEN versions are for back-end nodes if different.
# PYC versions are for front-end nodes.
# SYSTEM_BLAS_SER_LIB=${SYSTEM_BLAS_SER_LIB:-""}
# SYSTEM_BLAS_PYCSH_LIB=${SYSTEM_BLAS_PYCSH_LIB:-""}
# SYSTEM_BLAS_BEN_LIB=${SYSTEM_BLAS_BEN_LIB:-""}
# SYSTEM_LAPACK_SER_LIB=${SYSTEM_LAPACK_SER_LIB:-""}
# SYSTEM_LAPACK_PYCSH_LIB=${SYSTEM_LAPACK_PYCSH_LIB:-""}
# SYSTEM_LAPACK_BEN_LIB=${SYSTEM_LAPACK_BEN_LIB:-""}

# IO directories:
# SYSTEM_HDF5_SER_DIR=${SYSTEM_HDF5_SER_DIR:-""}
# SYSTEM_HDF5_PAR_DIR=${SYSTEM_HDF5_PAR_DIR:-""}
# SYSTEM_NETCDF_SER_DIR=${SYSTEM_NETCDF_SER_DIR:-""}
# SYSTEM_NETCDF_PAR_DIR=${SYSTEM_NETCDF_PAR_DIR:-""}

# Java options
# export _JAVA_OPTIONS=

# Choose preferred buildsystem
# PREFER_CMAKE=${PREFER_CMAKE:-""}

# Variables for the packages, .
# All variables override defaults in files in bilder/packages.
# <PKG>_BLDRVERSION contains the version to be built.
# <PKG>_BUILDS contains the desired builds. Use of NOBUILD is deprecated.
# <PKG>_<BUILD>_OTHER_ARGS contains the other configuration arguments
#   for build <BUILD>.  If a package could have a cmake or an autotools
#   build, then the variables are <PKG>_<BUILD>_CMAKE_OTHER_ARGS
#   and <PKG>_<BUILD>_CONFIG_OTHER_ARGS

# ADIOS_BLDRVERSION=${ADIOS_BLDRVERSION:-""}
# ADIOS_BUILDS=${ADIOS_BUILDS:-""}
# ADIOS_SER_OTHER_ARGS=${ADIOS_SER_OTHER_ARGS:-""}

# ADOLC_BLDRVERSION=${ADOLC_BLDRVERSION:-""}
# ADOLC_BUILDS=${ADOLC_BUILDS:-""}
# ADOLC_SER_OTHER_ARGS=${ADOLC_SER_OTHER_ARGS:-""}

# ARPREC_BLDRVERSION=${ARPREC_BLDRVERSION:-""}
# ARPREC_BUILDS=${ARPREC_BUILDS:-""}
# ARPREC_SER_OTHER_ARGS=${ARPREC_SER_OTHER_ARGS:-""}

# ATLAS_BLDRVERSION=${ATLAS_BLDRVERSION:-""}
# ATLAS_BUILDS=${ATLAS_BUILDS:-""}
# ATLAS_PYCSH_OTHER_ARGS=${ATLAS_PYCSH_OTHER_ARGS:-""}
# ATLAS_CLP_OTHER_ARGS=${ATLAS_CLP_OTHER_ARGS:-""}
# ATLAS_SER_OTHER_ARGS=${ATLAS_SER_OTHER_ARGS:-""}

# AUTOCONF_BLDRVERSION=${AUTOCONF_BLDRVERSION:-""}
# AUTOCONF_BUILDS=${AUTOCONF_BUILDS:-""}
# AUTOCONF_SER_OTHER_ARGS=${AUTOCONF_SER_OTHER_ARGS:-""}

# AUTOMAKE_BLDRVERSION=${AUTOMAKE_BLDRVERSION:-""}
# AUTOMAKE_BUILDS=${AUTOMAKE_BUILDS:-""}
# AUTOMAKE_SER_OTHER_ARGS=${AUTOMAKE_SER_OTHER_ARGS:-""}

# AUTOTOOLS_BLDRVERSION=${AUTOTOOLS_BLDRVERSION:-""}
# AUTOTOOLS_BUILDS=${AUTOTOOLS_BUILDS:-""}
# AUTOTOOLS_FAKE_OTHER_ARGS=${AUTOTOOLS_FAKE_OTHER_ARGS:-""}

# BABEL_BLDRVERSION=${BABEL_BLDRVERSION:-""}
BABEL_BUILDS=${BABEL_BUILDS:-"NONE"}
# BABEL_SHARED_OTHER_ARGS=${BABEL_SHARED_OTHER_ARGS:-""}
# BABEL_STATIC_OTHER_ARGS=${BABEL_STATIC_OTHER_ARGS:-""}

# BHSSOLVER_BLDRVERSION=${BHSSOLVER_BLDRVERSION:-""}
# BHSSOLVER_BUILDS=${BHSSOLVER_BUILDS:-""}
# BHSSOLVER_BEN_OTHER_ARGS=${BHSSOLVER_BEN_OTHER_ARGS:-""}
# BHSSOLVER_SER_OTHER_ARGS=${BHSSOLVER_SER_OTHER_ARGS:-""}

# BINUTILS_BLDRVERSION=${BINUTILS_BLDRVERSION:-""}
# BINUTILS_BUILDS=${BINUTILS_BUILDS:-""}
# BINUTILS_SER_OTHER_ARGS=${BINUTILS_SER_OTHER_ARGS:-""}

# BOOST_BLDRVERSION=${BOOST_BLDRVERSION:-""}
# BOOST_BUILDS=${BOOST_BUILDS:-""}
# BOOST_SER_OTHER_ARGS=${BOOST_SER_OTHER_ARGS:-""}

# BOTAN_BLDRVERSION=${BOTAN_BLDRVERSION:-""}
# BOTAN_BUILDS=${BOTAN_BUILDS:-""}
# BOTAN_PYCSH_OTHER_ARGS=${BOTAN_PYCSH_OTHER_ARGS:-""}
# BOTAN_SERSH_OTHER_ARGS=${BOTAN_SERSH_OTHER_ARGS:-""}

# BZIP2_BLDRVERSION=${BZIP2_BLDRVERSION:-""}
# BZIP2_BUILDS=${BZIP2_BUILDS:-""}
# BZIP2_SER_OTHER_ARGS=${BZIP2_SER_OTHER_ARGS:-""}

# CFITSIO_BLDRVERSION=${CFITSIO_BLDRVERSION:-""}
# CFITSIO_BUILDS=${CFITSIO_BUILDS:-""}
# CFITSIO_SER_OTHER_ARGS=${CFITSIO_SER_OTHER_ARGS:-""}

# CGMA_BLDRVERSION=${CGMA_BLDRVERSION:-""}
# CGMA_BUILDS=${CGMA_BUILDS:-""}
# CGMA_SER_OTHER_ARGS=${CGMA_SER_OTHER_ARGS:-""}

# CHEFLIBS_BLDRVERSION=${CHEFLIBS_BLDRVERSION:-""}
# CHEFLIBS_BUILDS=${CHEFLIBS_BUILDS:-""}
# CHEFLIBS_PAR_OTHER_ARGS=${CHEFLIBS_PAR_OTHER_ARGS:-""}
# CHEFLIBS_SER_OTHER_ARGS=${CHEFLIBS_SER_OTHER_ARGS:-""}

# CHOMBO_BLDRVERSION=${CHOMBO_BLDRVERSION:-""}
# CHOMBO_BUILDS=${CHOMBO_BUILDS:-""}
# CHOMBO_PAR2D_OTHER_ARGS=${CHOMBO_PAR2D_OTHER_ARGS:-""}
# CHOMBO_PAR2DDBG_OTHER_ARGS=${CHOMBO_PAR2DDBG_OTHER_ARGS:-""}
# CHOMBO_PAR3D_OTHER_ARGS=${CHOMBO_PAR3D_OTHER_ARGS:-""}
# CHOMBO_PAR3DDBG_OTHER_ARGS=${CHOMBO_PAR3DDBG_OTHER_ARGS:-""}
# CHOMBO_SER2D_OTHER_ARGS=${CHOMBO_SER2D_OTHER_ARGS:-""}
# CHOMBO_SER2DDBG_OTHER_ARGS=${CHOMBO_SER2DDBG_OTHER_ARGS:-""}
# CHOMBO_SER3D_OTHER_ARGS=${CHOMBO_SER3D_OTHER_ARGS:-""}
# CHOMBO_SER3DDBG_OTHER_ARGS=${CHOMBO_SER3DDBG_OTHER_ARGS:-""}

# CHRPATH_BLDRVERSION=${CHRPATH_BLDRVERSION:-""}
# CHRPATH_BUILDS=${CHRPATH_BUILDS:-""}
# CHRPATH_SER_OTHER_ARGS=${CHRPATH_SER_OTHER_ARGS:-""}

# CLAPACK_CMAKE_BLDRVERSION=${CLAPACK_CMAKE_BLDRVERSION:-""}
CLAPACK_CMAKE_BUILDS=${CLAPACK_CMAKE_BUILDS:-"ser,sermd"}
# CLAPACK_CMAKE_PYCSH_OTHER_ARGS=${CLAPACK_CMAKE_PYCSH_OTHER_ARGS:-""}
CLAPACK_CMAKE_SER_OTHER_ARGS=${CLAPACK_CMAKE_SER_OTHER_ARGS:-"-DBUILD_SHARED_LIBS:BOOL=OFF"}

# CMAKE_BLDRVERSION=${CMAKE_BLDRVERSION:-""}
# CMAKE_BUILDS=${CMAKE_BUILDS:-""}
# CMAKE_SER_OTHER_ARGS=${CMAKE_SER_OTHER_ARGS:-""}

# COIN_BLDRVERSION=${COIN_BLDRVERSION:-""}
# COIN_BUILDS=${COIN_BUILDS:-""}
# COIN_PYCSH_OTHER_ARGS=${COIN_PYCSH_OTHER_ARGS:-""}

# CORRCALC_BLDRVERSION=${CORRCALC_BLDRVERSION:-""}
# CORRCALC_BUILDS=${CORRCALC_BUILDS:-""}
# CORRCALC_PAR_OTHER_ARGS=${CORRCALC_PAR_OTHER_ARGS:-""}
# CORRCALC_SER_OTHER_ARGS=${CORRCALC_SER_OTHER_ARGS:-""}

# COSML_BLDRVERSION=${COSML_BLDRVERSION:-""}
# COSML_BUILDS=${COSML_BUILDS:-""}
# COSML_PYCSH_OTHER_ARGS=${COSML_PYCSH_OTHER_ARGS:-""}

# COSML_LITE_BLDRVERSION=${COSML_LITE_BLDRVERSION:-""}
# COSML_LITE_BUILDS=${COSML_LITE_BUILDS:-""}
# COSML_LITE_PYCSH_OTHER_ARGS=${COSML_LITE_PYCSH_OTHER_ARGS:-""}

# CPPUNIT_BLDRVERSION=${CPPUNIT_BLDRVERSION:-""}
# CPPUNIT_BUILDS=${CPPUNIT_BUILDS:-""}
# CPPUNIT_SER_OTHER_ARGS=${CPPUNIT_SER_OTHER_ARGS:-""}

# CURL_BLDRVERSION=${CURL_BLDRVERSION:-""}
# CURL_BUILDS=${CURL_BUILDS:-""}
# CURL_SER_OTHER_ARGS=${CURL_SER_OTHER_ARGS:-""}

# CUSP_BLDRVERSION=${CUSP_BLDRVERSION:-""}
# CUSP_BUILDS=${CUSP_BUILDS:-""}
# CUSP_GPU_OTHER_ARGS=${CUSP_GPU_OTHER_ARGS:-""}

# CYTHON_BLDRVERSION=${CYTHON_BLDRVERSION:-""}
# CYTHON_BUILDS=${CYTHON_BUILDS:-""}
# CYTHON_PYCSH_OTHER_ARGS=${CYTHON_PYCSH_OTHER_ARGS:-""}

# DAKOTA_BLDRVERSION=${DAKOTA_BLDRVERSION:-""}
# DAKOTA_BUILDS=${DAKOTA_BUILDS:-""}
# DAKOTA_PAR_OTHER_ARGS=${DAKOTA_PAR_OTHER_ARGS:-""}
# DAKOTA_SER_OTHER_ARGS=${DAKOTA_SER_OTHER_ARGS:-""}

# DDSFLOW_BLDRVERSION=${DDSFLOW_BLDRVERSION:-""}
# DDSFLOW_BUILDS=${DDSFLOW_BUILDS:-""}
# DDSFLOW_SER_OTHER_ARGS=${DDSFLOW_SER_OTHER_ARGS:-""}

# DOCUTILS_BLDRVERSION=${DOCUTILS_BLDRVERSION:-""}
# DOCUTILS_BUILDS=${DOCUTILS_BUILDS:-""}
# DOCUTILS_PYCSH_OTHER_ARGS=${DOCUTILS_PYCSH_OTHER_ARGS:-""}

# DOXYGEN_BLDRVERSION=${DOXYGEN_BLDRVERSION:-""}
# DOXYGEN_BUILDS=${DOXYGEN_BUILDS:-""}
# DOXYGEN_SER_OTHER_ARGS=${DOXYGEN_SER_OTHER_ARGS:-""}

# EIGEN3_BLDRVERSION=${EIGEN3_BLDRVERSION:-""}
# EIGEN3_BUILDS=${EIGEN3_BUILDS:-""}
# EIGEN3_SER_OTHER_ARGS=${EIGEN3_SER_OTHER_ARGS:-""}

# EQCODES_BLDRVERSION=${EQCODES_BLDRVERSION:-""}
# EQCODES_BUILDS=${EQCODES_BUILDS:-""}
# EQCODES_BEN_OTHER_ARGS=${EQCODES_BEN_OTHER_ARGS:-""}
# EQCODES_SER_OTHER_ARGS=${EQCODES_SER_OTHER_ARGS:-""}

# EXODUSII_BLDRVERSION=${EXODUSII_BLDRVERSION:-""}
# EXODUSII_BUILDS=${EXODUSII_BUILDS:-""}
# EXODUSII_SER_OTHER_ARGS=${EXODUSII_SER_OTHER_ARGS:-""}

# FACETS_BLDRVERSION=${FACETS_BLDRVERSION:-""}
# FACETS_BUILDS=${FACETS_BUILDS:-""}
# FACETS_DEVELDOCS_OTHER_ARGS=${FACETS_DEVELDOCS_OTHER_ARGS:-""}
# FACETS_PAR_OTHER_ARGS=${FACETS_PAR_OTHER_ARGS:-""}
# FACETS_PARTAU_OTHER_ARGS=${FACETS_PARTAU_OTHER_ARGS:-""}
# FACETS_SER_OTHER_ARGS=${FACETS_SER_OTHER_ARGS:-""}

# FACETSIFC_BLDRVERSION=${FACETSIFC_BLDRVERSION:-""}
# FACETSIFC_BUILDS=${FACETSIFC_BUILDS:-""}
# FACETSIFC_SER_OTHER_ARGS=${FACETSIFC_SER_OTHER_ARGS:-""}

# FCIOWRAPPERS_BLDRVERSION=${FCIOWRAPPERS_BLDRVERSION:-""}
# FCIOWRAPPERS_BUILDS=${FCIOWRAPPERS_BUILDS:-""}
# FCIOWRAPPERS_PAR_OTHER_ARGS=${FCIOWRAPPERS_PAR_OTHER_ARGS:-""}
# FCIOWRAPPERS_SER_OTHER_ARGS=${FCIOWRAPPERS_SER_OTHER_ARGS:-""}

# FCTESTS_BLDRVERSION=${FCTESTS_BLDRVERSION:-""}
# FCTESTS_BUILDS=${FCTESTS_BUILDS:-""}
# FCTESTS_ALL_OTHER_ARGS=${FCTESTS_ALL_OTHER_ARGS:-""}

# FFTW_BLDRVERSION=${FFTW_BLDRVERSION:-""}
# FFTW_BUILDS=${FFTW_BUILDS:-""}
# FFTW_BEN_OTHER_ARGS=${FFTW_BEN_OTHER_ARGS:-""}
# FFTW_PAR_OTHER_ARGS=${FFTW_PAR_OTHER_ARGS:-""}
# FFTW_SER_OTHER_ARGS=${FFTW_SER_OTHER_ARGS:-""}

# FFTW3_BLDRVERSION=${FFTW3_BLDRVERSION:-""}
# FFTW3_BUILDS=${FFTW3_BUILDS:-""}
# FFTW3_BEN_OTHER_ARGS=${FFTW3_BEN_OTHER_ARGS:-""}
# FFTW3_PAR_OTHER_ARGS=${FFTW3_PAR_OTHER_ARGS:-""}
# FFTW3_SER_OTHER_ARGS=${FFTW3_SER_OTHER_ARGS:-""}

# FGTESTS_BLDRVERSION=${FGTESTS_BLDRVERSION:-""}
# FGTESTS_BUILDS=${FGTESTS_BUILDS:-""}
# FGTESTS_ALL_OTHER_ARGS=${FGTESTS_ALL_OTHER_ARGS:-""}

# FLUXGRID_BLDRVERSION=${FLUXGRID_BLDRVERSION:-""}
# FLUXGRID_BUILDS=${FLUXGRID_BUILDS:-""}
# FLUXGRID_SER_OTHER_ARGS=${FLUXGRID_SER_OTHER_ARGS:-""}

# FMCFM_BLDRVERSION=${FMCFM_BLDRVERSION:-""}
# FMCFM_BUILDS=${FMCFM_BUILDS:-""}
# FMCFM_PAR_OTHER_ARGS=${FMCFM_PAR_OTHER_ARGS:-""}
# FMCFM_SER_OTHER_ARGS=${FMCFM_SER_OTHER_ARGS:-""}

# FMTESTS_BLDRVERSION=${FMTESTS_BLDRVERSION:-""}
# FMTESTS_BUILDS=${FMTESTS_BUILDS:-""}
# FMTESTS_ALL_OTHER_ARGS=${FMTESTS_ALL_OTHER_ARGS:-""}

# FORTHON_BLDRVERSION=${FORTHON_BLDRVERSION:-""}
# FORTHON_BUILDS=${FORTHON_BUILDS:-""}
# FORTHON_PYCSH_OTHER_ARGS=${FORTHON_PYCSH_OTHER_ARGS:-""}

# FREECAD_BLDRVERSION=${FREECAD_BLDRVERSION:-""}
# FREECAD_BUILDS=${FREECAD_BUILDS:-""}
# FREECAD_SER_OTHER_ARGS=${FREECAD_SER_OTHER_ARGS:-""}

# FREETYPE_BLDRVERSION=${FREETYPE_BLDRVERSION:-""}
# FREETYPE_BUILDS=${FREETYPE_BUILDS:-""}
# FREETYPE_PYCSH_OTHER_ARGS=${FREETYPE_PYCSH_OTHER_ARGS:-""}

# FTGL_BLDRVERSION=${FTGL_BLDRVERSION:-""}
# FTGL_BUILDS=${FTGL_BUILDS:-""}
# FTGL_SER_OTHER_ARGS=${FTGL_SER_OTHER_ARGS:-""}

# FUSION_MACHINE_BLDRVERSION=${FUSION_MACHINE_BLDRVERSION:-""}
# FUSION_MACHINE_BUILDS=${FUSION_MACHINE_BUILDS:-""}
# FUSION_MACHINE_PYCSH_OTHER_ARGS=${FUSION_MACHINE_PYCSH_OTHER_ARGS:-""}

# GA_TRANSPORT_BLDRVERSION=${GA_TRANSPORT_BLDRVERSION:-""}
# GA_TRANSPORT_BUILDS=${GA_TRANSPORT_BUILDS:-""}
# GA_TRANSPORT_PAR_OTHER_ARGS=${GA_TRANSPORT_PAR_OTHER_ARGS:-""}
# GA_TRANSPORT_SER_OTHER_ARGS=${GA_TRANSPORT_SER_OTHER_ARGS:-""}

# GACODE_BLDRVERSION=${GACODE_BLDRVERSION:-""}
# GACODE_BUILDS=${GACODE_BUILDS:-""}
# GACODE_PAR_OTHER_ARGS=${GACODE_PAR_OTHER_ARGS:-""}
# GACODE_SER_OTHER_ARGS=${GACODE_SER_OTHER_ARGS:-""}

# GELUS_BLDRVERSION=${GELUS_BLDRVERSION:-""}
# GELUS_BUILDS=${GELUS_BUILDS:-""}
# GELUS_SER_OTHER_ARGS=${GELUS_SER_OTHER_ARGS:-""}

# GENRAY_BLDRVERSION=${GENRAY_BLDRVERSION:-""}
# GENRAY_BUILDS=${GENRAY_BUILDS:-""}
# GENRAY_PAR_OTHER_ARGS=${GENRAY_PAR_OTHER_ARGS:-""}
# GENRAY_SER_OTHER_ARGS=${GENRAY_SER_OTHER_ARGS:-""}

# GKEYLL_BLDRVERSION=${GKEYLL_BLDRVERSION:-""}
# GKEYLL_BUILDS=${GKEYLL_BUILDS:-""}
# GKEYLL_PAR_OTHER_ARGS=${GKEYLL_PAR_OTHER_ARGS:-""}
# GKEYLL_SER_OTHER_ARGS=${GKEYLL_SER_OTHER_ARGS:-""}

# GOTOBLAS2_BLDRVERSION=${GOTOBLAS2_BLDRVERSION:-""}
# GOTOBLAS2_BUILDS=${GOTOBLAS2_BUILDS:-""}
# GOTOBLAS2_SER_OTHER_ARGS=${GOTOBLAS2_SER_OTHER_ARGS:-""}

# GPERF_BLDRVERSION=${GPERF_BLDRVERSION:-""}
# GPERF_BUILDS=${GPERF_BUILDS:-""}
# GPERF_SER_OTHER_ARGS=${GPERF_SER_OTHER_ARGS:-""}
# GPERF_SERSH_OTHER_ARGS=${GPERF_SERSH_OTHER_ARGS:-""}

# GPULIB_BLDRVERSION=${GPULIB_BLDRVERSION:-""}
# GPULIB_BUILDS=${GPULIB_BUILDS:-""}
# GPULIB_GPU_OTHER_ARGS=${GPULIB_GPU_OTHER_ARGS:-""}

# GSL_BLDRVERSION=${GSL_BLDRVERSION:-""}
# GSL_BUILDS=${GSL_BUILDS:-""}
# GSL_SER_OTHER_ARGS=${GSL_SER_OTHER_ARGS:-""}

# GTEST_BLDRVERSION=${GTEST_BLDRVERSION:-""}
# GTEST_BUILDS=${GTEST_BUILDS:-""}
# GTEST_SER_OTHER_ARGS=${GTEST_SER_OTHER_ARGS:-""}

# HDF5_BLDRVERSION=${HDF5_BLDRVERSION:-""}
# HDF5_BUILDS=${HDF5_BUILDS:-""}
HDF5_PYCSH_OTHER_ARGS=${HDF5_PYCSH_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_PAR_OTHER_ARGS=${HDF5_PAR_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_PARSH_OTHER_ARGS=${HDF5_PARSH_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_SER_OTHER_ARGS=${HDF5_SER_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_SERSH_OTHER_ARGS=${HDF5_SERSH_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}

# HTTPLIB2_BLDRVERSION=${HTTPLIB2_BLDRVERSION:-""}
# HTTPLIB2_BUILDS=${HTTPLIB2_BUILDS:-""}
# HTTPLIB2_PYCSH_OTHER_ARGS=${HTTPLIB2_PYCSH_OTHER_ARGS:-""}

# HWLOC_BLDRVERSION=${HWLOC_BLDRVERSION:-""}
# HWLOC_BUILDS=${HWLOC_BUILDS:-""}
# HWLOC_SER_OTHER_ARGS=${HWLOC_SER_OTHER_ARGS:-""}

# HYPRE_BLDRVERSION=${HYPRE_BLDRVERSION:-""}
# HYPRE_BUILDS=${HYPRE_BUILDS:-""}
# HYPRE_PAR_OTHER_ARGS=${HYPRE_PAR_OTHER_ARGS:-""}
# HYPRE_PARSH_OTHER_ARGS=${HYPRE_PARSH_OTHER_ARGS:-""}

# IMAGING_BLDRVERSION=${IMAGING_BLDRVERSION:-""}
# IMAGING_BUILDS=${IMAGING_BUILDS:-""}
# IMAGING_PYCSH_OTHER_ARGS=${IMAGING_PYCSH_OTHER_ARGS:-""}

# IPS_BLDRVERSION=${IPS_BLDRVERSION:-""}
# IPS_BUILDS=${IPS_BUILDS:-""}
# IPS_PYCSH_OTHER_ARGS=${IPS_PYCSH_OTHER_ARGS:-""}

# IPYTHON_BLDRVERSION=${IPYTHON_BLDRVERSION:-""}
# IPYTHON_BUILDS=${IPYTHON_BUILDS:-""}
# IPYTHON_PYCSH_OTHER_ARGS=${IPYTHON_PYCSH_OTHER_ARGS:-""}

# JSMATH_BLDRVERSION=${JSMATH_BLDRVERSION:-""}
# JSMATH_BUILDS=${JSMATH_BUILDS:-""}
# JSMATH_PYCSH_OTHER_ARGS=${JSMATH_PYCSH_OTHER_ARGS:-""}

# LAPACK_BLDRVERSION=${LAPACK_BLDRVERSION:-""}
# LAPACK_BUILDS=${LAPACK_BUILDS:-""}
# LAPACK_BEN_OTHER_ARGS=${LAPACK_BEN_OTHER_ARGS:-""}
# LAPACK_PYCSH_OTHER_ARGS=${LAPACK_PYCSH_OTHER_ARGS:-""}
# LAPACK_SER_OTHER_ARGS=${LAPACK_SER_OTHER_ARGS:-""}
# LAPACK_SERSH_OTHER_ARGS=${LAPACK_SERSH_OTHER_ARGS:-""}

# LIBPNG_BLDRVERSION=${LIBPNG_BLDRVERSION:-""}
# LIBPNG_BUILDS=${LIBPNG_BUILDS:-""}
# LIBPNG_PYCSH_OTHER_ARGS=${LIBPNG_PYCSH_OTHER_ARGS:-""}

# LIBTOOL_BLDRVERSION=${LIBTOOL_BLDRVERSION:-""}
# LIBTOOL_BUILDS=${LIBTOOL_BUILDS:-""}
# LIBTOOL_SER_OTHER_ARGS=${LIBTOOL_SER_OTHER_ARGS:-""}

# LIBXML2_BLDRVERSION=${LIBXML2_BLDRVERSION:-""}
# LIBXML2_BUILDS=${LIBXML2_BUILDS:-""}
# LIBXML2_SER_OTHER_ARGS=${LIBXML2_SER_OTHER_ARGS:-""}

# LP_SOLVE_BLDRVERSION=${LP_SOLVE_BLDRVERSION:-""}
# LP_SOLVE_BUILDS=${LP_SOLVE_BUILDS:-""}
# LP_SOLVE_SER_OTHER_ARGS=${LP_SOLVE_SER_OTHER_ARGS:-""}

# LUA_BLDRVERSION=${LUA_BLDRVERSION:-""}
# LUA_BUILDS=${LUA_BUILDS:-""}
# LUA_SER_OTHER_ARGS=${LUA_SER_OTHER_ARGS:-""}

# LUABIND_BLDRVERSION=${LUABIND_BLDRVERSION:-""}
# LUABIND_BUILDS=${LUABIND_BUILDS:-""}
# LUABIND_SER_OTHER_ARGS=${LUABIND_SER_OTHER_ARGS:-""}

# M4_BLDRVERSION=${M4_BLDRVERSION:-""}
# M4_BUILDS=${M4_BUILDS:-""}
# M4_SER_OTHER_ARGS=${M4_SER_OTHER_ARGS:-""}

# MAGMA_BLDRVERSION=${MAGMA_BLDRVERSION:-""}
# MAGMA_BUILDS=${MAGMA_BUILDS:-""}
# MAGMA_GPU_OTHER_ARGS=${MAGMA_GPU_OTHER_ARGS:-""}

# MAKO_BLDRVERSION=${MAKO_BLDRVERSION:-""}
# MAKO_BUILDS=${MAKO_BUILDS:-""}
# MAKO_PYCSH_OTHER_ARGS=${MAKO_PYCSH_OTHER_ARGS:-""}

# MATHJAX_BLDRVERSION=${MATHJAX_BLDRVERSION:-""}
# MATHJAX_BUILDS=${MATHJAX_BUILDS:-""}
# MATHJAX_FULL_OTHER_ARGS=${MATHJAX_FULL_OTHER_ARGS:-""}
# MATHJAX_LITE_OTHER_ARGS=${MATHJAX_LITE_OTHER_ARGS:-""}

# MATPLOTLIB_BLDRVERSION=${MATPLOTLIB_BLDRVERSION:-""}
# MATPLOTLIB_BUILDS=${MATPLOTLIB_BUILDS:-""}
# MATPLOTLIB_PYCSH_OTHER_ARGS=${MATPLOTLIB_PYCSH_OTHER_ARGS:-""}

# MERCURIAL_BLDRVERSION=${MERCURIAL_BLDRVERSION:-""}
# MERCURIAL_BUILDS=${MERCURIAL_BUILDS:-""}
# MERCURIAL_PYCSH_OTHER_ARGS=${MERCURIAL_PYCSH_OTHER_ARGS:-""}

# MESA_BLDRVERSION=${MESA_BLDRVERSION:-""}
MESA_BUILDS=${MESA_BUILDS:-"NONE"}
# MESA_MGL_OTHER_ARGS=${MESA_MGL_OTHER_ARGS:-""}
# MESA_OS_OTHER_ARGS=${MESA_OS_OTHER_ARGS:-""}

# METATAU_BLDRVERSION=${METATAU_BLDRVERSION:-""}
METATAU_BUILDS=${METATAU_BUILDS:-"NONE"}
# METATAU_PAR_OTHER_ARGS=${METATAU_PAR_OTHER_ARGS:-""}

# METIS_BLDRVERSION=${METIS_BLDRVERSION:-""}
# METIS_BUILDS=${METIS_BUILDS:-""}
# METIS_SER_OTHER_ARGS=${METIS_SER_OTHER_ARGS:-""}
# METIS_SERSH_OTHER_ARGS=${METIS_SERSH_OTHER_ARGS:-""}

# MPE2_BLDRVERSION=${MPE2_BLDRVERSION:-""}
# MPE2_BUILDS=${MPE2_BUILDS:-""}
# MPE2_NODL_OTHER_ARGS=${MPE2_NODL_OTHER_ARGS:-""}

# MPI4PY_BLDRVERSION=${MPI4PY_BLDRVERSION:-""}
# MPI4PY_BUILDS=${MPI4PY_BUILDS:-""}
# MPI4PY_PYCSH_OTHER_ARGS=${MPI4PY_PYCSH_OTHER_ARGS:-""}

# MPICH2_BLDRVERSION=${MPICH2_BLDRVERSION:-""}
# MPICH2_BUILDS=${MPICH2_BUILDS:-""}
# MPICH2_STATIC_OTHER_ARGS=${MPICH2_STATIC_OTHER_ARGS:-""}

# MUPARSER_BLDRVERSION=${MUPARSER_BLDRVERSION:-""}
# MUPARSER_BUILDS=${MUPARSER_BUILDS:-""}
# MUPARSER_SER_OTHER_ARGS=${MUPARSER_SER_OTHER_ARGS:-""}
# MUPARSER_SERSH_OTHER_ARGS=${MUPARSER_SERSH_OTHER_ARGS:-""}

# MXML_BLDRVERSION=${MXML_BLDRVERSION:-""}
# MXML_BUILDS=${MXML_BUILDS:-""}
# MXML_SER_OTHER_ARGS=${MXML_SER_OTHER_ARGS:-""}

# NCURSES_BLDRVERSION=${NCURSES_BLDRVERSION:-""}
# NCURSES_BUILDS=${NCURSES_BUILDS:-""}
# NCURSES_SER_OTHER_ARGS=${NCURSES_SER_OTHER_ARGS:-""}

# NE7SSH_BLDRVERSION=${NE7SSH_BLDRVERSION:-""}
# NE7SSH_BUILDS=${NE7SSH_BUILDS:-""}
# NE7SSH_PYCSH_OTHER_ARGS=${NE7SSH_PYCSH_OTHER_ARGS:-""}
# NE7SSH_SERSH_OTHER_ARGS=${NE7SSH_SERSH_OTHER_ARGS:-""}

# NETCDF_BLDRVERSION=${NETCDF_BLDRVERSION:-""}
# NETCDF_BUILDS=${NETCDF_BUILDS:-""}
# NETCDF_BEN_OTHER_ARGS=${NETCDF_BEN_OTHER_ARGS:-""}
# NETCDF_PYCSH_OTHER_ARGS=${NETCDF_PYCSH_OTHER_ARGS:-""}
# NETCDF_PAR_OTHER_ARGS=${NETCDF_PAR_OTHER_ARGS:-""}
# NETCDF_SER_OTHER_ARGS=${NETCDF_SER_OTHER_ARGS:-""}

# NETLIB_LITE_BLDRVERSION=${NETLIB_LITE_BLDRVERSION:-""}
# NETLIB_LITE_BUILDS=${NETLIB_LITE_BUILDS:-""}
# NETLIB_LITE_BEN_OTHER_ARGS=${NETLIB_LITE_BEN_OTHER_ARGS:-""}
# NETLIB_LITE_SER_OTHER_ARGS=${NETLIB_LITE_SER_OTHER_ARGS:-""}

# NIMDEVEL_BLDRVERSION=${NIMDEVEL_BLDRVERSION:-""}
NIMDEVEL_BUILDS=${NIMDEVEL_BUILDS:-"NONE"}
# NIMDEVEL_PAR_OTHER_ARGS=${NIMDEVEL_PAR_OTHER_ARGS:-""}
# NIMDEVEL_PARDBG_OTHER_ARGS=${NIMDEVEL_PARDBG_OTHER_ARGS:-""}
# NIMDEVEL_PARSURF_OTHER_ARGS=${NIMDEVEL_PARSURF_OTHER_ARGS:-""}
# NIMDEVEL_PARTAU_OTHER_ARGS=${NIMDEVEL_PARTAU_OTHER_ARGS:-""}
# NIMDEVEL_SER_OTHER_ARGS=${NIMDEVEL_SER_OTHER_ARGS:-""}
# NIMDEVEL_SERDBG_OTHER_ARGS=${NIMDEVEL_SERDBG_OTHER_ARGS:-""}
# NIMDEVEL_SERSURF_OTHER_ARGS=${NIMDEVEL_SERSURF_OTHER_ARGS:-""}

# NIMTESTS_BLDRVERSION=${NIMTESTS_BLDRVERSION:-""}
# NIMTESTS_BUILDS=${NIMTESTS_BUILDS:-""}
# NIMTESTS_ALL_OTHER_ARGS=${NIMTESTS_ALL_OTHER_ARGS:-""}

# NTCC_TRANSPORT_BLDRVERSION=${NTCC_TRANSPORT_BLDRVERSION:-""}
NTCC_TRANSPORT_BUILDS=${NTCC_TRANSPORT_BUILDS:-"NONE"}
# NTCC_TRANSPORT_PAR_OTHER_ARGS=${NTCC_TRANSPORT_PAR_OTHER_ARGS:-""}
# NTCC_TRANSPORT_SER_OTHER_ARGS=${NTCC_TRANSPORT_SER_OTHER_ARGS:-""}

# NUBEAM_BLDRVERSION=${NUBEAM_BLDRVERSION:-""}
NUBEAM_BUILDS=${NUBEAM_BUILDS:-"NONE"}
# NUBEAM_PAR_OTHER_ARGS=${NUBEAM_PAR_OTHER_ARGS:-""}
# NUBEAM_SER_OTHER_ARGS=${NUBEAM_SER_OTHER_ARGS:-""}

# NUMEXPR_BLDRVERSION=${NUMEXPR_BLDRVERSION:-""}
# NUMEXPR_BUILDS=${NUMEXPR_BUILDS:-""}
# NUMEXPR_PYCSH_OTHER_ARGS=${NUMEXPR_PYCSH_OTHER_ARGS:-""}

# NUMPY_BLDRVERSION=${NUMPY_BLDRVERSION:-""}
# NUMPY_BUILDS=${NUMPY_BUILDS:-""}
# NUMPY_PYCSH_OTHER_ARGS=${NUMPY_PYCSH_OTHER_ARGS:-""}

# OCE_BLDRVERSION=${OCE_BLDRVERSION:-""}
# OCE_BUILDS=${OCE_BUILDS:-""}
# OCE_SER_OTHER_ARGS=${OCE_SER_OTHER_ARGS:-""}

# OPENMPI_BLDRVERSION=${OPENMPI_BLDRVERSION:-""}
OPENMPI_BUILDS=${OPENMPI_BUILDS:-"NONE"}
# OPENMPI_NODL_OTHER_ARGS=${OPENMPI_NODL_OTHER_ARGS:-""}
# OPENMPI_STATIC_OTHER_ARGS=${OPENMPI_STATIC_OTHER_ARGS:-""}

# OPENSPLICE_BLDRVERSION=${OPENSPLICE_BLDRVERSION:-""}
# OPENSPLICE_BUILDS=${OPENSPLICE_BUILDS:-""}
# OPENSPLICE_SER_OTHER_ARGS=${OPENSPLICE_SER_OTHER_ARGS:-""}

# PANDAS_BLDRVERSION=${PANDAS_BLDRVERSION:-""}
# PANDAS_BUILDS=${PANDAS_BUILDS:-""}
# PANDAS_PYCSH_OTHER_ARGS=${PANDAS_PYCSH_OTHER_ARGS:-""}

# PARAMIKO_BLDRVERSION=${PARAMIKO_BLDRVERSION:-""}
# PARAMIKO_BUILDS=${PARAMIKO_BUILDS:-""}
# PARAMIKO_PYCSH_OTHER_ARGS=${PARAMIKO_PYCSH_OTHER_ARGS:-""}

# PARMETIS_BLDRVERSION=${PARMETIS_BLDRVERSION:-""}
# PARMETIS_BUILDS=${PARMETIS_BUILDS:-""}
# PARMETIS_PAR_OTHER_ARGS=${PARMETIS_PAR_OTHER_ARGS:-""}
# PARMETIS_PARSH_OTHER_ARGS=${PARMETIS_PARSH_OTHER_ARGS:-""}

# PCRE_BLDRVERSION=${PCRE_BLDRVERSION:-""}
PCRE_BUILDS=${PCRE_BUILDS:-"NONE"}
# PCRE_SER_OTHER_ARGS=${PCRE_SER_OTHER_ARGS:-""}

# PETSC_BLDRVERSION=${PETSC_BLDRVERSION:-""}
PETSC_BUILDS=${PETSC_BUILDS:-"NONE"}
# PETSC_PAR_OTHER_ARGS=${PETSC_PAR_OTHER_ARGS:-""}
# PETSC_PARCPLX_OTHER_ARGS=${PETSC_PARCPLX_OTHER_ARGS:-""}
# PETSC_PARCPLXDBG_OTHER_ARGS=${PETSC_PARCPLXDBG_OTHER_ARGS:-""}
# PETSC_PARDBG_OTHER_ARGS=${PETSC_PARDBG_OTHER_ARGS:-""}
# PETSC_SER_OTHER_ARGS=${PETSC_SER_OTHER_ARGS:-""}
# PETSC_SERCPLX_OTHER_ARGS=${PETSC_SERCPLX_OTHER_ARGS:-""}

# PETSC33_BLDRVERSION=${PETSC33_BLDRVERSION:-""}
# PETSC33_BUILDS=${PETSC33_BUILDS:-""}
# PETSC33_PAR_OTHER_ARGS=${PETSC33_PAR_OTHER_ARGS:-""}
# PETSC33_PARCPLX_OTHER_ARGS=${PETSC33_PARCPLX_OTHER_ARGS:-""}
# PETSC33_SER_OTHER_ARGS=${PETSC33_SER_OTHER_ARGS:-""}
# PETSC33_SERCPLX_OTHER_ARGS=${PETSC33_SERCPLX_OTHER_ARGS:-""}

# PETSC4PY_BLDRVERSION=${PETSC4PY_BLDRVERSION:-""}
# PETSC4PY_BUILDS=${PETSC4PY_BUILDS:-""}
# PETSC4PY_PYCSH_OTHER_ARGS=${PETSC4PY_PYCSH_OTHER_ARGS:-""}

# PETSCREPO_BLDRVERSION=${PETSCREPO_BLDRVERSION:-""}
# PETSCREPO_BUILDS=${PETSCREPO_BUILDS:-""}
# PETSCREPO_PAR_OTHER_ARGS=${PETSCREPO_PAR_OTHER_ARGS:-""}
# PETSCREPO_PARCPLX_OTHER_ARGS=${PETSCREPO_PARCPLX_OTHER_ARGS:-""}
# PETSCREPO_SER_OTHER_ARGS=${PETSCREPO_SER_OTHER_ARGS:-""}
# PETSCREPO_SERCPLX_OTHER_ARGS=${PETSCREPO_SERCPLX_OTHER_ARGS:-""}

# PLASMA_STATE_BLDRVERSION=${PLASMA_STATE_BLDRVERSION:-""}
PLASMA_STATE_BUILDS=${PLASMA_STATE_BUILDS:-"NONE"}
# PLASMA_STATE_BEN_OTHER_ARGS=${PLASMA_STATE_BEN_OTHER_ARGS:-""}
# PLASMA_STATE_SER_OTHER_ARGS=${PLASMA_STATE_SER_OTHER_ARGS:-""}

# PSPLINE_BLDRVERSION=${PSPLINE_BLDRVERSION:-""}
# PSPLINE_BUILDS=${PSPLINE_BUILDS:-""}
# PSPLINE_PAR_OTHER_ARGS=${PSPLINE_PAR_OTHER_ARGS:-""}
# PSPLINE_SER_OTHER_ARGS=${PSPLINE_SER_OTHER_ARGS:-""}

# PTK_BLDRVERSION=${PTK_BLDRVERSION:-""}
# PTK_BUILDS=${PTK_BUILDS:-""}
# PTK_SER_OTHER_ARGS=${PTK_SER_OTHER_ARGS:-""}

# PYDAP_BLDRVERSION=${PYDAP_BLDRVERSION:-""}
# PYDAP_BUILDS=${PYDAP_BUILDS:-""}
# PYDAP_PYCSH_OTHER_ARGS=${PYDAP_PYCSH_OTHER_ARGS:-""}

# PYDDS_BLDRVERSION=${PYDDS_BLDRVERSION:-""}
# PYDDS_BUILDS=${PYDDS_BUILDS:-""}
# PYDDS_SER_OTHER_ARGS=${PYDDS_SER_OTHER_ARGS:-""}

# PYGMENTS_BLDRVERSION=${PYGMENTS_BLDRVERSION:-""}
# PYGMENTS_BUILDS=${PYGMENTS_BUILDS:-""}
# PYGMENTS_PYCSH_OTHER_ARGS=${PYGMENTS_PYCSH_OTHER_ARGS:-""}

# PYNETCDF4_BLDRVERSION=${PYNETCDF4_BLDRVERSION:-""}
# PYNETCDF4_BUILDS=${PYNETCDF4_BUILDS:-""}
# PYNETCDF4_PYCSH_OTHER_ARGS=${PYNETCDF4_PYCSH_OTHER_ARGS:-""}

# PYPARSING_BLDRVERSION=${PYPARSING_BLDRVERSION:-""}
# PYPARSING_BUILDS=${PYPARSING_BUILDS:-""}
# PYPARSING_PYCSH_OTHER_ARGS=${PYPARSING_PYCSH_OTHER_ARGS:-""}

# PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-""}
# PYQT_BUILDS=${PYQT_BUILDS:-""}
# PYQT_PYCSH_OTHER_ARGS=${PYQT_PYCSH_OTHER_ARGS:-""}

# PYREADLINE_BLDRVERSION=${PYREADLINE_BLDRVERSION:-""}
# PYREADLINE_BUILDS=${PYREADLINE_BUILDS:-""}
# PYREADLINE_PYCSH_OTHER_ARGS=${PYREADLINE_PYCSH_OTHER_ARGS:-""}

# PYSYNTHDIAG_BLDRVERSION=${PYSYNTHDIAG_BLDRVERSION:-""}
# PYSYNTHDIAG_BUILDS=${PYSYNTHDIAG_BUILDS:-""}
# PYSYNTHDIAG_PYCSH_OTHER_ARGS=${PYSYNTHDIAG_PYCSH_OTHER_ARGS:-""}

# PYTHON_BLDRVERSION=${PYTHON_BLDRVERSION:-""}
# PYTHON_BUILDS=${PYTHON_BUILDS:-""}
# PYTHON_PYCSH_OTHER_ARGS=${PYTHON_PYCSH_OTHER_ARGS:-""}

# PYTHONOCC_BLDRVERSION=${PYTHONOCC_BLDRVERSION:-""}
# PYTHONOCC_BUILDS=${PYTHONOCC_BUILDS:-""}
# PYTHONOCC_PYCSH_OTHER_ARGS=${PYTHONOCC_PYCSH_OTHER_ARGS:-""}

# PYZMQ_BLDRVERSION=${PYZMQ_BLDRVERSION:-""}
# PYZMQ_BUILDS=${PYZMQ_BUILDS:-""}
# PYZMQ_PYCSH_OTHER_ARGS=${PYZMQ_PYCSH_OTHER_ARGS:-""}

# QD_BLDRVERSION=${QD_BLDRVERSION:-""}
# QD_BUILDS=${QD_BUILDS:-""}
# QD_SER_OTHER_ARGS=${QD_SER_OTHER_ARGS:-""}

# QDSTESTS_BLDRVERSION=${QDSTESTS_BLDRVERSION:-""}
# QDSTESTS_BUILDS=${QDSTESTS_BUILDS:-""}
# QDSTESTS_SER_OTHER_ARGS=${QDSTESTS_SER_OTHER_ARGS:-""}

# QHULL_BLDRVERSION=${QHULL_BLDRVERSION:-""}
# QHULL_BUILDS=${QHULL_BUILDS:-""}
# QHULL_SER_OTHER_ARGS=${QHULL_SER_OTHER_ARGS:-""}

# QSCINTILLA_BLDRVERSION=${QSCINTILLA_BLDRVERSION:-""}
# QSCINTILLA_BUILDS=${QSCINTILLA_BUILDS:-""}
# QSCINTILLA_SER_OTHER_ARGS=${QSCINTILLA_SER_OTHER_ARGS:-""}

# QT_BLDRVERSION=${QT_BLDRVERSION:-""}
QT_BUILDS=${QT_BUILDS:-"NONE"}
# QT_SER_OTHER_ARGS=${QT_SER_OTHER_ARGS:-""}

# QT3D_BLDRVERSION=${QT3D_BLDRVERSION:-""}
# QT3D_BUILDS=${QT3D_BUILDS:-""}
# QT3D_SER_OTHER_ARGS=${QT3D_SER_OTHER_ARGS:-""}

# QUIDS_BLDRVERSION=${QUIDS_BLDRVERSION:-""}
# QUIDS_BUILDS=${QUIDS_BUILDS:-""}
# QUIDS_SER_OTHER_ARGS=${QUIDS_SER_OTHER_ARGS:-""}

# R_BLDRVERSION=${R_BLDRVERSION:-""}
# R_BUILDS=${R_BUILDS:-""}
# R_SER_OTHER_ARGS=${R_SER_OTHER_ARGS:-""}

# READLINE_BLDRVERSION=${READLINE_BLDRVERSION:-""}
# READLINE_BUILDS=${READLINE_BUILDS:-""}
# READLINE_SER_OTHER_ARGS=${READLINE_SER_OTHER_ARGS:-""}

# RPY2_BLDRVERSION=${RPY2_BLDRVERSION:-""}
# RPY2_BUILDS=${RPY2_BUILDS:-""}
# RPY2_PYCSH_OTHER_ARGS=${RPY2_PYCSH_OTHER_ARGS:-""}

# RST2PDF_BLDRVERSION=${RST2PDF_BLDRVERSION:-""}
# RST2PDF_BUILDS=${RST2PDF_BUILDS:-""}
# RST2PDF_PYCSH_OTHER_ARGS=${RST2PDF_PYCSH_OTHER_ARGS:-""}

# SCIPY_BLDRVERSION=${SCIPY_BLDRVERSION:-""}
SCIPY_BUILDS=${SCIPY_BUILDS:-"NONE"}
# SCIPY_PYCSH_OTHER_ARGS=${SCIPY_PYCSH_OTHER_ARGS:-""}

# SCITOOLS_BLDRVERSION=${SCITOOLS_BLDRVERSION:-""}
# SCITOOLS_BUILDS=${SCITOOLS_BUILDS:-""}
# SCITOOLS_PYCSH_OTHER_ARGS=${SCITOOLS_PYCSH_OTHER_ARGS:-""}

# SETUPTOOLS_BLDRVERSION=${SETUPTOOLS_BLDRVERSION:-""}
# SETUPTOOLS_BUILDS=${SETUPTOOLS_BUILDS:-""}
# SETUPTOOLS_PYCSH_OTHER_ARGS=${SETUPTOOLS_PYCSH_OTHER_ARGS:-""}

# SHIBOKEN_BLDRVERSION=${SHIBOKEN_BLDRVERSION:-""}
# SHIBOKEN_BUILDS=${SHIBOKEN_BUILDS:-""}
# SHIBOKEN_SER_OTHER_ARGS=${SHIBOKEN_SER_OTHER_ARGS:-""}

# SHTOOL_BLDRVERSION=${SHTOOL_BLDRVERSION:-""}
# SHTOOL_BUILDS=${SHTOOL_BUILDS:-""}
# SHTOOL_SER_OTHER_ARGS=${SHTOOL_SER_OTHER_ARGS:-""}

# SIMD_BLDRVERSION=${SIMD_BLDRVERSION:-""}
# SIMD_BUILDS=${SIMD_BUILDS:-""}
# SIMD_SER_OTHER_ARGS=${SIMD_SER_OTHER_ARGS:-""}

# SIMPLEJSON_BLDRVERSION=${SIMPLEJSON_BLDRVERSION:-""}
# SIMPLEJSON_BUILDS=${SIMPLEJSON_BUILDS:-""}
# SIMPLEJSON_PYCSH_OTHER_ARGS=${SIMPLEJSON_PYCSH_OTHER_ARGS:-""}

# SIMYAN_BLDRVERSION=${SIMYAN_BLDRVERSION:-""}
# SIMYAN_BUILDS=${SIMYAN_BUILDS:-""}
# SIMYAN_PYCSH_OTHER_ARGS=${SIMYAN_PYCSH_OTHER_ARGS:-""}

# SIP_BLDRVERSION=${SIP_BLDRVERSION:-""}
# SIP_BUILDS=${SIP_BUILDS:-""}
# SIP_PYCSH_OTHER_ARGS=${SIP_PYCSH_OTHER_ARGS:-""}

# SLEPC_BLDRVERSION=${SLEPC_BLDRVERSION:-""}
# SLEPC_BUILDS=${SLEPC_BUILDS:-""}
# SLEPC_PAR_OTHER_ARGS=${SLEPC_PAR_OTHER_ARGS:-""}
# SLEPC_PARCPLX_OTHER_ARGS=${SLEPC_PARCPLX_OTHER_ARGS:-""}
# SLEPC_PARCPLXDBG_OTHER_ARGS=${SLEPC_PARCPLXDBG_OTHER_ARGS:-""}
# SLEPC_PARDBG_OTHER_ARGS=${SLEPC_PARDBG_OTHER_ARGS:-""}
# SLEPC_SER_OTHER_ARGS=${SLEPC_SER_OTHER_ARGS:-""}
# SLEPC_SERCPLX_OTHER_ARGS=${SLEPC_SERCPLX_OTHER_ARGS:-""}

# SOQT_BLDRVERSION=${SOQT_BLDRVERSION:-""}
# SOQT_BUILDS=${SOQT_BUILDS:-""}
# SOQT_PYCSH_OTHER_ARGS=${SOQT_PYCSH_OTHER_ARGS:-""}

# SPARSKIT_BLDRVERSION=${SPARSKIT_BLDRVERSION:-""}
# SPARSKIT_BUILDS=${SPARSKIT_BUILDS:-""}
# SPARSKIT_SER_OTHER_ARGS=${SPARSKIT_SER_OTHER_ARGS:-""}

# SPHINX_BLDRVERSION=${SPHINX_BLDRVERSION:-""}
# SPHINX_BUILDS=${SPHINX_BUILDS:-""}
# SPHINX_PYCSH_OTHER_ARGS=${SPHINX_PYCSH_OTHER_ARGS:-""}

# SPHINX_NUMFIG_BLDRVERSION=${SPHINX_NUMFIG_BLDRVERSION:-""}
# SPHINX_NUMFIG_BUILDS=${SPHINX_NUMFIG_BUILDS:-""}
# SPHINX_NUMFIG_PYCSH_OTHER_ARGS=${SPHINX_NUMFIG_PYCSH_OTHER_ARGS:-""}

# SQLITE_BLDRVERSION=${SQLITE_BLDRVERSION:-""}
# SQLITE_BUILDS=${SQLITE_BUILDS:-""}
# SQLITE_SER_OTHER_ARGS=${SQLITE_SER_OTHER_ARGS:-""}

# SQUISH_BLDRVERSION=${SQUISH_BLDRVERSION:-""}
# SQUISH_BUILDS=${SQUISH_BUILDS:-""}
# SQUISH_SER_OTHER_ARGS=${SQUISH_SER_OTHER_ARGS:-""}

# SUBVERSION_BLDRVERSION=${SUBVERSION_BLDRVERSION:-""}
# SUBVERSION_BUILDS=${SUBVERSION_BUILDS:-""}
# SUBVERSION_SER_OTHER_ARGS=${SUBVERSION_SER_OTHER_ARGS:-""}

# SUNDIALS_BLDRVERSION=${SUNDIALS_BLDRVERSION:-""}
# SUNDIALS_BUILDS=${SUNDIALS_BUILDS:-""}
# SUNDIALS_BEN_OTHER_ARGS=${SUNDIALS_BEN_OTHER_ARGS:-""}
# SUNDIALS_PAR_OTHER_ARGS=${SUNDIALS_PAR_OTHER_ARGS:-""}
# SUNDIALS_SER_OTHER_ARGS=${SUNDIALS_SER_OTHER_ARGS:-""}

# SUPERLU_BLDRVERSION=${SUPERLU_BLDRVERSION:-""}
# SUPERLU_BUILDS=${SUPERLU_BUILDS:-""}
# SUPERLU_SER_OTHER_ARGS=${SUPERLU_SER_OTHER_ARGS:-""}
# SUPERLU_SERSH_OTHER_ARGS=${SUPERLU_SERSH_OTHER_ARGS:-""}

# SUPERLU_DIST_BLDRVERSION=${SUPERLU_DIST_BLDRVERSION:-""}
# SUPERLU_DIST_BUILDS=${SUPERLU_DIST_BUILDS:-""}
# SUPERLU_DIST_PAR_OTHER_ARGS=${SUPERLU_DIST_PAR_OTHER_ARGS:-""}
# SUPERLU_DIST_PARCOMM_OTHER_ARGS=${SUPERLU_DIST_PARCOMM_OTHER_ARGS:-""}
# SUPERLU_DIST_PARCOMMSH_OTHER_ARGS=${SUPERLU_DIST_PARCOMMSH_OTHER_ARGS:-""}
# SUPERLU_DIST_PARSH_OTHER_ARGS=${SUPERLU_DIST_PARSH_OTHER_ARGS:-""}

# SWIG_BLDRVERSION=${SWIG_BLDRVERSION:-""}
SWIG_BUILDS=${SWIG_BUILDS:-"NONE"}
# SWIG_SER_OTHER_ARGS=${SWIG_SER_OTHER_ARGS:-""}

# SWIMGUI_BLDRVERSION=${SWIMGUI_BLDRVERSION:-""}
# SWIMGUI_BUILDS=${SWIMGUI_BUILDS:-""}
# SWIMGUI_SER_OTHER_ARGS=${SWIMGUI_SER_OTHER_ARGS:-""}

# SYNERGIA2_BLDRVERSION=${SYNERGIA2_BLDRVERSION:-""}
# SYNERGIA2_BUILDS=${SYNERGIA2_BUILDS:-""}
# SYNERGIA2_SER_OTHER_ARGS=${SYNERGIA2_SER_OTHER_ARGS:-""}

# TABLES_BLDRVERSION=${TABLES_BLDRVERSION:-""}
# TABLES_BUILDS=${TABLES_BUILDS:-""}
# TABLES_PYCSH_OTHER_ARGS=${TABLES_PYCSH_OTHER_ARGS:-""}

# TEASPINK_BLDRVERSION=${TEASPINK_BLDRVERSION:-""}
# TEASPINK_BUILDS=${TEASPINK_BUILDS:-""}
# TEASPINK_SER_OTHER_ARGS=${TEASPINK_SER_OTHER_ARGS:-""}

# THRUST_BLDRVERSION=${THRUST_BLDRVERSION:-""}
# THRUST_BUILDS=${THRUST_BUILDS:-""}
# THRUST_SER_OTHER_ARGS=${THRUST_SER_OTHER_ARGS:-""}

# TINKERER_BLDRVERSION=${TINKERER_BLDRVERSION:-""}
# TINKERER_BUILDS=${TINKERER_BUILDS:-""}
# TINKERER_PYCSH_OTHER_ARGS=${TINKERER_PYCSH_OTHER_ARGS:-""}

# TORIC_BLDRVERSION=${TORIC_BLDRVERSION:-""}
# TORIC_BUILDS=${TORIC_BUILDS:-""}
# TORIC_PAR_OTHER_ARGS=${TORIC_PAR_OTHER_ARGS:-""}
# TORIC_SER_OTHER_ARGS=${TORIC_SER_OTHER_ARGS:-""}

# TORNADO_BLDRVERSION=${TORNADO_BLDRVERSION:-""}
# TORNADO_BUILDS=${TORNADO_BUILDS:-""}
# TORNADO_PYCSH_OTHER_ARGS=${TORNADO_PYCSH_OTHER_ARGS:-""}

# TRILINOS_BLDRVERSION=${TRILINOS_BLDRVERSION:-""}
# TRILINOS_BUILDS=${TRILINOS_BUILDS:-""}
# TRILINOS_PARBARE_OTHER_ARGS=${TRILINOS_PARBARE_OTHER_ARGS:-""}
# TRILINOS_PARBARESH_OTHER_ARGS=${TRILINOS_PARBARESH_OTHER_ARGS:-""}
# TRILINOS_PARCOMM_OTHER_ARGS=${TRILINOS_PARCOMM_OTHER_ARGS:-""}
# TRILINOS_PARCOMMSH_OTHER_ARGS=${TRILINOS_PARCOMMSH_OTHER_ARGS:-""}
# TRILINOS_PARFULL_OTHER_ARGS=${TRILINOS_PARFULL_OTHER_ARGS:-""}
# TRILINOS_PARFULLSH_OTHER_ARGS=${TRILINOS_PARFULLSH_OTHER_ARGS:-""}
# TRILINOS_SERBARE_OTHER_ARGS=${TRILINOS_SERBARE_OTHER_ARGS:-""}
# TRILINOS_SERBARESH_OTHER_ARGS=${TRILINOS_SERBARESH_OTHER_ARGS:-""}
# TRILINOS_SERCOMM_OTHER_ARGS=${TRILINOS_SERCOMM_OTHER_ARGS:-""}
# TRILINOS_SERCOMMSH_OTHER_ARGS=${TRILINOS_SERCOMMSH_OTHER_ARGS:-""}
# TRILINOS_SERFULL_OTHER_ARGS=${TRILINOS_SERFULL_OTHER_ARGS:-""}
# TRILINOS_SERFULLSH_OTHER_ARGS=${TRILINOS_SERFULLSH_OTHER_ARGS:-""}

# TSTESTS_BLDRVERSION=${TSTESTS_BLDRVERSION:-""}
# TSTESTS_BUILDS=${TSTESTS_BUILDS:-""}
# TSTESTS_ALL_OTHER_ARGS=${TSTESTS_ALL_OTHER_ARGS:-""}

# TUTORIAL_PYTHON_BLDRVERSION=${TUTORIAL_PYTHON_BLDRVERSION:-""}
# TUTORIAL_PYTHON_BUILDS=${TUTORIAL_PYTHON_BUILDS:-""}
# TUTORIAL_PYTHON_PYCSH_OTHER_ARGS=${TUTORIAL_PYTHON_PYCSH_OTHER_ARGS:-""}

# TVMET_BLDRVERSION=${TVMET_BLDRVERSION:-""}
# TVMET_BUILDS=${TVMET_BUILDS:-""}
# TVMET_SER_OTHER_ARGS=${TVMET_SER_OTHER_ARGS:-""}

# TXBASE_BLDRVERSION=${TXBASE_BLDRVERSION:-""}
# TXBASE_BUILDS=${TXBASE_BUILDS:-""}
# TXBASE_PYCSH_OTHER_ARGS=${TXBASE_PYCSH_OTHER_ARGS:-""}
# TXBASE_PAR_OTHER_ARGS=${TXBASE_PAR_OTHER_ARGS:-""}
# TXBASE_PARSH_OTHER_ARGS=${TXBASE_PARSH_OTHER_ARGS:-""}
# TXBASE_SER_OTHER_ARGS=${TXBASE_SER_OTHER_ARGS:-""}
# TXBASE_SERSH_OTHER_ARGS=${TXBASE_SERSH_OTHER_ARGS:-""}

# TXBTESTS_BLDRVERSION=${TXBTESTS_BLDRVERSION:-""}
# TXBTESTS_BUILDS=${TXBTESTS_BUILDS:-""}
# TXBTESTS_ALL_OTHER_ARGS=${TXBTESTS_ALL_OTHER_ARGS:-""}

# TXGEOM_BLDRVERSION=${TXGEOM_BLDRVERSION:-""}
# TXGEOM_BUILDS=${TXGEOM_BUILDS:-""}
# TXGEOM_PAR_OTHER_ARGS=${TXGEOM_PAR_OTHER_ARGS:-""}
# TXGEOM_SER_OTHER_ARGS=${TXGEOM_SER_OTHER_ARGS:-""}

# TXPHYSICS_BLDRVERSION=${TXPHYSICS_BLDRVERSION:-""}
TXPHYSICS_BUILDS=${TXPHYSICS_BUILDS:-"ser"}
# TXPHYSICS_BEN_OTHER_ARGS=${TXPHYSICS_BEN_OTHER_ARGS:-""}
# TXPHYSICS_SER_OTHER_ARGS=${TXPHYSICS_SER_OTHER_ARGS:-""}
# TXPHYSICS_SERSH_OTHER_ARGS=${TXPHYSICS_SERSH_OTHER_ARGS:-""}

# TXSSH_BLDRVERSION=${TXSSH_BLDRVERSION:-""}
# TXSSH_BUILDS=${TXSSH_BUILDS:-""}
# TXSSH_PYCSH_OTHER_ARGS=${TXSSH_PYCSH_OTHER_ARGS:-""}
# TXSSH_SER_OTHER_ARGS=${TXSSH_SER_OTHER_ARGS:-""}
# TXSSH_SERSH_OTHER_ARGS=${TXSSH_SERSH_OTHER_ARGS:-""}

# UEDGE_BLDRVERSION=${UEDGE_BLDRVERSION:-""}
UEDGE_BUILDS=${UEDGE_BUILDS:-"NONE"}
# UEDGE_NOPETSC_OTHER_ARGS=${UEDGE_NOPETSC_OTHER_ARGS:-""}
# UEDGE_PAR_OTHER_ARGS=${UEDGE_PAR_OTHER_ARGS:-""}
# UEDGE_PARTAU_OTHER_ARGS=${UEDGE_PARTAU_OTHER_ARGS:-""}
# UEDGE_SER_OTHER_ARGS=${UEDGE_SER_OTHER_ARGS:-""}

# UETESTS_BLDRVERSION=${UETESTS_BLDRVERSION:-""}
# UETESTS_BUILDS=${UETESTS_BUILDS:-""}
# UETESTS_ALL_OTHER_ARGS=${UETESTS_ALL_OTHER_ARGS:-""}

# VALGRIND_BLDRVERSION=${VALGRIND_BLDRVERSION:-""}
VALGRIND_BUILDS=${VALGRIND_BUILDS:-"NONE"}
# VALGRIND_SER_OTHER_ARGS=${VALGRIND_SER_OTHER_ARGS:-""}

# VISIT_BLDRVERSION=${VISIT_BLDRVERSION:-""}
# VISIT_BUILDS=${VISIT_BUILDS:-""}
# VISIT_PAR_OTHER_ARGS=${VISIT_PAR_OTHER_ARGS:-""}
# VISIT_SER_OTHER_ARGS=${VISIT_SER_OTHER_ARGS:-""}

# VISIT_VTK_BLDRVERSION=${VISIT_VTK_BLDRVERSION:-""}
# VISIT_VTK_BUILDS=${VISIT_VTK_BUILDS:-""}
# VISIT_VTK_SER_OTHER_ARGS=${VISIT_VTK_SER_OTHER_ARGS:-""}

# VTK_BLDRVERSION=${VTK_BLDRVERSION:-""}
# VTK_BUILDS=${VTK_BUILDS:-""}
# VTK_SER_OTHER_ARGS=${VTK_SER_OTHER_ARGS:-""}

# WALLPSI_BLDRVERSION=${WALLPSI_BLDRVERSION:-""}
# WALLPSI_BUILDS=${WALLPSI_BUILDS:-""}
# WALLPSI_BEN_OTHER_ARGS=${WALLPSI_BEN_OTHER_ARGS:-""}
# WALLPSI_SER_OTHER_ARGS=${WALLPSI_SER_OTHER_ARGS:-""}

# WALLPSITESTS_BLDRVERSION=${WALLPSITESTS_BLDRVERSION:-""}
# WALLPSITESTS_BUILDS=${WALLPSITESTS_BUILDS:-""}
# WALLPSITESTS_ALL_OTHER_ARGS=${WALLPSITESTS_ALL_OTHER_ARGS:-""}

# XDMF_BLDRVERSION=${XDMF_BLDRVERSION:-""}
# XDMF_BUILDS=${XDMF_BUILDS:-""}
# XDMF_SER_OTHER_ARGS=${XDMF_SER_OTHER_ARGS:-""}

# XERCESC_BLDRVERSION=${XERCESC_BLDRVERSION:-""}
# XERCESC_BUILDS=${XERCESC_BUILDS:-""}
# XERCESC_SER_OTHER_ARGS=${XERCESC_SER_OTHER_ARGS:-""}

# XZ_BLDRVERSION=${XZ_BLDRVERSION:-""}
# XZ_BUILDS=${XZ_BUILDS:-""}
# XZ___OTHER_ARGS=${XZ___OTHER_ARGS:-""}

# ZEROMQ_BLDRVERSION=${ZEROMQ_BLDRVERSION:-""}
# ZEROMQ_BUILDS=${ZEROMQ_BUILDS:-""}
# ZEROMQ_PYCSH_OTHER_ARGS=${ZEROMQ_PYCSH_OTHER_ARGS:-""}

# ZLIB_BLDRVERSION=${ZLIB_BLDRVERSION:-""}
# ZLIB_BUILDS=${ZLIB_BUILDS:-""}
# ZLIB_SER_OTHER_ARGS=${ZLIB_SER_OTHER_ARGS:-""}
# ZLIB_SERSH_OTHER_ARGS=${ZLIB_SERSH_OTHER_ARGS:-""}

