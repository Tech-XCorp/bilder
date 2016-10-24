# #!/bin/bash
#
# Build information for qt5.
#
# $Id: qt5.sh 2982 2016-02-06 21:19:04Z cary $
#
######################################################################

######################################################################
#
# Trigger variables set in qt5_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/qt5_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setQt5NonTriggerVars() {
  QT5_UMASK=002
}
setQt5NonTriggerVars

######################################################################
#
# Launch qt5 builds.
#
######################################################################

buildQt5() {

# Qt5 requires g++ to have that precise name
# If different, link it into contrib's bin dir.
  QT5_GXX_LINKED=false

# QT5 must be built in place
  if ! bilderUnpack -i qt5; then
    return
  fi

# Set the link as needed
  case `uname` in
    Linux | Darwin)
      if test "$(basename $PYC_CXX)" != g++ -a ! -f ${CONTRIB_DIR}/bin/g++; then
        QT5_GXX_LINKED=true
        mkdir -p ${CONTRIB_DIR}/bin
        ln -s `which $PYC_CXX` ${CONTRIB_DIR}/bin/g++
        addtopathvar PATH $CONTRIB_DIR/bin
      fi
      ;;
  esac

# Get the addition args and environment per-platform.
# Get the phonon args separately to allow experimental builds without it.
  local QT5_ADDL_ARGS=
  local ldlibpath=
  local QT5_ENV=
  local QT5_PHONON_ARGS=-phonon
  case `uname` in

    CYGWIN*)
      ;;

    Darwin)
        
# jpeg present, but qt5 cannot find headers
#      if echo $CXXFLAGS | grep -q stdlib=libc++; then
#        QT5_ADDL_ARGS="$QT5_ADDL_ARGS -platform unsupported/macx-clang-libc++"
#      else
#        QT5_ADDL_ARGS="$QT5_ADDL_ARGS -platform macx-g++"
#      fi
      
      case `uname -r` in
        13.*)
      # This will need to be clang
          ;;
        1[0-2].*)
          case `uname -m` in
            i386) QT5_ADDL_ARGS="$QT5_ADDL_ARGS -arch x86_64";;
          esac
          ;;
      esac
      case $QT5_BLDRVERSION in
        5.*) ;;
        *) QT5_ADDL_ARGS="$QT5_ADDL_ARGS -cocoa";;
      esac
      QT5_ADDL_ARGS="$QT5_ADDL_ARGS -no-gif -qt-libpng"
      ;;

    Linux)
# Adding to the LD_RUN_PATH gets rpath set for the qt5 libs.
# Adding to the LD_LIBRARY_PATH gets around the missing Qt5CLucene link bug.
# To get around bash space separation of string, we separate env settings
# with a comma.
      case `uname -m` in
        x86_64)
          QT5_ADDL_ARGS="$QT5_ADDL_ARGS -platform linux-g++-64"
          ;;
        *)
          QT5_ADDL_ARGS="$QT5_ADDL_ARGS -platform linux-g++"
          ;;
      esac
      QT5_ADDL_ARGS="$QT5_ADDL_ARGS -system-libpng"

# Need the following for phonon (and for webkit):
#   glib (aka glib2 for the rpm)
#   gstreamer-devel
#   gstreamer-plugins-base-devel
#   libxml2
# For some systems, like the Crays, we have to build our own version of
# glib, gstreamer, and xml2.  Previously all were done in $CONTRIB_DIR/extras.
# Now gstreamer is bilderized.
# Look for those, and if present add the appropriate flags.

      local gstprefix=
      local gstlibdir=
      for gstprefix in $CONTRIB_DIR/gstreamer-${GSTREAMER_BLDRVERSION}-sersh $CONTRIB_DIR/extras /usr; do
        techo "Testing for $gstprefix/lib."
        if test -e $gstprefix/lib; then
          techo "Found $gstprefix/lib."
          break
        fi
      done
      if test -n "${gstprefix}"; then
        QT5_PHONON_ARGS="$QT5_PHONON_ARGS -L$gstprefix/lib -I$gstprefix/include/gstreamer-0.10"
        gstlibdir=$gstprefix/lib
      fi

# Add system include directories if present.  This should not be duplication,
# as the above should be built only when these are not found.
# The paths on redhat are:
#  -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include
#  -I/usr/include/libxml2

      local incdir=
# qt5 will not compile with gstreamer-1.0, so specifically look for 0.10
      local gpkgs="libxml2 dbus-1.0 glib-2.0"
      test -z "${gstprefix}" && gpkgs="$gpkgs gstreamer-0.10"
      for i in $gpkgs; do
# Get the latest
        incdir=`ls -1d /usr/include/$i{,-*} 2>/dev/null | tail -1`
        if test -n "$incdir"; then
          QT5_PHONON_ARGS="$QT5_PHONON_ARGS -I$incdir"
        else
          techo "WARNING: [qt5.sh] May need to install ${i}-devel."
        fi
      done
# glib a little special to deal with versions
      incdir=`ls -1d /usr/include/glib-* 2>/dev/null | tail -1`
      if test -n "$incdir"; then
        QT5_PHONON_ARGS="$QT5_PHONON_ARGS -I$incdir"
      else
        techo "WARNING: [qt5.sh] May need to install glib2-devel."
      fi
# On different distros, this include directory can be in different places
      local glibbn=`basename $incdir`
      if test "i686" == `uname -m`; then
        srchdirs="lib lib64 lib/x86_64-linux-gnu"
      else
        srchdirs="lib64 lib/x86_64-linux-gnu lib"
      fi
      local glibincdir=
      for l in $srchdirs; do
        if test -d /usr/$l/$glibbn/include; then
          glibincdir=/usr/$l/$glibbn/include
          break
        fi
      done
      if test -n "$glibincdir"; then
        QT5_PHONON_ARGS="$QT5_PHONON_ARGS -I$glibincdir -ldbus-1 -lglib-2.0 -lgthread-2.0 -lgstreamer-0.10 -lgobject-2.0"
      else
        techo "WARNING: [qt5.sh] glib word-size include dir not found."
        techo "WARNING: [qt5.sh] May need to install glib2-devel."
      fi
      local gstprobe=`find /usr/include -name gstappsrc.h`
      if test -z "$gstprobe"; then
        techo "WARNING: [qt5.sh] May need to install gstreamer-plugins-base-devel."
      fi
# Adjust for possible change to typedef in glib
      if grep -q 'union *_GMutex' $incdir/glib/gthread.h; then
        techo "Adjusting Qt5 for change in gthread.h."
        local qt5gtypedefs=$BUILD_DIR/qt5-$QT5_BLDRVERSION/$QT5_BUILD/src/3rdparty/webkit/Source/JavaScriptCore/wtf/gobject/GTypedefs.h
        cmd="sed -i.bak 's/struct _GMutex/union _GMutex/' $qtgtypedefs"
        techo "$cmd"
        eval "$cmd"
      fi
      QT5_ENV="LD_RUN_PATH=${CONTRIB_DIR}/mesa-mgl/lib:$LD_RUN_PATH LD_LIBRARY_PATH=$BUILD_DIR/qt5-$QT5_BLDRVERSION/$QT5_BUILD/lib:$LD_LIBRARY_PATH"
      ;;

  esac

# PyQt will not build on Linux when Qt5 is built without phonon, so restoring.
# Phonon is also required for WebKit, which the composers need.
# On Linux, this requires glib2-devel and gstreamer-plugins-base-devel
  QT5_WITH_PHONON=${QT5_WITH_PHONON:-"true"}
  if ! $QT5_WITH_PHONON; then
    techo "NOTE: Building Qt5 without phonon."
    QT5_PHONON_ARGS=-no-phonon
  fi

# Version dependent args
# qt5-5 configures differently
# make -j does not work with 4.8.6, apparently.
  case $QT5_BLDRVERSION in
    5.*)
      QT5_VERSION_ARGS="-developer-build"
      ;;
    4.8.6)
      QT5_VERSION_ARGS="-buildkey bilder -no-libtiff -declarative -webkit $QT5_PHONON_ARGS"
      QT5_MAKEJ_USEARGS="$QT5_MAKEJ_ARGS"
      ;;
    4.*)
      QT5_VERSION_ARGS="-buildkey bilder -no-libtiff -declarative -webkit $QT5_PHONON_ARGS"
      QT5_MAKEJ_USEARGS="$QT5_MAKEJ_ARGS"
      ;;
  esac

# Restore dbus and xmlpatterns or get wrong one
  local otherargsvar=`genbashvar QT5_${QT5_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`
#  if bilderConfig -i qt5 $QT5_BUILD "$QT5_ADDL_ARGS $QT5_VERSION_ARGS -confirm-license -make libs -make tools -fast -opensource -opengl -no-separate-debug-info -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-tds -no-javascript-jit -nomake docs -nomake examples -nomake demos $otherargsval" "" "$QT5_ENV"; then
  if bilderConfig -i qt5 $QT5_BUILD "$QT5_ADDL_ARGS $QT5_VERSION_ARGS -confirm-license -make libs -make tools -opensource -opengl -no-separate-debug-info -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-tds -nomake examples $otherargsval" "" "$QT5_ENV"; then
      
# Make clean seems to hang
    bilderBuild -k qt5 $QT5_BUILD "$QT5_MAKEJ_USEARGS" "$QT5_ENV"
  else
# Remove linked file if present
    if $QT5_GXX_LINKED; then
      rm -f ${CONTRIB_DIR}/bin/g++
    fi
  fi
}

######################################################################
#
# Test qt5
#
######################################################################

testQt5() {
  techo "Not testing qt5."
}

######################################################################
#
# Install qt5
#
######################################################################

#
# Fix up various problems (bad links) with QT5 installations
# We used to change the installation names of qt5 in VisIt, but now
# VisIt takes care of that in its build system.
#
fixQt5Install() {
# Remove linked file if present
  if $QT5_GXX_LINKED; then
    rm -f ${CONTRIB_DIR}/bin/g++
  fi
# Fix the bad node that Qt5 leaves behind on a Darwin installation.
# (Seems not to do this on an overinstallation?)
  case `uname` in
    Darwin)
      local badnode="$CONTRIB_DIR/qt5-$QT5_BLDRVERSION-$QT5_BUILD/lib/QtTest.framework/Versions/4/4"
      if test -L $badnode; then
        techo "NOTE: Removing leftover link from qt5 installation, $badnode."
        cmd="chmod -h u+rwx $badnode"
        techo "$cmd"
        $cmd
        cmd="rm $badnode"
        techo "$cmd"
        $cmd
      fi
      if test -L $badnode; then
        techo "WARNING: Unable to remove leftover link, $badnode, from qt5 installation.  Must be done as root."
      fi
      ;;
  esac
}

#
# Install Qt5
#
installQt5() {
  local qt5_tried=false
  local qt5pid=`deref QT5_${QT5_BUILD}_PID`
  if test -n "$qt5pid"; then
    qt5_tried=true
  fi
  if bilderInstall -r -p open qt5 $QT5_BUILD; then
    fixQt5Install
  elif $qt5_tried; then
    cat <<EOF | tee -a $LOGFILE
Qt5 failed to build.  Bilder will try the following:
  cd $BUILD_DIR/qt5-$QT5_BLDRVERSION/$QT5_BUILD
  make -i install
and then follow with the usual installation.
EOF
    cd $BUILD_DIR/qt5-$QT5_BLDRVERSION/$QT5_BUILD
    make -i install 2>&1 | tee qt5-install2.txt
    bilderBuild qt5 $QT5_BUILD "$QT5_MAKEJ_ARGS"
    if bilderInstall -r -p open qt5 $QT5_BUILD; then
      fixQt5Install
    else
      techo "Extra build steps failed."
    fi
  fi
}
