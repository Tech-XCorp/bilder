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

  getVersion scotch
  bilderPreconfig scotch
  res=$?

  if test $res = 0; then
      local cmd=''
      case `uname` in
	  Darwin)
	      cmd="cp src/Make.inc/Makefile.inc.i686_mac_darwin10 src/Makefile.inc"
	      ;;
	  Linux)
	      cmd="cp src/Make.inc/Makefile.inc.i686_pc_linux2 src/Makefile.inc"
	      ;;
      esac
      if bilderConfig -c scotch par "$CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR"; then
	  bilderBuild scotch par
      fi
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
  bilderInstallAll scotch "  -r -p open"
}

