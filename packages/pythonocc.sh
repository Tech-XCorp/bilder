#!/bin/bash
#
# Version and build information for pythonocc
#
# $Id$
#
######################################################################

# The tarball,
cat >/dev/null <<EOF
tar xzf ../numpkgs/pythonocc-0.5.tar.gz
cd pythonocc-0.5
tar xzf ../../numpkgs/pythonocc-0.5-examples.tar.gz
# Remove OS X resource files
find . -name "._*" -delete
cd ..
tar czf ../numpkgs/pythonocc-0.5.tar.gz  pythonocc-0.5
EOF
# is too old.  Better to get the latest git version from
# git clone https://github.com/tpaviot/pythonocc.git

# Building smesh (must be done in place)
cat >/dev/null <<EOF
cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/smesh-5.1.2.2 \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=TRUE \
  -DOCE_DIR:PATH=/contrib/oce/OCE.framework/Versions/0.10-dev/Resources \
  -DCMAKE_SHARED_LINKER_FLAGS:STRING='-L/opt/local/lib' \
  .
make all install
# fails
EOF

# Building pythonocc.
cat >/dev/null <<EOF
mkdir -p build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/pythonocc-0.6dev.0.r1291 \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=TRUE \
  -DSMESH_INCLUDE_PATH:PATH=/contrib/smesh-5.1.2.2/include/smesh \
  -DSMESH_LIB_PATH:PATH=/contrib/smesh-5.1.2.2/lib \
  -DOCE_DIR:PATH=/contrib/oce/OCE.framework/Versions/0.10-dev/Resources \
  -DOCE_INCLUDE_PATH:PATH=/contrib/oce/include \
  -DOCE_LIB_PATH:PATH=/contrib/oce/lib \
  -DCMAKE_SHARED_LINKER_FLAGS:STRING='-L/opt/local/lib' \
  -DpythonOCC_INSTALL_DIRECTORY:PATH=/contrib/lib/python2.6/site-packages/OCC \
  ..
make all install
# To run (not yet working):
DYLD_LIBRARY_PATH=/volatile/FreeCAD-r5443-ser/lib:/contrib/boost-1_47_0-ser/lib
PYTHONPATH=/volatile/FreeCAD-r5443-ser/bin/pivy:$PYTHONPATH
EOF

######################################################################
#
# Version
#
######################################################################

PYTHONOCC_BLDRVERSION=0.5

######################################################################
#
# Builds and deps
#
######################################################################

PYTHONOCC_BUILDS=${PYTHONOCC_BUILDS:-"pycsh"}
PYTHONOCC_DEPS=Python,atlas # Okay to have an unfound dependency

######################################################################
#
# Launch pythonocc builds.
#
######################################################################

buildPythonocc() {

  if bilderUnpack pythonocc; then

    cd $BUILD_DIR/pythonocc-${PYTHONOCC_BLDRVERSION}

# Build/install
    bilderDuBuild pythonocc "--disable-GEOM --disable-SMESH --with-occ-include=$CONTRIB_DIR/oce-0.10.1-r747-ser/include --with-occ-lib=$CONTRIB_DIR/oce-0.10.1-r747-ser/lib " "$PYTHONOCC_ENV"

  fi

}

######################################################################
#
# Test pythonocc
#
######################################################################

testPythonocc() {
  techo "Not testing pythonocc."
}

######################################################################
#
# Install pythonocc
#
######################################################################

installPythonocc() {
  case `uname` in
    CYGWIN*) bilderDuInstall -n pythonocc "-" "$PYTHONOCC_ENV";;
    *) bilderDuInstall -r pythonocc pythonocc "-" "$PYTHONOCC_ENV";;
  esac
  # techo "WARNING: Quitting at end of pythonocc.sh."; exit
}

