# #!/bin/bash
#
# Building Squish package.
#
# $Id: squish.sh 5841 2012-04-18 18:01:30Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SQUISH_BLDRVERSION=${SQUISH_BLDRVERSION:-"4.1.1"}

######################################################################
#
# Other values
#
######################################################################

SQUISH_BUILDS=${SQUISH_BUILDS:-"ser"}
SQUISH_DEPS=qt

SQUISH_UMASK=002
######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/squish/bin

######################################################################
#
# Build Squish
#
######################################################################

buildSquish() {

# Must locate Qt to build Squish.

  if findQt; then

    if bilderUnpack squish; then
  
# Get variables.  Per platform.  Just do mac for now.
      local SQUISH_PLATFORM_ARGS=
      local SQUISH_ENV=
      case `uname` in
        Linux)
          case `uname -m` in
            x86_64)
              SQUISH_PLATFORM_ARGS="$SQUISH_PLATFORM_ARGS --enable-64bit"
              ;;
          esac
          ;;
        Darwin)
          case `uname -m` in
            x86_64)
              SQUISH_PLATFORM_ARGS="$SQUISH_PLATFORM_ARGS --enable-64bit"
              ;;
          esac
          ;;
      esac

      if test -n "$SQUISH_ENV"; then
  # Put two levels of quotes to get through calls
        local SQUISH_ENV_ARG="-e $SQUISH_ENV"
      fi
      
      if bilderConfig -m "configure" $SQUISH_ENV_ARG squish ser "$SQUISH_PLATFORM_ARGS --with-qtdir=$QT_SER_DIR"; then
        bilderBuild -m ./build $SQUISH_ENV_ARG squish ser
      fi


    fi
  fi
}

######################################################################
#
# Test Squish
#
######################################################################

testSquish() {
  techo "Not testing Squish."
}

######################################################################
#
# Install Squish
#
######################################################################

installSquish() {

  bilderInstall -r -c squish ser 

}

