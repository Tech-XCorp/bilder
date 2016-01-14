@echo off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsbild through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

echo jenkinsbild.bat: ========= EXECUTING jenkinsbild.bat ========
echo jenkinsbild.bat: ========= EXECUTING jenkinsbild.bat ======== > jenkinsbild.log
echo jenkinsbild.bat: starting up in %CD% with arguments, %*.
echo jenkinsbild.bat: starting up in %CD% with arguments, %*. >> jenkinsbild.log
echo jenkinsbild.bat: ++++++JENKINS VARIABLES++++++
echo jenkinsbild.bat: ++++++JENKINS VARIABLES++++++ >> jenkinsbild.log
echo jenkinsbild.bat: JENKINS_HOME=%JENKINS_HOME%
echo jenkinsbild.bat: JENKINS_HOME=%JENKINS_HOME% >> jenkinsbild.log
echo jenkinsbild.bat: JOB_NAME=%JOB_NAME%
echo jenkinsbild.bat: JOB_NAME=%JOB_NAME% >> jenkinsbild.log
echo jenkinsbild.bat: BUILD_ID=%BUILD_ID%
echo jenkinsbild.bat: BUILD_ID=%BUILD_ID% >> jenkinsbild.log
echo jenkinsbild.bat: BUILD_TAG=%BUILD_TAG%
echo jenkinsbild.bat: BUILD_TAG=%BUILD_TAG% >> jenkinsbild.log
echo jenkinsbild.bat: JAVA_HOME=%JAVA_HOME%
echo jenkinsbild.bat: JAVA_HOME=%JAVA_HOME% >> jenkinsbild.log
echo jenkinsbild.bat: WORKSPACE=%WORKSPACE%
echo jenkinsbild.bat: WORKSPACE=%WORKSPACE% >> jenkinsbild.log
echo jenkinsbild.bat: +++++++++++++++++++++++++++++
echo jenkinsbild.bat: +++++++++++++++++++++++++++++ >> jenkinsbild.log

rem JOB_NAME contains <JOB>/n=<NODE>
set JOB_LINK_BASENAME=
if defined JOB_NAME (
  for /f "tokens=1 delims=/" %%A in ("%JOB_NAME%") do set JOB_LINK_BASENAME=%%A
)
echo jenkinsbild.bat: JOB_LINK_BASENAME = %JOB_LINK_BASENAME%

rem Declare vars outside of if parens so they have current scope
set BILDER_WSPATH=%CD%
set drive=%cd:~0,2%

rem If Jenkins define where to link job
if defined JOB_LINK_BASENAME (
  set JOB_LINK=%drive%\%JOB_LINK_BASENAME%
rem Allow for some namespacing of link
  if exist %drive%\jenkins set JOB_LINK=%drive%\jenkins\%JOB_LINK_BASENAME%
  echo jenkinsbild.bat: Added drive letter.
rem Jenkins workspace variable has forward slashes, but
rem we need a windows path, so we convert
  set BILDER_WSPATH=%WORKSPACE%
  set BILDER_WSPATH=%BILDER_WSPATH:/=\%
)
echo jenkinsbild.bat: JOB_LINK=%JOB_LINK%

rem If workspace path doesn't contain drive letter
rem then we add the current drive letter to the path.
set foundcolon=false
set teststr=%BILDER_WSPATH%
if not x%teststr::=%==x%teststr% set foundcolon=true
if "%foundcolon%"=="false" (
  echo jenkinsbild.bat: Adding drive, %drive%, to WS path.
  echo jenkinsbild.bat: Adding drive, %drive%, to WS path. >> jenkinsbild.log
  set BILDER_WSPATH=%drive%%BILDER_WSPATH%
)
echo jenkinsbild.bat: BILDER_WSPATH=%BILDER_WSPATH%
echo jenkinsbild.bat: BILDER_WSPATH=%BILDER_WSPATH% >> jenkinsbild.log

rem if jenkins create link
if defined JOB_LINK (
  if exist %JOB_LINK% goto linkexistscontinue
    echo jenkinsbild.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %BILDER_WSPATH%
    echo jenkinsbild.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %BILDER_WSPATH% >> jenkinsbild.log
    @echo on
    mklink /D %JOB_LINK% %BILDER_WSPATH%
    @echo off
  :linkexistscontinue
  if exist %JOB_LINK% goto havelinkcontinue
    echo jenkinsbild.bat: %JOB_LINK% still does not exist.
    echo jenkinsbild.bat: %JOB_LINK% still does not exist. >> jenkinsbild.log
  :havelinkcontinue
  if not exist %JOB_LINK% goto nothavelinkcontinue
    echo jenkinsbild.bat: %JOB_LINK% exists.  
    echo Executing rmdir %JOB_LINK% to refresh existing link.
    echo Executing mklink /D %JOB_LINK% %BILDER_WSPATH% to refresh existing link.
    echo jenkinsbild.bat: %JOB_LINK% exists.  Executing mklink /D %JOB_LINK% %BILDER_WSPATH% to refresh existing link. >> jenkinsbild.log
    echo Executing rmdir %JOB_LINK% to refresh existing link. >> jenkinsbild.log
    echo Executing mklink /D %JOB_LINK% %BILDER_WSPATH% to refresh existing link. >> jenkinsbild.log
    @echo on
    rmdir %JOB_LINK%
    mklink /D %JOB_LINK% %BILDER_WSPATH%
    @echo off
  :nothavelinkcontinue
  cd %JOB_LINK%
)

echo jenkinsbild.bat: Working in %CD%.
echo jenkinsbild.bat: Working in %CD%. >> jenkinsbild.log

rem Jenkins xshell converts forward slashes in arguments to back slashes,
rem but we need forward slashes so undo
set BILDER_ARGS=%*
set BILDER_ARGS=%BILDER_ARGS:\=/%
echo jenkinsbild.bat: BILDER_ARGS = %BILDER_ARGS%.

rem Find cygwinbasedir
set CYGWINBASEDIR=C:\cygwin64
if exist %CYGWINBASEDIR% goto cygwinbasedir64
  set CYGWINBASEDIR=C:\cygwin
:cygwinbasedir64

%CYGWINBASEDIR%\bin\cygpath %CD% >temp.txt
rem %CYGWINBASEDIR%\bin\cygpath %JOB_LINK% >temp.txt
set /p CYGWINPROJDIR= < temp.txt
echo jenkinsbild.bat: CYGWINPROJDIR = %CYGWINPROJDIR%.
echo jenkinsbild.bat: CYGWINPROJDIR = %CYGWINPROJDIR%.  >> jenkinsbild.log
del temp.txt
set JBILDERR=0
@echo on
rem %CYGWINBASEDIR%\bin\bash --login %CYGWINPROJDIR%/bilder/jenkins/jenkinsbild %*
%CYGWINBASEDIR%\bin\bash --login %CYGWINPROJDIR%/bilder/jenkins/jenkinsbild %BILDER_ARGS%
@echo off
if ERRORLEVEL 1 set JBILDERR=1

echo jenkinsbild.bat: completed with error = %JBILDERR%.
echo jenkinsbild.bat: completed with error = %JBILDERR%. >> jenkinsbild.log

exit /B %JBILDERR%

