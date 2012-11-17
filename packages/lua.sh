#!/bin/bash
#
# Version and build information for lua
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LUA_BLDRVERSION=${LUA_BLDRVERSION:-"5.1"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$LUA_BUILDS"; then
  LUA_BUILDS=ser
fi
# Deps include autotools for configuring tests
LUA_DEPS=cmake
trimvar LUA_DEPS ','

######################################################################
#
# Launch lua builds.
#
######################################################################

buildLua() {

# Check for svn version or package
  if test -d $PROJECT_DIR/lua; then
    getVersion lua
    bilderPreconfig -c lua
    res=$?
  else
    bilderUnpack lua
    res=$?
  fi
  LUA_MAKE_ARGS="$LUA_MAKEJ_ARGS"

# Regular build
  if test $res = 0; then
# Do quotes around compilers cause problems with cygwin.vs9?
    if bilderConfig -c lua ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $LUA_SER_OTHER_ARGS"; then
      bilderBuild lua ser "$LUA_MAKE_ARGS"
    fi
  fi

}

######################################################################
#
# Test lua
#
######################################################################

testLua() {
  echo "Nothing to do"
}

######################################################################
#
# Install lua
#
######################################################################

installLua() {
  bilderInstallTestedPkg -p open lua LuaTests
}

