#!/bin/bash
#
# Version and find information for oce
#
# $Id$
#
######################################################################

getOceVersion() {
  # OCE_BLDRVERSION=${OCE_BLDRVERSION:-"0.10.1-r747"}
  OCE_REPO_URL=git://github.com/tpaviot/oce.git
  OCE_UPSTREAM_URL=git://github.com/tpaviot/oce.git
  OCE_REPO_TAG_STD=OCE-0.14.1
  OCE_REPO_TAG_EXP=OCE-0.15
}
getOceVersion

######################################################################
#
# Find oce
#
######################################################################

# Find the directory containing the OCE cmake files
findOceCmakeDir() {
  local CGM_ADDL_ARGS=
  local ocerootdir=
  for dir in $BLDR_INSTALL_DIR/oce-sersh $CONTRIB_DIR/oce-sersh; do
    if ocerootdir=`(cd $dir; pwd -P) 2>/dev/null`; then
      break
    fi
  done
  if test -z "$ocerootdir"; then
    return
  fi
  ocever=`basename $ocerootdir | sed -e 's/^oce-//' -e 's/^OCE-//' -e "s/-$OCE_BUILD$//"`
  techo "Found OCE of version $ocever." 1>&2
  local ocecmakedir=
  case `uname` in
    CYGWIN*)
      ocecmakedir=${ocerootdir}/cmake
      ;;
    Darwin)
      for dir in ${ocerootdir}/OCE.framework/Versions/{$ocever,${ocever}-dev,*}; do
        if test -d $dir; then
          ocecmakedir=$dir/Resources
          break
        fi
      done
      ;;
    Linux)
      for dir in ${ocerootdir}/lib/{oce-$ocever,oce-${ocever}-dev,oce-*}; do
        if test -d $dir; then
          ocecmakedir=$dir
          break
        fi
      done
      ;;
  esac
  techo -2 "ocecmakedir =  $ocecmakedir." 1>&2
  echo "$ocecmakedir"
}

