#!/bin/bash
#
# Build information for libssh
#
# $Id$
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
      buildargs="-m nmake"
      local zlibsershdir=`cygpath -am $ZLIB_SERSH_DIR`
      LIBSSH_SERSH_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$zlibsershdir/include -DZLIB_LIBRARY:PATH=$zlibsershdir/lib/zlib.lib"
      local zlibpycshdir=`cygpath -am $ZLIB_PYCSH_DIR`
      LIBSSH_PYCSH_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$zlibpycshdir/include -DZLIB_LIBRARY:PATH=$zlibpycshdir/lib/zlib.lib"
      ;;
    Linux)
      LIBSSH_ALL_ADDL_ARGS="-DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,--allow-multiple-definition -DCMAKE_EXE_LINKER_FLAGS:STRING=-Wl,--allow-multiple-definition"
      ;;
  esac

  LIBSSH_ALL_ADDL_ARGS="${LIBSSH_ALL_ADDL_ARGS} -DCMAKE_INSTALL_NAME_DIR:PATH='\${CMAKE_INSTALL_PREFIX}/lib'"

# configure and launch builds
  if bilderConfig -c libssh ser "-DWITH_STATIC_LIB:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $LIBSSH_ALL_ADDL_ARGS $LIBSSH_SERSH_ADDL_ARGS $LIBSSH_SER_OTHER_ARGS"; then
    bilderBuild $buildargs libssh ser
  fi
  if bilderConfig -c libssh pycsh "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $LIBSSH_ALL_ADDL_ARGS $LIBSSH_PYCSH_ADDL_ARGS $LIBSSH_PYCSH_OTHER_ARGS"; then
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

