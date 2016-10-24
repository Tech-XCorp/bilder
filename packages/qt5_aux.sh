# #!/bin/bash
#
# Trigger vars and find information
#
# NOTE: As of 10/21/2016 these instructions need updating once
# the package details are settled.
#
# Latest source packages available from
#   http://get.qt.nokia.com/qt/source/.
#   20121125: Moved to http://qt-project.org/downloads.
#   20150723: Moved to http://www.qt.io/download-open-source/
#
# These have to be unpacked and repacked for Bilder standards.  E.g.:
#   tar xzf qt-everywhere-opensource-src-5.5.0.tar.gz
#   mv qt-everywhere-opensource-src-5.5.0 qt-5.5.0
#   env COPYFILE_DISABLE=true tar cjf qt-5.5.0.tar.bz2 qt-5.5.0
#
# The env change is to prevent addition of resource files on OSX.
#
# Tar up on an older dist, or one may get errors like
# gtar: Ignoring unknown extended header keyword `SCHILY.dev'
#
# $Id: qt_aux.sh 2980 2016-02-06 19:46:15Z cary $
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setQt5TriggerVars() {
  QT5_BLDRVERSION_STD=${QT5_BLDRVERSION_STD:-"5.6.1"}
  #  QT5_BLDRVERSION_EXP=${QT5_BLDRVERSION_EXP:-"4.8.7"}
  QT5_BUILDS=${QT5_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  QT5_BUILD=$FORPYTHON_SHARED_BUILD
  # QT5_DEPS=gst-plugins-base,bzip2
  QT5_DEPS=bzip2
# Need the following for phonon (and for webkit) on Linux:
#   dbus
#   glib (aka glib2 for the rpm)
#   gstreamer-devel
#   gstreamer-plugins-base-devel
#   libxml2
}
setQt5TriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

#
# print Qt5 vars
#
printQt5Vars() {
  local qt5vars="QMAKE QT5DIR QT5_BINDIR"
  for i in $qt5vars; do
    printvar $i
  done
}

#
# Set qmake variables for later use
#
setQmakeArgs() {

  case `uname` in

    CYGWIN*)
      case $CC in
        *cl)
          case ${VISUALSTUDIO_VERSION} in
            9)  QMAKE_PLATFORM_ARGS="-spec win32-msvc2008";;
            10) QMAKE_PLATFORM_ARGS="-spec win32-msvc2010";;
            11) QMAKE_PLATFORM_ARGS="-spec win32-msvc2012";;
          esac
          ;;
        *mingw*)
          ;;
      esac
      ;;

    Darwin) QMAKE_PLATFORM_ARGS="-spec macx-g++";;

    Linux)
      case `uname -m` in
        x86_64) QMAKE_PLATFORM_ARGS="-spec linux-g++-64";;
        *) QMAKE_PLATFORM_ARGS="-spec linux-g++";;
      esac
      ;;

  esac

}

findQt5() {

# Try accepting what the user specified
  if test -n "$QT5_BINDIR"; then
    if QMAKE=`env PATH=$QT5_BINDIR:/usr/bin which qmake 2>/dev/null`; then
      techo "qmake found in $QT5_BINDIR"
      addtopathvar PATH $QT5_BINDIR
      QT5DIR=`dirname $QT5_BINDIR`
      setQmakeArgs
      printQt5Vars
      return
    else
      techo "Qt5 not found in $QT5_BINDIR."
      unset QT5_BINDIR
      unset QT5DIR
    fi
  else
    techo "QT5_BINDIR not set."
  fi

# Seek Qt5 in the contrib directory
  local libname=
  if [[ `uname` =~ CYGWIN ]]; then
lsikdjf    libname=QtCore4 
  else
sdldikjf    libname=QtCore
  fi
  
  findContribPackage Qt5 $libname sersh pycsh
  techo "QT5_SERSH_DIR = $QT5_SERSH_DIR."
  findPycshDir Qt5
  if test -n "$QT5_PYCSH_DIR"; then
    techo "QT5_PYCSH_DIR = $QT5_PYCSH_DIR."
  else
    findContribPackage Qt5 $libname ser
  fi
  local qt5dir=$QT5_PYCSH_DIR
  qt5dir=${qt5dir:-"$QT5_SER_DIR"}
  if test -n "$qt5dir"; then
    techo "Qt5 found in $CONTRIB_DIR."
    QT5_BINDIR=$qt5dir/bin
    addtopathvar PATH $QT5_BINDIR
    QMAKE=`env PATH=$QT5_BINDIR:/usr/bin which qmake 2>/dev/null`
    QT5DIR=$qt5dir
    setQmakeArgs
    printQt5Vars
    return
  fi
  techo "Qt5 not found in $CONTRIB_DIR."

# Seek qmake in one's path
  if QMAKE=`which qmake 2>/dev/null`; then
    QT5_BINDIR=`dirname $QMAKE`
    addtopathvar PATH $QT5_BINDIR
    QT5DIR=`dirname $QT5_BINDIR`
    setQmakeArgs
    printQt5Vars
    return
  fi
  techo "qmake not found in the user path = $PATH."

# Look in standard windows installation dirs
  if [[ `uname` =~ CYGWIN ]]; then
    techo "Searching Windows installation directories."
    QT5_BVER=`ls /cygdrive/c/Qt5 | grep "^4" | tail -1`
    if test -n "$QT5_BVER"; then
      QT5_BINDIR=/cygdrive/c/Qt5/$QT5_BVER/bin
      addtopathvar PATH $QT5_BINDIR
      QMAKE=`env PATH=$QT5_BINDIR which qmake 2>/dev/null`
      QT5DIR=`dirname $QT5_BINDIR`
      setQmakeArgs
      printQt5Vars
      return
    fi
    techo "Qt5 not found in the Windows standard installation areas."
  fi

# Out of ideas
  techo "findQt5 could not find Qt5."
  return 0
}

