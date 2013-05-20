#!/bin/bash
#
# $Id$
#
# To set a package as installed or uninstalled.
#
######################################################################

usage() {
  if test -n "$2"; then
    echo "ERROR: $2"
    echo
  fi
  cat >&2 <<EOF
Usage: $0 [options] package,build (e.g., hdf5,ser) to set installation state of a build of a package.
The version is taken from the build file in bilder/packages.
OPTIONS:
  -i    the installation directory
  -r    remove this from installation database.  (Default is to add.)
  -h    get this message
  -X    Get version for BUILD_EXPERIMENTAL being true
EOF
  exit $1
}

unset PKG_INSTALL_DIR
REMOVE=false
BUILD_EXPERIMENTAL=${BUILD_EXPERIMENTAL:-"false"}
BILDER_PACKAGE=${BILDER_PACKAGE:-"cmdline"}

# Hack so that bildfcns will not crap out looking for $VERBOSITY.
VERBOSITY=0

while getopts "b:i:hl:rX" arg; do
  case "$arg" in
    b) BILDER_PACKAGE=$OPTARG;;
    i) PKG_INSTALL_DIR=$OPTARG;;
    h) usage 0;;
    l) LOGFILE=$OPTARG;;
    r) REMOVE=true;;
    X) BUILD_EXPERIMENTAL=true;;
  esac
done
shift $(($OPTIND - 1))
# echo After args, have $*

if test -z "$1"; then
  usage 0
fi

if test -z "$PKG_INSTALL_DIR"; then
  usage 1 "Installation directory not specified."
fi

case $1 in
  *,*) package=`echo $1 | sed 's/,.*$//'`
       if test -z "$package"; then
         usage 1 "Package not specified."
       fi;;
    *) usage 1 "Build not specified.";;
esac

build=`echo $1 | sed 's/^.*,//'`

mydir=`dirname $0`
BILDER_DIR=`(cd $mydir; pwd -P)`
echo "BILDER_DIR = $BILDER_DIR."
if test -z "$PROJECT_DIR"; then
  PROJECT_DIR=`(cd $BILDER_DIR/..; pwd -P)`
fi

# Get the functions
source $BILDER_DIR/runnr/runnrfcns.sh
source $BILDER_DIR/bildfcns.sh
# Source any machine file
if test -n "$MACHINE_FILE"; then
  source $BILDER_DIR/machines/$MACHINE_FILE
fi

# We need PKGNM later, regardless of how we're determining the version.
PKGNM=`echo $package | tr 'A-Z./-' 'a-z___'`
#SEK: BILDER_CONFDIR/packages take precedence over BILDER_DIR/packages
# techo "$PKG_FILE does not exist."
if test -n "$BILDER_CONFDIR"; then
  PKG_FILE=$BILDER_CONFDIR/packages/$PKGNM.sh
  if test ! -e $PKG_FILE; then
    PKG_FILE=$BILDER_DIR/packages/$PKGNM.sh
    if test ! -e $PKG_FILE; then
      techo "Can't find $PKGNM.sh in $BILDER_DIR or $BILDER_CONFDIR.  Quitting."
      exit 1
    fi
  fi
else
  PKG_FILE=$BILDER_DIR/packages/$PKGNM.sh
  if test ! -e $PKG_FILE; then
    techo "Can't find $PKGNM.sh in $BILDER_DIR or $BILDER_CONFDIR.  Quitting."
    exit 1
  fi
fi
techo "PKG_FILE = $PKG_FILE."
#TMP
echo "PKG_FILE = $PKG_FILE."
exit 1

# If a repo, get that version, otherwise look in variables
vervar=`genbashvar $package`_BLDRVERSION
if test -d $PROJECT_DIR/$package; then
  getVersion $package
  verval=`deref $vervar`
else # Look in variables
  cmd="source $PKG_FILE"
  techo -2 "$cmd"
  $cmd
  cmd="computeVersion $package"
  techo -2 "$cmd"
  $cmd
  verval=`deref $vervar`
fi
techo "$vervar = $verval."

# Determine the version variable name
installstrval=${package}-${verval}-${build}
pkgScriptRev=`svn info $PKG_FILE | grep 'Last Changed Rev:' | sed 's/.* //'`
fullstrval="$installstrval $USER $BILDER_PACKAGE `date +%F-%T` bilder-r$pkgScriptRev"

# Put string into file
if $REMOVE; then
  techo "Removing record that $installstrval is installed."
  cp $PKG_INSTALL_DIR/installations.txt $PKG_INSTALL_DIR/installations.txt.old
  sed "/^$installstrval/d" <$PKG_INSTALL_DIR/installations.txt.old >$PKG_INSTALL_DIR/installations.txt
  rm $PKG_INSTALL_DIR/installations.txt.old
else
  techo "Marking $installstrval as installed."
  echo "$fullstrval" >> $PKG_INSTALL_DIR/installations.txt
fi

