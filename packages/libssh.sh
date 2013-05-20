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

LIBSSH_BLDRVERSION=${LIBSSH_BLDRVERSION:-"0.5.4"}

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
    local buildargs=
    case `uname` in
      CYGWIN*)
# Some failures with jom on focus
        buildargs="-m nmake"
        local zlibdir=`cygpath -am $CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh`
        LIBSSH_SER_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$zlibdir/include -DZLIB_LIBRARY:PATH=$zlibdir/lib/zlib.lib"
        ;;
      Linux)
        LIBSSH_SER_ADDL_ARGS="  -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,--allow-multiple-definition -DCMAKE_EXE_LINKER_FLAGS:STRING=-Wl,--allow-multiple-definition"
        ;;
    esac
    if bilderConfig -c libssh ser "-DWITH_STATIC_LIB:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TARBALL_NODEFLIB_FLAGS $LIBSSH_SER_ADDL_ARGS $LIBSSH_SER_OTHER_ARGS"; then
      bilderBuild $buildargs libssh ser
    fi
    if bilderConfig -c libssh cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $TARBALL_NODEFLIB_FLAGS $LIBSSH_SER_ADDL_ARGS $LIBSSH_CC4PY_OTHER_ARGS"; then
      bilderBuild $buildargs libssh cc4py
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

