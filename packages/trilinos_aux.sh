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
  TRILINOS_BLDRVERSION_EXP=11.10.2
# Can add builds in package file only if no add builds defined.
  if test -z "$TRILINOS_DESIRED_BUILDS"; then
    TRILINOS_DESIRED_BUILDS="serbare,parbare,sercomm,parcomm"
    case `uname` in
      Darwin | Linux) TRILINOS_DESIRED_BUILDS="${TRILINOS_DESIRED_BUILDS},serbaresh,parbaresh,sercommsh,parcommsh,serfull,parfull,serfullsh,parfullsh";;
    esac
  fi
# Can remove builds based on OS here, as this decides what can build.
  case `uname` in
    CYGWIN*) TRILINOS_NOBUILDS=${TRILINOS_NOBUILDS},serbaresh,parbaresh,serfullsh,parfullsh,sercommsh,parcommsh;;
    Darwin) TRILINOS_NOBUILDS=${TRILINOS_NOBUILDS},parbaresh,parfullsh,parcommsh;;
  esac
  computeBuilds trilinos

# Add in superlu all the time.  May be needed elsewhere
  TRILINOS_DEPS=${TRILINOS_DEPS:-"hypre,mumps,superlu_dist,boost,$MPI_BUILD,superlu,swig,numpy,atlas,lapack"}
# commio builds depend on netcdf and hdf5. Only add in if these builds are present.
  if echo "$TRILINOS_BUILDS" | grep -q "commio" ; then
    TRILINOS_DEPS="netcdf,hdf5,${TRILINOS_DEPS}"
  fi

}
setTrilinosTriggerVars

######################################################################
#
# Find trilinos
#
######################################################################

findTrilinos() {
  :
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
    local tplLibName=${@:3:20}
    local tplConfig="-D${TPL}_INCLUDE_DIRS:PATH='${tplDir}/include' -D${TPL}_LIBRARY_DIRS:PATH='${tplDir}/lib' -D${TPL}_LIBRARY_NAMES:STRING='$tplLibName'"
    echo $tplConfig
}

getTriTPLs() {
  local buildtype=${1}
  local parflag=${buildtype:0:3}     # This converts sercplx to ser
  local TPLs=${@:2:20}

  local tplArgs=""
  for TPL in $TPLs; do
    argOn="-DTPL_ENABLE_${TPL}:BOOL=ON"
    case "$TPL" in
      Hypre) 
        if test "$parflag" == "ser"; then
          tplDir=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-sersh
        else
          tplDir=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-parsh
        fi
        tplLibName="HYPRE"
        ;;
      SuperLU) 
        if test "$parflag" == "ser"; then
          tplDir=$CONTRIB_DIR/superlu
        else
          continue  # parallel only
        fi
        tplLibName="superlu"
        ;;
      SuperLU_DIST) 
        if test "$parflag" == "ser"; then
          continue  # parallel only
        else
          tplDir=$CONTRIB_DIR/superlu_dist-par
        fi
        tplLibName="superlu_dist"
        ;;
      MUMPS)
        if test "$parflag" == "ser"; then
          if test -d $CONTRIB_DIR/mumps; then
            tplDir=$CONTRIB_DIR/mumps
          else
            tplDir=$BLDR_INSTALL_DIR/mumps
          fi
        else
          if test -d $CONTRIB_DIR/mumps-par; then
            tplDir=$CONTRIB_DIR/mumps-par
          else
            tplDir=$BLDR_INSTALL_DIR/mumps-par
          fi
        fi
        tplLibName='cmumps zmumps smumps dmumps mumps_common'
        ;;
    esac
    local tplLibArgs=`mkTplLibConfig $TPL $tplDir $tplLibName`
    tplArgs="$tplArgs $argOn $tplLibArgs"
  done
  echo $tplArgs
  return
}
