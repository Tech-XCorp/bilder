#!/bin/bash
#
# Version and build information for superlu_dist version 3
#
# $Id: superlu_dist.sh 492 2013-11-05 21:05:44Z jrobcary $
#
######################################################################

######################################################################
#
# Set to version 3 and source regular package file. 
# Trilinos depends on SuperLU_dist 2, so regular package file will use
# that version until Trilinos is updated.
#
######################################################################

SUPERLU_DIST3_BLDRVERSION=${SUPERLU_DIST3_BLDRVERSION:-"3.3"}

sed 's/_dist/_dist3/g' < $BILDER_DIR/packages/superlu_dist.sh | sed 's/_Dist/_Dist3/g' | sed 's/_DIST/_DIST3/g' > $PROJECT_DIR/superlu_dist3.sh

source $PROJECT_DIR/superlu_dist3.sh
rm $PROJECT_DIR/superlu_dist3.sh
