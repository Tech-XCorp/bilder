#!/bin/bash
#
# $Id$
#
# For creating a template file with all needed variables
#
######################################################################

usage() {
cat <<EOF
Usage: $0 [options]
Result sent to stdout
  -d <pkgdir> . comma-delimited list of directories containing package files.
                Defaults to subdir, packages.
  -f <file> ... name of file to work from.
  -G .......... do not include global variable definitions.
  -K .......... do not include the KEEPTHIS section.
  -h .......... get this message.
EOF
}

writevars() {
  for i in $1; do
    val=`deref $i`
    if test -n "$val"; then
      # val=`echo $val | sed 's?"?\"?g'`
      if test -n "$2"; then
        echo $2 $i='${'$i:-\"$val'"}'
      else
        echo $i='${'$i:-\"$val'"}'
      fi
    else
      if test -n "$2"; then
        echo '# '$2 $i=
      else
        echo '# '$i='${'$i':-""}'
      fi
    fi
  done
}

pdirs=
printglobals=true
printkeep=true
while getopts "d:f:GKh" arg; do
  case "$arg" in
    d) pdirs=$OPTARG;;
    f) sourcefile=$OPTARG;;
    h) usage; exit;;
    G) printglobals=false;;
    K) printkeep=false;;
  esac
done

# All variables are defined below
fccomps="HAVE_SER_FORTRAN HAVE_PAR_FORTRAN"
sercomps="CC CXX FC F77"
gcccomps="PYC_CC PYC_CXX PYC_FC PYC_F77"
bencomps="BENCC BENCXX BENFC BENF77"
parcomps="MPICC MPICXX MPIFC MPIF77"
sercompflags="CFLAGS CXXFLAGS FCFLAGS FFLAGS"
gcccompflags="PYC_CFLAGS PYC_CXXFLAGS PYC_FCFLAGS PYC_FFLAGS PYC_LDFLAGS PYC_MODFLAGS PYC_LD_LIBRARY_PATH PYC_LD_RUN_PATH"
parcompflags="MPI_CFLAGS MPI_CXXFLAGS MPI_FCFLAGS MPI_FFLAGS"
iodirs="SYSTEM_HDF5_SER_DIR SYSTEM_HDF5_PAR_DIR SYSTEM_NETCDF_SER_DIR SYSTEM_NETCDF_PAR_DIR"
linalglibs="SYSTEM_BLAS_SER_LIB SYSTEM_BLAS_CC4PY_LIB SYSTEM_BLAS_BEN_LIB SYSTEM_LAPACK_SER_LIB SYSTEM_LAPACK_CC4PY_LIB SYSTEM_LAPACK_BEN_LIB"
javaopts="_JAVA_OPTIONS"
buildsysprefs="PREFER_CMAKE"
allvars="$fccomps $sercomps $gcccomps $bencomps $parcomps $sercompflags $gcccompflags $parcompflags $iodirs $linalglibs $javaopts $buildsysprefs"

# If sourcing, then just define the above variables
# Cannot do this or they go to all configures.
if test "$BASH_SOURCE" != $0; then
  return
fi

# If run, then inside a machines area, do need to determine the packages area.
mydir=`dirname $0`
if test -n "$pdirs"; then
  pkgdirs=
  for i in `echo $pdirs | tr ',' ' '`; do
    pdir=`(cd $i; pwd -P)`
    pkgdirs="$pkgdirs $pdir"
  done
elif test -d ../packages; then
  pkgdirs=`(cd ../packages; pwd -P)`
elif test -d $mydir/packages; then
  pkgdirs=`(cd $mydir/packages; pwd -P)`
else
  echo "Packages directory unknown."; usage
fi
# echo pkgdirs = $pkgdirs.; exit

# Get the functions
source $mydir/bildfcns.sh
source $mydir/runnr/runnrfcns.sh

# Unset all variables
for i in $allvars; do
  unset $i
done

# Source variables from the file
if test -n "$sourcefile"; then
  if test -f $sourcefile; then
    echo Sourcing $sourcefile >&2
    sed  '/^# KEEP THIS$/,/^# END KEEP THIS$/d' <$sourcefile >tmp.sh
    source tmp.sh
    cp $sourcefile $sourcefile.bak
  else
    echo $sourcefile does not exist.  Quitting. >&2
    exit
  fi
else
  touch tmp.sh   # Stuff breaks if this is not here
fi

# Write out the header
cat <<END
#!/bin/bash
#
# \$Id$
# /* vim: set filetype=sh : */
#
# Define variables.
# Do not override existing definitions.
# Put any comments between the first block starting with '# KEEP THIS'
# and ending with '# END KEEP THIS'
#
######################################################################

END

# Grab the keep this section
if $printkeep; then
  if test -n "$sourcefile"; then
    sed -n '/^# KEEP THIS$/,/^# END KEEP THIS$/p' <$sourcefile
  fi
else
  cat <<EOF
# KEEP THIS

# END KEEP THIS
EOF
fi

if $printglobals; then
  cat <<EOF

# Serial compilers
# FC should be a compiler that compiles F77 or F90 but takes free format.
# F77 should be a compiler that compiles F77 or F90 but takes fixed format.
# Typically this means that both are the F90 compiler, and they figure out the
# format from the file suffix.  The exception is the XL suite, where xlf
# compiles F77 or F90, and expects fixed format, while xlf9x ignores
# the suffix and looks for the -qfixed flag or else fails on fixed format.
EOF
  writevars "$sercomps"

  cat <<EOF

# Python builds -- much use gcc for consistency.
EOF
  writevars "$gcccomps"

  cat <<EOF

# Backend compilers:
EOF
  writevars "$bencomps"

  cat <<EOF

# Parallel compilers:
EOF
  writevars "$parcomps"

  cat <<EOF

# Compilation flags:
# Do not set optimization flags as packages should add good defaults
# pic flags are added later

# Serial
EOF
  writevars "$sercompflags"

  cat <<EOF

# PYC flags:
# PYC_LDFLAGS is for creating an executable.
# PYC_MODFLAGS is for creating a module.
EOF
  writevars "$gcccompflags"

  cat <<EOF

# Parallel
EOF
  writevars "$parcompflags"

  cat <<EOF

# Linear algebra libraries:
# All should be a full path to the library.
# SER versions are for front-end nodes.
# BEN versions are for back-end nodes if different.
# PYC versions are for front-end nodes.
EOF
  writevars "$linalglibs"

  cat <<EOF

# IO directories:
EOF
  writevars "$iodirs"

  cat <<EOF

# Java options
EOF
  writevars "$javaopts" "export"

  cat <<EOF

# Choose preferred buildsystem
EOF
  writevars "$buildsysprefs"

fi

echo
echo "# Variables for the packages, "${pkgs}.
echo "# All variables override defaults in files in bilder/packages."
echo "# <PKG>_BLDRVERSION contains the version to be built."
echo "# <PKG>_BUILDS contains the desired builds.  NOBUILD is deprecated."
echo "# <PKG>_<BUILD>_OTHER_ARGS contains the other configuration arguments"
echo "#   for build <BUILD>.  If a package could have a cmake or an autotools"
echo "#   build, then the variables are <PKG>_<BUILD>_CMAKE_OTHER_ARGS"
echo "#   and <PKG>_<BUILD>_CONFIG_OTHER_ARGS"
for pkgdir in $pkgdirs; do
  pkgs=`\ls $pkgdir/*.sh | grep -v _aux | sed -e 's/\.sh//' -e "s?^.*/??"`
  # echo pkgs are $pkgs; exit
  rm -f mkerrs.out
  for pkg in $pkgs; do

# Variable name
    cappkg=`echo $pkg | tr 'a-z\./-' 'A-Z___'`
# Start new group
# Versions
    varname=${cappkg}_BLDRVERSION
    varstr=`sed -n "/^ *${varname}=/p" <tmp.sh`
    pkgname=`grep bilderUnpack $pkgdir/$pkg.sh | head -1 | sed -e 's/ *#.$//' -e 's/;.*$//' -e 's/^.*  *//'`
    if test -z "$pkgname"; then
      pkgname=`grep bilderPreconfig $pkgdir/$pkg.sh | head -1 | sed -e 's/ *#.$//' -e 's/;.*$//' -e 's/^.*  *//'`
    fi
    # echo "pkgname = $pkgname." 1>&2

# For python packages, only cc4py build
    unset builds
    ispypkg=false
    if grep -q bilderDuBuild $pkgdir/$pkg.sh; then
      builds=cc4py
      ispypkg=true
    fi
    if test -z "$builds" -a -n "$pkgname"; then
      builds=`sed -e 's/ *#.*$//' <$pkgdir/$pkg.sh | grep bilderBuild | sed -e 's/"[^"]*"//' -e "s/^.* $pkgname *//" -e 's/[ ;].*$//' -e 's/\$FORPYTHON/FORPYTHON/' -e 's/[\$"].*//' | sort -u`
    fi
    echo $pkg has builds $builds. 1>&2
# If did not get builds this way, try to determine from BUILDS variable
    if test -z "$builds"; then
      if test -e $pkgdir/${pkg}_aux.sh; then
        pkgbldsfile=$pkgdir/${pkg}_aux.sh
      else
        pkgbldsfile=$pkgdir/${pkg}.sh
      fi
      builds1=`grep "^ *${cappkg}_BUILDS=..${cappkg}_BUILDS" $pkgbldsfile | sed -e "s/${cappkg}_BUILDS//g" -e 's/\\$//g' -e 's/=//g'`
# Or builds can come from the quoted or not
      builds2=`grep "^ *${cappkg}_BUILDS=[\"a-z]" $pkgbldsfile | sed -e "s/${cappkg}_BUILDS//g" -e 's/\\$//g' -e 's/=//g'`
      builds="$builds1 $builds2"
      builds=`echo $builds | tr -d '":{}' | tr -d '\-'`
      builds=`echo $builds | sed -e 's/,/ /g' -e 's/NONE//'`
      builds=`echo $builds | sed -e 's/  / /g' -e 's/ /,/g'`
      echo $builds | tr ',' '\n' > builds.txt
      builds=`sort -u <builds.txt`
      rm builds.txt
      if grep -q '^ *addBenBuild' $pkgdir/$pkg.sh; then
        if ! echo $builds | egrep -q "(^| )ben($| )"; then
          builds="$builds ben"
        fi
      fi
      if grep -q '^ *addCc4pyBuild' $pkgdir/$pkg.sh; then
        if ! echo $builds | egrep -q "(^| )cc4py($| )"; then
          builds="$builds cc4py"
        fi
      fi
    fi
    if echo $builds | grep -q FORPYTHON_BUILD; then
      builds=`echo $builds | sed 's/FORPYTHON_BUILD//'`" sersh cc4py"
    fi
    builds=$(echo "$builds" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    trimvar builds ' '
    echo $pkg has builds $builds. 1>&2
    if test $pkg = nubeam; then
      : # echo exit; exit
    fi

# Loop over the builds to add other args
    if test -z "$builds"; then
      echo "# WARNING: [mkvars.sh] No builds specified for package, $pkg." 1>&2
    else
# Builds looks good, so output
      echo
      if test -n "$varstr"; then
        echo "$varstr"
      else
        echo "# $varname="'${'$varname':-""}'
      fi
# Get builds from sourcefile
      varname=${cappkg}_BUILDS
      varstr=`sed -n "/^ *${varname}=/p" <tmp.sh`
      if test -n "$varstr"; then
        echo "$varstr"
      else
        echo "# $varname="'${'$varname':-""}'
      fi
# Get other vars from grep
      for i in $builds; do
        capbld=`echo $i | tr 'a-z./-' 'A-Z___'`
        hascmake=`grep ${cappkg}_${capbld}_CMAKE $pkgdir/$pkg.sh`
        usescmake=`grep USE_CMAKE_ARG $pkgdir/$pkg.sh`
        hasconfig=`grep ${cappkg}_${capbld}_CONFIG $pkgdir/$pkg.sh`
        if test -n "$hascmake" -o -n "$usescmake" && test -n "$hasconfig"; then
          for j in CMAKE CONFIG; do
            echo "$pkg has autotools and cmake." >>mkerrs.out
            echo "hascmake = $hascmake." >>mkerrs.out
            echo "hasconfig = $hasconfig." >>mkerrs.out
            echo "usescmake = $usescmake." >>mkerrs.out
            varname=${cappkg}_${capbld}_${j}_OTHER_ARGS
            # varval="`deref $varname`"
            varstr=`sed -n "/^ *${varname}=/p" <tmp.sh`
            if test -n "$varstr"; then
              echo "$varstr"
            else
              # echo "# $varname="
              echo "# $varname="'${'$varname':-""}'
            fi
          done
        else
          varname=${cappkg}_${capbld}_OTHER_ARGS
          # varval="`deref $varname`"
          varstr=`sed -n "/^ *${varname}=/p" <tmp.sh`
          if test -n "$varstr"; then
            echo "$varstr"
          else
            # echo "# $varname="
            echo "# $varname="'${'$varname':-""}'
          fi
        fi
      done
    fi
  done
  echo
rm -f tmp.sh
done

