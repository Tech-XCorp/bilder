#!/bin/bash
#
# Trigger vars and find information
#
# This is repacked to obey bilder conventions
# tar xzf trilinos-10.2.0-Source.tar.gz
# mv trilinos-10.2.0-Source trilinos-10.2.0
# tar czf trilinos-10.2.0.tar.gz trilinos-10.2.0
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setTrilinosTriggerVars() {
# Versions
  TRILINOS_BLDRVERSION_STD=11.4.3
  TRILINOS_BLDRVERSION_EXP=11.12.1
# Can add builds in package file only if no add builds defined.
  if test -z "$TRILINOS_DESIRED_BUILDS"; then
    TRILINOS_DESIRED_BUILDS="sercomm,parcomm"
    case `uname` in
      Darwin | Linux) TRILINOS_DESIRED_BUILDS="${TRILINOS_DESIRED_BUILDS},sercommsh,parcommsh";;
    esac
  fi
# Can remove builds based on OS here, as this decides what can build.
  case `uname` in
    CYGWIN*) TRILINOS_NOBUILDS=${TRILINOS_NOBUILDS},serbaresh,parbaresh,serfullsh,parfullsh,sercommsh,parcommsh;;
    Darwin) TRILINOS_NOBUILDS=${TRILINOS_NOBUILDS},parbaresh,parfullsh,parcommsh;;
  esac
  computeBuilds trilinos

# Add in superlu all the time.  May be needed elsewhere
  TRILINOS_DEPS=${TRILINOS_DEPS:-"mumps,superlu_dist,boost,$MPI_BUILD,superlu,swig,numpy,atlas,lapack"}
# commio builds depend on netcdf and hdf5.
# Only add in if these builds are present.
  if echo "$TRILINOS_BUILDS" | grep -q "commio" ; then
    TRILINOS_DEPS="netcdf,hdf5,${TRILINOS_DEPS}"
  fi
  case `uname` in
     CYGWIN*) ;;
     *) TRILINOS_DEPS="hypre,mumps,${TRILINOS_DEPS}";;
  esac

}
setTrilinosTriggerVars

######################################################################
#
# Find trilinos
#
######################################################################

findTrilinos() {
  findContribPackage Trilinos trilinos sercomm parcomm  sercommio parcommio sercommsh parcommsh
}

getTriPackages() {
  local triPackages=$@
  local triPkgArgs=""
  for pkg in $triPackages; do
    triPkgArgs="$triPkgArgs -DTrilinos_ENABLE_${pkg}:BOOL=ON"
  done
  echo $triPkgArgs
}

mkTplLibConfig() {
    local TPL=$1
    local tplDir=$2
    if test -e $tplDir; then
      if [[ `uname` =~ CYGWIN ]]; then
        tplDir=`cygpath -am $tplDir`
      fi
      local tplLibName=${@:3:20}
      local tplConfig="-D${TPL}_INCLUDE_DIRS:PATH='${tplDir}/include' -D${TPL}_LIBRARY_DIRS:PATH='${tplDir}/lib' -D${TPL}_LIBRARY_NAMES:STRING='$tplLibName'"
      echo $tplConfig
    fi
}

getTriTPLs() {
  local buildtype=${1}
  local parflag=${buildtype:0:3}     # This converts sercplx to ser
  local TPLs=${@:2:20}

  local tplArgs=""
  for TPL in $TPLs; do
    tplDir=
    addlArgs=""
    case "$TPL" in

      HYPRE)
        if test "$parflag" == "ser"; then
          continue  # parallel only
        elif test -e $CONTRIB_DIR/hypre-parsh; then
          tplDir=$CONTRIB_DIR/hypre-parsh
        fi
        tplLibName="HYPRE"
        ;;

      MUMPS)
        tplLibName='cmumps;zmumps;smumps;dmumps;mumps_common;pord'
        if test "$parflag" == "ser"; then
# Experimental trilinos not building serial with Mumps on Linux
          if ! $BUILD_EXPERIMENTAL || ! test `uname` = Linux; then
            tplLibName="${tplLibName};seq"
            if test -e $CONTRIB_DIR/mumps; then
              tplDir=$CONTRIB_DIR/mumps
            elif test -e $BLDR_INSTALL_DIR/mumps; then
              tplDir=$BLDR_INSTALL_DIR/mumps
            fi
          fi
        else
          if test -e $CONTRIB_DIR/mumps-par; then
            tplDir=$CONTRIB_DIR/mumps-par
          elif test -e $BLDR_INSTALL_DIR/mumps-par; then
            tplDir=$BLDR_INSTALL_DIR/mumps-par
          fi
        fi
        ;;

      SuperLU)
        if test "$parflag" == "ser"; then
          tplDir=$CONTRIB_DIR/superlu
        else
          continue  # serial only
          # Note that I worry aboud duplicate symbols with dist
        fi
        tplLibName="superlu"
        ;;

      SuperLUDist)
        if test "$parflag" == "ser"; then
          continue  # parallel only
        else
          tplDir=$CONTRIB_DIR/superlu_dist-par
        fi
        tplLibName="superlu_dist"
        addlArgs="-DTPL_ENABLE_SuperLUDist_Without_ParMETIS:BOOL=TRUE"
        ;;

    esac
    if test -n "$tplDir"; then
      tplDir=`(cd $tplDir; pwd -P)`
      argOn="-DTPL_ENABLE_${TPL}:BOOL=ON"
      local tplLibArgs=`mkTplLibConfig $TPL $tplDir $tplLibName`
      tplArgs="$tplArgs $argOn $tplLibArgs $addlArgs"
    else
      techo "Not enabling $TPL as installation directory not found." 1>&2
    fi
  done

  echo $tplArgs
  return

}
