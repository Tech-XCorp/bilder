#!/bin/bash
#
# Version and build information for openmpi
#
# $Id: openmpi.sh 6986 2012-11-11 13:39:41Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

OPENMPI_BLDRVERSION_STD=1.6.1
OPENMPI_BLDRVERSION_EXP=1.6.1

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
        OPENMPI_NODL_ADDL_ARGS=${OPENMPI_NODL_ADDL_ARGS:-"--with-wrapper-ldflags='-Wl,-rpath,${CONTRIB_DIR}/openmpi-${OPENMPI_BLDRVERSION}-nodl/lib $SER_EXTRA_LDFLAGS'"}
        if [[ $OPENMPI_BLDRVERSION =~ 1.6 ]]; then
          OPENMPI_NODL_ADDL_ARGS="$OPENMPI_NODL_ADDL_ARGS --disable-vt"
          OPENMPI_STATIC_ADDL_ARGS="$OPENMPI_STATIC_ADDL_ARGS --disable-vt"
        fi
        ;;
    esac

    if bilderConfig openmpi nodl "$CONFIG_COMPILERS_SER --enable-static --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_NODL_ADDL_ARGS $OPENMPI_NODL_OTHER_ARGS"; then
      bilderBuild openmpi nodl "$JMAKEARGS $SER_CONFIG_LDFLAGS"
    fi
    if bilderConfig openmpi static "$CONFIG_COMPILERS_SER --enable-static --disable-shared --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_STATIC_ADDL_ARGS $OPENMPI_STATIC_OTHER_ARGS"; then
      bilderBuild openmpi static "$JMAKEARGS $SER_CONFIG_LDFLAGS"
    fi
  fi
}

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
      bilderBuild openmpi nodl "$JMAKEARGS"
    fi
    if bilderConfig -c openmpi static "$CMAKE_COMPILERS_SER --enable-static --disable-shared --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_STATIC_ADDL_ARGS $OPENMPI_STATIC_OTHER_ARGS"; then
      bilderBuild openmpi static "$JMAKEARGS"
    fi
  fi
}

# For easy switching
buildOpenmpi() {
# cmake works on windows only, if then
  case `uname` in
    CYGWIN*)
      buildOpenmpiCM
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
    case $OPENMPI_BLDRVERSION in
      1.3* | 1.4*)
        echo "plm_rsh_agent = rsh" >>$CONTRIB_DIR/openmpi/etc/openmpi-mca-params.conf
        ;;
      *)
        echo "orte_rsh_agent = rsh" >>$CONTRIB_DIR/openmpi/etc/openmpi-mca-params.conf
        ;;
    esac
  else
    cat <<EOF | tee -a $LOGFILE
EOF
  fi
  bilderInstall openmpi static
# Obtain correct mpi compiler names after bildall.sh is called
  MPICC=`basename "$MPICC"`
  MPICXX=`basename "$MPICXX"`
  MPIFC=`basename "$MPIFC"`
  MPIF77=`basename "$MPIF77"`
  findParallelFcComps
  getCombinedCompVars
  # techo "WARNING. Quitting at end of openmpi.sh."; exit
}

