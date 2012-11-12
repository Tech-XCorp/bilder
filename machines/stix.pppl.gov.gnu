#!/bin/bash
#
# $Id: stix.pppl.gov.gnu 6264 2012-06-23 19:22:01Z cary $
#
# Define variables.
# Do not override existing definitions.
# Put any comments between the first block starting with '# KEEP THIS'
# and ending with '# END KEEP THIS'
#
######################################################################

# KEEP THIS
# stix.pppl.gov is a RHEL-5 machine.
# Packages that had to be installed:
#   matplotlib: png-devel freetype-devel
#   qt: libmng-devel libjpeg-devel glib2-devel
#       libX11-devel libXt-devel libXext-devel
#       mesa-libGL-devel mesa-libGLU-devel
#       qt-devel is needed due to build bug in qt

# END KEEP THIS

# Serial compilers
# FC should be a compiler that compiles F77 or F90 but takes free format.
# F77 should be a compiler that compiles F77 or F90 but takes fixed format.
# Typically this means that both are the F90 compiler, and they figure out the
# format from the file suffix.  The exception is the XL suite, where xlf
# compiles F77 or F90, and expects fixed format, while xlf9x ignores
# the suffix and looks for the -qfixed flag or else fails on fixed format.
CC=${CC:-"gcc4"}
CXX=${CXX:-"g++4"}
FC=${FC:-"gfortran4"}
F77=${F77:-"gfortran4"}

# PYC compilers:
# Some of the packages, in particular distutils, build with only PYC
# Python gcc compilers:
PYC_CC=${PYC_CC:-"gcc4"}
PYC_CXX=${PYC_CXX:-"g++4"}
PYC_FC=${PYC_FC:-"gfortran4"}
PYC_F77=${PYC_F77:-"gfortran4"}

# Backend compilers:
# BENCC=${BENCC:-""}
# BENCXX=${BENCXX:-""}
# BENFC=${BENFC:-""}
# BENF77=${BENF77:-""}

# Parallel compilers:
MPICC=${MPICC:-"mpicc"}
MPICXX=${MPICXX:-"mpicxx"}
MPIFC=${MPIFC:-"mpif90"}
MPIF77=${MPIF77:-"mpif90"}

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
SYSTEM_BLAS_SER_LIB=${SYSTEM_BLAS_SER_LIB:-"/usr/pppl/gcc/4.4-pkgs/acml/4.3.0/gfortran64/lib/libacml.a"}
# SYSTEM_BLAS_CC4PY_LIB=${SYSTEM_BLAS_CC4PY_LIB:-""}
# SYSTEM_BLAS_BEN_LIB=${SYSTEM_BLAS_BEN_LIB:-""}
SYSTEM_LAPACK_SER_LIB=${SYSTEM_LAPACK_SER_LIB:-"/usr/pppl/gcc/4.4-pkgs/acml/4.3.0/gfortran64/lib/libacml.a"}
# SYSTEM_LAPACK_CC4PY_LIB=${SYSTEM_LAPACK_CC4PY_LIB:-""}
# SYSTEM_LAPACK_BEN_LIB=${SYSTEM_LAPACK_BEN_LIB:-""}

# HDF5 directories:
# SYSTEM_HDF5_PAR_DIR=${SYSTEM_HDF5_PAR_DIR:-""}
# SYSTEM_HDF5_SER_DIR=${SYSTEM_HDF5_SER_DIR:-""}

# Java options
# export _JAVA_OPTIONS=
# Choose preferred buildsystem
# PREFER_CMAKE=${PREFER_CMAKE:-""}

# Variables for the packages, adios atlas autoconf automake babel bhssolver boost cfitsio cheflibs chombo chompst chrpath clapack_cmake cmake composertoolkit corrcalc ctktests cuda cython dakota ddsflow doxygen eqcodes facetscomposer facetsifc facets fciowrappers fctests fftw3 fftw fgtests fluxgrid fmcfmgacode fmcfm fmtests forthon gacode ga_transport genray gpulib gsl gtest hdf5 imaging ips jsmath lapack libpng libtool linalg lpsolve m4 mako mathjax matplotlib mesa metatau muparser mxml nautilusCMake nautiluscomposer nautilus netcdf netlib_lite nimrod nimtests ntcc_transport nttests nubeam numexpr numpy openmpi petsc plasma_state polyswiftcomposer polyswift pspline pstests pygments pyqt python qhull qscintilla qt quids scipy setuptools shtool simd simplejson simyan sip slepc sphinx sundials swig swimgui synergia2 tables thrust toric transpbase transpgraphics transpnumeric trilinos txbase txbtests txgeom txphysics uedge uetests valgrind visit vorpalcomposer vorpal vpexamples vptests vtk wallpsi wallpsitests zlib.
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
# ATLAS_BUILDS=${ATLAS_BUILDS:-""}
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
# BABEL_BUILDS=${BABEL_BUILDS:-""}
# BABEL_SHARED_OTHER_ARGS=${BABEL_SHARED_OTHER_ARGS:-""}
# BABEL_STATIC_OTHER_ARGS=${BABEL_STATIC_OTHER_ARGS:-""}

# BHSSOLVER_BLDRVERSION=${BHSSOLVER_BLDRVERSION:-""}
# BHSSOLVER_BUILDS=${BHSSOLVER_BUILDS:-""}
# BHSSOLVER_BEN_OTHER_ARGS=${BHSSOLVER_BEN_OTHER_ARGS:-""}
# BHSSOLVER_SER_OTHER_ARGS=${BHSSOLVER_SER_OTHER_ARGS:-""}

# BOOST_BLDRVERSION=${BOOST_BLDRVERSION:-""}
# BOOST_BUILDS=${BOOST_BUILDS:-""}
# BOOST_SER_OTHER_ARGS=${BOOST_SER_OTHER_ARGS:-""}

# CFITSIO_BLDRVERSION=${CFITSIO_BLDRVERSION:-""}
# CFITSIO_BUILDS=${CFITSIO_BUILDS:-""}
# CFITSIO_SER_OTHER_ARGS=${CFITSIO_SER_OTHER_ARGS:-""}

# CHOMBO_BLDRVERSION=${CHOMBO_BLDRVERSION:-""}
# CHOMBO_BUILDS=${CHOMBO_BUILDS:-""}
# CHOMBO_$BLDTYPE_OTHER_ARGS=${CHOMBO_$BLDTYPE_OTHER_ARGS:-""}

# CHOMPST_BLDRVERSION=${CHOMPST_BLDRVERSION:-""}
# CHOMPST_BUILDS=${CHOMPST_BUILDS:-""}
# CHOMPST_PAR2D_OTHER_ARGS=${CHOMPST_PAR2D_OTHER_ARGS:-""}
# CHOMPST_PAR3D_OTHER_ARGS=${CHOMPST_PAR3D_OTHER_ARGS:-""}
# CHOMPST_PAR3D_DEBUG_OTHER_ARGS=${CHOMPST_PAR3D_DEBUG_OTHER_ARGS:-""}
# CHOMPST_SER2D_OTHER_ARGS=${CHOMPST_SER2D_OTHER_ARGS:-""}
# CHOMPST_SER2D_DEBUG_OTHER_ARGS=${CHOMPST_SER2D_DEBUG_OTHER_ARGS:-""}
# CHOMPST_SER3D_OTHER_ARGS=${CHOMPST_SER3D_OTHER_ARGS:-""}

# CHRPATH_BLDRVERSION=${CHRPATH_BLDRVERSION:-""}
# CHRPATH_BUILDS=${CHRPATH_BUILDS:-""}
# CHRPATH_SER_OTHER_ARGS=${CHRPATH_SER_OTHER_ARGS:-""}

# CLAPACK_CMAKE_BLDRVERSION=${CLAPACK_CMAKE_BLDRVERSION:-""}
# CLAPACK_CMAKE_BUILDS=${CLAPACK_CMAKE_BUILDS:-""}
# CLAPACK_CMAKE_CC4PY_OTHER_ARGS=${CLAPACK_CMAKE_CC4PY_OTHER_ARGS:-""}
# CLAPACK_CMAKE_SER_OTHER_ARGS=${CLAPACK_CMAKE_SER_OTHER_ARGS:-""}

# CMAKE_BLDRVERSION=${CMAKE_BLDRVERSION:-""}
# CMAKE_BUILDS=${CMAKE_BUILDS:-""}
# CMAKE_SER_OTHER_ARGS=${CMAKE_SER_OTHER_ARGS:-""}

# COMPOSERTOOLKIT_BLDRVERSION=${COMPOSERTOOLKIT_BLDRVERSION:-""}
# COMPOSERTOOLKIT_BUILDS=${COMPOSERTOOLKIT_BUILDS:-""}
# COMPOSERTOOLKIT_NOVISIT_OTHER_ARGS=${COMPOSERTOOLKIT_NOVISIT_OTHER_ARGS:-""}
# COMPOSERTOOLKIT_VISIT_OTHER_ARGS=${COMPOSERTOOLKIT_VISIT_OTHER_ARGS:-""}
# COMPOSERTOOLKIT_WEBDOCS_OTHER_ARGS=${COMPOSERTOOLKIT_WEBDOCS_OTHER_ARGS:-""}

# CORRCALC_BLDRVERSION=${CORRCALC_BLDRVERSION:-""}
# CORRCALC_BUILDS=${CORRCALC_BUILDS:-""}
# CORRCALC_PAR_OTHER_ARGS=${CORRCALC_PAR_OTHER_ARGS:-""}
# CORRCALC_SER_OTHER_ARGS=${CORRCALC_SER_OTHER_ARGS:-""}

# CTKTESTS_BLDRVERSION=${CTKTESTS_BLDRVERSION:-""}
# CTKTESTS_BUILDS=${CTKTESTS_BUILDS:-""}
# CTKTESTS_ALL_OTHER_ARGS=${CTKTESTS_ALL_OTHER_ARGS:-""}

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

# DOXYGEN_BLDRVERSION=${DOXYGEN_BLDRVERSION:-""}
# DOXYGEN_BUILDS=${DOXYGEN_BUILDS:-""}
# DOXYGEN_SER_OTHER_ARGS=${DOXYGEN_SER_OTHER_ARGS:-""}

# EQCODES_BLDRVERSION=${EQCODES_BLDRVERSION:-""}
# EQCODES_BUILDS=${EQCODES_BUILDS:-""}
# EQCODES_BEN_OTHER_ARGS=${EQCODES_BEN_OTHER_ARGS:-""}
# EQCODES_SER_OTHER_ARGS=${EQCODES_SER_OTHER_ARGS:-""}

# FACETSCOMPOSER_BLDRVERSION=${FACETSCOMPOSER_BLDRVERSION:-""}
# FACETSCOMPOSER_BUILDS=${FACETSCOMPOSER_BUILDS:-""}
# FACETSCOMPOSER_SER_OTHER_ARGS=${FACETSCOMPOSER_SER_OTHER_ARGS:-""}

# FACETSIFC_BLDRVERSION=${FACETSIFC_BLDRVERSION:-""}
# FACETSIFC_BUILDS=${FACETSIFC_BUILDS:-""}
# FACETSIFC_SER_OTHER_ARGS=${FACETSIFC_SER_OTHER_ARGS:-""}

# FACETS_BLDRVERSION=${FACETS_BLDRVERSION:-""}
# FACETS_BUILDS=${FACETS_BUILDS:-""}
# FACETS_PAR_OTHER_ARGS=${FACETS_PAR_OTHER_ARGS:-""}
# FACETS_PARTAU_OTHER_ARGS=${FACETS_PARTAU_OTHER_ARGS:-""}
# FACETS_SER_OTHER_ARGS=${FACETS_SER_OTHER_ARGS:-""}
# FACETS_WEBDOCS_OTHER_ARGS=${FACETS_WEBDOCS_OTHER_ARGS:-""}

# FCIOWRAPPERS_BLDRVERSION=${FCIOWRAPPERS_BLDRVERSION:-""}
# FCIOWRAPPERS_BUILDS=${FCIOWRAPPERS_BUILDS:-""}
# FCIOWRAPPERS_PAR_OTHER_ARGS=${FCIOWRAPPERS_PAR_OTHER_ARGS:-""}
# FCIOWRAPPERS_SER_OTHER_ARGS=${FCIOWRAPPERS_SER_OTHER_ARGS:-""}

# FCTESTS_BLDRVERSION=${FCTESTS_BLDRVERSION:-""}
# FCTESTS_BUILDS=${FCTESTS_BUILDS:-""}
# FCTESTS_ALL_OTHER_ARGS=${FCTESTS_ALL_OTHER_ARGS:-""}

# FFTW3_BLDRVERSION=${FFTW3_BLDRVERSION:-""}
# FFTW3_BUILDS=${FFTW3_BUILDS:-""}
# FFTW3_BEN_OTHER_ARGS=${FFTW3_BEN_OTHER_ARGS:-""}
# FFTW3_PAR_OTHER_ARGS=${FFTW3_PAR_OTHER_ARGS:-""}
# FFTW3_SER_OTHER_ARGS=${FFTW3_SER_OTHER_ARGS:-""}

# FFTW_BLDRVERSION=${FFTW_BLDRVERSION:-""}
# FFTW_BUILDS=${FFTW_BUILDS:-""}
# FFTW_BEN_OTHER_ARGS=${FFTW_BEN_OTHER_ARGS:-""}
# FFTW_PAR_OTHER_ARGS=${FFTW_PAR_OTHER_ARGS:-""}
# FFTW_SER_OTHER_ARGS=${FFTW_SER_OTHER_ARGS:-""}

# FGTESTS_BLDRVERSION=${FGTESTS_BLDRVERSION:-""}
# FGTESTS_BUILDS=${FGTESTS_BUILDS:-""}
# FGTESTS_ALL_OTHER_ARGS=${FGTESTS_ALL_OTHER_ARGS:-""}

# FLUXGRID_BLDRVERSION=${FLUXGRID_BLDRVERSION:-""}
# FLUXGRID_BUILDS=${FLUXGRID_BUILDS:-""}
# FLUXGRID_SER_OTHER_ARGS=${FLUXGRID_SER_OTHER_ARGS:-""}

# FMCFMGACODE_BLDRVERSION=${FMCFMGACODE_BLDRVERSION:-""}
# FMCFMGACODE_BUILDS=${FMCFMGACODE_BUILDS:-""}
# FMCFMGACODE_PAR_OTHER_ARGS=${FMCFMGACODE_PAR_OTHER_ARGS:-""}
# FMCFMGACODE_SER_OTHER_ARGS=${FMCFMGACODE_SER_OTHER_ARGS:-""}
# FMCFMGACODE_WEBDOCS_OTHER_ARGS=${FMCFMGACODE_WEBDOCS_OTHER_ARGS:-""}

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

# GACODE_BLDRVERSION=${GACODE_BLDRVERSION:-""}
# GACODE_BUILDS=${GACODE_BUILDS:-""}
# GACODE_PAR_OTHER_ARGS=${GACODE_PAR_OTHER_ARGS:-""}
# GACODE_SER_OTHER_ARGS=${GACODE_SER_OTHER_ARGS:-""}

# GA_TRANSPORT_BLDRVERSION=${GA_TRANSPORT_BLDRVERSION:-""}
# GA_TRANSPORT_BUILDS=${GA_TRANSPORT_BUILDS:-""}
# GA_TRANSPORT_PAR_OTHER_ARGS=${GA_TRANSPORT_PAR_OTHER_ARGS:-""}
# GA_TRANSPORT_SER_OTHER_ARGS=${GA_TRANSPORT_SER_OTHER_ARGS:-""}

# GENRAY_BLDRVERSION=${GENRAY_BLDRVERSION:-""}
# GENRAY_BUILDS=${GENRAY_BUILDS:-""}
# GENRAY_PAR_OTHER_ARGS=${GENRAY_PAR_OTHER_ARGS:-""}
# GENRAY_SER_OTHER_ARGS=${GENRAY_SER_OTHER_ARGS:-""}

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
# HDF5_CC4PY_OTHER_ARGS=${HDF5_CC4PY_OTHER_ARGS:-""}
# HDF5_PAR_OTHER_ARGS=${HDF5_PAR_OTHER_ARGS:-""}
# HDF5_PARSH_OTHER_ARGS=${HDF5_PARSH_OTHER_ARGS:-""}
# HDF5_SER_OTHER_ARGS=${HDF5_SER_OTHER_ARGS:-""}
# HDF5_SERSH_OTHER_ARGS=${HDF5_SERSH_OTHER_ARGS:-""}

# IMAGING_BLDRVERSION=${IMAGING_BLDRVERSION:-""}
# IMAGING_BUILDS=${IMAGING_BUILDS:-""}
# IMAGING_CC4PY_OTHER_ARGS=${IMAGING_CC4PY_OTHER_ARGS:-""}

# IPS_BLDRVERSION=${IPS_BLDRVERSION:-""}
# IPS_BUILDS=${IPS_BUILDS:-""}
# IPS_PAR_OTHER_ARGS=${IPS_PAR_OTHER_ARGS:-""}
# IPS_SER_OTHER_ARGS=${IPS_SER_OTHER_ARGS:-""}

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
# LIBPNG_SER_OTHER_ARGS=${LIBPNG_SER_OTHER_ARGS:-""}
# LIBPNG_SERSH_OTHER_ARGS=${LIBPNG_SERSH_OTHER_ARGS:-""}

# LIBTOOL_BLDRVERSION=${LIBTOOL_BLDRVERSION:-""}
# LIBTOOL_BUILDS=${LIBTOOL_BUILDS:-""}
# LIBTOOL_SER_OTHER_ARGS=${LIBTOOL_SER_OTHER_ARGS:-""}

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
# MESA_BUILDS=${MESA_BUILDS:-""}
# MESA_MGL_OTHER_ARGS=${MESA_MGL_OTHER_ARGS:-""}
# MESA_OS_OTHER_ARGS=${MESA_OS_OTHER_ARGS:-""}

# METATAU_BLDRVERSION=${METATAU_BLDRVERSION:-""}
# METATAU_BUILDS=${METATAU_BUILDS:-""}
METATAU_PAR_OTHER_ARGS=${METATAU_PAR_OTHER_ARGS:-"-cc=gcc4 -c++=g++4 -fortran=gfortran4 -pdt_c++=g++4"}

# MUPARSER_BLDRVERSION=${MUPARSER_BLDRVERSION:-""}
# MUPARSER_BUILDS=${MUPARSER_BUILDS:-""}
# MUPARSER_SER_OTHER_ARGS=${MUPARSER_SER_OTHER_ARGS:-""}
# MUPARSER_SERSH_OTHER_ARGS=${MUPARSER_SERSH_OTHER_ARGS:-""}

# MXML_BLDRVERSION=${MXML_BLDRVERSION:-""}
# MXML_BUILDS=${MXML_BUILDS:-""}
# MXML_SER_OTHER_ARGS=${MXML_SER_OTHER_ARGS:-""}

# NAUTILUSCOMPOSER_BLDRVERSION=${NAUTILUSCOMPOSER_BLDRVERSION:-""}
# NAUTILUSCOMPOSER_BUILDS=${NAUTILUSCOMPOSER_BUILDS:-""}
# NAUTILUSCOMPOSER_SER_OTHER_ARGS=${NAUTILUSCOMPOSER_SER_OTHER_ARGS:-""}

# NAUTILUS_BLDRVERSION=${NAUTILUS_BLDRVERSION:-""}
# NAUTILUS_BUILDS=${NAUTILUS_BUILDS:-""}
# NAUTILUS_PAR_OTHER_ARGS=${NAUTILUS_PAR_OTHER_ARGS:-""}
# NAUTILUS_SER_OTHER_ARGS=${NAUTILUS_SER_OTHER_ARGS:-""}
# NAUTILUS_WEBDOCS_OTHER_ARGS=${NAUTILUS_WEBDOCS_OTHER_ARGS:-""}

# NETCDF_BLDRVERSION=${NETCDF_BLDRVERSION:-""}
# NETCDF_BUILDS=${NETCDF_BUILDS:-""}
# NETCDF_BEN_OTHER_ARGS=${NETCDF_BEN_OTHER_ARGS:-""}
# NETCDF_PAR_OTHER_ARGS=${NETCDF_PAR_OTHER_ARGS:-""}
# NETCDF_SER_OTHER_ARGS=${NETCDF_SER_OTHER_ARGS:-""}

# NETLIB_LITE_BLDRVERSION=${NETLIB_LITE_BLDRVERSION:-""}
# NETLIB_LITE_BUILDS=${NETLIB_LITE_BUILDS:-""}
# NETLIB_LITE_BEN_OTHER_ARGS=${NETLIB_LITE_BEN_OTHER_ARGS:-""}
# NETLIB_LITE_SER_OTHER_ARGS=${NETLIB_LITE_SER_OTHER_ARGS:-""}

# NIMROD_BLDRVERSION=${NIMROD_BLDRVERSION:-""}
# NIMROD_BUILDS=${NIMROD_BUILDS:-""}
# NIMROD_CURRENTBUILD_OTHER_ARGS=${NIMROD_CURRENTBUILD_OTHER_ARGS:-""}
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
# NTCC_TRANSPORT_BUILDS=${NTCC_TRANSPORT_BUILDS:-""}
# NTCC_TRANSPORT_PAR_OTHER_ARGS=${NTCC_TRANSPORT_PAR_OTHER_ARGS:-""}
# NTCC_TRANSPORT_SER_OTHER_ARGS=${NTCC_TRANSPORT_SER_OTHER_ARGS:-""}

# NTTESTS_BLDRVERSION=${NTTESTS_BLDRVERSION:-""}
# NTTESTS_BUILDS=${NTTESTS_BUILDS:-""}
# NTTESTS_ALL_OTHER_ARGS=${NTTESTS_ALL_OTHER_ARGS:-""}

# NUBEAM_BLDRVERSION=${NUBEAM_BLDRVERSION:-""}
# NUBEAM_BUILDS=${NUBEAM_BUILDS:-""}
# NUBEAM_PAR_OTHER_ARGS=${NUBEAM_PAR_OTHER_ARGS:-""}
# NUBEAM_SER_OTHER_ARGS=${NUBEAM_SER_OTHER_ARGS:-""}

# NUMEXPR_BLDRVERSION=${NUMEXPR_BLDRVERSION:-""}
# NUMEXPR_BUILDS=${NUMEXPR_BUILDS:-""}
# NUMEXPR_CC4PY_OTHER_ARGS=${NUMEXPR_CC4PY_OTHER_ARGS:-""}

# NUMPY_BLDRVERSION=${NUMPY_BLDRVERSION:-""}
# NUMPY_BUILDS=${NUMPY_BUILDS:-""}
# NUMPY_CC4PY_OTHER_ARGS=${NUMPY_CC4PY_OTHER_ARGS:-""}

# OPENMPI_BLDRVERSION=${OPENMPI_BLDRVERSION:-""}
# OPENMPI_BUILDS=${OPENMPI_BUILDS:-""}
# OPENMPI_NODL_OTHER_ARGS=${OPENMPI_NODL_OTHER_ARGS:-""}
# OPENMPI_STATIC_OTHER_ARGS=${OPENMPI_STATIC_OTHER_ARGS:-""}

# PETSC_BLDRVERSION=${PETSC_BLDRVERSION:-""}
# PETSC_BUILDS=${PETSC_BUILDS:-""}
# PETSC_PAR_OTHER_ARGS=${PETSC_PAR_OTHER_ARGS:-""}
# PETSC_PARDBG_OTHER_ARGS=${PETSC_PARDBG_OTHER_ARGS:-""}
# PETSC_SER_OTHER_ARGS=${PETSC_SER_OTHER_ARGS:-""}

# PLASMA_STATE_BLDRVERSION=${PLASMA_STATE_BLDRVERSION:-""}
# PLASMA_STATE_BUILDS=${PLASMA_STATE_BUILDS:-""}
# PLASMA_STATE_BEN_OTHER_ARGS=${PLASMA_STATE_BEN_OTHER_ARGS:-""}
# PLASMA_STATE_SER_OTHER_ARGS=${PLASMA_STATE_SER_OTHER_ARGS:-""}

# POLYSWIFTCOMPOSER_BLDRVERSION=${POLYSWIFTCOMPOSER_BLDRVERSION:-""}
# POLYSWIFTCOMPOSER_BUILDS=${POLYSWIFTCOMPOSER_BUILDS:-""}
# POLYSWIFTCOMPOSER_SER_OTHER_ARGS=${POLYSWIFTCOMPOSER_SER_OTHER_ARGS:-""}

# POLYSWIFT_BLDRVERSION=${POLYSWIFT_BLDRVERSION:-""}
# POLYSWIFT_BUILDS=${POLYSWIFT_BUILDS:-""}
# POLYSWIFT_PAR_OTHER_ARGS=${POLYSWIFT_PAR_OTHER_ARGS:-""}
# POLYSWIFT_SER_OTHER_ARGS=${POLYSWIFT_SER_OTHER_ARGS:-""}
# POLYSWIFT_WEBDOCS_OTHER_ARGS=${POLYSWIFT_WEBDOCS_OTHER_ARGS:-""}

# PSPLINE_BLDRVERSION=${PSPLINE_BLDRVERSION:-""}
# PSPLINE_BUILDS=${PSPLINE_BUILDS:-""}
# PSPLINE_BEN_OTHER_ARGS=${PSPLINE_BEN_OTHER_ARGS:-""}
# PSPLINE_SER_OTHER_ARGS=${PSPLINE_SER_OTHER_ARGS:-""}

# PSTESTS_BLDRVERSION=${PSTESTS_BLDRVERSION:-""}
# PSTESTS_BUILDS=${PSTESTS_BUILDS:-""}
# PSTESTS_ALL_OTHER_ARGS=${PSTESTS_ALL_OTHER_ARGS:-""}

# PYGMENTS_BLDRVERSION=${PYGMENTS_BLDRVERSION:-""}
# PYGMENTS_BUILDS=${PYGMENTS_BUILDS:-""}
# PYGMENTS_CC4PY_OTHER_ARGS=${PYGMENTS_CC4PY_OTHER_ARGS:-""}

# PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-""}
# PYQT_BUILDS=${PYQT_BUILDS:-""}
# PYQT_CC4PY_OTHER_ARGS=${PYQT_CC4PY_OTHER_ARGS:-""}

# PYTHON_BLDRVERSION=${PYTHON_BLDRVERSION:-""}
# PYTHON_BUILDS=${PYTHON_BUILDS:-""}
# PYTHON_CC4PY_OTHER_ARGS=${PYTHON_CC4PY_OTHER_ARGS:-""}

# QHULL_BLDRVERSION=${QHULL_BLDRVERSION:-""}
# QHULL_BUILDS=${QHULL_BUILDS:-""}
# QHULL_SER_OTHER_ARGS=${QHULL_SER_OTHER_ARGS:-""}

# QSCINTILLA_BLDRVERSION=${QSCINTILLA_BLDRVERSION:-""}
# QSCINTILLA_BUILDS=${QSCINTILLA_BUILDS:-""}
# QSCINTILLA_SER_OTHER_ARGS=${QSCINTILLA_SER_OTHER_ARGS:-""}

# QT_BLDRVERSION=${QT_BLDRVERSION:-""}
# QT_BUILDS=${QT_BUILDS:-""}
# QT_SER_OTHER_ARGS=${QT_SER_OTHER_ARGS:-""}

# QUIDS_BLDRVERSION=${QUIDS_BLDRVERSION:-""}
# QUIDS_BUILDS=${QUIDS_BUILDS:-""}
# QUIDS_SER_OTHER_ARGS=${QUIDS_SER_OTHER_ARGS:-""}

# SCIPY_BLDRVERSION=${SCIPY_BLDRVERSION:-""}
# SCIPY_BUILDS=${SCIPY_BUILDS:-""}
# SCIPY_CC4PY_OTHER_ARGS=${SCIPY_CC4PY_OTHER_ARGS:-""}

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
# SLEPC_PARDBG_OTHER_ARGS=${SLEPC_PARDBG_OTHER_ARGS:-""}
# SLEPC_SER_OTHER_ARGS=${SLEPC_SER_OTHER_ARGS:-""}

# SPHINX_BLDRVERSION=${SPHINX_BLDRVERSION:-""}
# SPHINX_BUILDS=${SPHINX_BUILDS:-""}
# SPHINX_CC4PY_OTHER_ARGS=${SPHINX_CC4PY_OTHER_ARGS:-""}

# SUNDIALS_BLDRVERSION=${SUNDIALS_BLDRVERSION:-""}
# SUNDIALS_BUILDS=${SUNDIALS_BUILDS:-""}
# SUNDIALS_BEN_OTHER_ARGS=${SUNDIALS_BEN_OTHER_ARGS:-""}
# SUNDIALS_PAR_OTHER_ARGS=${SUNDIALS_PAR_OTHER_ARGS:-""}
# SUNDIALS_SER_OTHER_ARGS=${SUNDIALS_SER_OTHER_ARGS:-""}

# SWIG_BLDRVERSION=${SWIG_BLDRVERSION:-""}
# SWIG_BUILDS=${SWIG_BUILDS:-""}
# SWIG_SER_OTHER_ARGS=${SWIG_SER_OTHER_ARGS:-""}

# SWIMGUI_BLDRVERSION=${SWIMGUI_BLDRVERSION:-""}
# SWIMGUI_BUILDS=${SWIMGUI_BUILDS:-""}
# SWIMGUI_SER_OTHER_ARGS=${SWIMGUI_SER_OTHER_ARGS:-""}

# SYNERGIA2_BLDRVERSION=${SYNERGIA2_BLDRVERSION:-""}
# SYNERGIA2_BUILDS=${SYNERGIA2_BUILDS:-""}
# SYNERGIA2_$BLD_OTHER_ARGS=${SYNERGIA2_$BLD_OTHER_ARGS:-""}
# SYNERGIA2_${BLD}_OTHER_ARGS=${SYNERGIA2_${BLD}_OTHER_ARGS:-""}

TABLES_BLDRVERSION=${TABLES_BLDRVERSION:-"2.1.2"}
# TABLES_BUILDS=${TABLES_BUILDS:-""}
# TABLES_CC4PY_OTHER_ARGS=${TABLES_CC4PY_OTHER_ARGS:-""}

# THRUST_BLDRVERSION=${THRUST_BLDRVERSION:-""}
# THRUST_BUILDS=${THRUST_BUILDS:-""}
# THRUST_SER_OTHER_ARGS=${THRUST_SER_OTHER_ARGS:-""}

# TORIC_BLDRVERSION=${TORIC_BLDRVERSION:-""}
# TORIC_BUILDS=${TORIC_BUILDS:-""}
# TORIC_PAR_OTHER_ARGS=${TORIC_PAR_OTHER_ARGS:-""}
# TORIC_SER_OTHER_ARGS=${TORIC_SER_OTHER_ARGS:-""}

# TRANSPBASE_BLDRVERSION=${TRANSPBASE_BLDRVERSION:-""}
# TRANSPBASE_BUILDS=${TRANSPBASE_BUILDS:-""}
# TRANSPBASE_BEN_OTHER_ARGS=${TRANSPBASE_BEN_OTHER_ARGS:-""}
# TRANSPBASE_PAR_OTHER_ARGS=${TRANSPBASE_PAR_OTHER_ARGS:-""}
# TRANSPBASE_SER_OTHER_ARGS=${TRANSPBASE_SER_OTHER_ARGS:-""}

# TRANSPGRAPHICS_BLDRVERSION=${TRANSPGRAPHICS_BLDRVERSION:-""}
# TRANSPGRAPHICS_BUILDS=${TRANSPGRAPHICS_BUILDS:-""}
# TRANSPGRAPHICS_BEN_OTHER_ARGS=${TRANSPGRAPHICS_BEN_OTHER_ARGS:-""}
# TRANSPGRAPHICS_SER_OTHER_ARGS=${TRANSPGRAPHICS_SER_OTHER_ARGS:-""}

# TRANSPNUMERIC_BLDRVERSION=${TRANSPNUMERIC_BLDRVERSION:-""}
# TRANSPNUMERIC_BUILDS=${TRANSPNUMERIC_BUILDS:-""}
# TRANSPNUMERIC_BEN_OTHER_ARGS=${TRANSPNUMERIC_BEN_OTHER_ARGS:-""}
# TRANSPNUMERIC_SER_OTHER_ARGS=${TRANSPNUMERIC_SER_OTHER_ARGS:-""}

# TRILINOS_BLDRVERSION=${TRILINOS_BLDRVERSION:-""}
# TRILINOS_BUILDS=${TRILINOS_BUILDS:-""}
# TRILINOS_PAR_OTHER_ARGS=${TRILINOS_PAR_OTHER_ARGS:-""}
# TRILINOS_PARSH_OTHER_ARGS=${TRILINOS_PARSH_OTHER_ARGS:-""}
# TRILINOS_SER_OTHER_ARGS=${TRILINOS_SER_OTHER_ARGS:-""}
# TRILINOS_SERSH_OTHER_ARGS=${TRILINOS_SERSH_OTHER_ARGS:-""}

# TXBASE_BLDRVERSION=${TXBASE_BLDRVERSION:-""}
# TXBASE_BUILDS=${TXBASE_BUILDS:-""}
# TXBASE_CC4PY_OTHER_ARGS=${TXBASE_CC4PY_OTHER_ARGS:-""}
# TXBASE_PAR_OTHER_ARGS=${TXBASE_PAR_OTHER_ARGS:-""}
# TXBASE_SER_OTHER_ARGS=${TXBASE_SER_OTHER_ARGS:-""}

# TXBTESTS_BLDRVERSION=${TXBTESTS_BLDRVERSION:-""}
# TXBTESTS_BUILDS=${TXBTESTS_BUILDS:-""}
# TXBTESTS_ALL_OTHER_ARGS=${TXBTESTS_ALL_OTHER_ARGS:-""}

# TXGEOM_BLDRVERSION=${TXGEOM_BLDRVERSION:-""}
# TXGEOM_BUILDS=${TXGEOM_BUILDS:-""}
# TXGEOM_PAR_OTHER_ARGS=${TXGEOM_PAR_OTHER_ARGS:-""}
# TXGEOM_SER_OTHER_ARGS=${TXGEOM_SER_OTHER_ARGS:-""}

# TXPHYSICS_BLDRVERSION=${TXPHYSICS_BLDRVERSION:-""}
# TXPHYSICS_BUILDS=${TXPHYSICS_BUILDS:-""}
# TXPHYSICS_BEN_OTHER_ARGS=${TXPHYSICS_BEN_OTHER_ARGS:-""}
# TXPHYSICS_SER_OTHER_ARGS=${TXPHYSICS_SER_OTHER_ARGS:-""}
# TXPHYSICS_SERSH_OTHER_ARGS=${TXPHYSICS_SERSH_OTHER_ARGS:-""}

# UEDGE_BLDRVERSION=${UEDGE_BLDRVERSION:-""}
# UEDGE_BUILDS=${UEDGE_BUILDS:-""}
# UEDGE_NOPETSC_OTHER_ARGS=${UEDGE_NOPETSC_OTHER_ARGS:-""}
# UEDGE_PAR_OTHER_ARGS=${UEDGE_PAR_OTHER_ARGS:-""}
# UEDGE_PARTAU_OTHER_ARGS=${UEDGE_PARTAU_OTHER_ARGS:-""}
# UEDGE_SER_OTHER_ARGS=${UEDGE_SER_OTHER_ARGS:-""}

# UETESTS_BLDRVERSION=${UETESTS_BLDRVERSION:-""}
# UETESTS_BUILDS=${UETESTS_BUILDS:-""}
# UETESTS_ALL_OTHER_ARGS=${UETESTS_ALL_OTHER_ARGS:-""}

# VALGRIND_BLDRVERSION=${VALGRIND_BLDRVERSION:-""}
# VALGRIND_BUILDS=${VALGRIND_BUILDS:-""}
# VALGRIND_SER_OTHER_ARGS=${VALGRIND_SER_OTHER_ARGS:-""}

# VISIT_BLDRVERSION=${VISIT_BLDRVERSION:-""}
# VISIT_BUILDS=${VISIT_BUILDS:-""}
# VISIT_PAR_OTHER_ARGS=${VISIT_PAR_OTHER_ARGS:-""}
# VISIT_SER_OTHER_ARGS=${VISIT_SER_OTHER_ARGS:-""}

# VORPALCOMPOSER_BLDRVERSION=${VORPALCOMPOSER_BLDRVERSION:-""}
# VORPALCOMPOSER_BUILDS=${VORPALCOMPOSER_BUILDS:-""}
# VORPALCOMPOSER_SER_OTHER_ARGS=${VORPALCOMPOSER_SER_OTHER_ARGS:-""}
# VORPALCOMPOSER_WEBDOCS_OTHER_ARGS=${VORPALCOMPOSER_WEBDOCS_OTHER_ARGS:-""}

# VORPAL_BLDRVERSION=${VORPAL_BLDRVERSION:-""}
# VORPAL_BUILDS=${VORPAL_BUILDS:-""}
# VORPAL_PAR_OTHER_ARGS=${VORPAL_PAR_OTHER_ARGS:-""}
# VORPAL_SER_OTHER_ARGS=${VORPAL_SER_OTHER_ARGS:-""}
# VORPAL_WEBDOCS_OTHER_ARGS=${VORPAL_WEBDOCS_OTHER_ARGS:-""}

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

# ZLIB_BLDRVERSION=${ZLIB_BLDRVERSION:-""}
# ZLIB_BUILDS=${ZLIB_BUILDS:-""}
# ZLIB_CC4PY_OTHER_ARGS=${ZLIB_CC4PY_OTHER_ARGS:-""}
# ZLIB_SER_OTHER_ARGS=${ZLIB_SER_OTHER_ARGS:-""}
# ZLIB_SERSH_OTHER_ARGS=${ZLIB_SERSH_OTHER_ARGS:-""}

