# #!/bin/bash
#
# Version and build information for qt.  Latest source packages
# available from http://get.qt.nokia.com/qt/source/.
# 20121125: Moved to http://qt-project.org/downloads.
#
# These have to be unpacked and repacked for Bilder standards.  E.g.:
#   tar xzf qt-everywhere-opensource-src-4.8.4.tar.gz
#   mv qt-everywhere-opensource-src-4.8.4 qt-4.8.4
#   tar --exclude '\._*' cjf qt-4.8.4.tar.bz2 qt-4.8.4
# OR
#   tar xzf qt-everywhere-opensource-src-5.0.0-beta2.tar.gz
#   mv qt-everywhere-opensource-src-5.0.0-beta2 qt-5.0.0b2
#   tar --exclude '\._*' cjf qt-5.0.0b2.tar.bz2 qt-5.0.0b2
#
# The args, --exclude '\._*', are needed to not put extended attributes
#   files in the tarball on OS X.
#
# Tar up on an older dist, or one may get errors like
# gtar: Ignoring unknown extended header keyword `SCHILY.dev'
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

case `uname`-`uname -r` in
  Darwin-13.*)
# 4.8.4 and 4.8.5 do not build on Mavericks
# 4.8.6 likely not available until Jan 2014.  For now install with homebrew.
    QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.6"}
    QT_BLDRVERSION_EXP=${QT_BLDRVERSION_STD:-"4.8.6"}
    ;;
  *)
    QT_BLDRVERSION_STD=${QT_BLDRVERSION_STD:-"4.8.4"}
    QT_BLDRVERSION_EXP=${QT_BLDRVERSION_EXP:-"4.8.5"}
    ;;
esac

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Only the python build is needed
case `uname`-`uname -r` in
  Darwin-13.*) QT_BUILDS=NONE;; # Until 4.8.6 comes out.
  *) QT_BUILDS=${QT_BUILDS:-"$FORPYTHON_BUILD"};;
esac
QT_BUILD=$FORPYTHON_BUILD
QT_DEPS=bzip2
QT_UMASK=002
addtopathvar PATH $CONTRIB_DIR/qt-$FORPYTHON_BUILD/bin

######################################################################
#
# Launch qt builds.
#
######################################################################

buildQt() {

# Qt requires g++ to have that precise name
# If different, link it into contrib's bin dir.
  QT_GXX_LINKED=false

# QT must be built in place
  if bilderUnpack -i qt; then

# Set the link as needed
    case `uname` in
      Linux | Darwin)
        if test "$(basename $PYC_CXX)" != g++ -a ! -f ${CONTRIB_DIR}/bin/g++; then
          QT_GXX_LINKED=true
          mkdir -p ${CONTRIB_DIR}/bin
          ln -s `which $PYC_CXX` ${CONTRIB_DIR}/bin/g++
          addtopathvar PATH $CONTRIB_DIR/bin
        fi
        ;;
    esac

# Get variables.  Per platform.  Just do mac for now.
    local QT_PLATFORM_ARGS=
    local QT_ENV=
    local QT_PHONON_ARGS=-phonon
    case `uname` in

      Darwin)
# jpeg present, but qt cannot find headers
        case `uname -r` in
          13.*)
# This will need to be clang
            QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform macx-g++ -no-gif"
            ;;
          1[0-2].*)
            case `uname -m` in
              i386) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -arch x86_64";;
              *)
                QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform macx-g++ -no-gif"
                ;;
            esac
            ;;
        esac
        case $QT_BLDRVERSION in
          5.*) ;;
          *) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -cocoa";;
        esac
        ;;

      Linux)
# Adding to the LD_RUN_PATH gets rpath set for the qt libs.
# Adding to the LD_LIBRARY_PATH gets around the missing QtCLucene link bug.
# To get around bash space separation of string, we separate env settings
# with a comma.
        QT_ENV="LD_RUN_PATH=${CONTRIB_DIR}/mesa-mgl/lib:$LD_RUN_PATH LD_LIBRARY_PATH=$BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD/lib:$LD_LIBRARY_PATH"
        case `uname -m` in
          x86_64)
            QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform linux-g++-64"
            ;;
          *)
            QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform linux-g++"
            ;;
        esac

# Need the following for phonon (and for webkit):
#   glib
#   gstreamer-devel
#   gstreamer-plugins-base-devel
#   libxml2
# For some systems, like the Crays, we have to build our own version of
# glib, gstreamer, and xml2, which we do using extras/gstreamer.sh.
# Look for that, and if present add the appropriate flags.
# These should perhaps be Bilderized, but the resulting separate-dir
# installation would make the qt flags a bit more complications
        local extras_libdir=
        if test -e $CONTRIB_DIR/extras/lib; then
          extras_libdir=$CONTRIB_DIR/extras/lib
        fi
        if test -n "${extras_libdir}"; then
          QT_PHONON_ARGS="$QT_PHONON_ARGS -L$extras_libdir"
        fi

# Add system include directories if present.  This should not be duplication,
# as the above should be built only when these are not found.
# The paths on redhat are:
#  -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include
#  -I/usr/include/gstreamer-0.10 -I/usr/include/libxml2
        local incdir=
        local libdir=
# qt will not compile with gstreamer-1.0, so specifically look for 0.10
        for i in gstreamer-0.10 libxml2; do
# Get the latest
          incdir=`ls -1d /usr/include/$i{,-*} 2>/dev/null | tail -1`
          if test -z "$incdir"; then
            incdir=`ls -1d $CONTRIB_DIR/extras/include/$i{,-*} 2>/dev/null | tail -1`
          fi
          if test -n "$incdir"; then
            QT_PHONON_ARGS="$QT_PHONON_ARGS -I$incdir"
          else
            techo "WARNING: [qt.sh] May need to install ${i}-devel."
          fi
# Looks like this is not used?
          # if test -n "$libdir"; then
            # QT_PHONON_ARGS="$QT_PHONON_ARGS -L$libdir"
          # fi
        done
# glib a little special to deal with versions
        incdir=`ls -1d /usr/include/glib-* 2>/dev/null | tail -1`
        if test -n "$incdir"; then
          QT_PHONON_ARGS="$QT_PHONON_ARGS -I$incdir"
        else
          techo "WARNING: [qt.sh] May need to install glib-devel."
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
          QT_PHONON_ARGS="$QT_PHONON_ARGS -I$glibincdir"
        else
          techo "WARNING: [qt.sh] glib word-size include dir not found."
          techo "WARNING: [qt.sh] May need to install glib-devel."
        fi
        local gstprobe=`find /usr/include -name gstappsrc.h`
        if test -z "$gstprobe"; then
          techo "WARNING: [qt.sh] May need to install gstreamer-plugins-base-devel."
        fi
# Adjust for possible change to typedef in glib
        if grep -q 'union *_GMutex' $incdir/glib/gthread.h; then
          techo "Adjusting Qt for change in gthread.h."
          local qtgtypedefs=$BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD/src/3rdparty/webkit/Source/JavaScriptCore/wtf/gobject/GTypedefs.h
          cmd="sed -i.bak 's/struct _GMutex/union _GMutex/' $qtgtypedefs"
          techo "$cmd"
          eval "$cmd"
        fi
        ;;

    esac

# PyQt will not build on Linux when Qt is built without phonon, so restoring.
# Phonon is also required for WebKit, which the composers need.
# On Linux, this requires glib-devel and gstreamer-plugins-base-devel
    QT_WITH_PHONON=${QT_WITH_PHONON:-"true"}
    if ! $QT_WITH_PHONON; then
      techo "NOTE: Building Qt without phonon."
      QT_PHONON_ARGS=-no-phonon
    fi

# Version dependent args
# qt-5 configures differently
# make -j does not work with 4.8.4, apparently.
    case $QT_BLDRVERSION in
      5.*)
        QT_VERSION_ARGS="-developer-build"
        ;;
      4.8.4)
        QT_VERSION_ARGS="-buildkey bilder -no-libtiff -declarative -webkit $QT_PHONON_ARGS"
        ;;
      4.*)
        QT_VERSION_ARGS="-buildkey bilder -no-libtiff -declarative -webkit $QT_PHONON_ARGS"
        QT_MAKEJ_USEARGS="$QT_MAKEJ_ARGS"
        ;;
    esac

# Restore dbus and xmlpatterns or get wrong one
    local qtotherargs=`deref QT_${QT_BUILD}_OTHER_ARGS`
    if bilderConfig -i qt $QT_BUILD "$QT_PLATFORM_ARGS $QT_VERSION_ARGS -confirm-license -make libs -make tools -fast -opensource -opengl -no-separate-debug-info -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-tds -no-javascript-jit -nomake docs -nomake examples -nomake demos $qtotherargs" "" "$QT_ENV"; then
# Make clean seems to hang
      bilderBuild -k qt $QT_BUILD "$QT_MAKEJ_USEARGS" "$QT_ENV"
    else
# Remove linked file if present
      if $QT_GXX_LINKED; then
        rm ${CONTRIB_DIR}/bin/g++
      fi
    fi
  fi
}

######################################################################
#
# Test qt
#
######################################################################

testQt() {
  techo "Not testing qt."
}

######################################################################
#
# Install qt
#
######################################################################

postInstallQt() {

# On Mac, we change the names of the library files
# And their cross links
# To remove references to the build directory
# NOTE: The "stock" qt install uses unqualified paths for everything
#       HOWEVER, this will not work for us, because we're not installing
#       in the default Framework search path (/Library/Frameworks/)
#       SO, we need to make the libraries point to each other using the
#       full path of the installation.
#       As a result, the installed copy of qt may NOT be moved
    case `uname` in
      Darwin)
# Taken from build_visit
        QtTopDir="${CONTRIB_DIR}/qt-${QT_BLDRVERSION}-$QT_BUILD"
# TODO - this should really do a listing of the lib directory
# instead of depending on a hard-coded list of libraries
        QtFrameworks="QtAssistant QtCore QtGui QtHelp QtMultimedia QtNetwork QtOpenGL QtSql QtTest QtWebKit QtXml"
        for QtFW in $QtFrameworks; do
          filename="$QtTopDir/lib/${QtFW}.framework/${QtFW}"
          debugFilename="${filename}_debug"
          oldSOName=$(otool -D $filename | tail -n -1)
          oldDebugSOName=$(otool -D $debugFilename | tail -n -1)
          internalFWPath=$(echo $oldSOName | sed -e 's/.*\.framework\///')
          internalDebugFWPath=$(echo $oldDebugSOName | sed -e 's/.*\.framework\///')
# These are the original lines, which install a relative path
          # newSOName="@executable_path/../lib/${QtFW}.framework/$internalFWPath"
          # newDebugSOName="@executable_path/../lib/${QtFW}.framework/$internalDebugFWPath"
# These are the "new" lines that install a path-less library name, and so
# relies on DYLD_LIBRARY_PATH.
          newSOName="${QtFW}.framework/$internalFWPath"
	  newDebugSOName="${QtFW}.framework/$internalDebugFWPath"
          install_name_tool -id $newSOName $filename
          install_name_tool -id $newDebugSOName $debugFilename
# This loop changes the name of THIS library in all the OTHER libraries
          for otherQtFW in $QtFrameworks; do
            install_name_tool -change $oldSOName $newSOName $QtTopDir/lib/${otherQtFW}.framework/${otherQtFW}
            install_name_tool -change $oldSOName $newSOName $QtTopDir/lib/${otherQtFW}.framework/${otherQtFW}_debug
# QtCLucene is not a framework, so it's a special case
	    install_name_tool -change $oldSOName $newSOName $QtTopDir/lib/libQtCLucene.dylib
	    install_name_tool -change $oldSOName $newSOName $QtTopDir/lib/libQtCLucene_debug.dylib
          done
        done

# once more for QtCLucene
        filenameROOT="${QtTopDir}/lib/libQtCLucene"
        debugFilename="${filenameROOT}_debug.dylib"
	filename="${filenameROOT}.dylib"
	techo "filename is ${filename}"
        oldSOName=$(otool -D $filename | tail -n -1)
	techo "for QtCLucene, oldSOName is ${oldSOName}"
        oldDebugSOName=$(otool -D $debugFilename | tail -n -1)
        internalFWPath=$(echo $oldSOName | sed -e 's/.*\lib\///')
	techo "for QtCLUcene,internalFWPath is ${internalFWPath}"
        internalDebugFWPath=$(echo $oldDebugSOName | sed -e 's/.*\lib\///')
# These are the new lines which install a no-path library name
        newSOName="${internalFWPath}"
        newDebugSOName="${internalDebugFWPath}"
	techo "Calling install_name_tool -d ${newSOName} ${filename}"
        install_name_tool -id $newSOName $filename
        install_name_tool -id $newDebugSOName $debugFilename
        for otherQtFW in $QtFrameworks; do
	    techo "Calling install_name_tool ${oldSOName} ${newSOName} on file $QtTopDir/lib/${otherQtFW}.framework/${otherQtFW}"
          install_name_tool -change $oldSOName $newSOName $QtTopDir/lib/${otherQtFW}.framework/${otherQtFW}
          install_name_tool -change $oldSOName $newSOName $QtTopDir/lib/${otherQtFW}.framework/${otherQtFW}_debug
        done
        ;;

    esac

}

# Fix up various problems with QT installations
#
fixQtInstall() {
# Remove linked file if present
  if $QT_GXX_LINKED; then
    rm ${CONTRIB_DIR}/bin/g++
  fi
# Fix the bad node that Qt leaves behind on a Darwin installation.
# (Seems not to do this on an overinstallation?)
  case `uname` in
    Darwin)
      local badnode="$CONTRIB_DIR/qt-$QT_BLDRVERSION-$QT_BUILD/lib/QtTest.framework/Versions/4/4"
      if test -L $badnode; then
        techo "NOTE: Removing leftover link from qt installation, $badnode."
        cmd="chmod -h u+rwx $badnode"
        techo "$cmd"
        $cmd
        cmd="rm $badnode"
        techo "$cmd"
        $cmd
      fi
      if test -L $badnode; then
        techo "WARNING: Unable to remove leftover link, $badnode, from qt installation.  Must be done as root."
      fi
      ;;
  esac
# Set the perms to open for Qt.
  setOpenPerms $CONTRIB_DIR/qt-$QT_BLDRVERSION-$QT_BUILD
}

installQt() {

  local qt_tried=false
  local qtpid=`deref QT_${QT_BUILD}_PID`
  if test -n "$qtpid"; then
    qt_tried=true
  fi
  if bilderInstall -r qt $QT_BUILD; then
    fixQtInstall
    findQt
  elif $qt_tried; then
    cat <<EOF | tee -a $LOGFILE
Qt failed to build.  Bilder will try the following:
  cd $BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD
  make -i install
and then follow with the usual installation.
EOF
    cd $BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD
    make -i install 2>&1 | tee qt-install2.txt
    bilderBuild qt $QT_BUILD "$QT_MAKEJ_ARGS"
    if bilderInstall -r qt $QT_BUILD; then
      fixQtInstall
      findQt
    else
      techo "Extra build steps failed."
    fi
  fi

}

