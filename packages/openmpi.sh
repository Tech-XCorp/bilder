#!/bin/sh
######################################################################
#
# @file    openmpi.sh
#
# @brief   Build information for openmpi.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in openmpi_aux.sh
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

# Unpack
  if ! bilderUnpack openmpi; then
    return 1
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
    1.8.* | 1.10.*)
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
        Linux-*)
          ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags"
          OPENMPI_NODL_ENV="LD_RUN_PATH=$CONTRIB_DIR/openmpi-${OPENMPI_BLDRVERSION}-nodl/lib"
          OPENMPI_SHARED_ENV="LD_RUN_PATH=$CONTRIB_DIR/openmpi-${OPENMPI_BLDRVERSION}-shared/lib"
          ;;
      esac
      ;;
    *)
      ompimakeflags="$OPENMPI_MAKEJ_ARGS $ompimakeflags"
      ;;
  esac

# Fix some flags
# Need to start building for C++11 to use threads
  local ompcxxflags="$CXXFLAGS"
# Below definitely not needed with experimental version
  trimvar ompcxxflags ' '
# http://www.open-mpi.org/community/lists/users/2015/01/26134.php
  ompcompflags="$CONFIG_COMPFLAGS_SER" # Perhaps good for all.
  if ! $BUILD_EXPERIMENTAL; then
    if test -n "$FCFLAGS"; then
      ompcompflags="$ompcompflags FCFLAGS='$FCFLAGS'"
    fi
  fi

#
# The builds
#

  if bilderConfig openmpi nodl "$CONFIG_COMPILERS_SER $ompcompflags --enable-static --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_NODL_ADDL_ARGS $OPENMPI_NODL_OTHER_ARGS" "" "$OPENMPI_NODL_ENV"; then
    bilderBuild openmpi nodl "$ompimakeflags" "$ompenv"
  fi

  if bilderConfig openmpi static "$CONFIG_COMPILERS_SER $ompcompflags --enable-static --disable-shared --with-pic --disable-dlopen --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_STATIC_ADDL_ARGS $OPENMPI_STATIC_OTHER_ARGS" "" "$OPENMPI_STATIC_ENV"; then
    bilderBuild openmpi static "$ompimakeflags" "$ompenv"
  fi

  if bilderConfig openmpi shared "$CONFIG_COMPILERS_SER $ompcompflags --enable-shared --disable-static --with-pic --enable-mpirun-prefix-by-default $OPENMPI_VALGRIND_ARG $OPENMPI_SHARED_ADDL_ARGS $OPENMPI_SHARED_OTHER_ARGS" "" "$OPENMPI_SHARED_ENV"; then
    bilderBuild openmpi shared "$ompimakeflags" "$ompenv"
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
  if test -h $CONTRIB_DIR/mpi; then
    rm -f $CONTRIB_DIR/mpi
  fi
  if bilderInstallAll openmpi; then
    case `uname`-`uname -r` in
      Darwin-1[6-9].*) OPENMPI_ALLOW_RSH=false;;
    esac
    OPENMPI_ALLOW_RSH=${OPENMPI_ALLOW_RSH:-"true"}
    for bld in `echo $OPENMPI_BUILDS | tr ',' ' '`; do
      prmsfile=$CONTRIB_DIR/openmpi-$bld/etc/openmpi-mca-params.conf
# "hwloc_base_binding_policy = core:overload-allowed" fails on osx.
      line="rmaps_base_oversubscribe = true"
      if ! grep -q "^$line" $prmsfile; then
        echo "$line" >>$prmsfile
      fi
      if $OPENMPI_ALLOW_RSH; then
# Allow rsh use.
        line="plm_rsh_agent = rsh"
        if ! grep -q "^$line" $prmsfile; then
          echo "$line" >>$prmsfile
        fi
      fi
    done
    case `uname` in
      Darwin)
        for bld in `echo $OPENMPI_BUILDS | tr ',' ' '`; do
          omf=`ls $CONTRIB_DIR/openmpi-$bld/lib/libmpi_usempi*.dylib | head -1`
          if test -n "$omf"; then
            local gflib=`otool -L $omf | grep libgfortran | tr -d '\t' | sed -e 's/ (com.*//'`
            if ! test -f "$gflib"; then
              local gflibn=`echo $gflib | sed -e 's/gcc4.9/gcc@4.9/'`
              if test -f "$gflibn"; then
                local cmd="install_name_tool -change '$gflib' '$gflibn' $omf"
                echo "$cmd"
                eval "$cmd"
              fi
            fi
            local gqlib=`otool -L $omf | grep libquadmath | tr -d '\t' | sed -e 's/ (com.*//'`
            if ! test -f "$gqlib"; then
              local gqlibn=`echo $gqlib | sed -e 's/gcc4.9/gcc@4.9/'`
              if test -f "$gqlibn"; then
                cmd="install_name_tool -change '$gqlib' '$gqlibn' $omf"
                echo "$cmd"
                eval "$cmd"
              fi
            fi
          fi
        done
        ;;
    esac
  fi
}

