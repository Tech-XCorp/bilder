#!/bin/bash
#
# Version and build information for Synergia2
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

SYNERGIA2_BLDRVERSION=${SYNERGIA2_BLDRVERSION:-"master"}

######################################################################
#
# Other values
#
######################################################################

#SYNERGIA2_BUILDS=${SYNERGIA2_BUILDS:-"ser,par"}
SYNERGIA2_BUILDS=${SYNERGIA2_BUILDS:-"ser"}
trimvar SYNERGIA2_BUILDS ','
SYNERGIA2_DEPS=chef_libs,Python,boost,tables,gsl,fftw3,numpy,fftw3
trimvar SYNERGIA2_DEPS ','
SYNERGIA2_UMASK=002
## Note that other cmake args have been moved lower to after more checks

######################################################################
#
# Launch Synergia2 builds.
#
######################################################################

buildSynergia2() {

# Check for git version
  local synergiarepo='git://compacc.fnal.gov/home/scmuser/git/synergia2.git'
  cd $PROJECT_DIR
  res=$?
  if test $res = 0; then
    getRepo -g synergia2 $synergiarepo "${SYNERGIA2_BLDRVERSION}"
    res=$?
  fi
  if test $res = 0; then
    if test -d $PROJECT_DIR/synergia2; then
      getVersion synergia2
      res=$?
      if test $res = 0; then
        bilderPreconfig synergia2
        res=$?
      fi
    fi
  fi

  SYNERGIA2_MAKE_ARGS="$SYNERGIA2_MAKEJ_ARGS"

# Find python
  if [ ! -n "${PYTHON_BLDRVERSION}" ]
  then
    source $BILDER_DIR/packages/python.sh
    buildPython
    installPython
  fi
  PYTHON_VER=python2.6
  PYTHON_LIB="${PYTHON_VER}"
  if ! test -z "${PYTHON_INCLUDE_DIRS}"; then
    if ! test -d "${PYTHON_INCLUDE_DIRS}"; then
      techo "Python include directory, \"${PYTHON_INCLUDE_DIRS}\", not found, trying other locations."
      PYTHON_INCLUDE_DIRS=""
    fi
  fi
  if test -z "${PYTHON_INCLUDE_DIRS}"; then
    PYTHON_INCLUDE_DIRS="/usr/include/${PYTHON_VER}"
  fi
  if ! test -d "${PYTHON_INCLUDE_DIRS}"; then
    PYTHON_INCLUDE_DIRS="$CONTRIB_DIR/include/${PYTHON_VER}"
  fi
  if ! test -d "${PYTHON_INCLUDE_DIRS}"; then
    techo "ERROR: Unable to locate python include directory, Synergia2 build aborted"
    res=1
  fi
  techo "PYTHON_INCLUDE_DIRS = ${PYTHON_INCLUDE_DIRS}"

# Find boost
  findBoost
  if test -z "${BOOST_INCDIR_ARG}"; then
    buildBoost
    installBoost
  fi
# We need Boost_INCLUDE_DIR defined
  if ! test -n "${BOOST_INCDIR_ARG:2}"; then
    techo "ERROR: Boost not found? Synergia2 build aborted"
    res=1
  fi
  if test $res = 0; then
    eval ${BOOST_INCDIR_ARG:2}
  fi

# Synergia2's CMakeLists.txt needs to find chef-config.sh
# We need to find the bin path for each build
  for bld in $SYNERGIA2_BUILDS; do
    local pkgline=`cat $BLDR_INSTALL_DIR/installations.txt | awk '{print $1}' | grep ^chef_libs-${CHEF_LIBS_BLDRVERSION}-${bld} | tail -1`
    local instdirvar=CHEF_LIBS_INSTALL_DIR_`genbashvar ${bld}`
    eval $instdirvar=$BLDR_INSTALL_DIR/$pkgline
    local instdirval=`deref $instdirvar`
    if ! test -d "$instdirval/bin"; then
      techo "ERROR: CHEF ${bld} install dir not found, Synergia2 build aborted"
      res=1
    else
      techo -2 "install for ${bld} is ${instdirval}"
    fi
  done

# Apparently, we need to locate the correct set of FFTW3 libraries in lieu of
#  fixing Synergia2's CMakeLists.txt file
  FFTW_SER_LIBRARY="${BLDR_INSTALL_DIR}/fftw3/lib/libfftw3${SHOBJEXT}"
  FFTW_SER_MPI_LIBRARY="${BLDR_INSTALL_DIR}/fftw3/lib/libfftw3_mpi${SHOBJEXT}"
  FFTW_PAR_LIBRARY="${BLDR_INSTALL_DIR}/fftw3-par/lib/libfftw3${SHOBJEXT}"
  FFTW_PAR_MPI_LIBRARY="${BLDR_INSTALL_DIR}/fftw3-par/lib/libfftw3_mpi${SHOBJEXT}"
  local fftw_libs=""
  for build in builds; do
    if test $build == "ser"; then
      fftw_libs="${fftw_libs} FFTW_SER_LIBRARY FFTW_SER_MPI_LIBRARY"
    elif test $build == "par"; then
      fftw_libs="${fftw_libs} FFTW_PAR_LIBRARY FFTW_PAR_MPI_LIBRARY"
    fi
  done
  for library in fftw_libs; do
    if ! test -f "`deref $library`"; then
      techo "WARNING: FFTW library, $library, not found at `deref $library`"
    fi
  done

# Set up the particular (but not build dependent) config args for Synergia2
  SYNERGIA2_SER_OTHER_ARGS=" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$BLDR_INSTALL_DIR -DCMAKE_INCLUDE_PATH:PATH=$BLDR_INSTALL_DIR"
# Add in python and boost
  SYNERGIA2_SER_OTHER_ARGS="${SYNERGIA2_SER_OTHER_ARGS} ${BOOST_INCDIR_ARG} -DPYTHON_INCLUDE_PATH:PATH=${PYTHON_INCLUDE_DIRS} -DPYTHON_LIBRARY:FILEPATH=-l${PYTHON_LIB}"
# Copy these paths to the parallel version (since they are not build dependent)
  SYNERGIA2_PAR_OTHER_ARGS="${SYNERGIA2_SER_OTHER_ARGS}"

# Now, add in the build-dependent args
  SYNERGIA2_SER_ARGS="$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS ${SYNERGIA2_SER_OTHER_ARGS} -DFFTW3_LIBRARIES:FILEPATH=${FFTW_SER_LIBRARY} -DFFTW3_MPI_LIBRARIES:FILEPATH=${FFTW_SER_MPI_LIBRARY} -DFFTW3_INCLUDE_DIR:PATH=${BLDR_INSTALL_DIR}/fftw3/include -DCHEF_PREFIX:PATH=${BLDR_INSTALL_DIR}"
  SYNERGIA2_PAR_ARGS="${SYNERGIA2_PAR_OTHER_ARGS} -DENABLE_PARALLEL:BOOL=TRUE -DFFTW3_LIBRARIES:FILEPATH=${FFTW_PAR_LIBRARY} -DFFTW3_MPI_LIBRARIES:FILEPATH=${FFTW_PAR_MPI_LIBRARY} -DCHEF_PREFIX:PATH=${BLDR_INSTALL_DIR}"

# Regular build
  for bld in $SYNERGIA2_BUILDS; do
    if test $res = 0; then
# Get the other args for this build
      local bldargvar=SYNERGIA2_`genbashvar ${bld}`_ARGS
      local bldargval=`deref $bldargvar`
# Add the correct CHEF bin path to PATH so that FindCHEF will work
      local instdirvar=CHEF_LIBS_INSTALL_DIR_`genbashvar ${bld}`
      local instdirval=`deref $instdirvar`
      PATH="${PATH}:${instdirval}/bin"
      techo -2 "PATH for Synergia2 build is: ${PATH}"

      if bilderConfig synergia2 $bld "${bldargval}"; then
        bilderBuild synergia2 $bld "$SYNERGIA2_MAKE_ARGS"
        res=$?
        techo "bilderBuild of synergia2 ${bld} returned $res"
      fi
# Now, we need to take the CHEF path back off
      PATH=`echo $PATH | sed 's/:[^:]*$//'`
      techo -2 "PATH for Synergia2 after build is: ${PATH}"
    fi
  done

  return $res
}

######################################################################
#
# Test Synergia2
#
######################################################################

testSynergia2() {
  techo "Not testing Synergia2"
  # Need to see how to run run_all_tests.sh in the chef_libs dir
}

######################################################################
#
# Install Synergia2
#
######################################################################

installSynergia2() {
  if bilderInstall -r synergia2 ser synergia2 ; then
# Make sure perms are correct.
    case $FQMAILHOST in
      *.ornl.gov | *.nersc.gov | *.alcf.anl.gov)
        cmd="chmod -R o-rwx ${BLDR_INSTALL_DIR}/chef-${SYNERGIA2_BLDRVERSION}"
        echo $cmd
        $cmd
        cmd="chmod -R g-w ${BLDR_INSTALL_DIR}/chef-${SYNERGIA2_BLDRVERSION}"
        echo $cmd
        $cmd
        ;;
    esac
  fi
}

