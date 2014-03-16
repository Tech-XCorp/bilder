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
# 4.8.6 snapshot below.
    QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.6-20140310-510"}
    ;;
  *)
    QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.5"}
    ;;
esac
QT_BLDRVERSION_EXP=${QT_BLDRVERSION_EXP:-"4.8.6-20140310-510"}

