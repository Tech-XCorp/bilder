#!/bin/bash
#
# Version and build information for vtk
#
# $Id$
#
######################################################################

######################################################################
#
# Version.
# This is directly from the VisIt repo at
# svn export https://portal.nersc.gov/svn/visit/trunk/third_party/VTK-5e3c539.tar.gz
# Build info taken from
# svn export svn export http://portal.nersc.gov/svn/visit/trunk/src/svn_bin/bv_support/bv_vtk.sh
#
######################################################################

VTK_BLDRVERSION=${VTK_BLDRVERSION:-"5e3c539"}
VTK_NAME=${VTK_NAME:-"VTK"}  # Needed because of vtk -> VTK

######################################################################
#
# Other values
#
######################################################################

VTK_BUILDS=${VTK_BUILDS:-"$FORPYTHON_BUILD"}
VTK_BUILD=$FORPYTHON_BUILD
VTK_DEPS=mesa,cmake

######################################################################
#
# Launch vtk builds.
#
######################################################################

buildVtk() {

  if ! bilderUnpack VTK; then
    return 1
  fi

# Set up variables
  VTK_NAME=${VTK_NAME:-"VTK"}
  local VTK_PREFIX="VTK"
  local VTK_LD_RUN_PATH=
  local VTK_OS_ARGS=
  local VTK_PKG_ARGS=
  local VTK_PYTHON_ARGS=
  local VTK_MAKE_ARGS=
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
          VTK_PYTHON_ARGS="$VTK_PYTHON_ARGS -DPYTHON_EXECUTABLE:FILEPATH='$MIXED_PYTHON' -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCDIR"
         ;;
      esac
# Protect against jom, as dependencies not right
      VTK_BUILD_ARGS="-m nmake"
      ;;
    Darwin)	# make -j can fail on Darwin
      VTK_OS_ARGS="$VTK_OS_ARGS -DVTK_USE_CARBON:BOOL=OFF -DVTK_USE_COCOA:BOOL=ON"
      case `uname -r` in
        9.*) ;;
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
        /usr/lib | /usr/lib64) ;;
        *) VTK_LD_LIB_PATH="$PYTHON_LIB_LIBDIR:$VTK_LD_LIB_PATH";;
      esac
      trimvar VTK_LD_LIB_PATH ':'
      if test -n "$VTK_LD_LIB_PATH"; then
        local VTK_LD_LIB_ARGS="LD_LIBRARY_PATH=$VTK_LD_LIB_PATH"
       fi
      techo "VTK_LD_LIB_ARGS = $VTK_LD_LIB_ARGS."
      if test -n "$VTK_LD_RUN_ARGS" -o -n "$VTK_LD_LIB_ARGS"; then
        local VTK_ENV="$VTK_LD_RUN_ARGS $VTK_LD_LIB_ARGS"
      fi
      trimvar VTK_ENV ' '
      VTK_MAKE_ARGS="$VTK_MAKE_ARGS $VTK_MAKEJ_ARGS"
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
# Use PYC compilers
# Upon going to VTK6, only Linux uses mesa
  VTK_COMPILERS="$CMAKE_COMPILERS_PYC"
  VTK_FLAGS="$CMAKE_COMPFLAGS_PYC"
  case `uname` in
    CYGWIN*)
      ;;
    Linux)
      VTK_MESA_ARGS="-DVTK_USE_MANGLED_MESA:BOOL=ON -DMANGLED_MESA_INCLUDE_DIR:PATH=$CONTRIB_DIR/mesa-mgl/include -DMANGLED_MESA_LIBRARY:FILEPATH=$CONTRIB_DIR/mesa-mgl/lib/${MANGLED_MESA_LIB} -DMANGLED_OSMESA_INCLUDE_DIR:PATH=$CONTRIB_DIR/mesa-mgl/include -DMANGLED_OSMESA_LIBRARY:FILEPATH=$CONTRIB_DIR/mesa-mgl/lib/${MANGLED_OSMESA_LIB}"
      ;;
  esac

# Packages
# Turn off module groups
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -D${VTK_PREFIX}_Group_Imaging:BOOL=OFF"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -D${VTK_PREFIX}_Group_MPI:BOOL=OFF"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -D${VTK_PREFIX}_Group_Qt:BOOL=OFF"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -D${VTK_PREFIX}_Group_Rendering:BOOL=OFF"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -D${VTK_PREFIX}_Group_StandAlone:BOOL=OFF"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -D${VTK_PREFIX}_Group_Tk:BOOL=OFF"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -D${VTK_PREFIX}_Group_Views:BOOL=OFF"

# Turn on individual modules. dependent modules are turned on automatically
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkCommonCore:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkFiltersFlowPaths:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkFiltersHybrid:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkFiltersModeling:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkGeovisCore:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkIOEnSight:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkIOGeometry:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkIOLegacy:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkIOPLY:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkIOXML:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkInteractionStyle:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkRenderingAnnotation:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkRenderingFreeType:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkRenderingFreeTypeOpenGL:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkRenderingOpenGL:BOOL=ON"
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtklibxml2:BOOL=ON"

# Turn on QtOpenGL
  VTK_PKG_ARGS="${VTK_PKG_ARGS} -DModule_vtkGUISupportQtOpenGL:BOOL=ON"

# Per build_visit:
# Linking OSMesa for MANGLED_MESA_LIBRARY is correct here; we'll never use
# MesaGL, as that is a xlib-based software path.  If we have an X context,
# we always want to use the 'system's GL library.
# The only time this is not done is Linux-static
# For Windows, try not replacing the RELEASE flags
  local otherargsvar=`genbashvar VTK_${VTK_BUILD}`_OTHER_ARGS
  local otherargsval=`deref $otherargsvar`
  local VTK_CONFIG_ARGS="$VTK_COMPILERS $VTK_FLAGS $VTK_OS_ARGS -DBUILD_TESTING:BOOL=OFF -DBUILD_DOCUMENTATION:BOOL=OFF -D${VTK_PREFIX}_ALL_NEW_OBJECT_FACTORY:BOOL=TRUE -DUSE_ANSI_STD_LIB:BOOL=ON -DVTK_USE_HYBRID:BOOL=ON ${VTK_PKG_ARGS} ${VTK_MESA_ARGS} $VTK_PYTHON_ARGS $otherargsval"
  techo -2 "VTK_CONFIG_ARGS=$VTK_CONFIG_ARGS"
# Pass with commas and separate later.
  if bilderConfig $VTK_NAME $VTK_BUILD "$VTK_CONFIG_ARGS" "" "$VTK_ENV"; then
# Build
    bilderBuild $VTK_BUILD_ARGS $VTK_NAME $VTK_BUILD "$VTK_MAKE_ARGS" "$VTK_ENV"
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
  if bilderInstall $VTK_BUILD_ARGS -r $VTK_NAME $VTK_BUILD "" "" "$VTK_ENV"; then
    case `uname` in
      Linux)
        runnrExec "rm -f $CONTRIB_DIR/$VTK_NAME-$VTK_BLDRVERSION-$VTK_BUILD/include/MangleMesaInclude"
        runnrExec "ln -s $CONTRIB_DIR/mesa-$MESA_BLDRVERSION-mgl/include/GL $CONTRIB_DIR/$VTK_NAME-$VTK_BLDRVERSION-$VTK_BUILD/include/MangleMesaInclude"
        ;;
    esac
  fi
}

