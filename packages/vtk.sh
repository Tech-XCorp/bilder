#!/bin/bash
#
# Version and build information for vtk
#
# $Id: vtk.sh 5429 2012-03-09 14:15:24Z cary $
#
######################################################################

######################################################################
#
# Version.
# This is the patched version from the VisIt repo:
# wget http://portal.nersc.gov/svn/visit//trunk/third_party/vtk-5.0.0i.tar.gz
# Then repacked:
# tar xzf vtk-5.0.0i.tar.gz
# mv VTK vtk-5.0.0i
# tar czf vtk-5.0.0i.tar.gz vtk-5.0.0i
#
######################################################################

VTK_BLDRVERSION=${VTK_BLDRVERSION:-"5.0.0i"}

######################################################################
#
# Other values
#
######################################################################

VTK_BUILDS=${VTK_BUILDS:-"ser"}
VTK_DEPS=mesa,cmake

######################################################################
#
# Launch vtk builds.
#
######################################################################

buildVtk() {

  if bilderUnpack vtk; then
    local VTK_LD_RUN_PATH=
    local VTK_OS_ARGS=
    local VTK_PYTHON_ARGS=
# build_visit sets both of these the same for Darwin
    local MANGLED_MESA_LIB=libOSMesa${SHOBJEXT}
    local MANGLED_OSMESA_LIB=libOSMesa${SHOBJEXT}
    case `uname` in
      CYGWIN*) # Add /MT flags
        VTK_OS_ARGS="$VTK_OS_ARGS -DVTK_USE_VIDEO_FOR_WINDOWS:BOOL=OFF"
# Cygwin on focus apparently need this
        VTK_PYTHON_ARGS="-DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIB"
        case `uname` in
          CYGWIN*64) # 64-bit Windows needs help finding correct python paths
            VTK_PYTHON_ARGS="$VTK_PYTHON_ARGS -DPYTHON_EXECUTABLE:FILEPATH='$PYTHON' -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCDIR"
           ;;
        esac
# Protect against jom, as dependencies not right
        VTK_BUILD_ARGS="-m nmake"
        ;;
      Darwin)	# make -j can fail on Darwin
        VTK_OS_ARGS="$VTK_OS_ARGS -DVTK_USE_CARBON:BOOL=OFF -DVTK_USE_COCOA:BOOL=ON"
        case `uname -r` in
          9.*)
            ;;
          10.*)
            VTK_OS_ARGS="$VTK_OS_ARGS -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=ON"
            ;;
        esac
        ;;
      Linux)
        VTK_LD_RUN_PATH=${PYTHON_LIBDIR}:${CONTRIB_DIR}/mesa-${MESA_BLDRVERSION}-mgl/lib:$LD_RUN_PATH
        trimvar VTK_LD_RUN_PATH ':'
        if test -n "$VTK_LD_RUN_PATH"; then
          local VTK_LD_RUN_ARGS="LD_RUN_PATH=$VTK_LD_RUN_PATH"
        fi
        local VTK_LD_LIB_PATH="$LD_LIBRARY_PATH"
        if test -n "$LIBFORTRAN_DIR"; then
         VTK_LD_LIB_PATH="$LIBFORTRAN_DIR:$VTK_LD_LIB_PATH"
        fi
        case $PYTHON_LIB_LIBDIR in
          /usr/lib | /usr/lib64)
            ;;
          *)
            VTK_LD_LIB_PATH="$PYTHON_LIB_LIBDIR:$VTK_LD_LIB_PATH"
            ;;
        esac
        trimvar VTK_LD_LIB_PATH ':'
        if test -n "$VTK_LD_LIB_PATH"; then
          local VTK_LD_LIB_ARGS="LD_LIBRARY_PATH=$VTK_LD_LIB_PATH"
         fi
        techo "VTK_LD_LIB_ARGS = $VTK_LD_LIB_ARGS."
        if test -n "$VTK_LD_RUN_ARGS" -o -n "$VTK_LD_LIB_ARGS"; then
          local VTK_ENV=$VTK_LD_RUN_ARGS,$VTK_LD_LIB_ARGS
        fi
        trimvar VTK_ENV ','
        if test -n "$VTK_ENV"; then
          VTK_ENV_ARGS="-e $VTK_ENV"
        fi
        VTK_MAKE_ARGS="$JMAKEARGS"
# build_visit uses MANGLED_OSMESA_LIB=libMesaGL on Linux.
        MANGLED_OSMESA_LIB=libMesaGL${SHOBJEXT}	# per build_visit
        if test -z "$PYTHON"; then
          techo "PYTHON NOT SET.  VTK Python wrappers will not build."
          return
        fi
        VTK_PYTHON_ARGS="-DPYTHON_EXECUTABLE:FILEPATH='$PYTHON' -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCDIR -DPYTHON_LIBRARY:FILEPATH=$PYTHON_SHLIB"
        VTK_OS_ARGS="$VTK_OS_ARGS -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=ON"
        ;;
    esac
    local VTK_COMPILERS
    local VTK_FLAGS

# For all, build shared.
    VTK_OS_ARGS="$VTK_OS_ARGS -DBUILD_SHARED_LIBS:BOOL=ON -DVTK_WRAP_PYTHON:BOOL=ON"
# CYGWIN uses serial compilers, does not use Mesa
# Others use gcc, use mesa
    case `uname` in
      CYGWIN*)
        VTK_COMPILERS="-DCMAKE_C_COMPILER:FILEPATH='$CC' -DCMAKE_CXX_COMPILER:FILEPATH='$CXX'"
        ;;
      *)
        VTK_COMPILERS="$CMAKE_COMPILERS_PYC"
        VTK_FLAGS="$CMAKE_COMPFLAGS_PYC"
        VTK_MESA_ARGS="-DVTK_USE_MANGLED_MESA:BOOL=ON -DMANGLED_MESA_INCLUDE_DIR:PATH=$CONTRIB_DIR/mesa-mgl/include -DMANGLED_MESA_LIBRARY:FILEPATH=$CONTRIB_DIR/mesa-mgl/lib/${MANGLED_MESA_LIB} -DMANGLED_OSMESA_INCLUDE_DIR:PATH=$CONTRIB_DIR/mesa-mgl/include -DMANGLED_OSMESA_LIBRARY:FILEPATH=$CONTRIB_DIR/mesa-mgl/lib/${MANGLED_OSMESA_LIB}"
        ;;
    esac

# Per build_visit:
# Linking OSMesa for MANGLED_MESA_LIBRARY is correct here; we'll never use
# MesaGL, as that is a xlib-based software path.  If we have an X context,
# we always want to use the 'system's GL library.
# The only time this is not done is Linux-static
# For Windows, try not replacing the RELEASE flags
    local VTK_CONFIG_ARGS="$VTK_COMPILERS $VTK_FLAGS $VTK_OS_ARGS -DBUILD_TESTING:BOOL=OFF -DUSE_ANSI_STD_LIB:BOOL=ON -DVTK_USE_HYBRID:BOOL=ON ${VTK_MESA_ARGS} -DVTK_USE_TK:BOOL=OFF $VTK_PYTHON_ARGS $VTK_SER_OTHER_ARGS"
    echo VTK_CONFIG_ARGS=$VTK_CONFIG_ARGS
# Pass with commas and separate later.
    if bilderConfig $VTK_ENV_ARGS vtk ser "$VTK_CONFIG_ARGS"; then
# Build
      bilderBuild $VTK_ENV_ARGS $VTK_BUILD_ARGS vtk ser "$VTK_MAKE_ARGS"
    fi
  fi

}

######################################################################
#
# Test vtk
#
######################################################################

testVtk() {
  techo "Not testing vtk."
}

######################################################################
#
# Install vtk
#
######################################################################

installVtk() {
  if bilderInstall $VTK_ENV_ARGS $VTK_BUILD_ARGS -r vtk ser; then
    case `uname` in
      CYGWIN*)
        ;;
      *)
        runnrExec "rm -f $CONTRIB_DIR/vtk-$VTK_BLDRVERSION-ser/include/MangleMesaInclude"
        runnrExec "ln -s $CONTRIB_DIR/mesa-$MESA_BLDRVERSION-mgl/include/GL $CONTRIB_DIR/vtk-$VTK_BLDRVERSION-ser/include/MangleMesaInclude"
        ;;
    esac
  fi
  # techo exit; exit
}

