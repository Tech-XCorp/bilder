#!/bin/bash
#
# Version and build information for libssh
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LIBSSH_BLDRVERSION=${LIBSSH_BLDRVERSION:-"0.5.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# libssh always builds the shared libs.  With configuration below,
# it will also build the static library, so we call this build ser.
LIBSSH_DESIRED_BUILDS=${LIBSSH_DESIRED_BUILDS:-"ser"}
computeBuilds libssh
# Since libssh always builds the shared libs in ser, addCc4py logic
# not right.
if ! isCcCc4py; then
  addCc4pyBuild libssh
fi

LIBSSH_DEPS=cmake,zlib
LIBSSH_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildLibssh() {
  if bilderUnpack libssh; then
    if [[ `uname` =~ CYGWIN ]]; then
      local zlibdir=`cygpath -am $CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh`
      LIBSSH_SER_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$zlibdir/include -DZLIB_LIBRARY:PATH=$zlibdir/lib/zlib.lib"
      if test -e $CONTRIB_DIR/openssl-sersh; then
        local openssldir=`cygpath -am $CONTRIB_DIR/openssl-sersh`
        LIBSSH_SER_ADDL_ARGS="$LIBSSH_SER_ADDL_ARGS -DOPENSSL_ROOT_DIR='$openssldir'"
      else
        techo "WARNING: $CONTRIB_DIR/openssl-sersh is not installed."
      fi
    fi
    if bilderConfig -c libssh ser "-DWITH_STATIC_LIB:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TARBALL_NODEFLIB_FLAGS $LIBSSH_SER_ADDL_ARGS $LIBSSH_SER_OTHER_ARGS"; then
      bilderBuild libssh ser
    fi
    if bilderConfig -c libssh cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $TARBALL_NODEFLIB_FLAGS $LIBSSH_SER_ADDL_ARGS $LIBSSH_CC4PY_OTHER_ARGS"; then
      bilderBuild libssh cc4py
    fi
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
  for bld in `echo $LIBSSH_BUILDS | tr ',' ' '`; do
    bilderInstall -r libssh $bld
  done
}

