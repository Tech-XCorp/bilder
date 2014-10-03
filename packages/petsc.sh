#!/bin/bash
#
# Version and build information for petsc
#
# $Id$
#
######################################################################

# A block comment on building PETSc for Windows
: <<'END'
# WINDOWS is not built automatically.  Here are some notes:

SERIAL (from Chetan Jhurani)

/usr/bin/python configure --prefix=/winsame/contrib-mingw/petsc-3.1-p8-ser --with-blas-lapack-dir=/winsame/contrib-mingw/lapack-3.3.0-ser/lib -with-debugging=no --with-mpi=0 -with-c-support=1 --with-fortran=1 --with-cc=mingw32-gcc --with-fc=mingw32-gfortran --with-cxx=mingw32-g++ PETSC_DIR=$PWD PETSC_ARCH=opt_32bit

make all PETSC_DIR=$PWD PETSC_ARCH=opt_32bit

make install PETSC_DIR=$PWD PETSC_ARCH=opt_32bit

PARALLEL (found on web and from Satish Balay)

  NO FORTRAN with Visual Studio

http://blogs.msdn.com/b/hpctrekker/archive/2008/09/07/running-petsc-on-windows.aspx

Satish says that step 6 must come before step 5, so:

So edit config/BuildSystem/config/packages/MPI.py, to comment out the line,

       self.functions          = ['MPI_Init', 'MPI_Comm_create']

Then do

config/configure.py --prefix=/winsame/builds-vs10/petsc-3.1-p8-par \
  --with-cc="win32fe cl" --with-fc=0 \
  --with-debugging=0 \
  --download-c-blas-lapack=1 \
  --with-mpi-include="/cygdrive/c/Program Files/Microsoft HPC Pack 2008 SDK/Include" \
  --with-mpi-lib="/cygdrive/c/Program Files/Microsoft HPC Pack 2008 SDK/Lib/i386/msmpi.lib" \
  --useThreads=0 --with-shared=0

  WITH FORTRAN AND MinGW

Brief summary

PETSc/mingw32-gfortran/HPCPACK (mpich2) fails because
mingw32-gfortran cannot link a simple MPI program.  There seem
also to be some problems with munging of the paths when using
"win32fe cl" for the C/C++ compiler.

PETSc/mingw32-gfortran/OpenMPI does not have the above basic link
problem, but it fails due to problems with the PETSc build
system.  When using CL (VS10), there are problems in option
translation (path munging).  When using mingw32-gcc/++, there
seem to be failures with the inclusion of some petsc generated
configuration files.

For longer report see
  Summary of attempts to get PETSc to work with mingw32-gfortran and MPI
on the petsc-dev list.
END

######################################################################
#
# Version.  This is actually petsc-lite, repackaged, which simply
# leaves out the documentation.
#
######################################################################

PETSC_BLDRVERSION=${PETSC_BLDRVERSION:-"3.1-p8"}
if $BUILD_PETSC_WITH_GPU_CODE; then
  PETSC_BLDVERSION=${PETSC_BLDRVERSION:-"20120320"}
fi

######################################################################
#
# Other values
#
######################################################################

PETSC_DEPS=$MPI_BUILD,atlas,lapack,clapack_cmake,Python
BUILD_PETSC_WITH_GPU_CODE=${BUILD_PETSC_WITH_GPU_CODE:-false}
if $BUILD_PETSC_WITH_GPU_CODE; then
 PETSC_DEPS=cusp
fi
if test -z "$PETSC_BUILDS"; then
  case `uname` in
    CYGWIN*)
      PETSC_BUILDS="ser"
      ;;
    Darwin | Linux)
      PETSC_BUILDS="ser,par,pardbg"
      if $BUILD_PETSCCOMPLEX; then
        PETSC_BUILDS=${PETSC_BUILDS}",sercplx,parcplx,parcplxdbg"
      fi
  esac
fi
PETSC_UMASK=002

######################################################################
#
# Launch petsc builds.
#
######################################################################

buildPetsc() {

# Check for svn version or package
  if test -d $PROJECT_DIR/petsc; then
    PETSC_BLDRVERSION="dev"
    bilderPreconfig petsc
    res=$?
    if $SVNUP; then
      cd $PROJECT_DIR/petsc
      hg pull
      cd -
    fi
  else
    bilderUnpack -i petsc
    res=$?
  fi
  if test $res = 0; then

# Modify to PETSc syntax
    if test -n "$PAR_CONFIG_LDFLAGS"; then
      PETSC_PAR_CONFIG_LDFLAGS=--$PAR_CONFIG_LDFLAGS
    fi

# Create petsc's compilers
    if test -z "$PETSC_SER_COMPILERS"; then
# Remove mingw C: stuff.
      local petscsercomps=`echo "--with-cc='$CC' --with-cxx='$CXX' --with-fc='$F77'" | sed "s/='[C-N]:/='/g"`
      PETSC_SER_COMPILERS="$petscsercomps"
    fi
# pgi-10 wants mpif90 for the fortran compiler
# xl wants xlf.  So this variation now in the machines files.
    if test -z "$PETSC_PAR_COMPILERS"; then
# Remove mingw C: stuff.
      local petscparcomps=`echo "--with-cc='$MPICC' --with-cxx='$MPICXX' --with-fc='$MPIF77'" | sed "s/='[C-N]:/='/g"`
      PETSC_PAR_COMPILERS="$petscparcomps"
    fi
# Set shared to 1 if not set to zero.
    for i in PETSC_PAR_ADDL_ARGS PETSC_PARDBG_ADDL_ARGS PETSC_SER_ADDL_ARGS; do
      eval local $i=
      case `uname` in
        CYGWIN*)
          eval $i="'--with-shared=0'"
          ;;
        Darwin)
          eval $i="'--with-shared=0'"
          ;;
        *)
# Must have pic flags to build on 64 bit Linux and link into uedge!
# so if shared not specified, make it shared
          hassh=`echo $val | grep with-shared`
          if test -z "$hassh"; then
            eval $i="'--with-shared=1'"
          fi
          ;;
      esac
    done
    case `uname` in
      CYGWIN*)
        PETSC_ENV="PATH=/usr/bin:'$PATH'"
        PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --with-blas-lapack-dir=${LAPACK_SER_DIR}/lib"
        ;;
      Linux)
# Need to save this for build for cases where libfortran is not
# in the system directory
        PETSC_ENV="LD_LIBRARY_PATH=$LIBFORTRAN_DIR:$LD_LIBRARY_PATH"
        ;;
      Darwin)
        if test -n "$LINLIB_SER_LIBS"; then
          PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --LIBS='$LINLIB_SER_LIBS'"
          PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --LIBS='$LINLIB_BEN_LIBS'"
          PETSC_PARDBG_ADDL_ARGS="$PETSC_PARDBG_ADDL_ARGS --LIBS='$LINLIB_BEN_LIBS'"
        fi
        ;;
      *)
        if test -n "$LINLIB_SER_LIBS"; then
          PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS --with-blas-lapack-dir='$LINLIB_SER_LIBS'"
          PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --with-blas-lapack-dir='$LINLIB_BEN_LIBS'"
          PETSC_PARDBG_ADDL_ARGS="$PETSC_PARDBG_ADDL_ARGS --with-blas-lapack-dir='$LINLIB_BEN_LIBS'"
        fi
        ;;
    esac
    if $BUILD_PETSC_WITH_GPU_CODE; then
      local PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS --download-txpetscgpu "
      PETSC_PAR_ADDL_ARGS="$PETSC_PAR_ADDL_ARGS  --download-txpetscgpu "
      local PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS  --download-txpetscgpu "
      PETSC_SER_ADDL_ARGS="$PETSC_SER_ADDL_ARGS  --download-txpetscgpu "
    fi


# Add in other C, C++, and Fortran flags
    if test -n "$CFLAGS"; then
      PETSC_SER_FLAG_ARGS="$PETSC_SER_FLAG_ARGS --CFLAGS='$CFLAGS'"
    fi
    if test -n "$CXXFLAGS"; then
      PETSC_SER_FLAG_ARGS="$PETSC_SER_FLAG_ARGS --CXXFLAGS='$CXXFLAGS'"
    fi
    if test -n "$FCFLAGS"; then
      PETSC_SER_FLAG_ARGS="$PETSC_SER_FLAG_ARGS --FFLAGS='$FCFLAGS'"
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

# Sundials not building shared-parallel
    if bilderConfig -i petsc par "--with-mpi --with-debugging=0 --with-x=0 $PETSC_PAR_COMPILERS --COPTFLAGS='-O2 -g' $PETSC_PAR_CONFIG_LDFLAGS --download-hypre --download-parmetis --download-superlu_dist --download-blacs --download-scalapack --download-mumps PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/par PETSC_ARCH=facets-par $PETSC_PAR_FLAG_ARGS $PETSC_PAR_OTHER_ARGS $PETSC_PAR_ADDL_ARGS $CONFIG_LINLIB_SER_ARGS" "" "$PETSC_ENV"; then
      bilderBuild petsc par "PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/par PETSC_ARCH=facets-par"
    fi

# Parallel debug build
# Sundials not building shared-parallel
    if bilderConfig -i petsc pardbg "--with-mpi --with-debugging=1 --with-x=0 $PETSC_PARDBG_COMPILERS --COPTFLAGS='-O2 -g' $PETSC_PARDBG_CONFIG_LDFLAGS --download-hypre --download-parmetis --download-superlu_dist --download-blacs --download-scalapack --download-mumps PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/pardbg PETSC_ARCH=facets-pardbg $PETSC_PAR_FLAG_ARGS $PETSC_PARDBG_OTHER_ARGS $PETSC_PARDBG_ADDL_ARGS" "" "$PETSC_ENV"; then
      bilderBuild petsc pardbg "PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/pardbg PETSC_ARCH=facets-pardbg"
    fi

# Serial build
    if test -n "$SER_CONFIG_LDFLAGS"; then
      PETSC_SER_CONFIG_LDFLAGS=--$SER_CONFIG_LDFLAGS
    fi
# Proceed with configuring
    if bilderConfig -i petsc ser "--with-mpi=0 --with-debugging=0 --with-x=0 $PETSC_SER_COMPILERS --COPTFLAGS='-O2 -g' $PETSC_SER_CONFIG_LDFLAGS --download-superlu PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/ser PETSC_ARCH=facets-ser $PETSC_SER_FLAG_ARGS $PETSC_SER_OTHER_ARGS $PETSC_SER_ADDL_ARGS" "" "$PETSC_ENV"; then
      bilderBuild petsc ser "PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/ser PETSC_ARCH=facets-ser"
    fi

#   Do the complex builds
    if bilderConfig -i petsc parcplx "--with-scalar-type=complex --with-mpi --with-debugging=0 --with-x=0 $PETSC_PAR_COMPILERS --COPTFLAGS='-O2 -g' $PETSC_PAR_CONFIG_LDFLAGS --download-parmetis --download-superlu_dist --download-blacs --download-scalapack --download-mumps PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/parcplx PETSC_ARCH=facets-parcplx $PETSC_PAR_FLAG_ARGS $PETSC_PAR_OTHER_ARGS $PETSC_PAR_ADDL_ARGS"; then
      bilderBuild petsc parcplx "PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/parcplx PETSC_ARCH=facets-parcplx"
    fi

# Parallel debug build
# Sundials not building shared-parallel
    if bilderConfig -i petsc parcplxdbg "--with-scalar-type=complex --with-mpi --with-debugging=1 --with-x=0 $PETSC_PARDBG_COMPILERS --COPTFLAGS='-O2 -g' $PETSC_PARDBG_CONFIG_LDFLAGS --download-parmetis --download-superlu_dist --download-blacs --download-scalapack --download-mumps PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/parcplxdbg PETSC_ARCH=facets-parcplxdbg $PETSC_PAR_FLAG_ARGS $PETSC_PARDBG_OTHER_ARGS $PETSC_PARDBG_ADDL_ARGS"; then
      bilderBuild petsc parcplxdbg "PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/parcplxdbg PETSC_ARCH=facets-parcplxdbg"
    fi

# Serial build
    if test -n "$SER_CONFIG_LDFLAGS"; then
      PETSC_SER_CONFIG_LDFLAGS=--$SER_CONFIG_LDFLAGS
    fi
# Proceed with configuring
    if bilderConfig -i petsc sercplx "--with-scalar-type=complex --with-mpi=0 --with-debugging=0 --with-x=0 $PETSC_SER_COMPILERS --COPTFLAGS='-O2 -g' $PETSC_SER_CONFIG_LDFLAGS --download-superlu PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/sercplx PETSC_ARCH=facets-sercplx $PETSC_SER_FLAG_ARGS $PETSC_SER_OTHER_ARGS $PETSC_SER_ADDL_ARGS"; then
      bilderBuild petsc sercplx "PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/sercplx PETSC_ARCH=facets-sercplx"
    fi

  fi

}

######################################################################
#
# Test petsc
#
######################################################################

testPetsc() {
  techo "Not testing petsc."
}

######################################################################
#
# Install petsc
#
######################################################################

installPetsc() {

# Get installation directory.  Should be set above.
  instdirvar=PETSC_INSTALL_DIR
  instdirval=`deref $instdirvar`
  if test -z "$instdirval"; then
    instdirval=$CONTRIB_DIR
  fi

  if bilderInstall -r petsc ser "" "" "$PETSC_ENV PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/ser PETSC_ARCH=facets-ser"; then
    local ser_installed=0
# Have to create mod file for mpiuni
    local resvarname=`genbashvar $1_$2`_RES
    if test $PETSC_SER_RES = 0; then
      cat >$instdirval/petsc-${PETSC_BLDRVERSION}-ser/include/mpiuni/mpimodule.F  <<END
      module mpi
#include "mpif.h"
      end module
END
      (cd $instdirval/petsc-${PETSC_BLDRVERSION}-ser/include/mpiuni; $FC -c mpimodule.F)
    fi
  fi

  if bilderInstall -r petsc sercplx petsc-cplx "" "$PETSC_ENV PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/sercplx PETSC_ARCH=facets-sercplx"; then
    local ser_installed=0
# Have to create mod file for mpiuni
    local resvarname=`genbashvar $1_$2`_RES
    if test $PETSC_SER_RES = 0; then
      cat >$instdirval/petsc-${PETSC_BLDRVERSION}-sercplx/include/mpiuni/mpimodule.F  <<END
      module mpi
#include "mpif.h"
      end module
END
      (cd $instdirval/petsc-${PETSC_BLDRVERSION}-sercplx/include/mpiuni; $FC -c mpimodule.F)
    fi
  fi

  bilderInstall -r petsc par "" "" "$PETSC_ENV PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/par PETSC_ARCH=facets-par"
  par_installed=$?

  bilderInstall -r petsc pardbg "" "" "$PETSC_ENV PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/pardbg PETSC_ARCH=facets-pardbg"
  pardbg_installed=$?

  bilderInstall -r petsc parcplx "" "" "$PETSC_ENV PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/parcplx PETSC_ARCH=facets-parcplx"
  parcplx_installed=$?

  bilderInstall -r petsc parcplxdbg "" "" "$PETSC_ENV PETSC_DIR=$BUILD_DIR/petsc-$PETSC_BLDRVERSION/parcplxdbg PETSC_ARCH=facets-parcplxdbg"
  parcplxdbg_installed=$?


# Post-installation
# Create other shared libs, modules
  for i in `echo $PETSC_BUILDS | tr ',' ' '`; do
    installed=`deref ${i}_installed`
    if test "$installed" != 0; then
      continue
    fi
    PETSC_DIR=$BLDR_INSTALL_DIR/petsc-${PETSC_BLDRVERSION}-$i

# If at alcf, create mpi.mod and install into petsc for parallel builds
    if test $i != ser; then
      case $FQMAILHOST in
        *.alcf.anl.gov)
          cp $PETSC_DIR/include/mpiuni/mpimodule.F .
          $MPIFC -c mpimodule.F -o mpimodule.o
          /usr/bin/install -m 664 mpimodule.o mpi.mod $PETSC_DIR/include
          rm -f mpimodule.F mpimodule.o mpi.mod
          ;;
      esac
    fi

# Create shared/dynamic libs for external packages
    local varname=PETSC_${i}_OTHER_ARGS
    eval varval='"\${$varname}"'
    local hassh=`echo $varval | grep -- --with-shared=1`
    if test -n "$hassh"; then
      local libs="blacs cmumps dmumps smumps zmumps mumps_common pord HYPRE metis parmetis scalapack superlu_dist_2.3 superlu_3.1 mpiuni"
      for lib in $libs; do
        if test -f $PETSC_DIR/lib/lib${lib}.a -a ! -f $PETSC_DIR/lib/lib${lib}${SHOBJEXT}; then
          techo "Need to create shared/dynamic libs for $lib in $PETSC_DIR/lib."
        fi
      done
    fi
  done
  # techo "Quitting at end of petsc.sh."; exit

}

