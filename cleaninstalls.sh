#!/bin/bash
#
# $Id$
#
# To clean up installations.txt, removing records of installations
# that are no longer present.
#
######################################################################

# Source needed functions
bldrdir=`dirname $0`
bldrdir=`(cd $bldrdir; pwd -P)`
source $bldrdir/runnr/runnrfcns.sh
source $bldrdir/bildfcns.sh

usage() {
  cat >&2 <<EOF
Usage: $0 [options] <installdirs> to clean up <installdirs>:
  remove unfound installations from installations.txt
  optionally remove older installations
OPTIONS:
  -b   base directory under which to find contrib, volatile, and internal
  -d   Debug (echo commands without executing them)
  -h   Print this message
  -i   Treat this as an INSTALL_DIR and remove anything installed from
       a tarball
  -k # Keep this number of recent directories (defaults to 10000)
  -l   Remove broken links
  -r   Remove old installations
  -s   Suffix to add to installation directories (eg, vs9)
  -R   Remove from installations.txt any non present installation
EOF
  exit $1
}

#
# Clean an installation directory
#
# Args:
#  1: The directory to clean
#
cleanInstallDir() {

  CLN_INSTALL_DIR=$1
  if ! test -d "$CLN_INSTALL_DIR"; then
    echo "Installation directory, $CLN_INSTALL_DIR, not found. Skipping."
    return
  fi
  CLN_INSTALL_DIR=`(cd $CLN_INSTALL_DIR; pwd -P)`

  echo
  echo "---------- Cleaning directory, $CLN_INSTALL_DIR ----------"

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
        bin | gcc | lib | lib64 | share | *-pycsh | *-nopetsc | *-novisit | *-par | *-partau | *-visit | *.bak | *.csh | *.lnk| *.out | *.rmv | *.sh | *.tmp | *.txt)
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
# others, like pycsh, have to be listed explicitly
# Really want sort -V, but that is not present on all platforms
# Try listing by modification time
      \ls -1trd $i-* 2>/dev/null | sed -e "s/^$i//" -e 's/\.lnk//' -e 's/-[[:alpha:]]*$//' -e 's/-pycsh//' -e "s/^-//" -e '/^$/d' | uniq >numversions_$i.txt
      numversions=`wc -l numversions_$i.txt | sed -e "s/numversions_$i.txt//" -e 's/  *//g'`
      case $i in
        bin | develdocs | include | lib | man | share | userdocs) continue;
      esac
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
    return
  fi

# Remove old cc4py installations
  sed -i.bak '/cc4py/d' installations.txt

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
  sed -i.bak '/pycsh/d' installations.txt
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
      echo "$inst is in installations.txt."
      pkg=`echo $inst | sed 's/-.*$//'`
      echo "Package is $pkg."
      build=`echo $inst | sed 's/^.*-//'`
      echo "Build in installations.txt is $build."
      ver=`echo $inst | sed -e "s/${pkg}-//" -e "s/-${build}\$//"`
      echo "Version in installations.txt is $ver."
      echo "$pkg-$ver is in installations.txt"
      pv=`echo $LINE | sed 's/-pycsh.*$//'`
      echo "Found record for $pv in installations.txt."
      pkglc=`echo $pkg | tr 'A-Z' 'a-z'`
      pkgfile=
# Add * to end of file name to invoke globbing
      if test -n "$BILDER_CONFDIR"; then
        pkgfile=`(shopt -s nocaseglob; \ls $BILDER_CONFDIR/packages/${pkg}.sh* 2>/dev/null)`
      fi
      if test -z "$pkgfile"; then
        pkgfile=`(shopt -s nocaseglob; \ls $bldrdir/packages/${pkg}.sh* 2>/dev/null)`
      fi
      if test -z "$pkgfile"; then
# Look one level up
        pkgfile=`(shopt -s nocaseglob; \ls $bldrdir/../*/packages/${pkg}.sh* 2>/dev/null)`
      fi
      if test -z "$pkgfile"; then
        echo "WARNING: [cleaninstalls.sh] Package file for ${pkg}.sh not found. Will keep installation."
        echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
        continue
      fi
      echo "Bilder package file is ${pkgfile}."

# If python, get version by importing
      pver=
      if pkgline=`grep -q bilderDu $pkgfile`; then
        echo "$pkg is a python package."
        pver=`python -c 'import $pkg; print $pkg.__version__' 2>/dev/null | tr -d '\r'`
        if test -z "$pver"; then
          echo "$pkg installation has no version.  Will try lower case."
          pver=`python -c 'import $pkglc; print ${pkglc}.__version__' 2>/dev/null | tr -d '\r'`
          if test -z "$pver"; then
            echo "WARNING: [cleaninstalls.sh] $pkglc installation has no version.  Keeping record."
            echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
            continue
          fi
        fi
        echo "${pkg}-$pver is actually installed."
        case $pkg in
          setuptools)
            echo "WARNING: [cleaninstalls.sh] $pkglc has conflicting version.  Keeping record because matplotlib installs older version of setuptools."
            echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
            ;;
          *)
            if test "$pv" = ${pkg}-$pver; then
              echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
            else
              echo "${pv} is not installed.  Removing record."
            fi
            ;;
        esac
        continue
      fi

      case $pkglc in
# Packages that install a binary of the same nae
        doxygen | ninja)
          bindir=$CLN_INSTALL_DIR/bin
          if test -x $bindir/$pkglc; then
            ver=`$bindir/$pgklc --version`
            if [[ "$LINE" =~ ${pkglc}-$ver ]]; then
              echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
            fi
          fi
          continue
          ;;
        m4 | autoconf | automake | libtool)
          if test -z "$LIBTOOL_BLDRVERSION"; then
            source $bldrdir/packages/libtool.sh
          fi
          bindir=$CLN_INSTALL_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin
          if test -x $bindir/$pkglc; then
            ver=`$bindir/$pkglc --version | head -1 | sed 's/^.* //'`
            if [[ "$LINE" =~ $pkglc-$ver ]]; then
              echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
            else
              echo "'$LINE'" does not match $pkglc-$ver
            fi
          else
            echo "$pkglc not found."
          fi
          continue
          ;;
        pyqt | qt3d | sip)
          echo "Keeping ${pkglc} as does not have a top-level installation dir."
          echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
          continue
          ;;
        *tests)
          echo "${pkglc} is tests. Will keep."
          echo $LINE >>$CLN_INSTALL_DIR/installations.tmp
          continue
          ;;
      esac

# Not needed for now
if false; then
# If package sets clean variable to false, do not clean
      cleanvar=`genbashvar $pkg`_CLEAN
      pkgauxfile=${pkgfile%.sh}_aux.sh
      if test -f $pkgauxfile && grep -q $cleanvar $pkgauxfile; then
        source $pkgauxfile
      fi
      cleanval=`deref $cleanvar`
      cleanval=${cleanval:-"true"}
      if ! $cleanval; then
        continue
      fi
fi

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
      pkgverbld=`echo $inst | sed -e 's/ .*$//'`
      dt=`echo $instline | sed -e 's/ [^ ]*$//' -e 's/^.* //'`
      echo "Removing $pkgverbld records previous to $dt from installations.txt."
      sed -i.bak "/^${pkgverbld} /d" $CLN_INSTALL_DIR/installationsr.txt
    done
    cp $CLN_INSTALL_DIR/installations.txt $CLN_INSTALL_DIR/installations.bak2
    cmd="$TAC $CLN_INSTALL_DIR/installationsrs.txt >$CLN_INSTALL_DIR/installations.txt"
    echo "$cmd"
    eval "$cmd"

  fi

# Fix perms
  chmod g+rw,o+r $CLN_INSTALL_DIR/installations.txt

# Clean old files
  if ! $DEBUG; then
    rm -f $CLN_INSTALL_DIR/installations.{bak,rmv,txt~}
    rm -f $CLN_INSTALL_DIR/installationsr.txt
    rm -f $CLN_INSTALL_DIR/installationsrs.txt
    rm -f $CLN_INSTALL_DIR/numversions_*.txt
    rm -f *.bak *.bak2
  fi

}

BASEDIR=
DEBUG=false
REMOVE_OLD=false
REMOVE_BROKEN_LINKS=false
REMOVE_CONTRIB_PKGS=false
REMOVE_UNFOUND=false
KEEP=10000
while getopts "b:dhik:lrs:R" arg; do
  case "$arg" in
    b) BASEDIR=$OPTARG;;
    d) DEBUG=true;;
    h) usage;;
    i) REMOVE_CONTRIB_PKGS=true;;
    k) KEEP=$OPTARG;;
    l) REMOVE_BROKEN_LINKS=true;;
    r) REMOVE_OLD=true;;
    s) SUFFIX=$OPTARG;;
    R) REMOVE_UNFOUND=true;;
   \?) usage 1;;
  esac
done
shift $(($OPTIND - 1))

if $REMOVE_OLD; then
  $DEBUG &&  echo "Keeping $KEEP installations."
else
  $DEBUG && echo "Keeping all installations."
fi

# Get tac
if which tac 1>/dev/null 2>&1; then
  TAC=tac
else
  TAC="tail -r"
fi
$DEBUG && echo "TAC = $TAC."

# Get all dirs
if test -n "$BASEDIR"; then
  dirs=`echo ${BASEDIR}/{contrib${SUFFIX},volatile${SUFFIX},internal${SUFFIX}}/{.,userdocs,develdocs}`
fi
dirs="$dirs $*"

# Clean up dirnames
cleandirs=
for i in $dirs; do
  if test -d $i; then
    dir=`(cd $i; pwd -P)`
    dir=`echo $dir | sed 's?//?/?g'`
    cleandirs="$cleandirs $dir"
  else
    echo "$i not present.  Ignoring."
  fi
done

if test -z "$cleandirs"; then
  echo No specified installation directories are present.
  usage 1
fi
dirs=

echo "---------- cleaninstalls.sh will clean $cleandirs  ----------"

for dir in $cleandirs; do
  cmd="cleanInstallDir $dir"
  echo "$cmd"
  $cmd
done

