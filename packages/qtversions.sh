# #!/bin/bash
#
# Version information for qt.
#
# $Id$
#
######################################################################

case `uname`-`uname -r` in
  Darwin-13.*)
# 4.8.4 and 4.8.5 do not build on Mavericks
# 4.8.6 snapshot below does.
# Snapshots: http://download.qt-project.org/snapshots/qt/4.8/
# Release cands: http://download.qt-project.org/development_releases/qt/4.8/
    QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.6"}
    ;;
  *)
    QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.5"}
    ;;
esac
QT_BLDRVERSION_EXP=${QT_BLDRVERSION_EXP:-"4.8.6"}

