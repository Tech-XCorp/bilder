#!/bin/bash
#
# Version and build information for dakota
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################
DAKOTA_BLDRVERSION=${DAKOTA_BLDRVERSION:-"5.3.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

DAKOTA_BUILDS=${DAKOTA_BUILDS:-"ser,par"}

# Dependency notes:
#   1. trilinos external is not needed. Dakota uses
#      an internal version of trilinos code.
#   2. On Darwin lapack build is skipped because system lapack/blas is used.
#   3. boostdevel used for pure boost builds with all enabled including MPI
#      Default boost can be used for Dakota
DAKOTA_DEPS=lapack,boost,openmpi,cmake
addtopathvar PATH $CONTRIB_DIR/dakota/bin

######################################################################
#
# Common arguments to find stuff or to simplify the builds
# See notes at the end
#
######################################################################

# System boost is breaking Peregrine build and we are always using bldr boost
# so system boost is explicitly turned off.
# Graphics off for now until tested on all platforms
# Shared version of boost needed for Peregrine. Shared boost for Mac but not needed

DAKOTA_ADDL_ARGS="-DHAVE_X_GRAPHICS:BOOL=FALSE \
                  -DBoost_NO_SYSTEM_PATHS:BOOL=TRUE \
                  -DBOOST_ROOT:PATH=$CONTRIB_DIR/boost-sersh"

techo " "
techo "Setting MPI_LIBRARY explicitly to openmpi"
techo " "

case `uname` in
    CYGWIN* | Darwin)
	DAKOTA_PAR_OTHER_ARGS="-DMPI_INCLUDE_PATH:PATH=$CONTRIB_DIR/openmpi/include \
                               -DMPI_LIBRARY:FILEPATH=$CONTRIB_DIR/openmpi/lib/libmpi_cxx.dylib"
	;;
    Linux)
        # On all but Mac need to find bilder versions of shared lapack builds
	DAKOTA_ADDL_ARGS="-DBLAS_LIBS:FILEPATH='$CONTRIB_DIR/lapack-sersh/lib/libblas.so' \
                          -DLAPACK_LIBS:FILEPATH='$CONTRIB_DIR/lapack-sersh/lib/liblapack.so' \
                          $DAKOTA_ADDL_ARGS"
        DAKOTA_PAR_OTHER_ARGS="-DMPI_INCLUDE_PATH:PATH=$CONTRIB_DIR/openmpi/include \
                               -DMPI_LIBRARY:FILEPATH=$CONTRIB_DIR/openmpi/lib/libmpi_cxx.a"

	DOMAIN_NAME=`hostname -d`
	case $DOMAIN_NAME in
	    hpc.nrel.gov )
		echo "Assuming Peregrine"
                # OPENMPIROOT should be set my module (intel too?)
		DAKOTA_PAR_OTHER_ARGS="-DMPI_INCLUDE_PATH:PATH=$OPENMPIROOT/include \
                                       -DMPI_LIBRARY:FILEPATH=$OPENMPIROOT/lib/libmpi_cxx.a"
	esac
	;;
esac

######################################################################
#
# Launch dakota builds.
#
######################################################################
buildDakota() {

  if bilderUnpack dakota; then

    # Serial build
    if bilderConfig -c dakota ser "-DDAKOTA_HAVE_MPI:BOOL=FALSE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $DAKOTA_ADDL_ARGS $DAKOTA_SER_OTHER_ARGS"; then
      bilderBuild dakota ser "$DAKOTA_MAKEJ_ARGS"
    fi

    # Parallel build
    if bilderConfig -c dakota par "-DDAKOTA_HAVE_MPI:BOOL=TRUE  $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $DAKOTA_ADDL_ARGS $DAKOTA_PAR_OTHER_ARGS"; then
      bilderBuild dakota par "$DAKOTA_MAKEJ_ARGS"
    fi

  fi
}

######################################################################
#
# Test dakota
#
######################################################################

testDakota() {
  techo "Not testing dakota."
}

######################################################################
#
# Install dakota
#
######################################################################

installDakota() {
  bilderInstall dakota ser dakota-ser
  bilderInstall dakota par dakota-par
}


######################################################################
#
# Stuff from configure --help
#
######################################################################

#  --with-blas=<lib>       use BLAS library <lib>
#  --with-lapack=<lib>     use LAPACK library <lib>
#  --with-libcurl=DIR      look for the curl library in DIR
#  --with-modelcenter      turn MODELCENTER support on
#  --with-plugin           turn PLUGIN support on
#  --with-dll              turn DLL API support on
#  --with-python           turn Python support on
#  --with-boost[=DIR]      use boost (default is yes) - it is possible to
#                          specify the root directory for boost (optional)
#  --with-boost-libdir=LIB_DIR
#                          Force given directory for boost libraries. Note that
#                          this will overwrite library path detection, so use
#                          this parameter only if default library detection
#                          fails and you know exactly where your boost
#                          libraries are located.
#  --with-teuchos-include=DIR
#                          use Teuchos headers in specified include DIR
#  --with-teuchos-lib=DIR  use Teuchos libraries in specified lib DIR
#  --with-teuchos=DIR      use Teuchos (default is yes), optionally specify the
#                          root Teuchos directory containing src or include/lib
#  --without-graphics      turn GRAPHICS support off
#  --with-x                use the X Window System
#  --without-xpm         do not use Xpm
#  --with-xpm-includes=DIR    Xpm include files are in DIR
#  --with-xpm-libraries=DIR   Xpm libraries are in DIR
#  --without-ampl          omit AMPL/solver interface library
#  --without-surfpack      turn SURFPACK support off
#  --with-gsl<=DIR>        use GPL package GSL (default no); optionally specify
#                          the root DIR for GSL include/lib
#  --without-acro          turn ACRO support off
#  --without-conmin        turn CONMIN support off
#  --without-ddace         turn DDACE support off
#  --with-dl_solver        turn DL_SOLVER support on
#  --without-dot           turn DOT support off
#  --without-fsudace       turn FSUDace support off
#  --with-gpmsa            turn GPL package GPMSA on
#  --with-queso            turn QUESO support on
#  --without-hopspack      turn HOPSPACK support off
#  --without-jega          turn JEGA support off
#  --without-ncsu          turn NCSUOpt support off
#  --without-nl2sol        turn NL2SOL support off
#  --without-nlpql         turn NLPQL support off
#  --without-npsol         turn NPSOL support off
#  --without-optpp         turn OPTPP support off
#  --without-psuade        turn PSUADE support off
#  --with-cppunit-prefix=PFX   Prefix where CppUnit is installed (optional)
#  --with-cppunit-exec-prefix=PFX  Exec prefix where CppUnit is installed (optional)

