#!/bin/sh
######################################################################
#
# @file    libssh.sh
#
# @brief   Build information for libssh.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in libssh_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/libssh_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLibsshNonTriggerVars() {
  LIBSSH_UMASK=002
}
setLibsshNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildLibssh() {

# Unpack if build needed
  if ! bilderUnpack libssh; then
    return
  fi

# Construct configure and build args
  local buildargs=
  case `uname` in
    CYGWIN*)
# Some failures with jom on focus
      LIBSSH_COMPFLAGS_SER="$CMAKE_COMPFLAGS_SER"
      LIBSSH_COMPFLAGS_PYC="$CMAKE_COMPFLAGS_PYC"
      buildargs="-m nmake"
      local zlibsershdir=`cygpath -am $ZLIB_SERSH_DIR`
      LIBSSH_SER_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$zlibsershdir/include -DZLIB_LIBRARY:PATH=$zlibsershdir/lib/zlib.lib"
      local zlibpycshdir=`cygpath -am $ZLIB_PYCSH_DIR`
      LIBSSH_PYCSH_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$zlibpycshdir/include -DZLIB_LIBRARY:PATH=$zlibpycshdir/lib/zlib.lib"
      ;;
    Darwin)
      case `uname -r` in
        14.*)
          LIBSSH_COMPFLAGS_SER="-DCMAKE_C_FLAGS:STRING='$CFLAGS -DHAVE_NTOHLL -DHAVE_HTONLL' -DCMAKE_CXX_FLAGS='$CXXFLAGS'"
          LIBSSH_COMPFLAGS_PYC="-DCMAKE_C_FLAGS:STRING='$PYC_CFLAGS -DHAVE_NTOHLL -DHAVE_HTONLL' -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS'"
          ;;
        *)
          LIBSSH_COMPFLAGS_SER="$CMAKE_COMPFLAGS_SER"
          LIBSSH_COMPFLAGS_PYC="$CMAKE_COMPFLAGS_PYC"
          ;;
      esac
      LIBSSH_SER_ADDL_ARGS="$LIBSSH_SER_ADDL_ARGS -DCMAKE_INSTALL_NAME_DIR:PATH='${CONTRIB_DIR}/libssh-${LIBSSH_BLDRVERSION}-ser/lib'"
      if test -n "$CMAKE_OPENSSL_SERSH_DIR"; then
        LIBSSH_SER_ADDL_ARGS="$LIBSSH_SER_ADDL_ARGS -DOPENSSL_ROOT_DIR:PATH='$CMAKE_OPENSSL_SERSH_DIR'"
      fi
      LIBSSH_PYCSH_ADDL_ARGS="$LIBSSH_PYCSH_ADDL_ARGS -DCMAKE_INSTALL_NAME_DIR:PATH='${CONTRIB_DIR}/libssh-${LIBSSH_BLDRVERSION}-pycsh/lib'"
      ;;
    Linux)
      LIBSSH_COMPFLAGS_SER="$CMAKE_COMPFLAGS_SER"
      LIBSSH_COMPFLAGS_PYC="$CMAKE_COMPFLAGS_PYC"
      LIBSSH_ALL_ADDL_ARGS="-DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,--allow-multiple-definition -DCMAKE_EXE_LINKER_FLAGS:STRING=-Wl,--allow-multiple-definition"
      ;;
  esac

# configure and launch builds
  if bilderConfig -c libssh ser "-DWITH_STATIC_LIB:BOOL=TRUE $CMAKE_COMPILERS_SER $LIBSSH_COMPFLAGS_SER $LIBSSH_ALL_ADDL_ARGS $LIBSSH_SER_ADDL_ARGS $LIBSSH_SER_OTHER_ARGS"; then
    bilderBuild $buildargs libssh ser
  fi
  if bilderConfig -c libssh pycsh "$CMAKE_COMPILERS_PYC $LIBSSH_COMPFLAGS_PYC $LIBSSH_ALL_ADDL_ARGS $LIBSSH_PYCSH_ADDL_ARGS $LIBSSH_PYCSH_OTHER_ARGS"; then
    bilderBuild $buildargs libssh pycsh
  fi

}

######################################################################
#
# Test
#
######################################################################

testLibssh() {
  techo "Not testing libssh."
}

######################################################################
#
# Install
#
######################################################################

installLibssh() {
  bilderInstallAll libssh "-r"
}

