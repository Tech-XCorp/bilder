#!/bin/bash
#
# Version and build information for rst2pdf
#
# $Id: rst2pdf.sh 4804 2012-01-07 10:43:55Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

RST2PDF_BLDRVERSION=${RST2PDF_BLDRVERSION:-"0.16"}

######################################################################
#
# Other values
#
######################################################################

RST2PDF_BUILDS=${RST2PDF_BUILDS:-"cc4py"}
# RST2PDF_DEPS=

#####################################################################
#
# Launch rst2pdf builds.
#
######################################################################

buildRst2pdf() {

# Use atlas if available
  if bilderUnpack rst2pdf; then
# Get env and args
    case `uname`-$CC in
      CYGWIN*-cl)
        RST2PDF_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        ;;
    esac
# Builds
    RST2PDF_ENV_USED="$DISTUTILS_ENV"
    bilderDuBuild rst2pdf "$RST2PDF_ARGS" "$RST2PDF_ENV_USED"
  fi

}

######################################################################
#
# Test rst2pdf
#
######################################################################

testRst2pdf() {
  techo "Not testing rst2pdf."
}

######################################################################
#
# Install rst2pdf
#
######################################################################

installRst2pdf() {
  case `uname`-$PYC_CC in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      if bilderDuInstall -n rst2pdf "-" "$RST2PDF_ENV_USED"; then
        :
      fi
      ;;
    *)
      bilderDuInstall rst2pdf "-" "$RST2PDF_ENV_USED"
      ;;
  esac
}

