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

# Determine whether we're on a 32-bit or 64-bit system
if uname | grep -c 'WOW64' 1>/dev/null; then
  IS_64BIT=true
else
  IS_64BIT=false
fi

# Trying no atlas builds on windows.  Trilinos may have problems,
# but numpy is building.
ATLAS_BUILDS=${ATLAS_BUILDS:-"NONE"}

# Set any variables based on 32/64 bit
FC=
if $IS_64BIT; then
#  ATLAS_BUILDS=${ATLAS_BUILDS:-"NONE"}
  FC=${FC:-`which mingw64-gfortran.exe 2>/dev/null`}
else
  FC=${FC:-`which mingw32-gfortran.exe 2>/dev/null`}
fi
if test -n "$FC"; then
  # techo "Found FC = $FC."
  FC=`cygpath -am $FC`
  # techo "Converted FC = $FC."
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

# PYC compilers:
# Some of the packages, in particular distutils, build with only PYC
# Python gcc compilers:
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
# CFLAGS=${CFLAGS:-""}
# CXXFLAGS=${CXXFLAGS:-""}
# FCFLAGS=${FCFLAGS:-""}
# FFLAGS=${FFLAGS:-""}

# PYC flags:
# PYC_LDFLAGS is for creating an executable.
# PYC_MODFLAGS is for creating a module.
# PYC_CFLAGS=${PYC_CFLAGS:-""}
# PYC_CXXFLAGS=${PYC_CXXFLAGS:-""}
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
# SYSTEM_BLAS_CC4PY_LIB=${SYSTEM_BLAS_CC4PY_LIB:-""}
# SYSTEM_BLAS_BEN_LIB=${SYSTEM_BLAS_BEN_LIB:-""}
# SYSTEM_LAPACK_SER_LIB=${SYSTEM_LAPACK_SER_LIB:-""}
# SYSTEM_LAPACK_CC4PY_LIB=${SYSTEM_LAPACK_CC4PY_LIB:-""}
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

# Variables for the packages, adios atlas autoconf automake autotools babel bhssolver boost botan cfitsio cheflibs chombo chompst chrpath clapack_cmake cmake composertoolkit corrcalc ctktests cuda curl cusp cython dakota ddsflow docutils doxygen eqcodes facets facetscomposer facetsifc fciowrappers fctests fftw fftw3 fgtests fluxgrid fmcfm fmtests forthon freetype fusion_machine ga_transport gacode genray gkeyll gotoblas2 gperf gpulib gsl gtest hdf5 httplib2 idlsave imaging ips ipscomposer ipython jsmath lapack libpng libtool libxml2 lp_solve m4 mako mathjax matplotlib mesa metatau mpe2 mpi4py mpich2 muparser mxml nautilus nautiluscomposer ncurses ne7ssh netcdf netlib_lite nimrod nimtests ntcc_transport nttests nubeam numexpr numpy openmpi opensplice pandas paramiko pcre petsc petsc4py petscdev petscgpu plasma_state polyswift polyswiftcomposer pspline pstests ptk pydap pygments pynetcdf4 pyparsing pyqt pyreadline pysynthdiag python pyzmq qdstests qhull qscintilla qt quids r readline rpy2 rst2pdf scipy scitools setuptools shtool simd simplejson simyan sip slepc sphinx sqlite squish subversion sundials swig swimgui synergia2 tables teaspink thrust tinkerer toric tornado tosml trilinos tstests tutorial_python txbase txbtests txgeom txlicmgr txphysics txssh uedge uetests valgrind vcptests visit visit_vtk vorpal vorpalcomposer vorpalview vpdocs vpexamples vptests vtk wallpsi wallpsitests xercesc xz zeromq zlib.
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

# ATLAS_BLDRVERSION=${ATLAS_BLDRVERSION:-""}
# ATLAS_BUILDS=${ATLAS_BUILDS:-"clp,ser"}
# ATLAS_CC4PY_OTHER_ARGS=${ATLAS_CC4PY_OTHER_ARGS:-""}
# ATLAS_CLP_OTHER_ARGS=${ATLAS_CLP_OTHER_ARGS:-""}
# ATLAS_SER_OTHER_ARGS=${ATLAS_SER_OTHER_ARGS:-""}

# AUTOCONF_BLDRVERSION=${AUTOCONF_BLDRVERSION:-""}
# AUTOCONF_BUILDS=${AUTOCONF_BUILDS:-""}
# AUTOCONF_SER_OTHER_ARGS=${AUTOCONF_SER_OTHER_ARGS:-""}

# AUTOMAKE_BLDRVERSION=${AUTOMAKE_BLDRVERSION:-""}
# AUTOMAKE_BUILDS=${AUTOMAKE_BUILDS:-""}
# AUTOMAKE_SER_OTHER_ARGS=${AUTOMAKE_SER_OTHER_ARGS:-""}

# BABEL_BLDRVERSION=${BABEL_BLDRVERSION:-""}
BABEL_BUILDS=${BABEL_BUILDS:-"NONE"}
# BABEL_SHARED_OTHER_ARGS=${BABEL_SHARED_OTHER_ARGS:-""}
# BABEL_STATIC_OTHER_ARGS=${BABEL_STATIC_OTHER_ARGS:-""}

# BHSSOLVER_BLDRVERSION=${BHSSOLVER_BLDRVERSION:-""}
# BHSSOLVER_BUILDS=${BHSSOLVER_BUILDS:-""}
# BHSSOLVER_BEN_OTHER_ARGS=${BHSSOLVER_BEN_OTHER_ARGS:-""}
# BHSSOLVER_SER_OTHER_ARGS=${BHSSOLVER_SER_OTHER_ARGS:-""}

# BOOST_BLDRVERSION=${BOOST_BLDRVERSION:-""}
# BOOST_BUILDS=${BOOST_BUILDS:-""}
# BOOST_SER_OTHER_ARGS=${BOOST_SER_OTHER_ARGS:-""}

# BOTAN_BLDRVERSION=${BOTAN_BLDRVERSION:-""}
# BOTAN_BUILDS=${BOTAN_BUILDS:-""}
# BOTAN_SER_OTHER_ARGS=${BOTAN_SER_OTHER_ARGS:-""}

# CFITSIO_BLDRVERSION=${CFITSIO_BLDRVERSION:-""}
# CFITSIO_BUILDS=${CFITSIO_BUILDS:-""}
# CFITSIO_SER_OTHER_ARGS=${CFITSIO_SER_OTHER_ARGS:-""}

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

# CHOMPST_BLDRVERSION=${CHOMPST_BLDRVERSION:-""}
# CHOMPST_BUILDS=${CHOMPST_BUILDS:-""}
# CHOMPST_PAR2D_OTHER_ARGS=${CHOMPST_PAR2D_OTHER_ARGS:-""}
# CHOMPST_PAR2DTAU_OTHER_ARGS=${CHOMPST_PAR2DTAU_OTHER_ARGS:-""}
# CHOMPST_PAR3D_OTHER_ARGS=${CHOMPST_PAR3D_OTHER_ARGS:-""}
# CHOMPST_PAR3DDBG_OTHER_ARGS=${CHOMPST_PAR3DDBG_OTHER_ARGS:-""}
# CHOMPST_PAR3DTAU_OTHER_ARGS=${CHOMPST_PAR3DTAU_OTHER_ARGS:-""}
# CHOMPST_SER2D_OTHER_ARGS=${CHOMPST_SER2D_OTHER_ARGS:-""}
# CHOMPST_SER2DDBG_OTHER_ARGS=${CHOMPST_SER2DDBG_OTHER_ARGS:-""}
# CHOMPST_SER3D_OTHER_ARGS=${CHOMPST_SER3D_OTHER_ARGS:-""}

# CHRPATH_BLDRVERSION=${CHRPATH_BLDRVERSION:-""}
# CHRPATH_BUILDS=${CHRPATH_BUILDS:-""}
# CHRPATH_SER_OTHER_ARGS=${CHRPATH_SER_OTHER_ARGS:-""}

# CLAPACK_CMAKE_BLDRVERSION=${CLAPACK_CMAKE_BLDRVERSION:-""}
CLAPACK_CMAKE_BUILDS=${CLAPACK_CMAKE_BUILDS:-"ser"}
# CLAPACK_CMAKE_CC4PY_OTHER_ARGS=${CLAPACK_CMAKE_CC4PY_OTHER_ARGS:-""}
CLAPACK_CMAKE_SER_OTHER_ARGS=${CLAPACK_CMAKE_SER_OTHER_ARGS:-"-DBUILD_SHARED_LIBS:BOOL=OFF"}

# CMAKE_BLDRVERSION=${CMAKE_BLDRVERSION:-""}
# JRC: restoring CMAKE builds, as need to get cmake to build
# on Windows.  Recheck for any reasons for not doing it.
# CMAKE_BUILDS=${CMAKE_BUILDS:-"NONE"}
# CMAKE_SER_OTHER_ARGS=${CMAKE_SER_OTHER_ARGS:-""}

# COMPOSERTOOLKIT_BLDRVERSION=${COMPOSERTOOLKIT_BLDRVERSION:-""}
# COMPOSERTOOLKIT_BUILDS=${COMPOSERTOOLKIT_BUILDS:-""}
# COMPOSERTOOLKIT_DEVELDOCS_OTHER_ARGS=${COMPOSERTOOLKIT_DEVELDOCS_OTHER_ARGS:-""}
# COMPOSERTOOLKIT_NOVISIT_OTHER_ARGS=${COMPOSERTOOLKIT_NOVISIT_OTHER_ARGS:-""}
# COMPOSERTOOLKIT_VISIT_OTHER_ARGS=${COMPOSERTOOLKIT_VISIT_OTHER_ARGS:-""}

# CORRCALC_BLDRVERSION=${CORRCALC_BLDRVERSION:-""}
# CORRCALC_BUILDS=${CORRCALC_BUILDS:-""}
# CORRCALC_PAR_OTHER_ARGS=${CORRCALC_PAR_OTHER_ARGS:-""}
# CORRCALC_SER_OTHER_ARGS=${CORRCALC_SER_OTHER_ARGS:-""}

# CTKTESTS_BLDRVERSION=${CTKTESTS_BLDRVERSION:-""}
# CTKTESTS_BUILDS=${CTKTESTS_BUILDS:-""}
# CTKTESTS_ALL_OTHER_ARGS=${CTKTESTS_ALL_OTHER_ARGS:-""}

# CURL_BLDRVERSION=${CURL_BLDRVERSION:-""}
# CURL_BUILDS=${CURL_BUILDS:-""}
# CURL_SER_OTHER_ARGS=${CURL_SER_OTHER_ARGS:-""}

# CUSP_BLDRVERSION=${CUSP_BLDRVERSION:-""}
# CUSP_BUILDS=${CUSP_BUILDS:-""}
# CUSP_GPU_OTHER_ARGS=${CUSP_GPU_OTHER_ARGS:-""}

# CYTHON_BLDRVERSION=${CYTHON_BLDRVERSION:-""}
# CYTHON_BUILDS=${CYTHON_BUILDS:-""}
# CYTHON_CC4PY_OTHER_ARGS=${CYTHON_CC4PY_OTHER_ARGS:-""}

# DAKOTA_BLDRVERSION=${DAKOTA_BLDRVERSION:-""}
# DAKOTA_BUILDS=${DAKOTA_BUILDS:-""}
# DAKOTA_PAR_OTHER_ARGS=${DAKOTA_PAR_OTHER_ARGS:-""}
# DAKOTA_SER_OTHER_ARGS=${DAKOTA_SER_OTHER_ARGS:-""}

# DDSFLOW_BLDRVERSION=${DDSFLOW_BLDRVERSION:-""}
# DDSFLOW_BUILDS=${DDSFLOW_BUILDS:-""}
# DDSFLOW_SER_OTHER_ARGS=${DDSFLOW_SER_OTHER_ARGS:-""}

# DOCUTILS_BLDRVERSION=${DOCUTILS_BLDRVERSION:-""}
# DOCUTILS_BUILDS=${DOCUTILS_BUILDS:-""}
# DOCUTILS_CC4PY_OTHER_ARGS=${DOCUTILS_CC4PY_OTHER_ARGS:-""}

# DOXYGEN_BLDRVERSION=${DOXYGEN_BLDRVERSION:-""}
# DOXYGEN_BUILDS=${DOXYGEN_BUILDS:-""}
# DOXYGEN_SER_OTHER_ARGS=${DOXYGEN_SER_OTHER_ARGS:-""}

# EQCODES_BLDRVERSION=${EQCODES_BLDRVERSION:-""}
# EQCODES_BUILDS=${EQCODES_BUILDS:-""}
# EQCODES_BEN_OTHER_ARGS=${EQCODES_BEN_OTHER_ARGS:-""}
# EQCODES_SER_OTHER_ARGS=${EQCODES_SER_OTHER_ARGS:-""}

# FACETS_BLDRVERSION=${FACETS_BLDRVERSION:-""}
# FACETS_BUILDS=${FACETS_BUILDS:-""}
# FACETS_PAR_OTHER_ARGS=${FACETS_PAR_OTHER_ARGS:-""}
# FACETS_PARTAU_OTHER_ARGS=${FACETS_PARTAU_OTHER_ARGS:-""}
# FACETS_SER_OTHER_ARGS=${FACETS_SER_OTHER_ARGS:-""}
# FACETS_WEBDOCS_OTHER_ARGS=${FACETS_WEBDOCS_OTHER_ARGS:-""}

# FACETSCOMPOSER_BLDRVERSION=${FACETSCOMPOSER_BLDRVERSION:-""}
# FACETSCOMPOSER_BUILDS=${FACETSCOMPOSER_BUILDS:-""}
# FACETSCOMPOSER_DEVELDOCS_OTHER_ARGS=${FACETSCOMPOSER_DEVELDOCS_OTHER_ARGS:-""}
# FACETSCOMPOSER_SER_OTHER_ARGS=${FACETSCOMPOSER_SER_OTHER_ARGS:-""}

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
# FMCFM_WEBDOCS_OTHER_ARGS=${FMCFM_WEBDOCS_OTHER_ARGS:-""}

# FMTESTS_BLDRVERSION=${FMTESTS_BLDRVERSION:-""}
# FMTESTS_BUILDS=${FMTESTS_BUILDS:-""}
# FMTESTS_ALL_OTHER_ARGS=${FMTESTS_ALL_OTHER_ARGS:-""}

# FORTHON_BLDRVERSION=${FORTHON_BLDRVERSION:-""}
# FORTHON_BUILDS=${FORTHON_BUILDS:-""}
# FORTHON_CC4PY_OTHER_ARGS=${FORTHON_CC4PY_OTHER_ARGS:-""}

# FREETYPE_BLDRVERSION=${FREETYPE_BLDRVERSION:-""}
# FREETYPE_BUILDS=${FREETYPE_BUILDS:-""}
# FREETYPE_CC4PY_OTHER_ARGS=${FREETYPE_CC4PY_OTHER_ARGS:-""}

# FUSION_MACHINE_BLDRVERSION=${FUSION_MACHINE_BLDRVERSION:-""}
# FUSION_MACHINE_BUILDS=${FUSION_MACHINE_BUILDS:-""}
# FUSION_MACHINE_CC4PY_OTHER_ARGS=${FUSION_MACHINE_CC4PY_OTHER_ARGS:-""}

# GA_TRANSPORT_BLDRVERSION=${GA_TRANSPORT_BLDRVERSION:-""}
# GA_TRANSPORT_BUILDS=${GA_TRANSPORT_BUILDS:-""}
# GA_TRANSPORT_PAR_OTHER_ARGS=${GA_TRANSPORT_PAR_OTHER_ARGS:-""}
# GA_TRANSPORT_SER_OTHER_ARGS=${GA_TRANSPORT_SER_OTHER_ARGS:-""}

# GACODE_BLDRVERSION=${GACODE_BLDRVERSION:-""}
# GACODE_BUILDS=${GACODE_BUILDS:-""}
# GACODE_PAR_OTHER_ARGS=${GACODE_PAR_OTHER_ARGS:-""}
# GACODE_SER_OTHER_ARGS=${GACODE_SER_OTHER_ARGS:-""}

# GENRAY_BLDRVERSION=${GENRAY_BLDRVERSION:-""}
# GENRAY_BUILDS=${GENRAY_BUILDS:-""}
# GENRAY_PAR_OTHER_ARGS=${GENRAY_PAR_OTHER_ARGS:-""}
# GENRAY_SER_OTHER_ARGS=${GENRAY_SER_OTHER_ARGS:-""}

# GKEYLL_BLDRVERSION=${GKEYLL_BLDRVERSION:-""}
# GKEYLL_BUILDS=${GKEYLL_BUILDS:-""}
# GKEYLL_PAR_OTHER_ARGS=${GKEYLL_PAR_OTHER_ARGS:-""}
# GKEYLL_SER_OTHER_ARGS=${GKEYLL_SER_OTHER_ARGS:-""}
# GKEYLL_WEBDOCS_OTHER_ARGS=${GKEYLL_WEBDOCS_OTHER_ARGS:-""}

# GOTOBLAS2_BLDRVERSION=${GOTOBLAS2_BLDRVERSION:-""}
# GOTOBLAS2_BUILDS=${GOTOBLAS2_BUILDS:-""}
# GOTOBLAS2_SER_OTHER_ARGS=${GOTOBLAS2_SER_OTHER_ARGS:-""}

# GPERF_BLDRVERSION=${GPERF_BLDRVERSION:-""}
# GPERF_BUILDS=${GPERF_BUILDS:-""}
# GPERF_SER_OTHER_ARGS=${GPERF_SER_OTHER_ARGS:-""}
# GPERF_SERSH_OTHER_ARGS=${GPERF_SERSH_OTHER_ARGS:-""}

# GPULIB_BLDRVERSION=${GPULIB_BLDRVERSION:-""}
# GPULIB_BUILDS=${GPULIB_BUILDS:-""}
# GPULIB_DOUBLE_OTHER_ARGS=${GPULIB_DOUBLE_OTHER_ARGS:-""}
# GPULIB_FERMI_OTHER_ARGS=${GPULIB_FERMI_OTHER_ARGS:-""}
# GPULIB_SINGLE_OTHER_ARGS=${GPULIB_SINGLE_OTHER_ARGS:-""}

# GSL_BLDRVERSION=${GSL_BLDRVERSION:-""}
# GSL_BUILDS=${GSL_BUILDS:-""}
# GSL_SER_OTHER_ARGS=${GSL_SER_OTHER_ARGS:-""}

# GTEST_BLDRVERSION=${GTEST_BLDRVERSION:-""}
# GTEST_BUILDS=${GTEST_BUILDS:-""}
# GTEST_SER_OTHER_ARGS=${GTEST_SER_OTHER_ARGS:-""}

# HDF5_BLDRVERSION=${HDF5_BLDRVERSION:-""}
# HDF5_BUILDS=${HDF5_BUILDS:-""}
HDF5_CC4PY_OTHER_ARGS=${HDF5_CC4PY_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_PAR_OTHER_ARGS=${HDF5_PAR_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_PARSH_OTHER_ARGS=${HDF5_PARSH_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_SER_OTHER_ARGS=${HDF5_SER_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}
HDF5_SERSH_OTHER_ARGS=${HDF5_SERSH_OTHER_ARGS:-"-DHDF5_BUILD_FORTRAN:BOOL=OFF"}

# HTTPLIB2_BLDRVERSION=${HTTPLIB2_BLDRVERSION:-""}
# HTTPLIB2_BUILDS=${HTTPLIB2_BUILDS:-""}
# HTTPLIB2_CC4PY_OTHER_ARGS=${HTTPLIB2_CC4PY_OTHER_ARGS:-""}

# IDLSAVE_BLDRVERSION=${IDLSAVE_BLDRVERSION:-""}
# IDLSAVE_BUILDS=${IDLSAVE_BUILDS:-""}
# IDLSAVE_CC4PY_OTHER_ARGS=${IDLSAVE_CC4PY_OTHER_ARGS:-""}

# IMAGING_BLDRVERSION=${IMAGING_BLDRVERSION:-""}
# IMAGING_BUILDS=${IMAGING_BUILDS:-""}
# IMAGING_CC4PY_OTHER_ARGS=${IMAGING_CC4PY_OTHER_ARGS:-""}

# IPS_BLDRVERSION=${IPS_BLDRVERSION:-""}
# IPS_BUILDS=${IPS_BUILDS:-""}
# IPS_PAR_OTHER_ARGS=${IPS_PAR_OTHER_ARGS:-""}
# IPS_SER_OTHER_ARGS=${IPS_SER_OTHER_ARGS:-""}

# IPSCOMPOSER_BLDRVERSION=${IPSCOMPOSER_BLDRVERSION:-""}
# IPSCOMPOSER_BUILDS=${IPSCOMPOSER_BUILDS:-""}
# IPSCOMPOSER_SER_OTHER_ARGS=${IPSCOMPOSER_SER_OTHER_ARGS:-""}

# IPYTHON_BLDRVERSION=${IPYTHON_BLDRVERSION:-""}
# IPYTHON_BUILDS=${IPYTHON_BUILDS:-""}
# IPYTHON_CC4PY_OTHER_ARGS=${IPYTHON_CC4PY_OTHER_ARGS:-""}

# JSMATH_BLDRVERSION=${JSMATH_BLDRVERSION:-""}
# JSMATH_BUILDS=${JSMATH_BUILDS:-""}
# JSMATH_CC4PY_OTHER_ARGS=${JSMATH_CC4PY_OTHER_ARGS:-""}

# LAPACK_BLDRVERSION=${LAPACK_BLDRVERSION:-""}
# LAPACK_BUILDS=${LAPACK_BUILDS:-""}
# LAPACK_BEN_OTHER_ARGS=${LAPACK_BEN_OTHER_ARGS:-""}
# LAPACK_CC4PY_OTHER_ARGS=${LAPACK_CC4PY_OTHER_ARGS:-""}
# LAPACK_SER_OTHER_ARGS=${LAPACK_SER_OTHER_ARGS:-""}

# LIBPNG_BLDRVERSION=${LIBPNG_BLDRVERSION:-""}
# LIBPNG_BUILDS=${LIBPNG_BUILDS:-""}
# LIBPNG_CC4PY_OTHER_ARGS=${LIBPNG_CC4PY_OTHER_ARGS:-""}

# LIBTOOL_BLDRVERSION=${LIBTOOL_BLDRVERSION:-""}
# LIBTOOL_BUILDS=${LIBTOOL_BUILDS:-""}
# LIBTOOL_SER_OTHER_ARGS=${LIBTOOL_SER_OTHER_ARGS:-""}

# LIBXML2_BLDRVERSION=${LIBXML2_BLDRVERSION:-""}
# LIBXML2_BUILDS=${LIBXML2_BUILDS:-""}
# LIBXML2_SER_OTHER_ARGS=${LIBXML2_SER_OTHER_ARGS:-""}

# LP_SOLVE_BLDRVERSION=${LP_SOLVE_BLDRVERSION:-""}
# LP_SOLVE_BUILDS=${LP_SOLVE_BUILDS:-""}
# LP_SOLVE_SER_OTHER_ARGS=${LP_SOLVE_SER_OTHER_ARGS:-""}

# M4_BLDRVERSION=${M4_BLDRVERSION:-""}
# M4_BUILDS=${M4_BUILDS:-""}
# M4_SER_OTHER_ARGS=${M4_SER_OTHER_ARGS:-""}

# MAKO_BLDRVERSION=${MAKO_BLDRVERSION:-""}
# MAKO_BUILDS=${MAKO_BUILDS:-""}
# MAKO_CC4PY_OTHER_ARGS=${MAKO_CC4PY_OTHER_ARGS:-""}

# MATHJAX_BLDRVERSION=${MATHJAX_BLDRVERSION:-""}
# MATHJAX_BUILDS=${MATHJAX_BUILDS:-""}
# MATHJAX_CC4PY_OTHER_ARGS=${MATHJAX_CC4PY_OTHER_ARGS:-""}
# MATHJAX_CTK_OTHER_ARGS=${MATHJAX_CTK_OTHER_ARGS:-""}

# MATPLOTLIB_BLDRVERSION=${MATPLOTLIB_BLDRVERSION:-""}
# MATPLOTLIB_BUILDS=${MATPLOTLIB_BUILDS:-""}
# MATPLOTLIB_CC4PY_OTHER_ARGS=${MATPLOTLIB_CC4PY_OTHER_ARGS:-""}

# MESA_BLDRVERSION=${MESA_BLDRVERSION:-""}
MESA_BUILDS=${MESA_BUILDS:-"NONE"}
# MESA_MGL_OTHER_ARGS=${MESA_MGL_OTHER_ARGS:-""}
# MESA_OS_OTHER_ARGS=${MESA_OS_OTHER_ARGS:-""}

# METATAU_BLDRVERSION=${METATAU_BLDRVERSION:-""}
METATAU_BUILDS=${METATAU_BUILDS:-"NONE"}
# METATAU_PAR_OTHER_ARGS=${METATAU_PAR_OTHER_ARGS:-""}

# MPE2_BLDRVERSION=${MPE2_BLDRVERSION:-""}
# MPE2_BUILDS=${MPE2_BUILDS:-""}
# MPE2_NODL_OTHER_ARGS=${MPE2_NODL_OTHER_ARGS:-""}

# MPI4PY_BLDRVERSION=${MPI4PY_BLDRVERSION:-""}
# MPI4PY_BUILDS=${MPI4PY_BUILDS:-""}
# MPI4PY_CC4PY_OTHER_ARGS=${MPI4PY_CC4PY_OTHER_ARGS:-""}

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

# NAUTILUS_BLDRVERSION=${NAUTILUS_BLDRVERSION:-""}
# NAUTILUS_BUILDS=${NAUTILUS_BUILDS:-""}
# NAUTILUS_PAR_OTHER_ARGS=${NAUTILUS_PAR_OTHER_ARGS:-""}
# NAUTILUS_SER_OTHER_ARGS=${NAUTILUS_SER_OTHER_ARGS:-""}
# NAUTILUS_USERDOCSMJL_OTHER_ARGS=${NAUTILUS_USERDOCSMJL_OTHER_ARGS:-""}
# NAUTILUS_WEBDOCS_OTHER_ARGS=${NAUTILUS_WEBDOCS_OTHER_ARGS:-""}

# NAUTILUSCOMPOSER_BLDRVERSION=${NAUTILUSCOMPOSER_BLDRVERSION:-""}
# NAUTILUSCOMPOSER_BUILDS=${NAUTILUSCOMPOSER_BUILDS:-""}
# NAUTILUSCOMPOSER_DEVELDOCS_OTHER_ARGS=${NAUTILUSCOMPOSER_DEVELDOCS_OTHER_ARGS:-""}
# NAUTILUSCOMPOSER_SER_OTHER_ARGS=${NAUTILUSCOMPOSER_SER_OTHER_ARGS:-""}

# NCURSES_BLDRVERSION=${NCURSES_BLDRVERSION:-""}
# NCURSES_BUILDS=${NCURSES_BUILDS:-""}
# NCURSES_SER_OTHER_ARGS=${NCURSES_SER_OTHER_ARGS:-""}

# NE7SSH_BLDRVERSION=${NE7SSH_BLDRVERSION:-""}
# NE7SSH_BUILDS=${NE7SSH_BUILDS:-""}
# NE7SSH_SER_OTHER_ARGS=${NE7SSH_SER_OTHER_ARGS:-""}

# NETCDF_BLDRVERSION=${NETCDF_BLDRVERSION:-""}
# NETCDF_BUILDS=${NETCDF_BUILDS:-""}
# NETCDF_BEN_OTHER_ARGS=${NETCDF_BEN_OTHER_ARGS:-""}
# NETCDF_CC4PY_OTHER_ARGS=${NETCDF_CC4PY_OTHER_ARGS:-""}
# NETCDF_PAR_OTHER_ARGS=${NETCDF_PAR_OTHER_ARGS:-""}
# NETCDF_SER_OTHER_ARGS=${NETCDF_SER_OTHER_ARGS:-""}

# NETLIB_LITE_BLDRVERSION=${NETLIB_LITE_BLDRVERSION:-""}
# NETLIB_LITE_BUILDS=${NETLIB_LITE_BUILDS:-""}
# NETLIB_LITE_BEN_OTHER_ARGS=${NETLIB_LITE_BEN_OTHER_ARGS:-""}
# NETLIB_LITE_SER_OTHER_ARGS=${NETLIB_LITE_SER_OTHER_ARGS:-""}

# NIMROD_BLDRVERSION=${NIMROD_BLDRVERSION:-""}
NIMROD_BUILDS=${NIMROD_BUILDS:-"NONE"}
# NIMROD_PAR_OTHER_ARGS=${NIMROD_PAR_OTHER_ARGS:-""}
# NIMROD_PARDBG_OTHER_ARGS=${NIMROD_PARDBG_OTHER_ARGS:-""}
# NIMROD_PARSURF_OTHER_ARGS=${NIMROD_PARSURF_OTHER_ARGS:-""}
# NIMROD_SER_OTHER_ARGS=${NIMROD_SER_OTHER_ARGS:-""}
# NIMROD_SERDBG_OTHER_ARGS=${NIMROD_SERDBG_OTHER_ARGS:-""}
# NIMROD_SERSURF_OTHER_ARGS=${NIMROD_SERSURF_OTHER_ARGS:-""}
# NIMROD_WEBDOCS_OTHER_ARGS=${NIMROD_WEBDOCS_OTHER_ARGS:-""}

# NIMTESTS_BLDRVERSION=${NIMTESTS_BLDRVERSION:-""}
# NIMTESTS_BUILDS=${NIMTESTS_BUILDS:-""}
# NIMTESTS_ALL_OTHER_ARGS=${NIMTESTS_ALL_OTHER_ARGS:-""}

# NTCC_TRANSPORT_BLDRVERSION=${NTCC_TRANSPORT_BLDRVERSION:-""}
NTCC_TRANSPORT_BUILDS=${NTCC_TRANSPORT_BUILDS:-"NONE"}
# NTCC_TRANSPORT_PAR_OTHER_ARGS=${NTCC_TRANSPORT_PAR_OTHER_ARGS:-""}
# NTCC_TRANSPORT_SER_OTHER_ARGS=${NTCC_TRANSPORT_SER_OTHER_ARGS:-""}

# NTTESTS_BLDRVERSION=${NTTESTS_BLDRVERSION:-""}
# NTTESTS_BUILDS=${NTTESTS_BUILDS:-""}
# NTTESTS_ALL_OTHER_ARGS=${NTTESTS_ALL_OTHER_ARGS:-""}

# NUBEAM_BLDRVERSION=${NUBEAM_BLDRVERSION:-""}
NUBEAM_BUILDS=${NUBEAM_BUILDS:-"NONE"}
# NUBEAM_PAR_OTHER_ARGS=${NUBEAM_PAR_OTHER_ARGS:-""}
# NUBEAM_SER_OTHER_ARGS=${NUBEAM_SER_OTHER_ARGS:-""}

# NUMEXPR_BLDRVERSION=${NUMEXPR_BLDRVERSION:-""}
# NUMEXPR_BUILDS=${NUMEXPR_BUILDS:-""}
# NUMEXPR_CC4PY_OTHER_ARGS=${NUMEXPR_CC4PY_OTHER_ARGS:-""}

# NUMPY_BLDRVERSION=${NUMPY_BLDRVERSION:-""}
# NUMPY_BUILDS=${NUMPY_BUILDS:-""}
# NUMPY_CC4PY_OTHER_ARGS=${NUMPY_CC4PY_OTHER_ARGS:-""}

# OPENMPI_BLDRVERSION=${OPENMPI_BLDRVERSION:-""}
OPENMPI_BUILDS=${OPENMPI_BUILDS:-"NONE"}
# OPENMPI_NODL_OTHER_ARGS=${OPENMPI_NODL_OTHER_ARGS:-""}
# OPENMPI_STATIC_OTHER_ARGS=${OPENMPI_STATIC_OTHER_ARGS:-""}

# OPENSPLICE_BLDRVERSION=${OPENSPLICE_BLDRVERSION:-""}
# OPENSPLICE_BUILDS=${OPENSPLICE_BUILDS:-""}
# OPENSPLICE_SER_OTHER_ARGS=${OPENSPLICE_SER_OTHER_ARGS:-""}

# PANDAS_BLDRVERSION=${PANDAS_BLDRVERSION:-""}
# PANDAS_BUILDS=${PANDAS_BUILDS:-""}
# PANDAS_CC4PY_OTHER_ARGS=${PANDAS_CC4PY_OTHER_ARGS:-""}

# PARAMIKO_BLDRVERSION=${PARAMIKO_BLDRVERSION:-""}
# PARAMIKO_BUILDS=${PARAMIKO_BUILDS:-""}
# PARAMIKO_CC4PY_OTHER_ARGS=${PARAMIKO_CC4PY_OTHER_ARGS:-""}

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

# PETSC4PY_BLDRVERSION=${PETSC4PY_BLDRVERSION:-""}
# PETSC4PY_BUILDS=${PETSC4PY_BUILDS:-""}
# PETSC4PY_CC4PY_OTHER_ARGS=${PETSC4PY_CC4PY_OTHER_ARGS:-""}

# PETSCDEV_BLDRVERSION=${PETSCDEV_BLDRVERSION:-""}
# PETSCDEV_BUILDS=${PETSCDEV_BUILDS:-""}
# PETSCDEV_PAR_OTHER_ARGS=${PETSCDEV_PAR_OTHER_ARGS:-""}
# PETSCDEV_SER_OTHER_ARGS=${PETSCDEV_SER_OTHER_ARGS:-""}

# PETSCGPU_BLDRVERSION=${PETSCGPU_BLDRVERSION:-""}
# PETSCGPU_BUILDS=${PETSCGPU_BUILDS:-""}
# PETSCGPU_PAR_OTHER_ARGS=${PETSCGPU_PAR_OTHER_ARGS:-""}
# PETSCGPU_SER_OTHER_ARGS=${PETSCGPU_SER_OTHER_ARGS:-""}

# PLASMA_STATE_BLDRVERSION=${PLASMA_STATE_BLDRVERSION:-""}
PLASMA_STATE_BUILDS=${PLASMA_STATE_BUILDS:-"NONE"}
# PLASMA_STATE_BEN_OTHER_ARGS=${PLASMA_STATE_BEN_OTHER_ARGS:-""}
# PLASMA_STATE_SER_OTHER_ARGS=${PLASMA_STATE_SER_OTHER_ARGS:-""}

# POLYSWIFT_BLDRVERSION=${POLYSWIFT_BLDRVERSION:-""}
# POLYSWIFT_BUILDS=${POLYSWIFT_BUILDS:-""}
# POLYSWIFT_DEVELDOCS_OTHER_ARGS=${POLYSWIFT_DEVELDOCS_OTHER_ARGS:-""}
# POLYSWIFT_PAR_OTHER_ARGS=${POLYSWIFT_PAR_OTHER_ARGS:-""}
# POLYSWIFT_SER_OTHER_ARGS=${POLYSWIFT_SER_OTHER_ARGS:-""}
# POLYSWIFT_USERDOCSMJL_OTHER_ARGS=${POLYSWIFT_USERDOCSMJL_OTHER_ARGS:-""}
# POLYSWIFT_USERDOCSMJW_OTHER_ARGS=${POLYSWIFT_USERDOCSMJW_OTHER_ARGS:-""}

# POLYSWIFTCOMPOSER_BLDRVERSION=${POLYSWIFTCOMPOSER_BLDRVERSION:-""}
# POLYSWIFTCOMPOSER_BUILDS=${POLYSWIFTCOMPOSER_BUILDS:-""}
# POLYSWIFTCOMPOSER_SER_OTHER_ARGS=${POLYSWIFTCOMPOSER_SER_OTHER_ARGS:-""}

# PSPLINE_BLDRVERSION=${PSPLINE_BLDRVERSION:-""}
# PSPLINE_BUILDS=${PSPLINE_BUILDS:-""}
# PSPLINE_PAR_OTHER_ARGS=${PSPLINE_PAR_OTHER_ARGS:-""}
# PSPLINE_SER_OTHER_ARGS=${PSPLINE_SER_OTHER_ARGS:-""}

# PSTESTS_BLDRVERSION=${PSTESTS_BLDRVERSION:-""}
# PSTESTS_BUILDS=${PSTESTS_BUILDS:-""}
# PSTESTS_ALL_OTHER_ARGS=${PSTESTS_ALL_OTHER_ARGS:-""}

# PTK_BLDRVERSION=${PTK_BLDRVERSION:-""}
# PTK_BUILDS=${PTK_BUILDS:-""}
# PTK_SER_OTHER_ARGS=${PTK_SER_OTHER_ARGS:-""}

# PYDAP_BLDRVERSION=${PYDAP_BLDRVERSION:-""}
# PYDAP_BUILDS=${PYDAP_BUILDS:-""}
# PYDAP_CC4PY_OTHER_ARGS=${PYDAP_CC4PY_OTHER_ARGS:-""}

# PYGMENTS_BLDRVERSION=${PYGMENTS_BLDRVERSION:-""}
# PYGMENTS_BUILDS=${PYGMENTS_BUILDS:-""}
# PYGMENTS_CC4PY_OTHER_ARGS=${PYGMENTS_CC4PY_OTHER_ARGS:-""}

# PYNETCDF4_BLDRVERSION=${PYNETCDF4_BLDRVERSION:-""}
# PYNETCDF4_BUILDS=${PYNETCDF4_BUILDS:-""}
# PYNETCDF4_CC4PY_OTHER_ARGS=${PYNETCDF4_CC4PY_OTHER_ARGS:-""}

# PYPARSING_BLDRVERSION=${PYPARSING_BLDRVERSION:-""}
# PYPARSING_BUILDS=${PYPARSING_BUILDS:-""}
# PYPARSING_CC4PY_OTHER_ARGS=${PYPARSING_CC4PY_OTHER_ARGS:-""}

# PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-""}
# PYQT_BUILDS=${PYQT_BUILDS:-""}
# PYQT_CC4PY_OTHER_ARGS=${PYQT_CC4PY_OTHER_ARGS:-""}

# PYREADLINE_BLDRVERSION=${PYREADLINE_BLDRVERSION:-""}
# PYREADLINE_BUILDS=${PYREADLINE_BUILDS:-""}
# PYREADLINE_CC4PY_OTHER_ARGS=${PYREADLINE_CC4PY_OTHER_ARGS:-""}

# PYSYNTHDIAG_BLDRVERSION=${PYSYNTHDIAG_BLDRVERSION:-""}
# PYSYNTHDIAG_BUILDS=${PYSYNTHDIAG_BUILDS:-""}
# PYSYNTHDIAG_CC4PY_OTHER_ARGS=${PYSYNTHDIAG_CC4PY_OTHER_ARGS:-""}

# PYTHON_BLDRVERSION=${PYTHON_BLDRVERSION:-""}
# PYTHON_BUILDS=${PYTHON_BUILDS:-""}
# PYTHON_CC4PY_OTHER_ARGS=${PYTHON_CC4PY_OTHER_ARGS:-""}

# PYZMQ_BLDRVERSION=${PYZMQ_BLDRVERSION:-""}
# PYZMQ_BUILDS=${PYZMQ_BUILDS:-""}
# PYZMQ_CC4PY_OTHER_ARGS=${PYZMQ_CC4PY_OTHER_ARGS:-""}

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
# RPY2_CC4PY_OTHER_ARGS=${RPY2_CC4PY_OTHER_ARGS:-""}

# RST2PDF_BLDRVERSION=${RST2PDF_BLDRVERSION:-""}
# RST2PDF_BUILDS=${RST2PDF_BUILDS:-""}
# RST2PDF_CC4PY_OTHER_ARGS=${RST2PDF_CC4PY_OTHER_ARGS:-""}

# SCIPY_BLDRVERSION=${SCIPY_BLDRVERSION:-""}
SCIPY_BUILDS=${SCIPY_BUILDS:-"NONE"}
# SCIPY_CC4PY_OTHER_ARGS=${SCIPY_CC4PY_OTHER_ARGS:-""}

# SCITOOLS_BLDRVERSION=${SCITOOLS_BLDRVERSION:-""}
# SCITOOLS_BUILDS=${SCITOOLS_BUILDS:-""}
# SCITOOLS_CC4PY_OTHER_ARGS=${SCITOOLS_CC4PY_OTHER_ARGS:-""}

# SETUPTOOLS_BLDRVERSION=${SETUPTOOLS_BLDRVERSION:-""}
# SETUPTOOLS_BUILDS=${SETUPTOOLS_BUILDS:-""}
# SETUPTOOLS_CC4PY_OTHER_ARGS=${SETUPTOOLS_CC4PY_OTHER_ARGS:-""}

# SHTOOL_BLDRVERSION=${SHTOOL_BLDRVERSION:-""}
# SHTOOL_BUILDS=${SHTOOL_BUILDS:-""}
# SHTOOL_SER_OTHER_ARGS=${SHTOOL_SER_OTHER_ARGS:-""}

# SIMD_BLDRVERSION=${SIMD_BLDRVERSION:-""}
# SIMD_BUILDS=${SIMD_BUILDS:-""}
# SIMD_SER_OTHER_ARGS=${SIMD_SER_OTHER_ARGS:-""}

# SIMPLEJSON_BLDRVERSION=${SIMPLEJSON_BLDRVERSION:-""}
# SIMPLEJSON_BUILDS=${SIMPLEJSON_BUILDS:-""}
# SIMPLEJSON_CC4PY_OTHER_ARGS=${SIMPLEJSON_CC4PY_OTHER_ARGS:-""}

# SIMYAN_BLDRVERSION=${SIMYAN_BLDRVERSION:-""}
# SIMYAN_BUILDS=${SIMYAN_BUILDS:-""}
# SIMYAN_CC4PY_OTHER_ARGS=${SIMYAN_CC4PY_OTHER_ARGS:-""}
# SIMYAN_WEBDOCS_OTHER_ARGS=${SIMYAN_WEBDOCS_OTHER_ARGS:-""}

# SIP_BLDRVERSION=${SIP_BLDRVERSION:-""}
# SIP_BUILDS=${SIP_BUILDS:-""}
# SIP_CC4PY_OTHER_ARGS=${SIP_CC4PY_OTHER_ARGS:-""}

# SLEPC_BLDRVERSION=${SLEPC_BLDRVERSION:-""}
# SLEPC_BUILDS=${SLEPC_BUILDS:-""}
# SLEPC_PAR_OTHER_ARGS=${SLEPC_PAR_OTHER_ARGS:-""}
# SLEPC_PARCPLX_OTHER_ARGS=${SLEPC_PARCPLX_OTHER_ARGS:-""}
# SLEPC_PARCPLXDBG_OTHER_ARGS=${SLEPC_PARCPLXDBG_OTHER_ARGS:-""}
# SLEPC_PARDBG_OTHER_ARGS=${SLEPC_PARDBG_OTHER_ARGS:-""}
# SLEPC_SER_OTHER_ARGS=${SLEPC_SER_OTHER_ARGS:-""}
# SLEPC_SERCPLX_OTHER_ARGS=${SLEPC_SERCPLX_OTHER_ARGS:-""}

# SPHINX_BLDRVERSION=${SPHINX_BLDRVERSION:-""}
# SPHINX_BUILDS=${SPHINX_BUILDS:-""}
# SPHINX_CC4PY_OTHER_ARGS=${SPHINX_CC4PY_OTHER_ARGS:-""}

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
# TABLES_CC4PY_OTHER_ARGS=${TABLES_CC4PY_OTHER_ARGS:-""}

# TEASPINK_BLDRVERSION=${TEASPINK_BLDRVERSION:-""}
# TEASPINK_BUILDS=${TEASPINK_BUILDS:-""}
# TEASPINK_SER_OTHER_ARGS=${TEASPINK_SER_OTHER_ARGS:-""}

# THRUST_BLDRVERSION=${THRUST_BLDRVERSION:-""}
# THRUST_BUILDS=${THRUST_BUILDS:-""}
# THRUST_SER_OTHER_ARGS=${THRUST_SER_OTHER_ARGS:-""}

# TINKERER_BLDRVERSION=${TINKERER_BLDRVERSION:-""}
# TINKERER_BUILDS=${TINKERER_BUILDS:-""}
# TINKERER_CC4PY_OTHER_ARGS=${TINKERER_CC4PY_OTHER_ARGS:-""}

# TORIC_BLDRVERSION=${TORIC_BLDRVERSION:-""}
# TORIC_BUILDS=${TORIC_BUILDS:-""}
# TORIC_PAR_OTHER_ARGS=${TORIC_PAR_OTHER_ARGS:-""}
# TORIC_SER_OTHER_ARGS=${TORIC_SER_OTHER_ARGS:-""}

# TORNADO_BLDRVERSION=${TORNADO_BLDRVERSION:-""}
# TORNADO_BUILDS=${TORNADO_BUILDS:-""}
# TORNADO_CC4PY_OTHER_ARGS=${TORNADO_CC4PY_OTHER_ARGS:-""}

# TOSML_BLDRVERSION=${TOSML_BLDRVERSION:-""}
# TOSML_BUILDS=${TOSML_BUILDS:-""}
# TOSML_CC4PY_OTHER_ARGS=${TOSML_CC4PY_OTHER_ARGS:-""}

# TRILINOS_BLDRVERSION=${TRILINOS_BLDRVERSION:-""}
# TRILINOS_BUILDS=${TRILINOS_BUILDS:-""}
# TRILINOS_PAR_OTHER_ARGS=${TRILINOS_PAR_OTHER_ARGS:-""}
# TRILINOS_PARSH_OTHER_ARGS=${TRILINOS_PARSH_OTHER_ARGS:-""}
# TRILINOS_SER_OTHER_ARGS=${TRILINOS_SER_OTHER_ARGS:-""}
# TRILINOS_SERSH_OTHER_ARGS=${TRILINOS_SERSH_OTHER_ARGS:-""}

# TSTESTS_BLDRVERSION=${TSTESTS_BLDRVERSION:-""}
# TSTESTS_BUILDS=${TSTESTS_BUILDS:-""}
# TSTESTS_ALL_OTHER_ARGS=${TSTESTS_ALL_OTHER_ARGS:-""}

# TUTORIAL_PYTHON_BLDRVERSION=${TUTORIAL_PYTHON_BLDRVERSION:-""}
# TUTORIAL_PYTHON_BUILDS=${TUTORIAL_PYTHON_BUILDS:-""}
# TUTORIAL_PYTHON_CC4PY_OTHER_ARGS=${TUTORIAL_PYTHON_CC4PY_OTHER_ARGS:-""}

# TXBASE_BLDRVERSION=${TXBASE_BLDRVERSION:-""}
# TXBASE_BUILDS=${TXBASE_BUILDS:-""}
# TXBASE_CC4PY_OTHER_ARGS=${TXBASE_CC4PY_OTHER_ARGS:-""}
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

# TXLICMGR_BLDRVERSION=${TXLICMGR_BLDRVERSION:-""}
# TXLICMGR_BUILDS=${TXLICMGR_BUILDS:-""}
# TXLICMGR_PAR_OTHER_ARGS=${TXLICMGR_PAR_OTHER_ARGS:-""}
# TXLICMGR_SER_OTHER_ARGS=${TXLICMGR_SER_OTHER_ARGS:-""}

# TXPHYSICS_BLDRVERSION=${TXPHYSICS_BLDRVERSION:-""}
TXPHYSICS_BUILDS=${TXPHYSICS_BUILDS:-"ser"}
# TXPHYSICS_BEN_OTHER_ARGS=${TXPHYSICS_BEN_OTHER_ARGS:-""}
# TXPHYSICS_SER_OTHER_ARGS=${TXPHYSICS_SER_OTHER_ARGS:-""}
# TXPHYSICS_SERSH_OTHER_ARGS=${TXPHYSICS_SERSH_OTHER_ARGS:-""}

# TXSSH_BLDRVERSION=${TXSSH_BLDRVERSION:-""}
# TXSSH_BUILDS=${TXSSH_BUILDS:-""}
# TXSSH_SER_OTHER_ARGS=${TXSSH_SER_OTHER_ARGS:-""}

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

# VCPTESTS_BLDRVERSION=${VCPTESTS_BLDRVERSION:-""}
# VCPTESTS_BUILDS=${VCPTESTS_BUILDS:-""}
# VCPTESTS_ALL_OTHER_ARGS=${VCPTESTS_ALL_OTHER_ARGS:-""}

# VISIT_BLDRVERSION=${VISIT_BLDRVERSION:-""}
# VISIT_BUILDS=${VISIT_BUILDS:-""}
# VISIT_PAR_OTHER_ARGS=${VISIT_PAR_OTHER_ARGS:-""}
# VISIT_SER_OTHER_ARGS=${VISIT_SER_OTHER_ARGS:-""}

# VISIT_VTK_BLDRVERSION=${VISIT_VTK_BLDRVERSION:-""}
# VISIT_VTK_BUILDS=${VISIT_VTK_BUILDS:-""}
# VISIT_VTK_SER_OTHER_ARGS=${VISIT_VTK_SER_OTHER_ARGS:-""}

# VORPAL_BLDRVERSION=${VORPAL_BLDRVERSION:-""}
# VORPAL_BUILDS=${VORPAL_BUILDS:-""}
# VORPAL_PAR_OTHER_ARGS=${VORPAL_PAR_OTHER_ARGS:-""}
# VORPAL_SER_OTHER_ARGS=${VORPAL_SER_OTHER_ARGS:-""}
# VORPAL_USERDOCSMJL_OTHER_ARGS=${VORPAL_USERDOCSMJL_OTHER_ARGS:-""}

# VORPALCOMPOSER_BLDRVERSION=${VORPALCOMPOSER_BLDRVERSION:-""}
# VORPALCOMPOSER_BUILDS=${VORPALCOMPOSER_BUILDS:-""}
# VORPALCOMPOSER_DEVELDOCS_OTHER_ARGS=${VORPALCOMPOSER_DEVELDOCS_OTHER_ARGS:-""}
# VORPALCOMPOSER_SER_OTHER_ARGS=${VORPALCOMPOSER_SER_OTHER_ARGS:-""}
# VORPALCOMPOSER_USERDOCS_OTHER_ARGS=${VORPALCOMPOSER_USERDOCS_OTHER_ARGS:-""}

# VORPALVIEW_BLDRVERSION=${VORPALVIEW_BLDRVERSION:-""}
# VORPALVIEW_BUILDS=${VORPALVIEW_BUILDS:-""}
# VORPALVIEW_SER_OTHER_ARGS=${VORPALVIEW_SER_OTHER_ARGS:-""}

# VPDOCS_BLDRVERSION=${VPDOCS_BLDRVERSION:-""}
# VPDOCS_BUILDS=${VPDOCS_BUILDS:-""}
# VPDOCS_DEVELDOCS_OTHER_ARGS=${VPDOCS_DEVELDOCS_OTHER_ARGS:-""}
# VPDOCS_USERDOCSMJW_OTHER_ARGS=${VPDOCS_USERDOCSMJW_OTHER_ARGS:-""}

# VPEXAMPLES_BLDRVERSION=${VPEXAMPLES_BLDRVERSION:-""}
# VPEXAMPLES_BUILDS=${VPEXAMPLES_BUILDS:-""}
# VPEXAMPLES_CTK_OTHER_ARGS=${VPEXAMPLES_CTK_OTHER_ARGS:-""}
# VPEXAMPLES_WEBDOCS_OTHER_ARGS=${VPEXAMPLES_WEBDOCS_OTHER_ARGS:-""}

# VPTESTS_BLDRVERSION=${VPTESTS_BLDRVERSION:-""}
# VPTESTS_BUILDS=${VPTESTS_BUILDS:-""}
# VPTESTS_ALL_OTHER_ARGS=${VPTESTS_ALL_OTHER_ARGS:-""}

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

# XERCESC_BLDRVERSION=${XERCESC_BLDRVERSION:-""}
# XERCESC_BUILDS=${XERCESC_BUILDS:-""}
# XERCESC_SER_OTHER_ARGS=${XERCESC_SER_OTHER_ARGS:-""}

# XZ_BLDRVERSION=${XZ_BLDRVERSION:-""}
# XZ_BUILDS=${XZ_BUILDS:-""}
# XZ_SER_OTHER_ARGS=${XZ_SER_OTHER_ARGS:-""}

# ZEROMQ_BLDRVERSION=${ZEROMQ_BLDRVERSION:-""}
# ZEROMQ_BUILDS=${ZEROMQ_BUILDS:-""}
# ZEROMQ_SER_OTHER_ARGS=${ZEROMQ_SER_OTHER_ARGS:-""}

# ZLIB_BLDRVERSION=${ZLIB_BLDRVERSION:-""}
# ZLIB_BUILDS=${ZLIB_BUILDS:-""}
# ZLIB_CC4PY_OTHER_ARGS=${ZLIB_CC4PY_OTHER_ARGS:-""}
# ZLIB_SER_OTHER_ARGS=${ZLIB_SER_OTHER_ARGS:-""}
# ZLIB_SERSH_OTHER_ARGS=${ZLIB_SERSH_OTHER_ARGS:-""}

