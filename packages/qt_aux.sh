# #!/bin/bash
#
# Auxiliary information for qt: anything that if changed should
# not per se force a rebuild.  E.g., changing the version info
# below will cause an appropriate rebuild anyway, but changing
# this file will not.
#
# $Id$
#
######################################################################

#
# Get the Qt version
#
getQtVersion() {
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
}
getQtVersion

#
# Find the QT packages
#
findQt() {

# First try to find Qt in the contrib directory
  local libname=
  if [[ `uname` =~ CYGWIN ]]; then
    libname=QtCore4
  else
    libname=QtCore
  fi
  findContribPackage Qt $libname cc4py
  if test -z "$QT_CC4PY_DIR"; then
    findContribPackage Qt $libname sersh
    if test -z "$QT_SERSH_DIR"; then
      findContribPackage Qt $libname ser
    fi
  fi
  local qtdir=$QT_CC4PY_DIR
  qtdir=${qtdir:-"$QT_SERSH_DIR"}
  qtdir=${qtdir:-"$QT_SER_DIR"}
  if test -n "$qtdir"; then
    QT_BINDIR=$qtdir/bin
    QMAKE=$qtdir/qmake
    techo "Qt found in $CONTRIB_DIR.  Using QT_BINDIR = $QT_BINDIR."
    addtopathvar PATH $QT_BINDIR
    techo "$QT_BINDIR added to path."
    return 0
  fi

  techo "Qt not found in $CONTRIB_DIR."
# Next try to find qmake in one's path
  QMAKE=`which qmake 2>/dev/null`
  if test -n "$QMAKE"; then
    QT_BINDIR=`dirname $QMAKE`
    techo "qmake found in PATH.  Using QT_BINDIR = $QT_BINDIR."
    return 0
  fi
  techo "qmake not in path."
  if test -z "$QT_BINDIR"; then
    case `uname` in
      CYGWIN*)
        techo "Searching Windows installation directories."
        QT_BVER=`ls /cygdrive/c/Qt | grep "^4" | tail -1`
        if test -n "$QT_BVER"; then
          QT_BINDIR=/cygdrive/c/Qt/$QT_BVER/bin
        fi
        ;;
    esac
  fi
  if test -z "$QT_BINDIR"; then
    techo "WARNING: [$FUNCNAME] Could not find Qt."
    return 1
  fi
  QMAKE=$QT_BINDIR/qmake
  techo "QT_BINDIR = $QT_BINDIR."
  addtopathvar PATH $QT_BINDIR
  local qtvars="QMAKE QTDIR QT_BINDIR"
  for i in $qtvars; do
    printvar $i
  done
  return 0
}

#
# Find Qt at time of sourcing, as installQt may not be called
#
findQt

