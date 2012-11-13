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
# Only Snow Leopard requires the version from svn
#
######################################################################

DAKOTA_BLDRVERSION=${DAKOTA_BLDRVERSION:-"5.2"}

######################################################################
#
# Other values
#
######################################################################

DAKOTA_BUILDS=${DAKOTA_BUILDS:-"ser,par"}
DAKOTA_DEPS=trilinos

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/dakota/bin

######################################################################
#
# Common arguments to find stuff or to simplify the builds
# See notes at the end
#
######################################################################
#SEK: Not sure this is the best
DAKOTA_TRILINOS_DIR_ARG="--with-teuchos=$CONTRIB_DIR/trilinos"
DAKOTA_BASE_ARGS="--without-graphics $DAKOTA_TRILINOS_DIR_ARG"

######################################################################
#
# Launch dakota builds.
#
######################################################################

buildDakota() {
  if bilderUnpack dakota; then
# Regular build
    if bilderConfig dakota ser "--disable-mpi $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS $DAKOTA_BASE_ARGS $DAKOTA_SER_OTHER_ARGS"; then
      bilderBuild dakota ser "$JMAKEARGS"
    fi
    if bilderConfig dakota par "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR $BEN_CONFIG_LDFLAGS $DAKOTA_BASE_ARGS $DAKOTA_PAR_OTHER_ARGS"; then
      bilderBuild dakota par "$JMAKEARGS"
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

  if bilderInstall dakota ser dakota; then
    : # Put post build commands here.
  fi
  if bilderInstall dakota par dakota; then
    : # Put post build commands here.
  fi


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


