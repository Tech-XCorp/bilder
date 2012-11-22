#!/bin/bash
#
# Version and build information for CHEF
#
# $Id$
#
######################################################################

# Need getRepo
if test -z "$SCRIPT_DIR"; then
    SCRIPT_DIR="${PROJECT_DIR}"
fi
techo -2 "SCRIPT_DIR = $SCRIPT_DIR"
source $SCRIPT_DIR/bilder/extrepofcns.sh

######################################################################
#
# Version
#
######################################################################

CHEF_LIBS_BLDRVERSION=${CHEF_LIBS_BLDRVERSION:-"master"}

######################################################################
#
# Other values
#
######################################################################

#CHEF_LIBS_BUILDS=${CHEF_LIBS_BUILDS:-"ser,par"}
CHEF_LIBS_BUILDS=${CHEF_LIBS_BUILDS:-"ser"}
trimvar CHEF_LIBS_BUILDS ','
#CHEF_LIBS_DEPS=Python,boost,?flex,?gxx,fftw3,?bison,libtool,numpy,?miniglib
CHEF_LIBS_DEPS=Python,boost,fftw3,libtool,numpy
trimvar CHEF_LIBS_DEPS ','
CHEF_LIBS_UMASK=002
CHEF_LIBS_SER_OTHER_ARGS=" --enable-implicit-templates"
CHEF_LIBS_PAR_OTHER_ARGS="${CHEF_LIBS_SER_OTHER_ARGS}"

######################################################################
#
# Launch chef builds.
#
######################################################################

buildCheflibs() {

# Check for git version
  local chefrepo='git://compacc.fnal.gov/home/scmuser/git/chef.git'
  cd $PROJECT_DIR
  res=$?
  if test $res = 0; then
    getRepo -g chef_libs $chefrepo "${CHEF_LIBS_BLDRVERSION}"
    res=$?
  fi
  if test $res = 0; then
# Do bootstrap if not already done (is this a hack?)
    if ! test -x chef_libs/configure; then
      cd $PROJECT_DIR/chef_libs
      techo "Running bootstrap in `pwd`"
      $PROJECT_DIR/chef_libs/bootstrap
      res=$?
    fi
  fi
  if test $res = 0; then
    if test -d $PROJECT_DIR/chef_libs; then
      getVersion chef_libs
      res=$?
      if test $res = 0; then
        bilderPreconfig chef_libs
        res=$?
      fi
    fi
  fi

  CHEF_LIBS_MAKE_ARGS="$CHEFLIBS_MAKEJ_ARGS"

# Look for glib
  if test -d /usr/lib64/glib-2.0/include; then
    GLIBCONFIG_INC="/usr/lib64/glib-2.0/include"
  elif test -d /usr/lib/glib-2.0/include; then
    GLIBCONFIG_INC="/usr/lib/glib-2.0/include"
  else
    techo "ERROR: glib include config file not found, CHEF build aborted"
    res=1
  fi
  if test -d /usr/include/glib-2.0; then
    GLIB_INC="/usr/include/glib-2.0"
  else
    techo "ERROR: glib include files not found, CHEF build aborted"
    res=1
  fi

# I know these library tests are bogus. Need to do right.
  if test -f /usr/lib64/libglib-2.0.so; then
    GLIB_LIB="/usr/lib64"
  else
    techo "ERROR: glib library files not found, CHEF build aborted"
    res=1
  fi

# Find python
  if [ ! -n "${PYTHON_BLDRVERSION}" ]
  then
    source $BILDER_DIR/packages/python.sh
    buildPython
    installPython
  fi

# Find boost
  findBoost
  if test -z "${Boost_INCLUDE_DIR}"; then
    buildBoost
    installBoost
  fi
# We need Boost_INCLUDE_DIR defined
  if ! test -n "${BOOST_INCDIR_ARG:2}"; then
    techo "ERROR: Boost not found? CHEF build aborted"
    res=1
  fi
  if test $res = 0; then
    eval ${BOOST_INCDIR_ARG:2}
  fi


# Set up the particular config args for CHEF
  CHEF_LIBS_SER_OTHER_ARGS="${CHEF_LIBS_SER_OTHER_ARGS} CXXFLAGS=-DBOOST_PYTHON_NO_PY_SIGNATURES FFTW3_INC=${FFTW3_INSTALL_DIR}/fftw3/include FFTW3_LIB=${FFTW3_INSTALL_DIR}/fftw3/lib GLIB_INC=${GLIB_INC} GLIBCONFIG_INC=${GLIBCONFIG_INC} GLIB_LIB=${GLIB_LIB} PYTHON_INC=${PYTHON_INCDIR} BOOST_INC=${Boost_INCLUDE_DIR}"
  CHEF_LIBS_PAR_OTHER_ARGS="${CHEF_LIBS_PAR_OTHER_ARGS} CXXFLAGS=-DBOOST_PYTHON_NO_PY_SIGNATURES FFTW3_INC=${FFTW3_INSTALL_DIR}/fftw3-par/include FFTW3_LIB=${FFTW3_INSTALL_DIR}/fftw3-par/lib GLIB_INC=${GLIB_INC} GLIBCONFIG_INC=${GLIBCONFIG_INC} GLIB_LIB=${GLIB_LIB} PYTHON_INC=${PYTHON_INCDIR} BOOST_INC=${Boost_INCLUDE_DIR}"

# Regular build
  if test $res = 0; then
# Do quotes around compilers cause problems with cygwin.vs9?
    if bilderConfig chef_libs ser "$CHEF_LIBS_SER_OTHER_ARGS"; then
      bilderBuild chef_libs ser "$CHEF_LIBS_MAKE_ARGS"
      res=$?
      techo "bilderBuild of chef_libs ser returned $res"
    fi
    if bilderConfig chef_libs par "-DENABLE_PARALLEL:BOOL=TRUE $CHEF_LIBS_PAR_OTHER_ARGS"; then
      bilderBuild chef_libs par "$CHEF_LIBS_MAKE_ARGS"
      res=$?
      techo "bilderBuild of chef_libs par returned $res"
    fi
#    if bilderConfig chef_libs cc4py "$CHEF_LIBS_CC4PY_OTHER_ARGS"; then
#      bilderBuild chef_libs cc4py "$CHEF_LIBS_MAKE_ARGS"
 #   fi
  fi

  return $res
}

######################################################################
#
# Test chef
#
######################################################################

testCheflibs() {
  techo "Not testing CHEF libs"
  # Need to see how to run run_all_tests.sh in the chef_libs dir
}

######################################################################
#
# Install chef
#
######################################################################

installCheflibs() {
  if bilderInstall -r chef_libs ser; then
# Make sure perms are correct.
    case $FQMAILHOST in
      *.ornl.gov | *.nersc.gov | *.alcf.anl.gov)
        cmd="chmod -R o-rwx ${BLDR_INSTALL_DIR}/chef-${CHEF_LIBS_BLDRVERSION}"
        echo $cmd
        $cmd
        cmd="chmod -R g-w ${BLDR_INSTALL_DIR}/chef-${CHEF_LIBS_BLDRVERSION}"
        echo $cmd
        $cmd
        ;;
    esac
  fi
}

