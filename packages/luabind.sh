#!/bin/bash
#
# Version and build information for luabind
#
# $Id: luabind.sh 6364 2012-07-15 09:04:57Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LUABIND_BLDRVERSION=${LUABIND_BLDRVERSION:-"0.9.1"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$LUABIND_BUILDS"; then
  LUABIND_BUILDS=ser
fi
# Deps include autotools for configuring tests
LUABIND_DEPS=lua,boost,cmake
trimvar LUABIND_DEPS ','

######################################################################
#
# Launch luabind builds.
#
######################################################################

buildLuabind() {

# Check for svn version or package
  if test -d $PROJECT_DIR/luabind; then
    getVersion luabind
    bilderPreconfig -c luabind
    res=$?
  else
    bilderUnpack luabind
    res=$?
  fi
  LUABIND_MAKE_ARGS="$JMAKEARGS"

# Regular build
  if test $res = 0; then
# Do quotes around compilers cause problems with cygwin.vs9?
    if bilderConfig -c luabind ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $LUABIND_SER_OTHER_ARGS"; then
      bilderBuild luabind ser "$LUABIND_MAKE_ARGS"
    fi
  fi

}

######################################################################
#
# Test luabind
#
######################################################################

testLuabind() {
  echo "Nothing to do"
}

######################################################################
#
# Install luabind
#
######################################################################

installLuabind() {
  bilderInstallTestedPkg -p open luabind LuabindTests
}

