#!/bin/bash
#
# Version and build information for R
#
# $Id: r.sh 4858 2012-01-11 19:13:22Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

R_BLDRVERSION=${R_BLDRVERSION:-"2.14.1"}
R_BUILDS=${R_BUILDS:-"ser"}
R_DEPS=

######################################################################
#
# Other values
#
######################################################################
case `uname` in
    CYGWIN*)
	unset R_BUILDS
	;;
esac

######################################################################
#
# Launch R builds.
#
######################################################################

buildR() {
  if bilderUnpack R; then
    if bilderConfig R ser "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $SER_CONFIG_LDFLAGS --enable-R-shlib"; then
      bilderBuild R ser
    fi
  fi
}

######################################################################
#
# Test R
#
######################################################################

testR() {
  techo "Not testing R."
}

######################################################################
#
# Install R
#
######################################################################

installR() {
# Ignore installation errors.  R tries to set perms of /contrib/bin.
  bilderInstall R ser "" ""
}

