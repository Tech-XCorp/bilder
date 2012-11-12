#!/bin/bash
#
# $Id: pbs_mkvorpal_dirac.sh 6168 2012-06-02 16:28:27Z benc $
#
# Default script for building Vorpal on a Dirac compute node to link
# correctly to the CUDA libraries
#
########################################################################

#PBS -q dirac_reg
#PBS -l nodes=1:ppn=8
#PBS -l walltime=4:00:00
#PBS -N buildVorpal
#PBS -m abe
#PBS -V

# Go to the submission directory; assume this is one above the bilder
# directory
cd $PBS_O_WORKDIR
mydir=${mydir:-"$PBS_O_WORKDIR"}

# Run the script to set the correct modules.  Then set the
# MODSETUPFILE environment variable to the module setup script so that
# the modules will be correct withon a subshell.  This assumes that
# you have the following snippet in your .bashrc.ext:
#
# if test -f "$MODSETUPFILE" ; then
#   source $MODSETUPFILE
# fi
source $mydir/bilder/toolchains/diracSetup.sh
export MODSETUPFILE="$mydir/bilder/toolchains/diracSetup.sh"

$mydir/mkvorpal-default.sh $bildArgs
