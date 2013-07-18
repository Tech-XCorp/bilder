#!/bin/bash
#
# Version and build information for openstudio
#
# $Id: openstudio.sh 664 2013-06-17 21:15:06Z pletzer $
#
######################################################################

######################################################################
#
# Builds and deps
# Built from svn repo only
#
######################################################################

OPENSTUDIO_DEPS=swig,ruby,rake,dakota,doxygen,vtk,qt
if test -z "$OPENSTUDIO_BUILDS"; then
  OPENSTUDIO_BUILDS=ser
fi

######################################################################
#
# Launch openstudio builds.
#
######################################################################

buildOpenstudio() {

  # SWS: These could be replaced by editing the openstudio cmake script and corresponding Find____.cmake scripts
  # OPENSTUDIO_PAR_ARGS=" "
  OPENSTUDIO_SER_ARGS="-DBOOST_ROOT:STRING=$CONTRIB_DIR/boost -DSWIG_EXECUTABLE:FILEPATH=$CONTRIB_DIR/swig/bin/swig -DRUBY_EXECUTABLE:STRING=$CONTRIB_DIR/ruby-ser/bin -DQT_QMAKE_EXECUTABLE:FILE=$CONTRIB_DIR/qt-4.8.4-sersh/bin/qmake"

  OPENSTUDIO_SER_ARGS="$OPENSTUDIO_SER_ARGS $CMAKE_COMPILERS_SER"
  # OPENSTUDIO_PAR_ARGS="$OPENSTUDIO_PAR_ARGS $CMAKE_COMPILERS_PAR"

  # Get openstudio checkout
  getVersion openstudio

  # Configure and build serial and parallel
  if bilderPreconfig openstudio; then

    # Serial build
    if bilderConfig $USE_CMAKE_ARG openstudio ser "$OPENSTUDIO_SER_ARGS $CMAKE_SUPRA_SP_ARG"; then
       bilderBuild openstudio ser "$OPENSTUDIO_MAKEJ_ARGS"
    fi

  fi
}



######################################################################
#
# Install openstudio
#
######################################################################

installOpenstudio() {
  bilderInstall openstudio ser openstudio
}
