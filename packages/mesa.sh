#!/bin/bash
#
# Version and build information for mesa
#
# $Id: mesa.sh 6712 2012-09-21 12:04:49Z cary $
#
# Repackage for bilder:
#   tar xzf MesaLib-7.10.2.tar.gz:w
#   mv Mesa-7.10.2 mesa-7.10.2
#   tar czf mesa-7.10.2.tar.gz mesa-7.10.2
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MESA_BLDRVERSION=${MESA_BLDRVERSION:-"7.8.2"}

######################################################################
#
# Other values
#
######################################################################

MESA_BUILDS=${MESA_BUILDS:-"mgl,os"}
MESA_DEPS=
MESA_UMASK=002

######################################################################
#
# Launch mesa builds.
#
# From the build_visit script...[ed] We build twice due to a VTK
# issue.  VTK can establish a rendering context via the system's GL
# using glX, via mangled Mesa using glX, and via offscreen mangled
# Mesa, and must have all three available.  For VisIt, we use
# either the system's GL, or offscreen mangled Mesa.  To placate
# VTK, we'll build a mangled+glX version, but then we'll build the
# offscreen one (driver=osmesa) that we really want.  This ensures
# we have the 'MesaGL' that VTK needs to link, but if we use
# 'OSMesa' we get a real, OSMesa library with no glX dependency.
#
# Due to this issue, it is imperative that one links "-lOSMesa
# -lMesaGL" when they want to render/link to an offscreen Mesa
# context and use MesaGL.  The two libraries will have a host of
# duplicate symbols, and it is important that we pick up the ones
# from OSMesa.
#
######################################################################

buildMesa() {

# Mesa no longer needs makedepend as of 7.8.2?
if false; then
  case `uname` in
    Linux)
      if ! which makedepend 1>/dev/null; then
        techo "WARNING: makedepend not found."
        techo "WARNING: May need to install imake."
      fi
      ;;
  esac
fi

# This has to be built and configured in place
  if bilderUnpack -i mesa; then

# Get variables
    local MESA_OFFSCREEN_PLATFORM_ARGS
    case `uname` in
      Linux)
        MESA_OFFSCREEN_PLATFORM_ARGS="--disable-glu"
        MESA_OS_FLAGS=-DGLX_USE_TLS
        ;;
    esac
    local MESA_COMPILERS="CC='$PYC_CC' CXX='$PYC_CXX'"
    local MESA_FLAGS="CFLAGS='-O2 ${CFLAGS} -DUSE_MGL_NAMESPACE ${MESA_OS_FLAGS}' CXXFLAGS='-O2 ${CXXFLAGS} -DUSE_MGL_NAMESPACE ${MESA_OS_FLAGS}'"

# Configure, build, and install with X driver, copying output as we
    if bilderConfig -i mesa mgl "$MESA_COMPILERS $MESA_FLAGS --without-demos --disable-gallium --with-driver=xlib --enable-gl-osmesa --enable-glx-tls --disable-glw --disable-glu --disable-egl $MESA_SER_OTHER_ARGS"; then
      bilderBuild mesa mgl
# Install without recording, so next build will proceed.
    fi

# Configure and build with offscreen driver, without glu on Linux, install
# in same place as mgl
    if bilderConfig -i -p mesa-${MESA_BLDRVERSION}-mgl mesa os "$MESA_COMPILERS $MESA_FLAGS --without-demos --with-driver=osmesa --disable-gallium --with-max-width=16384  --with-max-height=16384 --enable-glx-tls --disable-glw $MESA_OFFSCREEN_PLATFORM_ARGS --disable-egl $MESA_SER_OTHER_ARGS"; then
      bilderBuild mesa os
    fi

  fi
}

######################################################################
#
# Test mesa
#
######################################################################

testMesa() {
  techo "Not testing mesa."
}

######################################################################
#
# Install mesa
#
######################################################################

installMesa() {
# Install MGL build
  bilderInstall mesa mgl
# Install os build and make links
  if bilderInstall mesa os; then
# Add link to mesa, as visit is otherwise not happy.
    cmd="rm -f $CONTRIB_DIR/mesa"
    techo "$cmd"
    $cmd
    cmd="ln -s $CONTRIB_DIR/mesa-mgl $CONTRIB_DIR/mesa"
    techo "$cmd"
    $cmd
# Remove any erroneously installed GLEW.  Otherwise VisIt gets confused
    cmd="rmall $CONTRIB_DIR/mesa-$MESA_BLDRVERSION-mgl/include/GL/gl*ew.h"
    techo "$cmd"
    $cmd
    cmd="rm -f $CONTRIB_DIR/mesa-$MESA_BLDRVERSION-mgl/include/MangleMesaInclude"
    techo "$cmd"
    $cmd
    cmd="ln -s $CONTRIB_DIR/mesa-$MESA_BLDRVERSION-mgl/include/GL $CONTRIB_DIR/mesa-$MESA_BLDRVERSION-mgl/include/MangleMesaInclude"
    techo "$cmd"
    $cmd
  fi
}

