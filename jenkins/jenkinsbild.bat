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

REM JOB_NAME contains <JOB>\<NODES>=<NODE>
for /f "tokens=1 delims=/" %%A in ("%JOB_NAME%") do set JOB_LINK=%%A
echo jenkinsbild.bat: JOB Part of JOB_NAME=%JOB_LINK%
echo jenkinsbild.bat: JOB Part of JOB_NAME=%JOB_LINK% >> jenkinsbild.log

for %%A in ("%CD%") do set drive=%%~dA
set JOB_LINK=%drive%\%JOB_LINK%
echo jenkinsbild.bat: Adding drive letter... JOB_LINK=%JOB_LINK%
echo jenkinsbild.bat: Adding drive letter... JOB_LINK=%JOB_LINK% >> jenkinsbild.log
REM Jenkins workspace variable has forward slashes, but
REM we need a windows path, so we convert
set JENKINS_WSPATH=%WORKSPACE%
set JENKINS_WSPATH=%JENKINS_WSPATH:/=\%

REM Jenkins xshell converts forward slashes in arguments to back slashes,
REM but we need forward slashes so undo
set BILDER_ARGS="%*"
set BILDER_ARGS="%BILDER_ARGS:\=/%"

REM If workspace path doesn't contain drive letter
REM then we add the current drive letter to the path.
set foundcolon=false
set teststr=%JENKINS_WSPATH%
if not x%teststr::=%==x%teststr% set foundcolon=true
if "%foundcolon%"=="false" (
  echo jenkinsbild.bat: Adding drive, %drive%, to WS path.
  echo jenkinsbild.bat: Adding drive, %drive%, to WS path. >> jenkinsbild.log
  set JENKINS_WSPATH=%drive%%JENKINS_WSPATH%
)
echo jenkinsbild.bat: JENKINS_WSPATH=%JENKINS_WSPATH%
echo jenkinsbild.bat: JENKINS_WSPATH=%JENKINS_WSPATH% >> jenkinsbild.log

if exist %JOB_LINK% goto linkexistscontinue
  echo jenkinsbild.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %JENKINS_WSPATH%
  echo jenkinsbild.bat: %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %JENKINS_WSPATH% >> jenkinsbild.log
  echo on
  mklink /D %JOB_LINK% %JENKINS_WSPATH%
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
set JENKINS_JOB_DIR=%JOB_LINK%
cd %JOB_LINK%

ECHO jenkinsbild.bat: Working in %CD%.
ECHO jenkinsbild.bat: Working in %CD%. >> jenkinsbild.log


C:\CYGWIN\bin\cygpath %CD% >temp.txt
REM C:\CYGWIN\bin\cygpath %JOB_LINK% >temp.txt
set /p CYGWINDIR= < temp.txt
echo jenkinsbild.bat: CYGWINDIR = %CYGWINDIR%.
echo jenkinsbild.bat: CYGWINDIR = %CYGWINDIR%.  >> jenkinsbild.log
del temp.txt
set JBILDERR=0
@ECHO on
REM C:\CYGWIN\bin\bash --login %CYGWINDIR%/bilder/jenkins/jenkinsbild %*
C:\CYGWIN\bin\bash --login %CYGWINDIR%/bilder/jenkins/jenkinsbild %BILDER_ARGS%
@ECHO off
if ERRORLEVEL 1 set JBILDERR=1

ECHO jenkinsbild.bat: completed with error = %JBILDERR%.
ECHO jenkinsbild.bat: completed with error = %JBILDERR%. >> jenkinsbild.log

EXIT /B %JBILDERR%

