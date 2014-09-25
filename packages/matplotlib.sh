#!/bin/bash
#
# Build information for matplotlib
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in matplotlib_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/matplotlib_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMatplotlibNonTriggerVars() {
  :
}
setMatplotlibNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

#
# Find the directory of matplotlib dependency
#
# Args:
# 1: The package name
# 2: The include file
# 3: The library name without any prefix or suffix
# 4: All possible include dirs.  If empty, set to include
#
findMatplotlibDepDir() {
# For some reason, need to go deeper for freetype and libpng
  local sysdirs="$CONTRIB_DIR /opt/homebrew/opt/freetype /opt/homebrew/opt/libpng /opt/homebrew /opt/X11 /usr/X11R6 /usr/X11"
  local pkgdir=
  local libprefix=
  local incdirs="$4"
  incdirs=${incdirs:-"include"}
  case `uname` in
    CYGWIN*) libsfxs=lib;;
    Darwin) libprefix=lib; libsfxs=dylib;;
    Linux) libprefix=lib; libsfxs=so;;
  esac
  for j in $CONTRIB_DIR/$1-cc4py $CONTRIB_DIR/$1-sersh $CONTRIB_DIR/$1-sermd $sysdirs; do
    local incdir=
    for i in $incdirs; do
      # techo "Looking for $j/$i/$2." 1>&2
      if test -f $j/$i/$2; then
        incdir=`(cd $j/$i; pwd -P)`
        break
      fi
    done
    if test -z "$incdir"; then
      # techo "Not found." 1>&2
      continue
    fi
    # techo "Found. incdir = $incdir." 1>&2
    for k in ${libsfxs}; do
      for l in lib64 lib; do
        # techo "Looking for $j/$l/${libprefix}$3.$k." 1>&2
        if test -L $j/$l/${libprefix}$3.$k -o -f $j/$l/${libprefix}$3.$k; then
          pkgdir=$j
          break
        fi
      done
      if test -n "$pkgdir"; then
        break
      fi
    done
    if test -n "$pkgdir"; then
      break
    fi
  done
  # techo "${1}dir = $pkgdir." 1>&2
  if test -n "$pkgdir"; then
    pkgdir=`(cd $pkgdir; pwd -P)`
    # techo "${1}dir = $pkgdir." 1>&2
    if [[ `uname` =~ CYGWIN ]]; then
      pkgdir=`cygpath -aw $pkgdir`
      # techo "After cygpath conversion, ${1}dir = $pkgdir." 1>&2
      pkgdir=`echo $pkgdir | sed 's/\\\\/\\\\\\\\/g'`
    fi
    techo "${1}dir = $pkgdir." 1>&2
  else
    techo "WARNING: [$FUNCNAME] Unable to find $1." 1>&2
  fi
  trimvar pkgdir ','
  # techo "${1}dir = $pkgdir." 1>&2
  echo $pkgdir
}

buildMatplotlib() {

# On surveyor need to do
# ln -s /usr/lib64/libfreetype.so.6 /usr/lib64/libfreetype.so
# ln -s /usr/lib64/libpng.so.3 /usr/lib64/libpng.so
# ln -s /usr/lib64/libpng12.so.0 /usr/lib64/libpng12.so
# and build with
# env LDFLAGS="-m64 -pthread -shared -L$CONTRIB_DIR/lib -Wl,-rpath,$CONTRIB_DIR/lib" python setup.py install --prefix=/gpfs/home/projects/facets/surveyor/contrib
#
# On Darwin, can get freetype using brew:
# http://sourceforge.net/p/bilder/wiki/Preparing%20a%20Darwin%20machine%20for%20Bilder/

# Get package, continue building if needed
  if ! bilderUnpack matplotlib; then
    return
  fi

# Find dependencies and construct the basedirs variable needed for setup
  # techo "Looking for freetype."
  local freetypedir=`findMatplotlibDepDir freetype ft2build.h freetype "include include/freetype2"`
  # techo "freetypedir = $freetypedir."
  if test -z "${freetypedir}"; then
    case `uname` in
      Darwin)
        techo "WARNING: [$FUNCNAME] freetype not found.  Install via homebrew."
        ;;
      Linux)
        techo "WARNING: [$FUNCNAME] May need to install the -devel or -dev versions of freetype."
        ;;
    esac
  fi
  # techo "Looking for libpng."
  local libpngdir=`findMatplotlibDepDir libpng png.h png`
  # techo "libpngdir = $libpngdir."
  # techo "Looking for zlib."
  local zlibdir=
  case `uname` in
    CYGWIN*) zlibdir=`findMatplotlibDepDir zlib zlib.h zlib`;;
    *)       zlibdir=`findMatplotlibDepDir zlib zlib.h z`;;
  esac
  # techo "zlibdir = $zlibdir."
  local basedirs=
  for dir in "$freetypedir" "$libpngdir" "$zlibdir"; do
    if test -n "$dir" && ! echo $basedirs | grep -q "'$dir'"; then
      # if ! [[ "$dir" =~ /usr ]]; then
      if ! test "$dir" = /usr; then
        basedirs="$basedirs '$dir',"
      fi
    fi
  done
# Escape even more backslashes to get through sed
  if [[ `uname` =~ CYGWIN ]]; then
    basedirs=`echo $basedirs | sed 's/\\\\/\\\\\\\\/g'`
    basedirs=`echo $basedirs | sed 's/\\\\/\\\\\\\\/g'`
  fi
  printvar basedirs
  cd $BUILD_DIR/matplotlib-$MATPLOTLIB_BLDRVERSION

# Fix appropriate file
  case `uname` in
    CYGWIN*)
# CYGWIN does not listen to setup.cfg
      echo "sed -i.bak -e \"/^ *'win32' *:/s?'win32_static',?$basedirs?\" setupext.py"
      sed -i.bak -e "/^ *'win32' *:/s?'win32_static',?$basedirs?" setupext.py
      ;;
    # Linux)
      # sed -i.bak -e "/^ *'linux' *:/s?\] ?$basedirs]?" setupext.py
      # ;;
    *)
      sed -e "/basedirlist *=/s?^# *??" -e "/basedirlist *=/s? *=.*? = $basedirs?" <setup.cfg.template >setup.cfg
      ;;
  esac

# Accumulate link flags for modules, and make ATLAS modifications.
# Darwin defines PYC_MODFLAGS = "-undefined dynamic_lookup",
#   but not PYC_LDSHARED
# Linux defines PYC_MODFLAGS = "-shared", but not PYC_LDSHARED
  local linkflags="$CC4PY_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"

# Compute args such that for
#   Cygwin: build, install, and make packages all at once.
#   Others, just build.
  MATPLOTLIB_ENV="$DISTUTILS_NOLV_ENV"
  case `uname`-"$CC" in
    CYGWIN*-*cl*)
      MATPLOTLIB_ARGS="install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
      ;;
    CYGWIN*-mingw*)
      MATPLOTLIB_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
      MATPLOTLIB_ENV="$MATPLOTLIB_ENV PATH=/MinGW/bin:'$PATH'"
      ;;
    Darwin-*)
      ;;
    Linux-*)
# On hopper cannot include LD_LIBRARY_PATH
      if test -n "$pngdir"; then
        linkflags="$linkflags -Wl,-rpath,$pngdir/lib"
      fi
      if test -n "$freetypelibdir"; then
        linkflags="$linkflags -Wl,-rpath,$freetypedir/lib"
      fi
      ;;
    *)
      techo "WARNING: [matplotlib.sh] uname-CC `uname`-$CC not recognized.  Not building."
      return
      ;;
  esac
  trimvar linkflags ' '
  if test -n "$linkflags"; then
    MATPLOTLIB_ENV="$MATPLOTLIB_ENV LDFLAGS='$linkflags'"
  fi

# Build/install
  techo "NOTE: Building matplotlib without a GUI backend."
  bilderDuBuild matplotlib "$MATPLOTLIB_ARGS" "$MATPLOTLIB_ENV"

}

######################################################################
#
# Test
#
######################################################################

testMatplotlib() {
  techo "Not testing matplotlib."
}

######################################################################
#
# Install
#
######################################################################

installMatplotlib() {

# Below installed by matplotlib-1.1.0.  Gone in 1.3.0
  MATPLOTLIB_REMOVE="matplotlib mpl_toolkits pylab pytz"
# Below installed by matplotlib-1.3.0
  MATPLOTLIB_REMOVE="$MATPLOTLIB_REMOVE distribute nose pyparsing tornado"
# Below modified by matplotlib-1.3.0, but should not remove, as additive.
  # MATPLOTLIB_REMOVE="$MATPLOTLIB_REMOVE easy-install.pth setuptools.pth"
  case `uname`-`uname -r` in
    CYGWIN*) bilderDuInstall -n matplotlib;;
    *) bilderDuInstall -r "$MATPLOTLIB_REMOVE" matplotlib;;
  esac
  res=$?

# Fix perms of other installed items
  if test $res = 0; then
    for i in $MATPLOTLIB_REMOVE; do
      local instdirs=`\ls $PYTHON_SITEPKGSDIR/${i}* 2>/dev/null`
      if test -n "$instdirs"; then
        for j in $PYTHON_SITEPKGSDIR/${i}*; do
          setOpenPerms ${j}
        done
      else
        techo "NOTE: [matplotlib.sh] Need not set perms on $i for matplotlib-$MATPLOTLIB_BLDRVERSION."
      fi
    done
  fi

}

