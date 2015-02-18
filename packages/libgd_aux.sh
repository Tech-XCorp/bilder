#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Find libgd.  This is used below, so must be first.
#
######################################################################

findLibgd() {

# Look for libgd-sersh in contrib directory on windows, but
# on mac and linux we use pkg-config
  case `uname` in
    CYGWIN*)
      findPackage Libgd gd "$CONTRIB_DIR" sersh
      if test -n "$LIBGD_SERSH_DIR"; then
        LIBGD_SERSH_DIR=`cygpath -am $LIBGD_SERSH_DIR`
      else
        techo "WARNING: libgd not found."
      fi
      ;;
    *)
      local libgdconfig=`which gdlib-config`
      if test -z "$libgdconfig"; then
        techo "WARNING: [$FUNCNAME] libgd not found by bilder. Please install gd-devel or gd-dev on Linux, or gd with homebrew on OSX."
      else
        local libgdlibdir=`$libgdconfig --libdir`
        local libgddir=`(cd $libgdlibdir/..; pwd -P)`
        techo "Using libgd from $libgddir."
        LIBGD_SERSH_DIR=$libgddir
      fi
      ;;
  esac

# If found, we set some arguments that can be used in other package
# configures to make sure libgd is consistent in all pkgs that use the args.
  if test -n "$LIBGD_SERSH_DIR"; then
    techo "Setting configure args to use libgd in $LIBGD_SERSH_DIR."
    CMAKE_LIBGD_SERSH_DIR_ARG="-DLibgd_ROOT_DIR:PATH='$LIBGD_SERSH_DIR'"
    CONFIG_LIBGD_SERSH_DIR_ARG="--with-libgd-dir='$LIBGD_SERSH_DIR'"
    printvar CMAKE_LIBGD_SERSH_DIR_ARG
    printvar CONFIG_LIBGD_SERSH_DIR_ARG
  else
    findPackage Libgd gd "$CONTRIB_DIR" sersh
  fi

# Look for libgd in contrib
  if test -z "$LIBGD_PYCSH_DIR"; then
    findPackage Libgd gd "$CONTRIB_DIR" pycsh
    findPycshDir Libgd
  fi

  if test -n "$LIBGD_PYCSH_DIR" -a "$LIBGD_PYCSH_DIR" != /usr; then
    addtopathvar PATH $LIBGD_PYCSH_DIR/bin
    if [[ `uname` =~ CYGWIN ]]; then
      LIBGD_PYCSH_DIR=`cygpath -am $LIBGD_PYCSH_DIR`
    fi
    CMAKE_LIBGD_PYCSH_DIR_ARG="-DLibgd_ROOT_DIR:PATH='$LIBGD_PYCSH_DIR'"
    CONFIG_LIBGD_PYCSH_DIR_ARG="--with-libgd-dir='$LIBGD_PYCSH_DIR'"
  fi
  printvar CMAKE_LIBGD_PYCSH_DIR_ARG
  printvar CONFIG_LIBGD_PYCSH_DIR_ARG

}

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setLibgdTriggerVars() {
  LIBGD_BLDRVERSION_STD=${LIBGD_BLDRVERSION_STD:-"2.1.0"}
  LIBGD_BLDRVERSION_EXP=${LIBGD_BLDRVERSION_EXP:-"2.1.0"}
# We do not install this as package managers work better on Linux and Mac,
# and Windows requires cmake, but that does not generate gdlib-config,
# which graphviz depends on.
  LIBGD_BUILDS=
  LIBGD_DEPS=cmake
}
setLibgdTriggerVars

