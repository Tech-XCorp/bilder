@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsrun through cygwin on windows.
rem
rem $Id: jenkinsrun.bat 276 2013-07-13 20:08:15Z techxdws $
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO jenkinsrun.bat: ========= EXECUTING jenkinsrun.bat ========
ECHO jenkinsrun.bat: ========= EXECUTING jenkinsrun.bat ======== > jenkinsrun.log
ECHO jenkinsrun.bat: starting up in %CD% with arguments, %*.
ECHO jenkinsrun.bat: starting up in %CD% with arguments, %*. >> jenkinsrun.log
ECHO jenkinsrun.bat: ++++++JENKINS VARIABLES++++++
ECHO jenkinsrun.bat: ++++++JENKINS VARIABLES++++++ >> jenkinsrun.log
ECHO jenkinsrun.bat: JENKINS_HOME=%JENKINS_HOME%
ECHO jenkinsrun.bat: JENKINS_HOME=%JENKINS_HOME% >> jenkinsrun.log
ECHO jenkinsrun.bat: JOB_NAME=%JOB_NAME%
ECHO jenkinsrun.bat: JOB_NAME=%JOB_NAME% >> jenkinsrun.log
ECHO jenkinsrun.bat: BUILD_ID=%BUILD_ID%
ECHO jenkinsrun.bat: BUILD_ID=%BUILD_ID% >> jenkinsrun.log
ECHO jenkinsrun.bat: BUILD_TAG=%BUILD_TAG%
ECHO jenkinsrun.bat: BUILD_TAG=%BUILD_TAG% >> jenkinsrun.log
ECHO jenkinsrun.bat: JAVA_HOME=%JAVA_HOME%
ECHO jenkinsrun.bat: JAVA_HOME=%JAVA_HOME% >> jenkinsrun.log
ECHO jenkinsrun.bat: WORKSPACE=%WORKSPACE%
ECHO jenkinsrun.bat: WORKSPACE=%WORKSPACE% >> jenkinsrun.log
ECHO jenkinsrun.bat: +++++++++++++++++++++++++++++
ECHO jenkinsrun.bat: +++++++++++++++++++++++++++++ >> jenkinsrun.log

REM JOB_NAME contains <JOB>\<NODES>=<NODE>
for /f "tokens=1 delims=/" %%A in ("%JOB_NAME%") do set JOB_LINK=%%A
echo jenkinsrun.bat: JOB Part of JOB_NAME=%JOB_LINK%
echo jenkinsrun.bat: JOB Part of JOB_NAME=%JOB_LINK% >> jenkinsrun.log

for %%A in ("%CD%") do set drive=%%~dA
set JOB_LINK=%drive%\%JOB_LINK%
echo jenkinsrun.bat: Adding drive letter... JOB_LINK=%JOB_LINK%
echo jenkinsrun.bat: Adding drive letter... JOB_LINK=%JOB_LINK% >> jenkinsrun.log
REM Jenkins workspace variable has forward slashes, but
REM we need a windows path, so we convert
set JENKINS_WSPATH=%WORKSPACE%
set JENKINS_WSPATH=%JENKINS_WSPATH:/=\%

REM If workspace path doesn't contain drive letter
REM then we add the current drive letter to the path.
set foundcolon=false
set teststr=%JENKINS_WSPATH%
if not x%teststr::=%==x%teststr% set foundcolon=true
if "%foundcolon%"=="false" (
  echo jenkinsrun.bat: Adding drive, %drive%, to WS path.
  echo jenkinsrun.bat: Adding drive, %drive%, to WS path. >> jenkinsrun.log
  set JENKINS_WSPATH=%drive%%JENKINS_WSPATH%
)
echo jenkinsrun.bat: JENKINS_WSPATH=%JENKINS_WSPATH%
echo jenkinsrun.bat: JENKINS_WSPATH=%JENKINS_WSPATH% >> jenkinsrun.log

if exist %JOB_LINK% goto linkexistscontinue
  echo jenkinsrun.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %JENKINS_WSPATH%
  echo jenkinsrun.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %JENKINS_WSPATH% >> jenkinsrun.log
  echo on
  mklink /D %JOB_LINK% %JENKINS_WSPATH%
  echo off
:linkexistscontinue
if exist %JOB_LINK% goto havelinkcontinue
  echo jenkinsrun.bat: %JOB_LINK% still does not exist.
  echo jenkinsrun.bat: %JOB_LINK% still does not exist. >> jenkinsrun.log
:havelinkcontinue
if not exist %JOB_LINK% goto nothavelinkcontinue
  echo jenkinsrun.bat: %JOB_LINK% exists.
  echo jenkinsrun.bat: %JOB_LINK% exists. >> jenkinsrun.log
:nothavelinkcontinue
set JENKINS_JOB_DIR=%JOB_LINK%
cd %JOB_LINK%

ECHO jenkinsrun.bat: Working in %CD%.
ECHO jenkinsrun.bat: Working in %CD%. >> jenkinsrun.log


C:\CYGWIN\bin\cygpath %CD% >temp.txt
REM C:\CYGWIN\bin\cygpath %JOB_LINK% >temp.txt
set /p CYGWINDIR= < temp.txt
echo jenkinsrun.bat: CYGWINDIR = %CYGWINDIR%.
echo jenkinsrun.bat: CYGWINDIR = %CYGWINDIR%.  >> jenkinsrun.log
del temp.txt
set JBILDERR=0
@ECHO on
C:\CYGWIN\bin\bash --login %CYGWINDIR%/bilder/jenkins/jenkinsrun %*
@ECHO off
if ERRORLEVEL 1 set JBILDERR=1

ECHO jenkinsrun.bat: completed with error = %JBILDERR%.
ECHO jenkinsrun.bat: completed with error = %JBILDERR%. >> jenkinsrun.log

EXIT /B %JBILDERR%

