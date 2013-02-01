#!/bin/bash
#
# $Id$
#
# To clean up installations.txt, removing records of installations
# that are no longer present.
#
######################################################################

usage() {
  cat >&2 <<EOF
Usage: $0 [options] <installdir> to clean up <installdir>:
  remove unfound installations from installations.txt
  optionally remove older installations
OPTIONS:
  -d   Debug (echo commands without executing them)
  -h   Print this message
  -i   Treat this as an INSTALL_DIR and remove anything installed from
       a tarball
  -k # Keep this number of recent directories (defaults to 10000)
  -l   Remove broken links
  -r   Remove old installations
  -R   Remove from installations.txt any non present installation
EOF
  exit $1
}

bldrdir=`dirname $0`
bldrdir=`(cd $bldrdir; pwd -P)`
DEBUG=false
REMOVE_OLD=false
REMOVE_BROKEN_LINKS=false
REMOVE_CONTRIB_PKGS=false
REMOVE_UNFOUND=false
KEEP=10000
while getopts "dhik:lrR" arg; do
  case "$arg" in
    d) DEBUG=true;;
    h) usage; exit;;
    i) REMOVE_CONTRIB_PKGS=true;;
    k) KEEP=$OPTARG;;
    l) REMOVE_BROKEN_LINKS=true;;
    r) REMOVE_OLD=true;;
    R) REMOVE_UNFOUND=true;;
   \?) usage 1;;
  esac
done
shift $(($OPTIND - 1))
CLN_INSTALL_DIR=$1

if test -z "$CLN_INSTALL_DIR"; then
  echo Installation directory not specified.
  usage 1
fi

if ! test -d "$CLN_INSTALL_DIR"; then
  echo Installation directory, $CLN_INSTALL_DIR, not found.
  usage 1
fi

if $REMOVE_OLD; then
  echo "Keeping $KEEP installations."
else
  echo "Keeping all installations."
fi

# Source needed functions
source $bldrdir/runnr/runnrfcns.sh

# Get tac
if which tac 1>/dev/null 2>&1; then
  TAC=tac
else
  TAC="tail -r"
fi
echo "TAC = $TAC."

# Remove old installations
if $DEBUG; then
  echo "CLN_INSTALL_DIR = $CLN_INSTALL_DIR"
fi
cd $CLN_INSTALL_DIR
if $REMOVE_OLD; then
  # pkgcands=`\ls -1  | sed 's/-.*-*$//' | sort -u`
  pkgcands=`\ls -1  | sed 's/-.*$//' | sort -u`
  # echo "pkgcands = $pkgcands"
  unset pkgs
  for i in $pkgcands; do
    case $i in
      bin | lib | lib64 | share | *-cc4py | *-nopetsc | *-novisit | *-par | *-partau | *-visit | *.bak | *.csh | *.lnk| *.out | *.rmv | *.sh | *.tmp | *.txt)
        ;;
      *)
        pkgs="$pkgs $i"
        ;;
      *)
    esac
  done
  echo "pkgs = $pkgs"
  for i in $pkgs; do
# Separate sorts or works on first field only.
# Following depends on non versions (builds) being alpha only, so
# others, like cc4py, have to be listed explicitly
# Really want sort -V, but that is not present on all platforms
    # \ls -1d $i-* 2>/dev/null | sed -e "s/^$i//" -e 's/\.lnk//' -e 's/-[[:alpha:]]*$//' -e 's/-cc4py//' -e "s/^-//" -e '/^$/d' | sort -u | sort -n >numversions_$i.txt
# Try listing by modification time
    # \ls -1trd $i-* 2>/dev/null | sed -e "s/^${i}//" -e "s/^-//" -e 's/-[^-]*$//' -e 's/\.lnk//' -e '/^$/d' | uniq >numversions_$i.txt
    \ls -1trd $i-* 2>/dev/null | sed -e "s/^$i//" -e 's/\.lnk//' -e 's/-[[:alpha:]]*$//' -e 's/-cc4py//' -e "s/^-//" -e '/^$/d' | uniq >numversions_$i.txt
    numversions=`wc -l numversions_$i.txt | sed -e "s/numversions_$i.txt//" -e 's/  *//g'`
    echo "There are $numversions versions of $i."
    cat numversions_$i.txt
    if test $numversions -gt $KEEP; then
      numrm=`expr $numversions - $KEEP`
      echo "Removing $numrm versions of $i."
      rmversions=`head -$numrm numversions_$i.txt | tr '\n' ' '`
      echo "rmversions = $rmversions"
      for j in $rmversions; do
        cmd="rm -rf $i-$j*"
        echo $cmd
        if ! $DEBUG; then
          $cmd
        fi
      done
    fi
    if ! $DEBUG; then
      rm numversions_$i.txt
    fi
  done
fi

if ! test -f "$CLN_INSTALL_DIR/installations.txt"; then
  echo $CLN_INSTALL_DIR/installations.txt not cleaned as not found in installation directory.
  exit 0
fi

# Removing tarball packages.  Do as subshell so as not to change
# nocaseglob in this shell.
if $REMOVE_CONTRIB_PKGS; then
  cd $CLN_INSTALL_DIR
cat >rmtarballs.sh <<EOF
#!/bin/bash
echo "Removing tarball packages."
shopt -s nocaseglob
for i in $bldrdir/packages/*; do
  if ! grep -q getVersion \$i; then
    pkg=\`basename \$i .sh\`
    dirs=\`ls -d \${pkg} \${pkg}-* 2>/dev/null\`
    if test -n "\$dirs"; then
      echo "Removing \$dirs. pkg = \$pkg."
      rm -rf \${dirs}
    else
      echo "\$pkg dirs not found."
    fi
  fi
done
# Special cases
rm -rf autotools* mpi tau lib/python*
# Double versions
rm -rf *-r[0-9]*-[0-9]*-* *-r[0-9]*\:[0-9]*-*
# Remove python
sed -i.bak '/cc4py/d' installations.txt
EOF
  chmod a+x rmtarballs.sh
  cmd="./rmtarballs.sh"
  echo $cmd
  $cmd
  if ! $DEBUG; then
    rm rmtarballs.sh
  fi
# Return to start directory
  cd - 1>/dev/null
fi

# Remove broken links.
# find -L $CLN_INSTALL_DIR -type l -delete
# Above does not work on benten, so go to below
if $REMOVE_BROKEN_LINKS; then
  echo "Removing broken links."
  find $CLN_INSTALL_DIR -follow -type l | while read f; do if [ ! -e "$f" ]; then rm -f "$f"; fi; done
  cd $CLN_INSTALL_DIR
  echo "Removing shortcuts without corresponding link."
  for i in `ls *.lnk 2>/dev/null`; do
    echo "Examining $i."
    b=`basename $i .lnk`
    if ! test -e $b; then
      cmd="rm $i"
      echo $cmd
      $cmd
    fi
  done
  cd - 1>/dev/null 2>&1
fi

# Read installations.txt a line at a time, look for installation.
# It need not have the build appended.
# PROBLEM: what about packages installed under a different subdir?
# Need to define installation subdir or installation suffix (ser -> sersh)
if $REMOVE_UNFOUND; then
# echo $bldrdir
  rm -f $CLN_INSTALL_DIR/installations.tmp $CLN_INSTALL_DIR/installations.rmv
  touch $CLN_INSTALL_DIR/installations.tmp
# source $bldrdir/bilderpy.sh 1>/dev/null 2>&1
# echo PYINSTDIR = $PYINSTDIR
# export PYTHONPATH=$PYINSTDIR
  cat $CLN_INSTALL_DIR/installations.txt | while read LINE; do
    inst=`echo $LINE | sed 's/ .*$//'`
    echo "Installation is $inst."
    pkg=`echo $inst | sed 's/-.*$//'`
    echo "Package is $pkg."
    build=`echo $inst | sed 's/^.*-//'`
    echo "Build is $build."
    ver=`echo $inst | sed -e "s/${pkg}-//" -e "s/-${build}\$//"`
    echo "Version is $ver."
    pkglc=`echo $pkg | tr 'A-Z' 'a-z'`
    echo "Bilder file is ${pkglc}.sh."
    pkgfile=
    if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/${pkglc}.sh; then
      pkgfile=$BILDER_CONFDIR/packages/${pkglc}.sh
    elif test -f $bldrdir/packages/${pkglc}.sh; then
      pkgfile=$bldrdir/packages/${pkglc}.sh
    else
# Look one level up
      pkgfile=`ls $bldrdir/../*/packages/${pkglc}.sh 2>/dev/null | head -1`
    fi
    if test -z "$pkgfile"; then
      echo "WARNING: ${pkglc}.sh not found. Will keep installation."
      echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
      continue
    fi
    if grep -q bilderDu $pkgfile; then
      echo "$subdir is a python package.  Not checking."
      echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
      continue
    fi
    case $pkglc in
      m4 | autoconf | automake | libtool)
        echo "${pkglc} is an autotools package. Will keep."
        echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
        continue
        ;;
      *tests)
        echo "${pkglc} is tests. Will keep."
        echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
        continue
        ;;
    esac
# If any subdir with that version present, keep
    # rev=`echo $inst | sed -e "s/${pkg}-//" -e 's/-.*$//'`
    dirs=`(cd $CLN_INSTALL_DIR; \ls -d ${pkg}-${ver}-* ${pkg}-${ver} 2>/dev/null)`
    if test -n "$dirs"; then
      echo "$CLN_INSTALL_DIR/${pkg}-${ver}-* present."
      echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
    else
      echo "$CLN_INSTALL_DIR/${pkg}-${ver}-* absent."
      echo $LINE >>$CLN_INSTALL_DIR/installations.rmv
    fi
  done
  mv $CLN_INSTALL_DIR/installations.txt $CLN_INSTALL_DIR/installations.bak
  mv $CLN_INSTALL_DIR/installations.tmp $CLN_INSTALL_DIR/installations.txt

# Now remove duplicate installations in installations.txt, keeping the latest
  cmd="$TAC $CLN_INSTALL_DIR/installations.txt >$CLN_INSTALL_DIR/installationsr.txt"
  echo "$cmd"
  eval "$cmd"
  rm -f $CLN_INSTALL_DIR/installationsrs.txt
  touch $CLN_INSTALL_DIR/installationsrs.txt
  while test -s $CLN_INSTALL_DIR/installationsr.txt; do
    # echo "Reading a line from installationsr.txt."
    read instline <$CLN_INSTALL_DIR/installationsr.txt
    echo $instline >>$CLN_INSTALL_DIR/installationsrs.txt
    inst=`echo $instline | sed 's/ .*$//'`
    pkg=`echo $inst | sed -e 's/-.*$//'`
    echo "Removing $pkg records older than $inst from installations.txt."
    sed -i.bak "/^${pkg}-/d" $CLN_INSTALL_DIR/installationsr.txt
  done
  cp $CLN_INSTALL_DIR/installations.txt $CLN_INSTALL_DIR/installations.bak2
  cmd="$TAC $CLN_INSTALL_DIR/installationsrs.txt >$CLN_INSTALL_DIR/installations.txt"
  echo "$cmd"
  eval "$cmd"

fi

# Clean old files
if ! $DEBUG; then
  rm -f $CLN_INSTALL_DIR/installations.{bak,rmv,txt~}
  rm -f $CLN_INSTALL_DIR/installationsr.txt
  rm -f $CLN_INSTALL_DIR/installationsrs.txt
  rm -f *.bak *.bak2
fi

