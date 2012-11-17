#!/bin/bash
#
# Version and build information for petsc-3.3 version
#
# $Id$
#
######################################################################

PETSC33_BLDRVERSION=${PETSC33_BLDRVERSION:-"p4"}

######################################################################
#
# Builds and dpes.  This can go up to 16 builds
#
######################################################################

if test -z "$PETSC33_BUILDS"; then
  PETSC33_BUILDS=ser,par
  if test -n "$BUILD_PETSCCOMPLEX"; then
    PETSC33_BUILDS=${PETSC33_BUILDS},sercplx,parcplx
  fi
  if $BUILD_DEBUG; then
    for build in `echo $PETSC33_BUILDS | tr , " "`; do
      PETSC33_BUILDS=$PETSC33_BUILDS,${build}dbg
    done
  fi
# Default is static but shared versions are needed for COSML
  if test -n "$BUILD_PETSCSHARED"; then
    for build in `echo $PETSC33_BUILDS | tr , " "`; do
      PETSC33_BUILDS=$PETSC33_BUILDS,${build}sh
    done
  fi
fi

PETSC33_DEPS=atlas,clapack_cmake,mercurial,hypre,superlu,superlu_dist,Python
BUILD_PETSC_WITH_GPU_CODE=${BUILD_PETSC_WITH_GPU_CODE:-false}
if $BUILD_PETSC_WITH_GPU_CODE; then
 PETSC33_DEPS=$PETSC33_DEPS,cusp
fi
PETSC33_UMASK=002
BUILD_PETSC_WITH_HYPRE=${BUILD_PETSC_WITH_HYPRE:-false}
BUILD_PETSC_WITH_SUPERLU=${BUILD_PETSC_WITH_SUPERLU:-false}


######################################################################
#  Functions that are going to be used to enable looping over all of the
#  above builds
######################################################################
get_petsc_vardefined() {
  # Example call: `get_petsc_vardefined parcplxdbg ADDL_ARGS`
  buildstrip=${1:0:3}     # This converts sersh or sercplx to ser
  local paddl_var=PETSC_`genbashvar $buildstrip`_$2
  echo `deref $paddl_var`
}
get_petsc_par_args() {
  buildstrip=${1:0:3}     # This converts sersh or sercplx to ser
  if test "$buildstrip" == "ser"; then
        echo "--with-mpi=0"
  else
        echo "--with-mpi=1"
  fi
}
get_petsc_dbg_args() {
  dbgflag=${1: -3}          # This pulls off if it's dbg
  if test "$dbgflag" == "dbg"; then
    echo "--with-debugging=1"
  else
    dbgshflag=${1: -5}          # This tests the dbgsh
    dbgflag=${dbgshflag:0:3}          # This tests the dbgsh
    if test "$dbgflag" == "dbg"; then
      echo "--with-debugging=1"
    else
      echo "--with-debugging=0 --COPTFLAGS='-O2 -g'"
    fi
  fi
}
get_petsc_sh_args() {
  shflag=${1: -2}      # Pull of the cplx from the build
  if test "$shflag" == "sh"; then
    echo "--with-shared-libraries=1"
  else
    echo "--with-shared-libraries=0"
  fi
}
get_petsc_cplx_args() {
  cplxflag=${1:3:4}      # Pull of the cplx from the build
  if test "$cplxflag" == "cplx"; then
    echo "--with-scalar-type=complex"
  else
    buildstrip=${1:0:3}     # This converts sersh or sercplx to ser
    #if test "$buildstrip" == "par"; then
    #  echo "--download-hypre"   # Hypre cannot be used with complex
    #fi
  fi
}

get_petsc_env() {
  echo "$PETSC_ENV PETSC_DIR=$BUILD_DIR/petsc33 PETSC_ARCH=$1"
}

######################################################################
#
# Launch petsc 3.3 builds.
#
######################################################################

buildPetsc33() {

  ###
  ## Check for svn version or package
  #
  if test -d $PROJECT_DIR/petsc33; then
    PETSCDIR_SUFFIX=""
    getVersion petsc33
    # SEK: No preconfig needed in general but perhaps there is
    # something else in preconfig we need?
    bilderPreconfig petsc33
    res=$?
    if $SVNUP; then
      cd $PROJECT_DIR/petsc33
      hg pull
      cd -
    fi
  else
    PETSCDIR_SUFFIX="-${PETSC33_BLDRVERSION}"
    bilderUnpack petsc33
    res=$?
  fi
  ###---------------------------------------------------------------------------
  # Start by specifying the following variables (SER/PAR):
  #   PETSC_PAR_COMPILERS: Put the compilers into the form that petsc wants
  #   PETSC_PAR_FLAG_ARGS: Put the flags into the form that petsc wants
  #   PETSC_PAR_OTHER_ARGS 
  #   PETSC_PAR_ADDL_ARGS 
  #   PETSC_PAR_PKGS:      Specify the packages
  #   PETSC_ENV 
  #   PETSC_DIRARG
  #   CONFIG_LINLIB_SER_ARGS  
  # Do not put any of the debug/opt or real/cplx into the above: They are
  # handled by the build name and the above functions
  ###---------------------------------------------------------------------------

  if test $res = 0; then
    ###---------------------------------------------------------------------------
    ## Create petscrepo's compilers
    #
    echo "------------------------> ", $res
    if test -z "$PETSC_SER_COMPILERS"; then
      # Remove mingw C: stuff.
      case `uname` in
        CYGWIN*)
          PCC="win32fe `basename \"$CC\"`"
          PCXX="win32fe `basename \"$CXX\"`"
          PF77="win32fe `basename \"$F77\"`"
          PMPICC="win32fe `basename \"$CC\"`"
          PMPICXX="win32fe `basename \"$CXX\"`"
          PMPIF77="win32fe `basename \"$F77\"`"
          ;;
        *)
          PCC=$CC;       PCXX=$CXX;       PF77=$F77
          PMPICC=$MPICC; PMPICXX=$MPICXX; PMPIF77=$MPIF77
          ;;
      esac

      if test -n "$F77"; then
        PETSC_SER_FORTRAN_CONF="--with-fortran=1 --with-fc='$PF77'"
      fi

      PETSC_SER_COMPILERS=`echo "--with-clanguage=C++ --with-c-support=1 --with-cc='$PCC' --with-cxx='$PCXX' $PETSC_SER_FORTRAN_CONF" | sed "s/='[C-N]:/='/g"`
    fi
    if test -z "$PETSC_PAR_COMPILERS"; then
      if test -n "$F77"; then
        PETSC_PAR_FORTRAN_CONF="--with-fortran=1 --with-fc='$PMPIF77'"
      fi

      PETSC_PAR_COMPILERS=`echo "--with-cc='$PMPICC' --with-cxx='$PMPICXX' $PETSC_PAR_FORTRAN_CONF" | sed "s/='[C-N]:/='/g"`
    fi

    ###---------------------------------------------------------------------------
    ## Add in other C, C++, and Fortran flags into the petsc format
    #
    if test -n "$SER_CONFIG_LDFLAGS"; then
      PETSC_SER_FLAG_ARGS="$PETSC_SER_FLAG_ARGS --$SER_CONFIG_LDFLAGS"
    fi
    if test -n "$CFLAGS"; then
      PETSC_SER_FLAG_ARGS="$PETSC_SER_FLAG_ARGS --CFLAGS='$CFLAGS'"
    fi
    if test -n "$CXXFLAGS"; then
      PETSC_SER_FLAG_ARGS="$PETSC_SER_FLAG_ARGS --CXXFLAGS='$CXXFLAGS'"
    fi
    if test -n "$FCFLAGS"; then
      PETSC_SER_FLAG_ARGS="$PETSC_SER_FLAG_ARGS --FFLAGS='$FCFLAGS'"
    fi
    if test -n "$PAR_CONFIG_LDFLAGS"; then
      PETSC_PAR_FLAG_ARGS="$PETSC_PAR_FLAG_ARGS --$PAR_CONFIG_LDFLAGS'"
    fi
    if test -n "$MPI_CFLAGS"; then
      PETSC_PAR_FLAG_ARGS="$PETSC_PAR_FLAG_ARGS --CFLAGS='$MPI_CFLAGS'"
    fi
    if test -n "$MPI_CXXFLAGS"; then
      PETSC_PAR_FLAG_ARGS="$PETSC_PAR_FLAG_ARGS --CXXFLAGS='$MPI_CXXFLAGS'"
    fi
    if test -n "$MPI_FCFLAGS"; then
      PETSC_PAR_FLAG_ARGS="$PETSC_PAR_FLAG_ARGS --FFLAGS='$MPI_FCFLAGS'"
    fi

    ###---------------------------------------------------------------------------
    ## SEK: The difference between OTHER_ARGS and ADDL_ARGS 
    ## SEK:     is always somewhat confusing to me
    ## SEK: For now: ADDL_ARGS are platform-dependen args
    ## 
    ## No build includes X windows support
    ##
    ## c2html removed because petsc team says flex is needed for c2html
    ## For hg based repo, petsc configure tries to build it by default. -- CJ 
    #
    #PETSC_SER_OTHER_ARGS=${PETSC_SER_ADDL_ARGS:-"--with-x=0 --with-make-np=$JMAKE"}
    #PETSC_PAR_OTHER_ARGS=${PETSC_PAR_ADDL_ARGS:-"--with-x=0 --with-make-np=$JMAKE"}
    PETSC_SER_OTHER_ARGS=${PETSC_SER_ADDL_ARGS:-"--with-c2html=0"}
    PETSC_PAR_OTHER_ARGS=${PETSC_PAR_ADDL_ARGS:-"--with-c2html=0"}
    ###
    ##  SEK: This needs to be cleaned up: Not sure why they blas library specification
    ##  SEK:  are different on different platforms and also why not part of CONFIG_LINLIB
    #
    case `uname` in
      CYGWIN*)
        PETSC_ENV="PATH=/usr/bin:\"$PATH\" LIB=\"$LIB\" INCLUDE=\"$INCLUDE\""
		# Turn-off x-windows capabilities for Windows
        PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --with-x=0 --with-make=/usr/bin/make --with-blas-lapack-lib='${LAPACK_SER_DIR}/lib/lapack.lib ${LAPACK_SER_DIR}/lib/blas.lib ${LAPACK_SER_DIR}/lib/f2c.lib'"
        PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --with-x=0 --with-make=/usr/bin/make --with-blas-lapack-lib='${LAPACK_SER_DIR}/lib/lapack.lib ${LAPACK_SER_DIR}/lib/blas.lib ${LAPACK_SER_DIR}/lib/f2c.lib'"
        PETSC_OUTOFPLACE=false
        ;;
      Linux)
        # Need to save this for build for cases where libfortran is not
        # in the system directory
        PETSC_ENV="LD_LIBRARY_PATH=$LIBFORTRAN_DIR:$LD_LIBRARY_PATH"
        PETSC_OUTOFPLACE=true
        ;;
      Darwin)
	    PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --with-x=1"
	    PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --with-x=1"
        if test -n "$LINLIB_SER_LIBS"; then
          PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --LIBS='$LINLIB_SER_LIBS'"
          PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --LIBS='$LINLIB_BEN_LIBS'"
        fi
        PETSC_OUTOFPLACE=true
        ;;
      *)
	    PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --with-x=1"
	    PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --with-x=1"
        if test -n "$LINLIB_SER_LIBS"; then
          PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --with-blas-lapack-dir='$LINLIB_SER_LIBS'"
          PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --with-blas-lapack-dir='$LINLIB_BEN_LIBS'"
        fi
        PETSC_OUTOFPLACE=true
        ;;
    esac

    ###---------------------------------------------------------------------------
    ##  Set the packages to build -- default is to do nothing.  Can be
    ##   set at the mk*.sh level.
    #
    PETSC_SER_PKGS=${PETSC_SER_PKGS:-""}
    PETSC_PAR_PKGS=${PETSC_PAR_PKGS:-""}

    if $BUILD_PETSC_WITH_GPU_CODE; then
      PETSC_PAR_PKGS="$PETSC_PAR_PKGS  --download-txpetscdevgpu "
      PETSC_SER_PKGS="$PETSC_SER_PKGS  --download-txpetscdevgpu "
    fi

    ###
    ## Set up Hypre
    ##
    if $BUILD_PETSC_WITH_HYPRE; then
      case `uname` in
	    CYGWIN*)
          PETSC_PAR_PKGS="$PETSC_PAR_PKGS --with-hypre=1 --with-hypre-include=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/include --with-hypre-lib=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/lib/HYPRE.lib"
          PETSC_PARSH_PKGS="$PETSC_PARSH_PKGS --with-hypre=1 --with-hypre-include=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/include --with-hypre-lib=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/lib/HYPRE.dll"
	      ;;
	    *)
	      PETSC_PAR_PKGS="$PETSC_PAR_PKGS --with-hypre=1 --with-hypre-include=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/include --with-hypre-lib=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/lib/libHYPRE.a"
          PETSC_PARSH_PKGS="$PETSC_PARSH_PKGS --with-hypre=1 --with-hypre-include=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/include --with-hypre-lib=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par/lib/libHYPRE.so"
          ;;
	  esac
    fi

    ###
    ## Set up SuperlU
    ##
    if $BUILD_PETSC_WITH_SUPERLU; then
      case `uname` in
	    CYGWIN*)
          PETSC_SER_PKGS="$PETSC_SER_PKGS  --with-superlu=1 --with-superlu-include=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include --with-superlu-lib=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib/superlu.lib "
          PETSC_SERSH_PKGS="$PETSC_SERSH_PKGS  --with-superlu=1 --with-superlu-include=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include --with-superlu-lib=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib/superlu.dll"
          PETSC_PAR_PKGS="$PETSC_PAR_PKGS  --with-superlu_dist=1 --with-superlu_dist-include=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/include --with-superlu_dist-lib=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/lib/superlu_dist.lib "
          PETSC_PARSH_PKGS="$PETSC_PARSH_PKGS  --with-superlu_dist=1 --with-superlu_dist-include=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcommsh/include --with-superlu_dist-lib=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcommsh/lib/superlu_dist.dll"
	      ;;
	    *)
          PETSC_SER_PKGS="$PETSC_SER_PKGS  --with-superlu=1 --with-superlu-include=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include --with-superlu-lib=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib/libsuperlu.a"
          PETSC_SERSH_PKGS="$PETSC_SERSH_PKGS  --with-superlu=1 --with-superlu-include=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/include --with-superlu-lib=$CONTRIB_DIR/superlu-${SUPERLU_BLDRVERSION}-ser/lib/libsuperlu.so"
          PETSC_PAR_PKGS="$PETSC_PAR_PKGS  --with-superlu_dist=1 --with-superlu_dist-include=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/include --with-superlu_dist-lib=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcomm/lib/libsuperlu_dist.a"
          PETSC_PARSH_PKGS="$PETSC_PARSH_PKGS  --with-superlu_dist=1 --with-superlu_dist-include=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-parcommsh/include --with-superlu_dist-lib=$CONTRIB_DIR/superlu_dist-${SUPERLU_DIST_BLDRVERSION}-par/lib/libsuperlu_dist.so"
		  ;;
      esac
    fi

    ###---------------------------------------------------------------------------
    ###         Start specifying the build
    ###---------------------------------------------------------------------------
    local barg
    for build in `echo $PETSC33_BUILDS | tr , " "`; do
      config_args=
      config_args="$config_args `get_petsc_par_args $build`"
      config_args="$config_args `get_petsc_sh_args $build`"
      config_args="$config_args `get_petsc_cplx_args $build`"
      config_args="$config_args `get_petsc_dbg_args $build`"
      config_args="$config_args `get_petsc_vardefined $build COMPILERS`"
      config_args="$config_args `get_petsc_vardefined $build FLAG_ARGS`"
      config_args="$config_args `get_petsc_vardefined $build OTHER_ARGS`"
      config_args="$config_args `get_petsc_vardefined $build ADDL_ARGS`"
      config_args="$config_args `get_petsc_vardefined $build PKGS`"
      PETSC_DIRARG=`get_petsc_env $build`
      #if bilderConfig -i petscrepo $build "$config_args" "" "$PETSC_DIRARG"; then
      if $PETSC_OUTOFPLACE; then 
            barg="-b $build"
      else
            barg="-B $build"
            config_args="--with-cmake=0 $config_args"
      fi
      if bilderConfig -i $barg petsc33 $build "$config_args" "" "$PETSC_DIRARG"; then
         bilderBuild petsc33 $build "" "$PETSC_DIRARG"
      fi
    done

  fi
}

######################################################################
#
# Test petscrepo
#
######################################################################

testPetsc33() {
  techo "Not testing petsc-3.3."
}

######################################################################
#
# Install petscrepo
#
######################################################################

installPetsc33() {
  #SEK: Need to check and make sure that the serial builds have the mpimodule installed
  #   For mpiuni

  for build in `echo $PETSC33_BUILDS | tr , " "`; do
    PETSC_DIRARG=`get_petsc_env $build`
	echo " "
	echo "PETSC_DIRARG = $PETSC_DIRARG"
	echo " "
    if test $build == "ser"; then
      lnpetscname="petsc-3.3"
    else
      lnpetscname="petsc-3.3-$build"
    fi
    bilderInstall -r -b "$BUILD_DIR/petsc33${PETSCDIR_SUFFIX}" petsc33 $build "$lnpetscname" "" "$PETSC_DIRARG"
    eval ${build}_installed=$?
  done
}
