#!/bin/bash
#
# Version and build information for freecad.
#
# Current tarball created from the trunk:
# svn co https://free-cad.svn.sourceforge.net/svnroot/free-cad/trunk FreeCAD
# Revision is r5443
#
# To run this, for OS X:
#  export DYLD_LIBRARY_PATH=/volatile/FreeCAD/lib:/volatile/FreeCAD/Mod/PartDesign:/contrib/boost-1_47_0-ser/lib:/volatile/oce-r747-ser/lib
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
#FREECAD_BLDRVERSION=${FREECAD_BLDRVERSION:-"0.12.5284"}

######################################################################
#
# Other values
#
######################################################################

FREECAD_BUILDS=${FREECAD_BUILDS:-"ser"}
FREECAD_DEPS=SoQt,Coin,pyqt,xercesc,eigen3,oce,ftgl,boost,f2c
FREECAD_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/freecad/bin

######################################################################
#
# Launch freecad builds.
#
######################################################################

buildFreecad() {

# Check for svn version or package
  if test -d $PROJECT_DIR/FreeCAD; then
    getVersion FreeCAD
    bilderPreconfig FreeCAD
    res=$?
  else
    bilderUnpack FreeCAD
    res=$?
  fi

  if test $res = 0; then

# These will need converson for Windows
    local FREECAD_ADDL_ARGS="-DFREECAD_MAINTAINERS_BUILD:BOOL=TRUE -DBOOST_ROOT:STRING='${CONTRIB_DIR}/boost' -DBoost_NO_SYSTEM_PATHS:BOOL=TRUE -DEIGEN3_INCLUDE_DIR:PATH='${CONTRIB_DIR}/eigen3/include/eigen3' -DXERCESC_INCLUDE_DIR:PATH='${CONTRIB_DIR}/xercesc/include'"
    if ! QMAKE_PATH=`which qmake 2>/dev/null`; then
      techo "WARNING: Could not find qmake in path. Please add location of qmake to your path in the case that QT CMake Macros can not be found by the FreeCAD configuration system"
    else
      techo "Found qmake in ${QMAKE_PATH}. Needed for FindQt4.cmake for proper configuration."
    fi
    local FREECAD_ENV
    case `uname` in
      Darwin)
        FREECAD_ADDL_ARGS="${FREECAD_ADDL_ARGS} -DXERCESC_LIBRARIES:FILEPATH='${CONTRIB_DIR}/xercesc/lib/libxerces-c-3.1.dylib' -DOCE_DIR='${BLDR_INSTALL_DIR}/oce/OCE.framework/Versions/0.12-dev/Resources' -DF2C_LIBRARIES:FILEPATH='${CONTRIB_DIR}/f2c-${F2C_BLDRVERSION}-ser/lib/libf2c.a' -DCOIN3D_INCLUDE_DIR:PATH='${CONTRIB_DIR}/Coin-cc4py/include' -DCOIN3D_LIBRARY:FILEPATH='${CONTRIB_DIR}/Coin-cc4py/lib/libCoin.dylib' -DSOQT_LIBRARY:FILEPATH='${CONTRIB_DIR}/Coin-cc4py/lib/libSoQt.dylib' -DCMAKE_SHARED_LINKER_FLAGS:STRING='-undefined dynamic_lookup -L/opt/local/lib'"
        ;;
      *)
        FREECAD_ADDL_ARGS="${FREECAD_ADDL_ARGS} -DXERCESC_LIBRARIES:FILEPATH='${CONTRIB_DIR}/xercesc/lib/libxerces-c-3.1.so' -DOCE_DIR='${BLDR_INSTALL_DIR}/oce/lib/oce-0.12-dev' -DCOIN3D_INCLUDE_DIR='${CONTRIB_DIR}/Coin-cc4py/include' -DCOIN3D_LIBRARY='${CONTRIB_DIR}/Coin-cc4py/lib/libCoin.so' -DSOQT_LIBRARY:FILEPATH='${CONTRIB_DIR}/Coin-cc4py/lib/libSoQt.so'"
        if test -n "$PYC_LD_RUN_PATH"; then
          FREECAD_ENV="LD_RUN_PATH=$PYC_LD_RUN_PATH"
        fi
        ;;
    esac

# Configure and build
    if bilderConfig -c FreeCAD ser "$FREECAD_ADDL_ARGS $FREECAD_OTHER_ARGS"; then
      bilderBuild FreeCAD ser "$FREECAD_MAKEJ_ARGS $FREECAD_ENV"
    fi

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
  if bilderInstall FreeCAD ser; then
    case `uname` in
      Darwin | Linux)
        libpathval="$BLDR_INSTALL_DIR/FreeCAD-${FREECAD_BLDRVERSION}-ser/lib:$BLDR_INSTALL_DIR/FreeCAD-${FREECAD_BLDRVERSION}-ser/Mod/PartDesign:$CONTRIB_DIR/qt-${QT_BLDRVERSION}-ser/lib:$CONTRIB_DIR/oce-${OCE_BLDRVERSION}-ser/lib:$CONTRIB_DIR/xercesc-${XERCESC_BLDRVERSION}-ser/lib:$CONTRIB_DIR/boost-${BOOST_BLDRVERSION}-ser/lib:$CONTRIB_DIR/Coin-${COIN_BLDRVERSION}-cc4py/lib"
        case `uname` in
          Darwin) libpathvar=DYLD_LIBRARY_PATH;;
          Linux)
            libpathvar=LD_LIBRARY_PATH
            libpathval="$libpathval:$PYC_LD_RUN_PATH"
            ;;
        esac
        cat >$BLDR_INSTALL_DIR/FreeCAD/bin/FreeCAD.sh <<EOF
#!/bin/bash
myenv="$libpathvar=$libpathval"
mydir=\`dirname \$0\`
mydir=\`(cd \$mydir; pwd -P)\`
cmd="env \$myenv \$mydir/FreeCAD -P $PYTHON_SITEPKGSDIR"
echo \$cmd
\$cmd
EOF
      chmod a+x $BLDR_INSTALL_DIR/FreeCAD/bin/FreeCAD.sh
      ;;
    esac
  fi
  # techo "WARNING: Quitting at end of freecad.sh."; cleanup
}

