#!/bin/bash
#
# Version and build information for txbtests
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Builds and deps
#
######################################################################

TXBTESTS_BUILDS=${TXBTESTS_BUILDS:-"all"}
TXBTESTS_DEPS=autotools,txutils
TXBTESTS_TESTDATA=txbresults

######################################################################
#
# Configure and build
#
######################################################################

buildTxbTests() {

# Get version.
  getVersion txbtests
  # techo "version = $TXBTESTS_BLDRVERSION."

# Test builds are called only when the non-ignored builds of the
# project all built successfully.  In this case, tests have to
# be run.  So here, forcetests should always contain -f.
# installed, force tests.
if false; then
  local forcetests=`getForceTests txbase`
  if test -n "$forcetests"; then
    techo "Current version, $TXBASE_BLDRVERSION, of txbase needs to be installed.  Will run txbtests."
  fi
fi
  local forcetests=-f

# Configure and run all tests
  if bilderPreconfig -t $forcetests txbtests; then
    cmd="bilderConfig -i -t $forcetests txbtests all '--with-source-dir=$PROJECT_DIR/txbase --with-serial-dir=${BUILD_DIR}/txbase/ser --with-parallel-dir=${BUILD_DIR}/txbase/par --with-txutils-dir=$BLDR_INSTALL_DIR/txutils $CONFIG_SUPRA_SP_ARG $EMAIL_ARG $MPI_LAUNCHER_ARG'"
    if eval "$cmd"; then
      local TXBTESTS_BUILD_ARGS=
      if [[ `uname` =~ CYGWIN ]]; then
        TXBTESTS_BUILD_ARGS="RUNTXTEST_OTHER_ARGS=-k"
      fi
      bilderBuild txbtests all "all runtests $TXBTESTS_BUILD_ARGS"
    fi
  fi

}

######################################################################
#
# Install.  Return whether tests succeeded
#
######################################################################

installTxbTests() {
  cmd="waitNamedTest txbtests txbase-txtest"
  echo $cmd
  $cmd
  return $?
}

