@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsbild through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO jenkinsbild.bat: ========= EXECUTING jenkinsbild.bat ========
ECHO jenkinsbild.bat: ========= EXECUTING jenkinsbild.bat ======== > jenkinsbild.log
ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*.
ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*. >> jenkinsbild.log
ECHO jenkinsbild.bat: ++++++JENKINS VARIABLES++++++
ECHO jenkinsbild.bat: ++++++JENKINS VARIABLES++++++ >> jenkinsbild.log
ECHO jenkinsbild.bat: JENKINS_HOME=%JENKINS_HOME%
ECHO jenkinsbild.bat: JENKINS_HOME=%JENKINS_HOME% >> jenkinsbild.log
ECHO jenkinsbild.bat: JOB_NAME=%JOB_NAME%
ECHO jenkinsbild.bat: JOB_NAME=%JOB_NAME% >> jenkinsbild.log
ECHO jenkinsbild.bat: BUILD_ID=%BUILD_ID%
ECHO jenkinsbild.bat: BUILD_ID=%BUILD_ID% >> jenkinsbild.log
ECHO jenkinsbild.bat: BUILD_TAG=%BUILD_TAG%
ECHO jenkinsbild.bat: BUILD_TAG=%BUILD_TAG% >> jenkinsbild.log
ECHO jenkinsbild.bat: JAVA_HOME=%JAVA_HOME%
ECHO jenkinsbild.bat: JAVA_HOME=%JAVA_HOME% >> jenkinsbild.log
ECHO jenkinsbild.bat: WORKSPACE=%WORKSPACE%
ECHO jenkinsbild.bat: WORKSPACE=%WORKSPACE% >> jenkinsbild.log
ECHO jenkinsbild.bat: +++++++++++++++++++++++++++++
ECHO jenkinsbild.bat: +++++++++++++++++++++++++++++ >> jenkinsbild.log

REM JOB_NAME contains <JOB>/n=<NODE>
set JOB_LINK_NAME=
if defined JOB_NAME (
  for /f "tokens=1 delims=/" %%A in ("%JOB_NAME%") do set JOB_LINK_NAME=%%A
)

REM Declare vars outside of if parens so they have current scope
set BILDER_WSPATH=%CD%
set drive=%cd:~0,2%

REM If Jenkins define where to link job
if defined JOB_LINK (
  set JOB_LINK=%drive%\%JOB_LINK_NAME%
REM Allow for some namespacing of link
  if exist %drive%\jenkins set JOB_LINK=%drive%\jenkins\%JOB_LINK_NAME%
  echo jenkinsbild.bat: Added drive letter.
REM Jenkins workspace variable has forward slashes, but
REM we need a windows path, so we convert
  set BILDER_WSPATH=%WORKSPACE%
  set BILDER_WSPATH=%BILDER_WSPATH:/=\%
)
echo jenkinsbild.bat: JOB_LINK=%JOB_LINK%

REM If workspace path doesn't contain drive letter
REM then we add the current drive letter to the path.
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

REM if jenkins create link
if defined JOB_LINK (
  if exist %JOB_LINK% goto linkexistscontinue
    echo jenkinsbild.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %BILDER_WSPATH%
    echo jenkinsbild.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %BILDER_WSPATH% >> jenkinsbild.log
    echo on
    mklink /D %JOB_LINK% %BILDER_WSPATH%
    echo off
  :linkexistscontinue
  if exist %JOB_LINK% goto havelinkcontinue
    echo jenkinsbild.bat: %JOB_LINK% still does not exist.
    echo jenkinsbild.bat: %JOB_LINK% still does not exist. >> jenkinsbild.log
  :havelinkcontinue
  if not exist %JOB_LINK% goto nothavelinkcontinue
    echo jenkinsbild.bat: %JOB_LINK% exists.
    echo jenkinsbild.bat: %JOB_LINK% exists. >> jenkinsbild.log
  :nothavelinkcontinue
  cd %JOB_LINK%
)

ECHO jenkinsbild.bat: Working in %CD%.
ECHO jenkinsbild.bat: Working in %CD%. >> jenkinsbild.log

REM Jenkins xshell converts forward slashes in arguments to back slashes,
REM but we need forward slashes so undo
set BILDER_ARGS=%*
set BILDER_ARGS=%BILDER_ARGS:\=/%
ECHO jenkinsbild.bat: BILDER_ARGS = %BILDER_ARGS%.

REM Find cygwinbasedir
set CYGWINBASEDIR=C:\cygwin64
if exist %CYGWINBASEDIR% goto cygwinbasedir64
  set CYGWINBASEDIR=C:\cygwin
:cygwinbasedir64

%CYGWINBASEDIR%\bin\cygpath %CD% >temp.txt
REM %CYGWINBASEDIR%\bin\cygpath %JOB_LINK% >temp.txt
set /p CYGWINPROJDIR= < temp.txt
echo jenkinsbild.bat: CYGWINPROJDIR = %CYGWINPROJDIR%.
echo jenkinsbild.bat: CYGWINPROJDIR = %CYGWINPROJDIR%.  >> jenkinsbild.log
del temp.txt
set JBILDERR=0
@ECHO on
REM %CYGWINBASEDIR%\bin\bash --login %CYGWINPROJDIR%/bilder/jenkins/jenkinsbild %*
%CYGWINBASEDIR%\bin\bash --login %CYGWINPROJDIR%/bilder/jenkins/jenkinsbild %BILDER_ARGS%
@ECHO off
if ERRORLEVEL 1 set JBILDERR=1

ECHO jenkinsbild.bat: completed with error = %JBILDERR%.
ECHO jenkinsbild.bat: completed with error = %JBILDERR%. >> jenkinsbild.log

EXIT /B %JBILDERR%

