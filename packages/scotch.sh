#!/bin/bash
#
# Build information for scotch
# PETSc does not allow serial build w/scotch
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in scotch_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/scotch_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setScotchNonTriggerVars() {
  SCOTCH_UMASK=002
}
setScotchNonTriggerVars

######################################################################
#
# Launch scotch builds.
#
######################################################################

buildScotch() {

  if ! bilderUnpack scotch; then
    return 1
  fi

      local cmd=''
      case `uname` in
	  Darwin)
	      cmd="cp $BUILD_DIR/scotch-$SCOTCH_BLDRVERSION/src/Make.inc/Makefile.inc.i686_mac_darwin10_mpi_nopthread $BUILD_DIR/scotch-$SCOTCH_BLDRVERSION/src/Makefile.inc"
	      ;;
	  Linux)
	      cmd="cp $BUILD_DIR/scotch-$SCOTCH_BLDRVERSION/src/Make.inc/Makefile.inc.i686_pc_linux2_mpi $BUILD_DIR/scotch-$SCOTCH_BLDRVERSION/src/Makefile.inc"
	      ;;
      esac
      techo $cmd
      $cmd
      if bilderConfig -B src scotch par "$CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR"; then
	  bilderBuild -m "cd src/; make $SCOTCH_MAKEJ_ARGS ptscotch; cd ../" scotch par
      fi

}

######################################################################
#
# Test scotch
#
######################################################################

testScotch() {
  techo "Not testing scotch."
}

######################################################################
#
# Install scotch
#
######################################################################

installScotch() {
  local cmd="mkdir ${CONTRIB_DIR}/scotch-$SCOTCH_BLDRVERSION-par"
  techo $cmd
  $cmd
  bilderInstall -m "cd src; make prefix=${CONTRIB_DIR}/scotch-$SCOTCH_BLDRVERSION-par install; cd ../" scotch par
}

