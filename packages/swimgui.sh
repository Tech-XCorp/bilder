#!/bin/bash
#
# Version and build information for swim gui
#
# $Id: swimgui.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

SWIMGUI_BUILDS=${SWIMGUI_BUILDS:-"ser"}
SWIMGUI_DEPS=composertoolkit,qt
SWIMGUI_UMASK=002

######################################################################
#
# Launch SWIM GUI builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildSwimgui() {

  getVersion swimgui
  if bilderPreconfig swimgui; then
    SWIMGUI_CMAKE_FLAGS="-DPYTHON_LLIB=${PYTHON_LLIB}"

    # On windows, we configure with shared library support
    # To match Qt and QScintilla
    # (this gives us the /MD compile option instead of /MT)
    local SHARED_LIBS_FLAG=""
    case `uname` in
      CYGWIN*)
      SHARED_LIBS_FLAG="-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE"
      ;;
    esac
    if $BUILD_INSTALLERS; then
      SWIMGUI_SER_MAKE_ARGS=${SWIMGUI_SER_MAKE_ARGS:-"all"}
    fi

    if bilderConfig swimgui ser "$CTK_COMPILERS $CTK_COMPILER_FLAGS $SHARED_LIBS_FLAG $SWIMGUI_CMAKE_FLAGS $CMAKE_CTK_PYTHON_ARGS $CMAKE_SUPRA_SP_ARG $SWIMGUI_SER_OTHER_ARGS"; then
      bilderBuild swimgui ser "${SWIMGUI_SER_MAKE_ARGS}"
    fi
  fi
}

######################################################################
#
# Test swim gui
#
######################################################################

testSwimgui() {
  techo "Not testing swim gui."
}

######################################################################
#
# Install swim gui
#
######################################################################

installSwimgui() {
  bilderInstall -r -s open/swim swimgui ser
}
