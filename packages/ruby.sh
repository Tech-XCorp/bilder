#!/bin/sh
######################################################################
#
# @file    ruby.sh
#
# @brief   Version and build information for ruby.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

RUBY_BLDRVERSION=${RUBY_BLDRVERSION:-"1.8.7.1"}

######################################################################
#
# Other values
#
######################################################################

# RUBY has only serial build
RUBY_BUILDS=${RUBY_BUILDS:-"ser"}
RUBY_DEPS=

######################################################################
#
# Launch RUBY builds.
#
######################################################################

buildRuby() {

  RUBY_SER_ARGS=" "
  RUBY_SER_OTHER_ARGS="$RUBY_SER_ARGS --disable-pthread --without-openssl"

  if bilderUnpack ruby; then

    if bilderConfig ruby ser "$RUBY_SER_OTHER_ARGS"; then
      bilderBuild ruby ser
    fi

  fi

}

######################################################################
#
# Test Ruby
#
######################################################################

testRuby() {
  techo "Not testing ruby."
}

######################################################################
#
# Install ruby
#
######################################################################

installRuby() {
  bilderInstall ruby ser ruby-ser
}
