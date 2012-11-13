#
# This fragment is keep here for copying into top level bilder scripts
# Changes should be made here then copied over
#
# $Id$
#

######################################################################
#
# Determine the projects directory.  This can be copied into other scripts
# for the sanity check.  Assumes that BILDER_NAME has been set.
# $BILDER_NAME.sh is the name of the script.
#
# The main copy is in bilder/findProjectDir.sh
#
######################################################################

findProjectDir() {
  myname=`basename "$0"`
  if test $myname = $BILDER_NAME.sh; then
# If name matches, PROJECT_DIR is my dirname.
    PROJECT_DIR=`dirname $0`
  elif test -n "$PBS_O_WORKDIR"; then
# Can I find via PBS?
    if test -f $PBS_O_WORKDIR/$BILDER_NAME.sh; then
      PROJECT_DIR=$PBS_O_WORKDIR
    else
      cat <<EOF
PBS, with PBS_O_WORKDIR = $PBS_O_WORKDIR and $PWD for the
current directory, but $PBS_O_WORKDIR does not contain
$BILDER_NAME.sh.  Under PBS, execute this in the directory
of $BILDER_NAME.sh, or set the working directory to be the
directory of $BILDER_NAME.sh
EOF
      exit 1
    fi
  else
    echo "This is not $BILDER_NAME.sh, yet not under PBS? Bailing out."
    exit 1
  fi
  PROJECT_DIR=`(cd "$PROJECT_DIR"; pwd -P)`
  if echo "$PROJECT_DIR" | grep -q ' '; then
    cat <<_
ERROR: Working directory, '$PROJECT_DIR', contains a space.
Bilder will fail.
Please remove the spaces from the directory name and then re-run.
_
    exit 1
  fi
}

