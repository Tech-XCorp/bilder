#!/bin/bash
#
# Version and build information for OpenSplice
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

OPENSPLICE_BLDRVERSION=${OPENSPLICE_BLDRVERSION:-"5.5.1"}

# Built from package only
######################################################################
#
# Other values
#
######################################################################

OPENSPLICE_BUILDS=${OPENSPLICE_BUILDS:-"ser"}
OPENSPLICE_DEPS="zlib"
OPENSPLICE_UMASK=002

######################################################################
#
# Launch opensplice builds.
#
######################################################################

buildOpensplice() {
  INSTALL_OPENSPLICE_FLAG=false
  if bilderUnpack -i opensplice; then
    case `uname` in
      CYGWIN*) 
        local  LINUX_PROGRAMFILES="$(cygpath "${PROGRAMFILES}")" # convert windows style "Program Files" path to linux style

        export SPLICE_TARGET="x86.win32-release"
        export VS_HOME="${LINUX_PROGRAMFILES}/Microsoft Visual Studio ${VISUALSTUDIO_VERSION}.0"
        export JAVA_HOME="$(/bin/ls -d "${LINUX_PROGRAMFILES}/Java/jdk"*)" # NOTE: assumes there is one and only one jdk installation
        export ZLIB_HOME="${MIXED_CONTRIB_DIR}/zlib-${ZLIB_BLDRVERSION}-ser"
        echo "SPLICE_TARGET = ${SPLICE_TARGET}"
        echo "VS_HOME       = ${VS_HOME}"
        echo "JAVA_HOME     = ${JAVA_HOME}"
        echo "ZLIB_HOME     = ${ZLIB_HOME}"
        ;;
      Linux) export SPLICE_TARGET="x86_64.linux2.6-release";;  # NOTE: assumes there are system installs of jdk and zlib
      *)     export SPLICE_TARGET="x86.linux2.6-release";;     # NOTE: assumes there are system installs of jdk and zlib
    esac
    if bilderConfig -C " " opensplice ser; then
      bilderBuild -k -m "source configure; make clean; make; make install" opensplice ser
      INSTALL_OPENSPLICE_FLAG=true
    fi
  fi
  export INSTALL_OPENSPLICE_FLAG
}


######################################################################
#
# Test opensplice
#
######################################################################

testOpensplice() {
  techo "Not testing opensplice."
}

######################################################################
#
# Install opensplice
#
######################################################################
installOpensplice() {
  if ${INSTALL_OPENSPLICE_FLAG}; then
    # If there was a build, the builddir was set
    local builddirvar=`genbashvar opensplice-ser`_BUILD_DIR
    local builddir=`deref ${builddirvar}`
    local vervar=`genbashvar opensplice`_BLDRVERSION
    local verval=`deref ${vervar}`
    local instsubdirvar=`genbashvar opensplice-ser`_INSTALL_SUBDIR
    local instsubdirval=`deref ${instsubdirvar}`
 
    local OpenSplice_SER_DIR_NAME="opensplice-${OPENSPLICE_BLDRVERSION}-ser"
    local OpenSplice_BASE_DIR_NAME="x86_64.linux2.6"
    local releaseFileName="release.com"
    local replaceString="@@INSTALLDIR@@"
    local printfCorrStr=""
    local CygwinFlag=false
    case `uname` in
      CYGWIN*)
        CygwinFlag=true
        OpenSplice_BASE_DIR_NAME="x86.win32"
        releaseFileName="release.bat"
        replaceString="%~dp0"
        printfCorrStr="%"
        ;;
    esac

#   Determine where it will be installed
    local instdirvar=`genbashvar opensplice-ser`_INSTALL_DIR
    echo !!!!!!!
    echo $TXOSPL_SER_INSTALL_DIR
    techo -2 instdirvar = ${instdirvar}
    local instdirval=`deref ${instdirvar}`
    if test -z "${instdirval}"; then
      TERMINATE_ERROR_MSG="Catastrophic error in bilderInstall.  ${instdirvar} is empty."
      cleanup
    fi

    if test -z "${builddir}"; then
      techo "Not installing ${OpenSplice_SER_DIR_NAME} since not built."
      # Check if opensplice install is available in the install dir and
      # set OSPL_HOME env var, needed for SimD build
      if test -L ${instdirval}/opensplice -o -d ${instdirval}/opensplice; then
        local ospldir=`(cd ${instdirval}/opensplice; pwd -P)`
        export OSPL_HOME=${ospldir}
      fi
      return 1
    fi
    local res
    waitAction opensplice-ser
    resvarname=`genbashvar opensplice_ser`_RES
    res=`deref ${resvarname}`
    if test "${res}" != 0; then
      techo "Not installing ${OpenSplice_SER_DIR_NAME} since did not build."
      return 1
    fi
    techo "${OpenSplice_SER_DIR_NAME} was built."
 
    #
    # If here, ready to install.  Determine whether to do so.
    #
    techo "Proceeding to install."
    # Validation
    if test -z "${builddir}"; then
      techo "Catastrophic error.  builddir unknown or cannot cd to ${builddir}."
      exit 1
    fi
    techo "Installing ${OpenSplice_SER_DIR_NAME} into ${instdirval} at `date` from ${builddir}."

    # Set umask, install, restore umask
    local umaskvar=`genbashvar opensplice`_UMASK
    local umaskval=`deref ${umaskvar}`
    if test -z "$umaskval"; then
      techo "Catastrophic error.  ${umaskvar} not set."
      exit 1
    fi
    local origumask=`umask`
    umask ${umaskval}

    cmd="rmall ${instdirval}/${OpenSplice_SER_DIR_NAME}"
    ${cmd}
    cmd="mkdir ${instdirval}/${OpenSplice_SER_DIR_NAME}"
    ${cmd}
    cmd="cp -R ${builddir}/install/HDE ${instdirval}/${OpenSplice_SER_DIR_NAME}/HDE"
    techo "${cmd}" | tee install.out
    ${cmd} 1>>install.out 2>&1
    cmd="cp -R ${OPENSPLICE_PATCH} ${instdirval}/${OpenSplice_SER_DIR_NAME}/"
    techo "${cmd}" | tee install.out
    ${cmd} 1>>install.out 2>&1
    RESULT=$?
    # If installed, record
    techo "Installation of ${OpenSplice_SER_DIR_NAME} concluded at `date` with result = ${RESULT}."
    if test $RESULT = 0; then
      if ! ${CygwinFlag}; then
        techo "Replace ${printfCorrStr}${replaceString} with ${instdirval}/${OpenSplice_SER_DIR_NAME} in ${instdirval}/${OpenSplice_SER_DIR_NAME}/HDE/${OpenSplice_BASE_DIR_NAME}/${releaseFileName}" | tee install.out
        cmd="sed -i \"s#${replaceString}#${instdirval}/${OpenSplice_SER_DIR_NAME}#g\" ${instdirval}/${OpenSplice_SER_DIR_NAME}/HDE/${OpenSplice_BASE_DIR_NAME}/${releaseFileName}"
        echo "${cmd}" | tee install.out
        eval ${cmd}

        # Source the release.com file, so the opensplice env vars are
        # available for other packages that need it
        techo "Sourcing ${releaseFileName} to set the opensplice enironment variables" | tee install.out
        cmd="source ${instdirval}/${OpenSplice_SER_DIR_NAME}/HDE/${OpenSplice_BASE_DIR_NAME}/${releaseFileName}"
      fi

      echo SUCCESS >>install.out

      # Record installation in installation directory
      techo "Recording installation of ${OpenSplice_SER_DIR_NAME}."
      cmd="${PROJECT_DIR}/bilder/setinstald.sh -b ${BILDER_PACKAGE} -i ${CONTRIB_DIR} opensplice,ser"
      techo "${cmd}"
      $cmd

      # Link to common name
      local linkname
      linkname=opensplice
      if test -n "${linkname}" -a ${instsubdirval} != '-'; then
        # Do not try to link if install directory does not exist
        local subdir
        subdir="${OpenSplice_SER_DIR_NAME}/HDE/${OpenSplice_BASE_DIR_NAME}"
        if test -d "${instdirval}/${instsubdirval}"; then
          techo "Linking ${instdirval}/${subdir} to ${instdirval}/${linkname}"
          mkLink ${linkargs} ${instdirval} ${subdir} ${linkname}
        else
          techo "WARNING: Not linking ${instdirval}/${subdir} to ${instdirval}/${linkname} because ${instdirval}/${instsubdirval} can not be found or installation subdir contains /."
        fi
      else
        techo "Not making an installation link."
      fi

      # Fix perms that libtool sometimes botches
      # subdir may not exist if installed at top
      if test -d "${instdirval}/${instsubdirval}"; then
        case ${umaskval} in
          000? | 00? | ?)  # printing format can vary.
            chmod -R g+wX ${instdirval}/${instsubdirval}
              ;;
        esac
        case ${umaskval} in
          0002 | 002 | 2)
            chmod -R o+rX ${instdirval}/${instsubdirval}
            ;;
        esac
      fi

      # Record build time
      techo "opensplice-ser installed."
      local starttimevar=`genbashvar opensplice`_START_TIME
      local starttimeval=`deref ${starttimevar}`
      techo -2 "${starttimevar} = ${starttimeval}"
      local endtimeval=`date +%s`
      local buildtime=`expr ${endtimeval} - ${starttimeval}`
      techo "opensplice-ser took `myTime ${buildtime}` to build and install." | tee -a ${BILDER_LOGDIR}/timers.txt

    else
      installFailures="${installFailures} $1-$2"
      anyFailures="${anyFailures} $1-$2"
      techo "$1-$2 failed to install."
      echo FAILURE >>install.out
    fi
    # umask restoration here so that links and installations.txt okay
    umask ${origumask}

    # Check if opensplice install is available in the install dir and
    # set OSPL_HOME env var, needed for SimD build
    if test -L ${instdirval}/opensplice -o -d ${instdirval}/opensplice; then
      local ospldir=`(cd ${instdirval}/opensplice; pwd -P)`
      export OSPL_HOME=${ospldir}
      techo "OSPL_HOME = ${OSPL_HOME}"
    fi
    return ${RESULT}
  else
    techo "Not installing opensplice-${OPENSPLICE_BLDRVERSION}-ser since not built. $(genbashvar opensplice-ser)_INSTALL_DIR = ."
    return 0
  fi
}

