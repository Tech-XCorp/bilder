#!/bin/bash
#
# Version and build information for grin
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# built from svn repo only

######################################################################
#
# Other values
#
######################################################################

GRIN_BUILDS=${GRIN_BUILDS:-"ser"}
GRIN_DEPS=cmake,hdf5
GRIN_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $BLDR_INSTALL_DIR/grin/bin

######################################################################
#
# Launch grin builds.
#
######################################################################

buildGrin() {

  getVersion grin
  if bilderPreconfig -c grin; then
    if bilderConfig grin ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SE $GRIN_SER_OTHER_ARGS"; then
      bilderBuild grin ser
    fi
  fi

}

######################################################################
#
# Test grin
#
######################################################################

testGrin() {
  techo "Not testing grin."
}

######################################################################
#
# Install grin
#
######################################################################

installGrin() {
 for bld in ser; do
    if bilderInstall -r grin $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/grin-$GRIN_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}

