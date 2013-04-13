#!/bin/bash
#
# Version and build information for visit_vtk
#
# This was the patched version from the VisIt repo:
# wget http://portal.nersc.gov/svn/visit/trunk/third_party/visit-vtk-5.8.tar.gz
# Then repacked:
# tar xzf visit-vtk-5.8.tar.gz
# mv visit-vtk-5.8 visit_vtk-5.8
# tar czf visit_vtk-5.8.tar.gz visit_vtk-5.8
#
# tarball updated Dec 24, 2011
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

VISIT_VTK_BLDRVERSION=${VISIT_VTK_BLDRVERSION:-"5.8.0.a"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# By default, visit_vtk is built only with the compiler that built python
if test -z "$VISIT_VTK_DESIRED_BUILDS"; then
  VISIT_VTK_DESIRED_BUILDS=$FORPYTHON_BUILD
fi
computeBuilds visit_vtk
VISIT_VTK_SER_BUILD=`echo $VISIT_VTK_BUILDS | sed 's/,.*$//'`
VISIT_VTK_SER_BUILD=${VISIT_VTK_SER_BUILD:-"unknown"} # Fallback
VISIT_VTK_DEPS=mesa,hdf5,Python,cmake

######################################################################
#
# Launch builds.
#
######################################################################

buildVisIt_Vtk() {

  if bilderUnpack visit_vtk; then

#
# Determine Python and OS args, and environments
    local VISIT_VTK_LD_RUN_PATH=
    local VISIT_VTK_OS_ARGS=
    local VISIT_VTK_PYTHON_ARGS=-DVTK_WRAP_PYTHON:BOOL=ON
    local VISIT_VTK_BUILD_ARGS=
    case `uname` in

      CYGWIN*)
# Cygwin on focus apparently need this
        VISIT_VTK_PYTHON_ARGS="-DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIB"
        case `uname` in
          CYGWIN*64) # 64-bit Windows needs help finding correct python paths
            VISIT_VTK_PYTHON_ARGS="$VISIT_VTK_PYTHON_ARGS -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCDIR"
           ;;
        esac
# JRC originally added this nmake argument, but as of 02/07/2012
# jom appears to work when building visit_vtk.sh.  After establishing
# that it works across all of our machines, we can remove this
# comment and the commented code.
# (JRC) Protect against jom, as dependencies not right
# 25Feb2013: Failure observed on focus (XP)
        VISIT_VTK_BUILD_ARGS="-m nmake"
        ;;

      Darwin)	# make -j can fail on Darwin
        VISIT_VTK_OS_ARGS="$VISIT_VTK_OS_ARGS -DVISIT_VTK_USE_CARBON:BOOL=OFF -DVISIT_VTK_USE_COCOA:BOOL=ON"
        case `uname -r` in
          9.*)
            techo "WARNING: Not supporting Darwin 9.*."
            ;;
        esac
        VISIT_VTK_OS_ARGS="-DVTK_USE_CARBON:BOOL=OFF -DVTK_USE_ANSI_STD_LIB:BOOL=ON -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-headerpad_max_install_names,-compatibility_version,5.7,-current_version,5.7.0 -DVTK_USE_COCOA:BOOL=ON"
        VISIT_VTK_PYTHON_ARGS="$VISIT_VTK_PYTHON_ARGS -DPYTHON_EXECUTABLE:FILEPATH='$PYTHON' -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCDIR -DPYTHON_LIBRARY:FILEPATH=$PYTHON_SHLIB -DPYTHON_EXTRA_LIBS:STRING=-lpthread"
        ;;

      Linux)
        local VISIT_VTK_MESA_LIB_PATH=
        local VISIT_VTK_LD_RUN_PATH=$LD_RUN_PATH
        if test -d ${CONTRIB_DIR}/mesa-${MESA_BLDRVERSION}-mgl/lib; then
          VISIT_VTK_MESA_LIB_PATH=${CONTRIB_DIR}/mesa-${MESA_BLDRVERSION}-mgl/lib
          VISIT_VTK_LD_RUN_PATH=${CONTRIB_DIR}/mesa-${MESA_BLDRVERSION}-mgl/lib:$VISIT_VTK_LD_RUN_PATH
        fi
        VISIT_VTK_LD_RUN_PATH=${BUILD_DIR}/visit_vtk-$VISIT_VTK_BLDRVERSION/$VISIT_VTK_SER_BUILD/bin:${PYTHON_LIBDIR}:$VISIT_VTK_LD_RUN_PATH
        trimvar VISIT_VTK_LD_RUN_PATH ':'
        if test -n "$VISIT_VTK_LD_RUN_PATH"; then
          local VISIT_VTK_LD_RUN_ARGS="LD_RUN_PATH=$VISIT_VTK_LD_RUN_PATH"
        fi
        local VISIT_VTK_LD_LIB_PATH="$LD_LIBRARY_PATH"
        if test -n "$LIBFORTRAN_DIR"; then
          VISIT_VTK_LD_LIB_PATH="$LIBFORTRAN_DIR:$VISIT_VTK_LD_LIB_PATH"
        fi
        case $PYTHON_LIB_LIBDIR in
          /usr/lib | /usr/lib64)
            ;;
          *)
            VISIT_VTK_LD_LIB_PATH="$PYTHON_LIB_LIBDIR:$VISIT_VTK_LD_LIB_PATH"
            ;;
        esac
        trimvar VISIT_VTK_LD_LIB_PATH ':'
        if test -n "$VISIT_VTK_LD_LIB_PATH"; then
          local VISIT_VTK_LD_LIB_ARGS="LD_LIBRARY_PATH=$VISIT_VTK_LD_LIB_PATH"
         fi
        techo "VISIT_VTK_LD_LIB_ARGS = $VISIT_VTK_LD_LIB_ARGS."
        if test -n "$VISIT_VTK_LD_RUN_ARGS" -o -n "$VISIT_VTK_LD_LIB_ARGS"; then
          local VISIT_VTK_ENV=$VISIT_VTK_LD_RUN_ARGS $VISIT_VTK_LD_LIB_ARGS
        fi
        trimvar VISIT_VTK_ENV ' '
        VISIT_VTK_MAKE_ARGS="$VISIT_VTK_MAKEJ_ARGS"
        if test -z "$PYTHON"; then
          techo "PYTHON NOT SET.  VISIT_VTK Python wrappers will not build."
          return
        fi
        VISIT_VTK_PYTHON_ARGS="$VISIT_VTK_PYTHON_ARGS -DPYTHON_EXECUTABLE:FILEPATH='$PYTHON' -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCDIR -DPYTHON_LIBRARY:FILEPATH=$PYTHON_SHLIB"
        VISIT_VTK_OS_ARGS="$VISIT_VTK_OS_ARGS -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=ON"
        ;;

    esac

#
# Determine compilers and mesa args
#
# CYGWIN uses serial compilers, does not use Mesa
# Others use gcc, use mesa
# build_visit sets both of these the same for Darwin
    local VISIT_VTK_COMPILERS="$CMAKE_COMPILERS_PYC"
    local VISIT_VTK_COMPFLAGS=
    local MANGLED_OSMESA_LIB=libOSMesa${SHOBJEXT}
    local VISIT_VTK_MESA_ARGS=
    case `uname` in
      CYGWIN*)
        local cygcc=`cygpath -am "$CC"`.exe
        local cygcxx=`cygpath -am "$CXX"`.exe
        VISIT_VTK_COMPILERS="-DCMAKE_C_COMPILER:FILEPATH='$cygcc' -DCMAKE_CXX_COMPILER:FILEPATH='$cygcxx'"
        # techo "VISIT_VTK_COMPILERS = $VISIT_VTK_COMPILERS."
        ;;
      *)
        VISIT_VTK_COMPFLAGS="-DCMAKE_C_FLAGS:STRING='-fno-common -fexceptions' -DCMAKE_CXX_FLAGS:STRING='-fno-common -fexceptions'"
        # if $VISIT_VTK_BUILD_WITH_MESA; then
        if test -e $CONTRIB_DIR/mesa-mgl; then
          VISIT_VTK_MESA_ARGS="-DVTK_USE_MANGLED_MESA:BOOL=OFF -DVTK_OPENGL_HAS_OSMESA:BOOL=ON -DOSMESA_INCLUDE_DIR:PATH=$CONTRIB_DIR/mesa-mgl/include -DOSMESA_LIBRARY:FILEPATH=$CONTRIB_DIR/mesa-mgl/lib/${MANGLED_OSMESA_LIB}"
        fi
        ;;
    esac

# Determine hdf5 args
    local VISIT_VTK_HDF5_DIR=$HDF5_CC4PY_DIR
    VISIT_VTK_HDF5_DIR=${VISIT_VTK_HDF5_DIR:-"$HDF5_SERSH_DIR"}
    VISIT_VTK_HDF5_DIR=${VISIT_VTK_HDF5_DIR:-"$HDF5_SER_DIR"}
    local VISIT_VTK_HDF5_ARGS=
    if test -n "$VISIT_VTK_HDF5_DIR"; then
      if [[ `uname` =~ CYGWIN ]]; then
        VISIT_VTK_HDF5_DIR=`cygpath -am $VISIT_VTK_HDF5_DIR`
      fi
# The location of hdf5-config.cmake has been changing with each version.
# When it settles, we will have the * case.
      case $HDF5_BLDRVERSION in
        1.8.7) VISIT_VTK_HDF5_ARGS="-DHDF5_DIR:PATH=$VISIT_VTK_HDF5_DIR/share/cmake/hdf5-1.8.7";;
        1.8.8 | 1.8.9) VISIT_VTK_HDF5_ARGS="-DHDF5_DIR:PATH=$VISIT_VTK_HDF5_DIR/share/cmake/hdf5";;
        1.8.10) VISIT_VTK_HDF5_ARGS="-DHDF5_DIR:PATH=$VISIT_VTK_HDF5_DIR/cmake/hdf5";;
        1.8.*) techo "WARNING: Location of hdf5-config.cmake not known.  Please update visit_vtk.sh."
      esac
    fi

# Per build_visit:
# Linking OSMesa for MANGLED_MESA_LIBRARY is correct here; we'll never use
# MesaGL, as that is a xlib-based software path.  If we have an X context,
# we always want to use the 'system's GL library.
# The only time this is not done is Linux-static
# For Windows, try not replacing the RELEASE flags
    local VISIT_VTK_CONFIG_ARGS=" \
      -DVTK_DEBUG_LEAKS:BOOL=OFF \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DVTK_INSTALL_INCLUDE_DIR:PATH=/include/ \
      -DVTK_INSTALL_LIB_DIR:PATH=/lib/ \
      -DBUILD_TESTING:BOOL=OFF \
      -DBUILD_DOCUMENTATION:BOOL=OFF \
      -DVTK_USE_NETCDF:BOOL=OFF \
      -DVTK_USE_EXODUS:BOOL=OFF \
      -DVTK_USE_TK:BOOL=OFF \
      -DVTK_USE_64BIT_IDS:BOOL=ON \
      -DVTK_USE_INFOVIS:BOOL=OFF \
      -DVTK_USE_METAIO:BOOL=OFF \
      -DVTK_USE_PARALLEL:BOOL=OFF \
      -DVTK_LEGACY_REMOVE:BOOL=ON \
      -DVTK_USE_SYSTEM_JPEG:BOOL=OFF \
      -DVTK_USE_SYSTEM_PNG:BOOL=OFF \
      -DVTK_USE_SYSTEM_TIFF:BOOL=OFF \
      -DVTK_USE_SYSTEM_ZLIB:BOOL=OFF \
      $VISIT_VTK_HDF5_ARGS \
      $VISIT_VTK_OS_ARGS \
      $VISIT_VTK_COMPILERS \
      $VISIT_VTK_COMPFLAGS \
      ${VISIT_VTK_MESA_ARGS} $VISIT_VTK_PYTHON_ARGS $VISIT_VTK_SER_OTHER_ARGS"
    if bilderConfig visit_vtk $VISIT_VTK_SER_BUILD "$VISIT_VTK_CONFIG_ARGS" "" "$VISIT_VTK_ENV"; then
# Build
      bilderBuild $VISIT_VTK_BUILD_ARGS visit_vtk $VISIT_VTK_SER_BUILD "$VISIT_VTK_MAKE_ARGS" "$VISIT_VTK_ENV"
    fi
  fi

}

######################################################################
#
# Test
#
######################################################################

testVisIt_Vtk() {
  techo "Not testing visit_vtk."
}

######################################################################
#
# Install
#
######################################################################

installVisIt_Vtk() {
  bilderInstall $VISIT_VTK_BUILD_ARGS -r visit_vtk $VISIT_VTK_SER_BUILD "" "" "$VISIT_VTK_ENV"
  # techo "Quitting at the end of visit_vtk.sh."; exit
}

