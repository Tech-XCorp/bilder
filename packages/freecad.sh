#!/bin/bash
#
# Version and build information for freecad.
#
# Current tarball created from the trunk:
# svn co https://free-cad.svn.sourceforge.net/svnroot/free-cad/trunk freecad
# Revision is r5443
#
# To run this, for OS X:
#  export DYLD_LIBRARY_PATH=/volatile/freecad/lib:/volatile/freecad/Mod/PartDesign:/contrib/boost-1_47_0-ser/lib:/volatile/oce-r747-ser/lib
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

FREECAD_BLDRVERSION=${FREECAD_BLDRVERSION:-"0.13.5443"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Only the python build needed.
FREECAD_BUILDS=${FREECAD_BUILDS:-"$FORPYTHON_BUILD"}
FREECAD_BUILD=$FORPYTHON_BUILD
FREECAD_DEPS=SoQt,coin,pyqt,xercesc,eigen3,oce,boost,f2c
FREECAD_UMASK=002
FREECAD_URL=git://free-cad.git.sourceforge.net/gitroot/free-cad/free-cad
addtopathvar PATH $CONTRIB_DIR/freecad/bin

######################################################################
#
# Launch freecad builds.
#
######################################################################

#
# Get freecad using git.
#
getFreecad() {
  updateRepo freecad
}

buildFreecad() {

# Get freecad from repo
  techo -2 "Getting freecad."
  (cd $PROJECT_DIR; getFreecad)

# Check for svn version or package
  getVersion freecad
# Patch
  cd $PROJECT_DIR
  if test -f $BILDER_DIR/patches/freecad.patch; then
    cmd="(cd freecad; patch -p1 <$BILDER_DIR/patches/freecad.patch)"
    techo "$cmd"
    eval "$cmd"
  fi

  if ! bilderPreconfig -c freecad; then
    return 1
  fi

# Find qt
  if ! QMAKE_PATH=`which qmake 2>/dev/null`; then
    techo "WARNING: Could not find qmake in path. Please add location of qmake to your path in the case that QT CMake Macros can not be found by the freecad configuration system"
    return 1
  fi
  techo "Found qmake in ${QMAKE_PATH}. Needed for FindQt4.cmake for proper configuration."

# These will need conversion for Windows
  local FREECAD_ADDL_ARGS="-DFREECAD_USE_FREETYPE:BOOL=FALSE -DFREECAD_MAINTAINERS_BUILD:BOOL=TRUE -DBoost_NO_SYSTEM_PATHS:BOOL=TRUE -DBoost_NO_BOOST_CMAKE:BOOL=TRUE"
  local boostdir="${CONTRIB_DIR}/boost-sersh"
  local eigendir="${CONTRIB_DIR}/eigen3-sersh"
  local xercescdir="${CONTRIB_DIR}/xercesc-sersh"
  local coin3ddir="${CONTRIB_DIR}/coin-$FREECAD_BUILD"
  local ocerootdir="${BLDR_INSTALL_DIR}/oce-$FREECAD_BUILD"
  for i in boostdir eigendir xercescdir coin3ddir ocerootdir; do
    val=`deref $i`
    val=`(cd $val; pwd -P)`
    if [[ `uname` =~ CYGWIN ]]; then
       val=`cygpath -am $val`
    fi
    eval $i="$val"
  done
  FREECAD_ADDL_ARGS="$FREECAD_ADDL_ARGS -DBOOST_ROOT:STRING='$boostdir' -DEIGEN3_INCLUDE_DIR:PATH='$eigendir/include/eigen3' -DXERCESC_INCLUDE_DIR:PATH='$xercescdir/include'"

  local libpre=
  local libpost=
  local ocedevdir=
  case `uname` in
    CYGWIN*)
      libpre=
      libpost=lib
      ;;
    Darwin)
      libpre=lib
      libpost=dylib
      ocedevdir=`ls -d ${ocerootdir}/OCE.framework/Versions/*-dev | tail -1`/Resources
      FREECAD_ADDL_ARGS="${FREECAD_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING='-undefined dynamic_lookup -L${ocerootdir}/lib $SER_EXTRA_LDFLAGS'"
      ;;
    Linux)
      libpre=lib
      libpost=so
      ocedevdir=`ls -d ${ocerootdir}/lib/oce-*-dev | tail -1`
      FREECAD_ADDL_ARGS="${FREECAD_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING='$SER_EXTRA_LDFLAGS'"
      if test -n "$PYC_LD_RUN_PATH"; then
        FREECAD_ENV="LD_RUN_PATH=$PYC_LD_RUN_PATH"
      fi
      ;;
  esac
  FREECAD_ADDL_ARGS="${FREECAD_ADDL_ARGS} -DXERCESC_LIBRARIES:FILEPATH='${xercescdir}/lib/${libpre}xerces-c-3.1.$libpost' -DCOIN3D_INCLUDE_DIR:PATH='${coin3ddir}/include' -DCOIN3D_LIBRARY:FILEPATH='${coin3ddir}/lib/${libpre}Coin.$libpost' -DSOQT_LIBRARY:FILEPATH='${coin3ddir}/lib/${libpre}SoQt.$libpost' -DOCE_DIR='${ocedevdir}'"

# Previously used
#  -DOCC_LIBRARY_DIR='${ocerootdir}/lib'
# -DF2C_LIBRARIES:FILEPATH='${CONTRIB_DIR}/f2c-${F2C_BLDRVERSION}-ser/lib/libf2c.a'  ???

# Configure and build
  if bilderConfig -c freecad $FREECAD_BUILD "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $FREECAD_ADDL_ARGS $FREECAD_OTHER_ARGS"; then
# Parallel builds failing
    # bilderBuild freecad $FREECAD_BUILD "$FREECAD_MAKEJ_ARGS $FREECAD_ENV"
    bilderBuild freecad $FREECAD_BUILD "$FREECAD_ENV"
  fi

}

######################################################################
#
# Test freecad
#
######################################################################

testFreecad() {
  techo "Not testing freecad."
}

######################################################################
#
# Install freecad
#
######################################################################

installFreecad() {
  if bilderInstall freecad $FREECAD_BUILD; then
    case `uname` in
      Darwin | Linux)
        libpathval="$BLDR_INSTALL_DIR/freecad-${FREECAD_BLDRVERSION}-$FREECAD_BUILD/lib:$BLDR_INSTALL_DIR/freecad-${FREECAD_BLDRVERSION}-$FREECAD_BUILD/Mod/PartDesign:$CONTRIB_DIR/qt-${QT_BLDRVERSION}-$FREECAD_BUILD/lib:$CONTRIB_DIR/oce-${OCE_BLDRVERSION}-$FREECAD_BUILD/lib:$CONTRIB_DIR/xercesc-${XERCESC_BLDRVERSION}-$FREECAD_BUILD/lib:$CONTRIB_DIR/boost-${BOOST_BLDRVERSION}-$FREECAD_BUILD/lib:$CONTRIB_DIR/Coin-${COIN_BLDRVERSION}-$FREECAD_BUILD/lib"
        case `uname` in
          Darwin) libpathvar=DYLD_LIBRARY_PATH;;
          Linux)
            libpathvar=LD_LIBRARY_PATH
            libpathval="$libpathval:$PYC_LD_RUN_PATH"
            ;;
        esac
        cat >$BLDR_INSTALL_DIR/freecad-$FREECAD_BUILD/bin/freecad.sh <<EOF
#!/bin/bash
myenv="$libpathvar=$libpathval"
mydir=\`dirname \$0\`
mydir=\`(cd \$mydir; pwd -P)\`
cmd="env \$myenv \$mydir/freecad -P $PYTHON_SITEPKGSDIR"
echo \$cmd
\$cmd
EOF
      chmod a+x $BLDR_INSTALL_DIR/freecad-$FREECAD_BUILD/bin/freecad.sh
      ;;
    esac
  fi
}

