# #!/bin/bash
#
# Trigger vars and find information
#
# Latest source packages available from
#   http://get.qt.nokia.com/qt/source/.
#   20121125: Moved to http://qt-project.org/downloads.
#
# These have to be unpacked and repacked for Bilder standards.  E.g.:
#   tar xzf qt-everywhere-opensource-src-4.8.6.tar.gz
#   mv qt-everywhere-opensource-src-4.8.6 qt-4.8.6
#   tar --exclude '\._*' cjf qt-4.8.6.tar.bz2 qt-4.8.6
# OR
#   tar xzf qt-everywhere-opensource-src-5.0.0-beta2.tar.gz
#   mv qt-everywhere-opensource-src-5.0.0-beta2 qt-5.0.0b2
#   tar --exclude '\._*' cjf qt-5.0.0b2.tar.bz2 qt-5.0.0b2
#
# The args, --exclude '\._*', are needed to not put extended attributes
#   files in the tarball on OS X.
#
# Tar up on an older dist, or one may get errors like
# gtar: Ignoring unknown extended header keyword `SCHILY.dev'
#
# $Id$
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

setQtTriggerVars() {
  case `uname`-`uname -r` in
    Darwin-13.*)
# 4.8.4 and 4.8.5 do not build on Mavericks
# 4.8.6 does.
# Snapshots: http://download.qt-project.org/snapshots/qt/4.8/
      QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.6"}
      ;;
    *)
      QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.5"}
      ;;
  esac
  QT_BLDRVERSION_EXP=${QT_BLDRVERSION_EXP:-"4.8.6"}
  QT_BUILDS=${QT_BUILDS:-"$FORPYTHON_BUILD"}
  QT_BUILD=$FORPYTHON_BUILD
  QT_DEPS=bzip2
  addtopathvar PATH $CONTRIB_DIR/qt-$FORPYTHON_BUILD/bin
}
setQtTriggerVars

#
# print Qt vars
#
printQtVars() {
  local qtvars="QMAKE QTDIR QT_BINDIR"
  for i in $qtvars; do
    printvar $i
  done
}

#
# Find the QT packages
#
findQt() {

# Try accepting what the user specified
  if test -n "$QT_BINDIR"; then
    if QMAKE=`env PATH=$QT_BINDIR:/usr/bin which qmake 2>/dev/null`; then
      techo "qmake found in $QT_BINDIR"
      addtopathvar PATH $QT_BINDIR
      QTDIR=`dirname $QT_BINDIR`
      printQtVars
      return
    else
      unset QT_BINDIR
      unset QTDIR
    fi
  fi
  techo "Qt not found in $QT_BINDIR."

# Seek Qt in the contrib directory
  local libname=
  if [[ `uname` =~ CYGWIN ]]; then
    libname=QtCore4
  else
    libname=QtCore
  fi
  findContribPackage Qt $libname cc4py sersh
  findCc4pyDir Qt
  if test -z "$QT_CC4PY_DIR"; then
    findContribPackage Qt $libname ser
  fi
  local qtdir=$QT_CC4PY_DIR
  qtdir=${qtdir:-"$QT_SER_DIR"}
  if test -n "$qtdir"; then
    techo "Qt found in $CONTRIB_DIR."
    QT_BINDIR=$qtdir/bin
    addtopathvar PATH $QT_BINDIR
    QMAKE=`env PATH=$QT_BINDIR:/usr/bin which qmake 2>/dev/null`
    QTDIR=$qtdir
    printQtVars
    return
  fi
  techo "Qt not found in $CONTRIB_DIR."

# Seek qmake in one's path
  if QMAKE=`which qmake 2>/dev/null`; then
    QT_BINDIR=`dirname $QMAKE`
    addtopathvar PATH $QT_BINDIR
    QTDIR=`dirname $QT_BINDIR`
    printQtVars
    return
  fi
  techo "qmake not found in the user path = $PATH."

# Look in standard windows installation dirs
  if [[ `uname` =~ CYGWIN ]]; then
    techo "Searching Windows installation directories."
    QT_BVER=`ls /cygdrive/c/Qt | grep "^4" | tail -1`
    if test -n "$QT_BVER"; then
      QT_BINDIR=/cygdrive/c/Qt/$QT_BVER/bin
      addtopathvar PATH $QT_BINDIR
      QMAKE=`env PATH=$QT_BINDIR which qmake 2>/dev/null`
      QTDIR=`dirname $QT_BINDIR`
      printQtVars
      return
    fi
    techo "Qt not found in the Windows standard installation areas."
  fi

# Out of ideas
  techo "findQt could not find Qt."
  return 0
}

