#!/bin/bash
#
# Build information for openmpi
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in open_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/openmpi_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOpenmpiNonTriggerVars() {
  OPENMPI_UMASK=002
}
setOpenmpiNonTriggerVars

######################################################################
#
# Launch openmpi builds.
#
######################################################################

buildOpenmpiAT() {

  if ! bilderUnpack openmpi; then
    return
  fi

  techo "OPENMPI_BLDRVERSION = $OPENMPI_BLDRVERSION."
# Look for valgrind
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
# Need to add -Wreserved-user-defined-literal to 1.6.4 for clang?
      ;;
    Linux)
      OPENMPI_NODL_ADDL_ARGS="--with-wrapper-ldflags='-Wl,-rpath,${CONTRIB_DIR}/openmpi-${OPENMPI_BLDRVERSION}-nodl/lib $SER_EXTRA_LDFLAGS'"
      OPENMPI_SHARED_ADDL_ARGS="--with-wrapper-ldflags='-Wl,-rpath,${CONTRIB_DIR}/openmpi-${OPENMPI_BLDRVERSION}-shared/lib $SER_EXTRA_LDFLAGS'"
      ;;
  esac

# Set jmake args.  Observed to fail on magnus.colorado.edu for openmpi-1.6.1,
# but then observed to work with --disable-vt
  local ompimakeflags="$SER_CONFIG_LDFLAGS"
  case $OPENMPI_BLDRVERSION in
    1.6.*)
# With version 1.6.1, openmpi will stop in the middle of the build
# with "library not found for -lmpi unless one has --disable-vt.
      OPENMPI_NODL_ADDL_ARGS="$OPENMPI_NODL_ADDL_ARGS --disable-vt"
      OPENMPI_STATIC_ADDL_ARGS="$OPENMPI_STATIC_ADDL_ARGS --disable-vt"
      OPENMPI_SHARED_ADDL_ARGS="$OPENMPI_SHARED_ADDL_ARGS --disable-vt"
      case `uname`-`uname -r` in
        Darwin-1[13].*) ;;
        *) ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags";;
      esac
      ;;
    1.8.*)
# Disabling vt can help build
      OPENMPI_NODL_ADDL_ARGS="$OPENMPI_NODL_ADDL_ARGS --disable-vt"
      OPENMPI_STATIC_ADDL_ARGS="$OPENMPI_STATIC_ADDL_ARGS --disable-vt"
      OPENMPI_SHARED_ADDL_ARGS="$OPENMPI_SHARED_ADDL_ARGS --disable-vt"
      case `uname`-`uname -r` in
# make -j2 fails on Darwin-11.4.2 with ld: "library not found for -lmpi"
# Restarting with just "make" succeeds.
        Darwin-1[12].*) ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags";;
# make -j2 failed on one Darwin-13.3.0 machine but succeeded on another??
# make -j2 succeeded on both with --disable-vt
        Darwin-1[34].*) ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags";;
        Darwin-*) ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags";;
# make -j2 failed on one Centos 6.3 machonewithout --disable-vt, succeeded with
        Linux) ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags";;
      esac
      ;;
    *)
      ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags"
      ;;
  esac

# Fix some flags
  local ompcxxflags=`echo $CXXFLAGS | sed 's/-std=c++11//g'`
  trimvar ompcxxflags ' '
  ompcompflags="CFLAGS='$CFLAGS' CXXFLAGS='$ompcxxflags'"
  if test -n "$FCFLAGS"; then
    ompcompflags="$ompcompflags FCFLAGS='$FCFLAGS'"
  fi

#
# The builds
#

  if bilderConfig openmpi nodl "$CONFIG_COMPILERS_SER $ompcompflags --enable-static --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_NODL_ADDL_ARGS $OPENMPI_NODL_OTHER_ARGS"; then
    bilderBuild openmpi nodl "$ompimakeflags"
  fi

  if bilderConfig openmpi static "$CONFIG_COMPILERS_SER $ompcompflags --enable-static --disable-shared --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_STATIC_ADDL_ARGS $OPENMPI_STATIC_OTHER_ARGS"; then
    bilderBuild openmpi static "$ompimakeflags"
  fi

  if bilderConfig openmpi shared "$CONFIG_COMPILERS_SER $ompcompflags --enable-shared --disable-static --with-pic --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_SHARED_ADDL_ARGS $OPENMPI_SHARED_OTHER_ARGS"; then
    bilderBuild openmpi shared "$ompimakeflags"
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
  bilderInstallAll openmpi
  (cd $CONTRIB_DIR; ln -sf openmpi-nodl openmpi; ln -s openmpi mpi)
# Is this needed?
  # echo "orte_rsh_agent = rsh" >>$CONTRIB_DIR/openmpi-nodl/etc/openmpi-mca-params.conf
}

