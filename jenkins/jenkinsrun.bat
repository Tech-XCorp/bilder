@echo off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsrun through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

DEL /Q jenkinsrun.log
LECHO ========= EXECUTING jenkinsrun.bat ========
LECHO starting up in %CD% with arguments, %*.
LECHO   ++++++JENKINS VARIABLES++++++
LECHO JENKINS_HOME=%JENKINS_HOME%
LECHO JOB_NAME=%JOB_NAME%
LECHO BUILD_ID=%BUILD_ID%
LECHO BUILD_TAG=%BUILD_TAG%
LECHO JAVA_HOME=%JAVA_HOME%
LECHO WORKSPACE=%WORKSPACE%
LECHO   +++++++++++++++++++++++++++++

REM JOB_NAME contains <JOB>\<NODES>=<NODE>
for /f "tokens=1 delims=/" %%A in ("%JOB_NAME%") do set JOB_LINK=%%A
LECHO JOB Part of JOB_NAME=%JOB_LINK%

for %%A in ("%CD%") do set drive=%%~dA
set JOB_LINK=%drive%\%JOB_LINK%
LECHO Adding drive letter... JOB_LINK=%JOB_LINK%
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
  LECHO Adding drive, %drive%, to WS path.
  set JENKINS_WSPATH=%drive%%JENKINS_WSPATH%
)
LECHO JENKINS_WSPATH=%JENKINS_WSPATH%

if exist %JOB_LINK% goto linkexistscontinue
  LECHO %JOB_LINK% does not exist.  Executing mklink /D %JOB_LINK% %JENKINS_WSPATH%
  @echo on
  mklink /D %JOB_LINK% %JENKINS_WSPATH%
  @echo off
:linkexistscontinue
if exist %JOB_LINK% goto havelinkcontinue
  LECHO %JOB_LINK% still does not exist.
:havelinkcontinue
if not exist %JOB_LINK% goto nothavelinkcontinue
  LECHO %JOB_LINK% exists.
:nothavelinkcontinue
set JENKINS_JOB_DIR=%JOB_LINK%
cd %JOB_LINK%
LECHO Working in %CD%.

REM Find cygwinbasedir
set CYGWINBASEDIR=C:\cygwin64
if exist %CYGWINBASEDIR% goto cygwinbasedir64
  set CYGWINBASEDIR=C:\cygwin
:cygwinbasedir64

%CYGWINBASEDIR%\bin\cygpath %CD% >temp.txt
REM %CYGWINBASEDIR%\bin\cygpath %JOB_LINK% >temp.txt
set /p CYGWINPROJDIR= < temp.txt
LECHO CYGWINPROJDIR = %CYGWINPROJDIR%.
del temp.txt
set JBILDERR=0
@echo on
%CYGWINBASEDIR%\bin\bash --login %CYGWINPROJDIR%/bilder/jenkins/jenkinsrun %*
@echo off
if ERRORLEVEL 1 set JBILDERR=1

LECHO Completed with error = %JBILDERR%.

EXIT /B %JBILDERR%

LECHO:
ECHO jenkinsrun.bat: %-1
ECHO jenkinsrun.bat: %-1 >> jenkinsrun.log

