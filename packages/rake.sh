#!/bin/bash
#
# Version and build information for rake (ruby make and scripting)
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

RAKE_BLDRVERSION_STD=0.8.7

######################################################################
#
# Other values
#
######################################################################

RAKE_BUILDS=${RAKE_BUILDS:-"ser"}
RAKE_DEPS=ruby
# RAKE_UMASK=002

#####################################################################
#
# Launch rake builds.
#
######################################################################

buildRake() {

  if bilderUnpack rake; then
      techo "Only unpacking rake in build step"
  fi
}

######################################################################
#
# Test rake
#
######################################################################

testRake() {
  techo "Not testing rake."
}

######################################################################
#
# Install rake
#
######################################################################

installRake() {
  techo "rake installs into appropriate ruby install directories"
  techo "Explicitly changing to rake build directory rake-$RAKE_BLDRVERSION_STD"
  cd $BUILD_DIR/rake-$RAKE_BLDRVERSION_STD
  $CONTRIB_DIR/ruby-ser/bin/ruby install.rb
}

