#!/bin/bash
#
# Version and build information for openmpi
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

OPENMPI_BLDRVERSION_STD=1.6.1
OPENMPI_BLDRVERSION_EXP=1.6.4

######################################################################
#
# Other values
#
######################################################################

if test -z "$OPENMPI_BUILDS"; then
  if $BUILD_OPENMPI; then
    case `uname` in
      CYGWIN*)
        OPENMPI_BUILDS=nodl
        ;;
      *)
        OPENMPI_BUILDS=nodl,static
        ;;
    esac
  fi
fi
OPENMPI_DEPS=valgrind,doxygen,cmake
OPENMPI_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/openmpi/bin

######################################################################
#
# Launch openmpi builds.
#
######################################################################

buildOpenmpiAT() {

  if bilderUnpack openmpi; then
    if test -h $CONTRIB_DIR/valgrind; then
      OPENMPI_VALGRIND_ARG="--with-valgrind=$CONTRIB_DIR/valgrind"
    fi

    case `uname` in
      Darwin)
        if test -f /usr/bin/mpicc; then
          cat <<EOF | tee -a $LOGFILE
WARNING: On OS X, you will need to execute the following commands
WARNING: as root to prevent interference from the system mpi.
WARNING:   cd /usr/lib
WARNING:   mkdir openmpi-save
WARNING:   mv libopen-* libmpi* openmpi-save
WARNING:   cd /usr/bin
WARNING:   mkdir openmpi-save
WARNING:   mv mpi* openmpi-save
EOF
        fi
        ;;
      Linux)
        OPENMPI_NODL_ADDL_ARGS="--with-wrapper-ldflags='-Wl,-rpath,${CONTRIB_DIR}/openmpi-${OPENMPI_BLDRVERSION}-nodl/lib $SER_EXTRA_LDFLAGS'"
        ;;
    esac

# With version 1.6.1, openmpi will stop in the middle of the build
# unless one does --disable-vt.  One can restart it, and it continues.
# Seems like an unregistered dependency.  Should try again after
# bumping version.
    case $OPENMPI_BLDRVERSION in
      1.6.1)
        OPENMPI_NODL_ADDL_ARGS="$OPENMPI_NODL_ADDL_ARGS --disable-vt"
        OPENMPI_STATIC_ADDL_ARGS="$OPENMPI_STATIC_ADDL_ARGS --disable-vt"
        ;;
    esac

# Set jmake args.  Observed to fail on magnus.colorado.edu for openmpi-1.6.1,
# but then observed to work with --disable-vt
if false; then
    local ompimakeflags="$SER_CONFIG_LDFLAGS"
    case $OPENMPI_BLDRVERSION in
      1.6.1)
        case `uname`-`uname -r` in
          # Darwin-1[12].*) ;;
          *) ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags" ;;
        esac
        ;;
      *) ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags" ;;
    esac
fi

    if bilderConfig openmpi nodl "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER --enable-static --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_NODL_ADDL_ARGS $OPENMPI_NODL_OTHER_ARGS"; then
      bilderBuild openmpi nodl "$ompimakeflags"
    fi
    if bilderConfig openmpi static "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER --enable-static --disable-shared --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_STATIC_ADDL_ARGS $OPENMPI_STATIC_OTHER_ARGS"; then
      bilderBuild openmpi static "$ompimakeflags"
    fi

  fi

}

#
# This method is not currently supported, as OpenMPI has dropped
# support for CMake builds.
#
buildOpenmpiCM() {
  case `uname` in
    Darwin)
      if test -f /usr/bin/mpicc; then
        cat <<EOF | tee -a $LOGFILE
WARNING: On OS X, you will need to execute the following commands
WARNING: as root to prevent interference from the system mpi.
  cd /usr/lib
  mkdir openmpi-save
  mv libopen-* libmpi* openmpi-save
  cd /usr/bin
  mkdir openmpi-save
  mv mpi* openmpi-save
EOF
      fi
      ;;
    Linux)
      : # OPENMPI_NODL_ADDL_ARGS=${OPENMPI_NODL_ADDL_ARGS:-"--with-wrapper-ldflags='-Wl,-rpath,${CONTRIB_DIR}/openmpi-${OPENMPI_BLDRVERSION}-nodl/lib $SER_EXTRA_LDFLAGS'"}
      ;;
  esac
  if test -h $CONTRIB_DIR/valgrind; then
    : # OPENMPI_VALGRIND_ARG="--with-valgrind=$CONTRIB_DIR/valgrind"
  fi
  if bilderUnpack openmpi; then
    if bilderConfig -c openmpi nodl "$CMAKE_COMPILERS_SER $OPENMPI_VALGRIND_ARG $OPENMPI_NODL_ADDL_ARGS $OPENMPI_NODL_OTHER_ARGS"; then
      bilderBuild openmpi nodl "$OPENMPI_MAKEJ_ARGS"
    fi
    if bilderConfig -c openmpi static "$CMAKE_COMPILERS_SER --enable-static --disable-shared --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_STATIC_ADDL_ARGS $OPENMPI_STATIC_OTHER_ARGS"; then
      bilderBuild openmpi static "$OPENMPI_MAKEJ_ARGS"
    fi
  fi
}

# For easy switching
buildOpenmpi() {
# cmake works on windows only, if then
  case `uname` in
    CYGWIN*)
      # buildOpenmpiCM # Not currently supported
      ;;
    *)
      buildOpenmpiAT
      ;;
  esac
}

######################################################################
#
# Test openmpi
#
######################################################################

testOpenmpi() {
  techo "Not testing openmpi."
}

######################################################################
#
# Install openmpi
#
######################################################################

# Set umask to allow only group to use
installOpenmpi() {
  if bilderInstall openmpi nodl openmpi; then
    if test -h $CONTRIB_DIR/mpi; then
      rm -f $CONTRIB_DIR/mpi
    fi
    ln -s $CONTRIB_DIR/openmpi $CONTRIB_DIR/mpi
# Allow rsh use
    OPENMPI_ALLOW_RSH=${OPENMPI_ALLOW_RSH:-"true"}
    if $OPENMPI_ALLOW_RSH; then
      case $OPENMPI_BLDRVERSION in
        1.3* | 1.4*)
          echo "plm_rsh_agent = rsh" >>$CONTRIB_DIR/openmpi/etc/openmpi-mca-params.conf
          ;;
        *)
          echo "orte_rsh_agent = rsh" >>$CONTRIB_DIR/openmpi/etc/openmpi-mca-params.conf
          ;;
      esac
    fi
  fi
  bilderInstall openmpi static
# Obtain correct mpi compiler names after bildall.sh is called
  MPICC=`basename "$MPICC"`
  MPICXX=`basename "$MPICXX"`
  MPIFC=`basename "$MPIFC"`
  MPIF77=`basename "$MPIF77"`
  findParallelFcComps
  getCombinedCompVars
}

