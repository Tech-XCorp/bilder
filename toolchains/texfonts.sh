#!/bin/bash
#
# This is not a bilder package, but just a convenient shell script
#
# $Id: texfonts.sh 5429 2012-03-09 14:15:24Z cary $
#
######################################################################

######################################################################
##
######################################################################

PROJECT_DIR=$PWD
source $BILDER_DIR/bildall.sh
TEXFONTS_BLDRVERSION=${TEXFONTS_BLDRVERSION:-"35"}
TEXFONTS_DIR=TeX-fonts-${TEXFONTS_BLDRVERSION}
TEXFONTS_FULLTAR=${PROJECT_DIR}/numpkgs/${TEXFONTS_DIR}.tar.gz

case "$RUNNRSYSTEM" in
  Darwin*)
    TEXFONTS_INSTALL_DIR=$HOME/Library/Fonts
    ;;
  Linux*)
    TEXFONTS_INSTALL_DIR=$HOME/.fonts
    if ! test -d ${TEXFONTS_INSTALL_DIR}; then
      mkdir -f ${TEXFONTS_INSTALL_DIR}
    fi
    ;;
  *)
    echo "Do not know how to install TeX-fonts for your system: "
    echo "$RUNNRSYSTEM"
    ;;
esac

#echo ${RUNNRSYSTEM}
#echo ${TEXFONTS_DIR}
#echo ${TEXFONTS_FULLTAR}
#echo ${TEXFONTS_INSTALL_DIR}

###
##  Now do the actual work
#
if test -d  "${TEXFONTS_INSTALL_DIR}/${TEXFONTS_DIR}"; then
  echo "Fonts are already installed at: "
  echo "${TEXFONTS_INSTALL_DIR}/${TEXFONTS_DIR}"
  echo "Remove this directory if you want to reinstall"
  exit
fi

svn up ${TEXFONTS_FULLTAR}
gunzip -c ${TEXFONTS_FULLTAR} | gtar --no-same-owner -xf -
mv ${TEXFONTS_DIR} ${TEXFONTS_INSTALL_DIR}

echo
echo "Fonts installed at: "
echo "${TEXFONTS_INSTALL_DIR}/${TEXFONTS_DIR}"
