#!/bin/bash
#
# Version and build information for vizschema
#
# $Id$
#
######################################################################


######################################################################
#
# Version
#
######################################################################
VIZSCHEMA_BLDRVERSION=${VIZSCHEMA_BLDRVERSION:-""}
CTEST_TARGET=${CTEST_TARGET:-Experimental}
VIZSCHEMA_TESTING=${VIZSCHEMA_TESTING:-$TESTING}
VIZSCHEMA_TESTING=${VIZSCHEMA_TESTING:-false}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VIZSCHEMA_DESIRED_BUILDS=${VIZSCHEMA_DESIRED_BUILDS:-"sersh"}
# Simpler way is to let clapack_cmake be a dependency but just not
# build it when LINK_WITH_MKL is true.
VIZSCHEMA_DEPS=vsreader,visit4vs
VIZSCHEMA_UMASK=007

computeBuilds vizschema

######################################################################
#
# Launch vizschema builds
#
######################################################################

buildVizschema() {

  getVersion vizschema
  if ! bilderPreconfig -c vizschema; then
    return
  fi

  if $VIZSCHEMA_TESTING; then
    VIZSCHEMA_MAKE_ARGS=${VIZSCHEMA_MAKE_ARGS:-"${CTEST_TARGET}Start ${CTEST_TARGET}Build"}
  else
    VIZSCHEMA_MAKE_ARGS=${VIZSCHEMA_MAKE_ARGS:-"all"}
  fi

  VIZSCHEMA_MAKE_ARGS="${VIZSCHEMA_MAKEJ_ARGS} ${VIZSCHEMA_MAKE_ARGS}"

  if [[ `uname` =~ CYGWIN ]]; then
# On Windows, we build vizschema with /MD enabled
# Bilder has no idea where to look for clapack, hdf5, vsreader,
# so we have to tell it.
#local VTK_CMAKE_ROOT_DIR_ARG="-DCLapackscimake_ROOT_DIR:PATH='${MIXED_CONTRIB_DIR}/clapack_cmake-${CLAPACK_CMAKE_BLDRVERSION}-sermd'"
#local _ROOT_DIR_ARG="-DHdf5_ROOT_DIR:PATH='${MIXED_CONTRIB_DIR}/hdf5-${HDF5_BLDRVERSION}-sersh'"
#VIZSCHEMA_SERSH_ADDL_ARGS="${VIZSCHEMA_SERSH_ADDL_ARGS} ${CLAPACK_CMAKE_ROOT_DIR_ARG} ${HDF5_ROOT_DIR_ARG}"
    VIZSCHEMA_SERSH_ADDL_ARGS="${VIZSCHEMA_SERSH_ADDL_ARGS}"
  else
    VIZSCHEMA_SERSH_ADDL_ARGS="${VIZSCHEMA_SERSH_ADDL_ARGS} ${CMAKE_VSREADER_SERSH_ARGS}"
  fi
  VIZSCHEMA_SERSH_ADDL_ARGS="${VIZSCHEMA_SERSH_ADDL_ARGS} -DPython_ROOT_DIR:PATH='${PYTHON_DIR}' -DEnv_PYTHONPATH:PATH='${PYTHONPATH}'"

# Standard sequence
  if bilderConfig vizschema sersh "-DBUILD_SHARED_LIBS:BOOL=TRUE ${CMAKE_COMPILERS_SER} ${CMAKE_COMPFLAGS_SER}  ${VIZSCHEMA_SERSH_ADDL_ARGS} ${VIZSCHEMA_SERSH_OTHER_ARGS} ${CMAKE_SUPRA_SP_ARG}"; then
    bilderBuild vizschema sersh "$VIZSCHEMA_MAKE_ARGS"
  fi

}

######################################################################
#
# Test vizschema must be driven from top level
#
######################################################################

testVizschema() {
# TODO: add memcheck target for automated/nightly builds
  bilderTest vizschema sersh "${CTEST_TARGET}Test"
  waitAction vizschema-sersh
  res=$?

# Do the following no matter if there's an error or not so
# cdash gets all the results
  if $VIZSCHEMA_TESTING; then
    local cmvar=VIZSCHEMA_CONFIG_METHOD
    local cmval=`deref $cmvar`
    bildermake=`getMaker $cmval`
    techo "Submitting test results..."
    $bildermake -i ${CTEST_TARGET}Coverage ${CTEST_TARGET}Submit &> /dev/null
  fi

  return $res
}

######################################################################
#
# Install vizschema
#
######################################################################

installVizschema() {
# TODO: replace with bilderInstallTestedPkg
  bilderInstall vizschema sersh
}

