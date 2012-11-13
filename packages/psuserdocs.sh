#!/bin/bash
#
# Version and build information for psuserdocs
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

PSUSERDOCS_BUILDS=${PSUSERDOCS_BUILDS:-"$DOCS_BUILDS"}
PSUSERDOCS_DEPS=Sphinx,MathJax,doxygen,cmake,psexamples
PSUSERDOCS_UMASK=002

######################################################################
#
# Launch POLYSWIFT documentation builds.
#
######################################################################

# Configure and build serial and parallel
buildPsuserdocs() {

# Get version and see if anything needs building
  getVersion psuserdocs
  local psudirs=$BLDR_INSTALL_DIR
  if [[ $PSUSERDOCS_BUILDS =~ "(^|,)url(,|$)" ]]; then
    psudirs=$psudirs,$USERDOCS_DIR
  fi
  if bilderPreconfig -I $psudirs psuserdocs; then

# Figure out polyswift version
    local PSUSERDOCS_ADDL_ARGS=
    if test -d $PROJECT_DIR/polyswift; then
      getVersion polyswift
      for val in MAJOR MINOR PATCH; do
        eval POLYSWIFT_VERSION_$val=`grep "set(VERSION_$val" $PROJECT_DIR/polyswift/CMakeLists.txt | sed -e 's/").*$//' -e 's/^.*"//'`
      done
      POLYSWIFT_PROJVERSION=${POLYSWIFT_VERSION_MAJOR}.${POLYSWIFT_VERSION_MINOR}.${POLYSWIFT_VERSION_MINOR}-${POLYSWIFT_BLDRVERSION}
      PSUSERDOCS_ADDL_ARGS="-DPOLYSWIFT_PROJVERSION:STRING=${POLYSWIFT_PROJVERSION}"
    fi

# Cygwin userdocs must be made with nmake (cannot be parallel as jom would do)
    PSUSERDOCS_MAKE_ARGS=
    case `uname` in
      CYGWIN*) PSUSERDOCS_MAKE_ARGS="-m nmake" ;;
    esac

# Docs build with various MathJax
    if bilderConfig psuserdocs lite "${POLYSWIFT_PROJVERSION_ARG} $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $PSUSERDOCS_ADDL_ARGS $PSUSERDOCS_SER_OTHER_ARGS"; then
      bilderBuild $PSUSERDOCS_MAKE_ARGS psuserdocs lite "userdocs"
    fi
    if bilderConfig psuserdocs full "${POLYSWIFT_PROJVERSION_ARG} $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $PSUSERDOCS_ADDL_ARGS $PSUSERDOCS_SER_OTHER_ARGS -DSPHINX_DEBUG:BOOL=TRUE"; then
      bilderBuild $PSUSERDOCS_MAKE_ARGS psuserdocs full "userdocs"
    fi
# The URL build (for putting on line) is installed under $USERDOCS_DIR
# for easy rsyncing.  We keep the last 10 versions.
    $BILDER_DIR/cleaninstalls.sh -lrR -k 10 $USERDOCS_DIR
    getSphinxMathArg
    if bilderConfig -I $USERDOCS_DIR psuserdocs url "${POLYSWIFT_PROJVERSION_ARG} $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $SPHINX_MATHARG $PSUSERDOCS_ADDL_ARGS $PSUSERDOCS_SER_OTHER_ARGS"; then
      bilderBuild $PSUSERDOCS_MAKE_ARGS psuserdocs url "userdocs"
    fi

  fi
}

######################################################################
#
# Test psdocs
#
######################################################################

# Set umask to allow only group to modify
testPsuserdocs() {
  echo "Not testing psuserdocs."
}

######################################################################
#
# Install psdocs
#
######################################################################

installPsuserdocs() {
  bilderInstall $PSUSERDOCS_MAKE_ARGS -r psuserdocs full "" install-userdocs
  bilderInstall $PSUSERDOCS_MAKE_ARGS -r psuserdocs lite "" install-userdocs
  bilderInstall $PSUSERDOCS_MAKE_ARGS -r psuserdocs url "" install-userdocs
  # techo "WARNING: Quitting at end of installPsuserdocs."; cleanup
}

