#!/bin/bash
#
# $Id$
#
# For creating a template file with all needed variables
#
######################################################################

usage() {
    echo "Usage: $0 [options]"
    echo "Result sent to stdout"
    echo "      -f <file>       name of file"
    echo "      -h              get this message"
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

mydir=`dirname $0`
while getopts "f:h" arg; do
  case "$arg" in
    f) sourcefile=$OPTARG;;
    h) usage; exit;;
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

# If sourcing, then just export the above variables
# Cannot do this or they go to all configures.
if test "$BASH_SOURCE" != $0; then
  return
fi

mydir=`dirname $0`

# Get the functions
source $mydir/bildfcns.sh

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
    echo $sourcefile does not exit.  Quitting. >&2
    exit
  fi
fi

# Write out the header
cat <<END
#!/bin/bash
#
# \$Id$
#
# Define variables.
# Do not override existing definitions.
# Put any comments between the first block starting with '# KEEP THIS'
# and ending with '# END KEEP THIS'
#
######################################################################

END

# Grab the keep this section
sed -n '/^# KEEP THIS$/,/^# END KEEP THIS$/p' <$sourcefile

echo
echo '# Serial compilers'
echo '# FC should be a compiler that compiles F77 or F90 but takes free format.'
echo '# F77 should be a compiler that compiles F77 or F90 but takes fixed format.'
echo '# Typically this means that both are the F90 compiler, and they figure out the'
echo '# format from the file suffix.  The exception is the XL suite, where xlf'
echo '# compiles F77 or F90, and expects fixed format, while xlf9x ignores'
echo '# the suffix and looks for the -qfixed flag or else fails on fixed format.'
writevars "$sercomps"

echo
echo '# PYC compilers:'
echo '# Some of the packages, in particular distutils, build with only PYC'
echo '# Python gcc compilers:'
# No need for defaults as set by bildvars.sh
if false; then
varval=`deref PYC_CC`
varval=${varval:-"gcc"}
echo 'PYC_CC=${PYC_CC:-"'$varval'"}'
varval=`deref PYC_CXX`
varval=${varval:-"g++"}
echo 'PYC_CXX=${PYC_CXX:-"'$varval'"}'
varval=`deref PYC_FC`
varval=${varval:-"gfortran"}
echo 'PYC_FC=${PYC_FC:-"'$varval'"}'
varval=`deref PYC_F77`
varval=${varval:-"gfortran"}
echo 'PYC_F77=${PYC_F77:-"'$varval'"}'
else
  writevars "PYC_CC PYC_CXX PYC_FC PYC_F77"
fi

echo
echo '# Backend compilers:'
writevars "$bencomps"

echo
echo '# Parallel compilers:'
writevars "$parcomps"

echo
echo '# Compilation flags:'
echo '# Do not set optimization flags as packages should add good defaults'
echo '# pic flags are added later'

echo
echo '# Serial'
writevars "$sercompflags"

echo
echo '# PYC flags:'
echo '# PYC_LDFLAGS is for creating an executable.'
echo '# PYC_MODFLAGS is for creating a module.'
writevars "$gcccompflags"

echo
echo '# Parallel'
writevars "$parcompflags"

echo
echo '# Linear algebra libraries:'
echo '# All should be a full path to the library.'
echo '# SER versions are for front-end nodes.'
echo '# BEN versions are for back-end nodes if different.'
echo '# PYC versions are for front-end nodes.'
writevars "$linalglibs"

echo
echo '# IO directories:'
writevars "$iodirs"

echo
echo '# Java options'
writevars "$javaopts" "export"

echo '# Choose preferred buildsystem'
writevars "$buildsysprefs"

echo
pkgs=`\ls $mydir/packages/*.sh | sed -e 's/\.sh//' -e "s/$mydir\/packages\///g"`
echo "# Variables for the packages, "${pkgs}.
echo "# All variables override defaults in files in bilder/packages."
echo "# <PKG>_BLDRVERSION contains the version to be built."
echo "# <PKG>_BUILDS contains the desired builds. Use of NOBUILD is deprecated."
echo "# <PKG>_<BUILD>_OTHER_ARGS contains the other configuration arguments"
echo "#   for build <BUILD>.  If a package could have a cmake or an autotools"
echo "#   build, then the variables are <PKG>_<BUILD>_CMAKE_OTHER_ARGS"
echo "#   and <PKG>_<BUILD>_CONFIG_OTHER_ARGS"
# echo pkgs are $pkgs
rm -f mkerrs.out
for pkg in $pkgs; do

# Variable name
  cappkg=`echo $pkg | tr 'a-z\./-' 'A-Z___'`
# Start new group
# Versions
  varname=${cappkg}_BLDRVERSION
  varstr=`sed -n "/^ *${varname}=/p" <tmp.sh`
  pkgname=`grep bilderUnpack $mydir/packages/$pkg.sh | head -1 | sed -e 's/ *#.$//' -e 's/;.*$//' -e 's/^.*  *//'`
  if test -z "$pkgname"; then
    pkgname=`grep bilderPreconfig $mydir/packages/$pkg.sh | head -1 | sed -e 's/ *#.$//' -e 's/;.*$//' -e 's/^.*  *//'`
  fi
  # echo "pkgname = $pkgname." 1>&2

# Get the builds
  unset builds
  if grep -q bilderDuBuild $mydir/packages/$pkg.sh; then
    builds=cc4py
  fi
  if test -z "$builds" -a -n "$pkgname"; then
    builds=`sed -e 's/ *#.*$//' <$mydir/packages/$pkg.sh | grep bilderBuild | sed -e 's/"[^"]*"//' -e "s/^.*$pkgname *//" -e 's/[ ;].*$//' -e 's/[\$"].*//' | sort -u`
  fi
# If did not get builds this way, try to determine from BUILDS variable
  if test -z "$builds"; then
    builds1=`grep "^ *${cappkg}_BUILDS=..${cappkg}_BUILDS" $mydir/packages/$pkg.sh | sed -e "s/${cappkg}_BUILDS//g" -e 's/\\$//g' -e 's/=//g'`
# Or builds can come from the quoted or not
    builds2=`grep "^ *${cappkg}_BUILDS=[\"a-z]" $mydir/packages/$pkg.sh | sed -e "s/${cappkg}_BUILDS//g" -e 's/\\$//g' -e 's/=//g'`
    builds="$builds1 $builds2"
    builds=`echo $builds | tr -d '":{}' | tr -d '\-'`
    builds=`echo $builds | sed -e 's/,/ /g' -e 's/NONE//'`
    builds=`echo $builds | sed -e 's/  / /g' -e 's/ /,/g'`
    echo $builds | tr ',' '\n' > builds.txt
    builds=`sort -u <builds.txt`
    rm builds.txt
    if grep -q '^ *addBenBuild' $mydir/packages/$pkg.sh; then
      if ! echo $builds | egrep -q "(^| )ben($| )"; then
        builds="$builds ben"
      fi
    fi
    if grep -q '^ *addCc4pyBuild' $mydir/packages/$pkg.sh; then
      if ! echo $builds | egrep -q "(^| )cc4py($| )"; then
        builds="$builds cc4py"
      fi
    fi
  fi
  # echo $pkg has builds $builds. 1>&2
  if test $pkg = nubeam; then
    : # echo exit; exit
  fi

# Loop over the builds to add other args
  if test -z "$builds"; then
    echo "# WARNING: No builds specified for package, $pkg." 1>&2
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
      hascmake=`grep ${cappkg}_${capbld}_CMAKE $mydir/packages/$pkg.sh`
      usescmake=`grep USE_CMAKE_ARG $mydir/packages/$pkg.sh`
      hasconfig=`grep ${cappkg}_${capbld}_CONFIG $mydir/packages/$pkg.sh`
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
  # if test $pkg = nimrod; then
    # exit
  # fi
done
echo
rm -f tmp.sh

