@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsbild through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO jenkinsbild.bat: ========= EXECUTING jenkinsbild.bat ========
ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*.
ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*. >> jenkinsbild.log
ECHO jenkinsbild.bat: ++++++JENKINS VARIABLES++++++
ECHO jenkinsbild.bat: JENKINS_HOME=%JENKINS_HOME%
ECHO jenkinsbild.bat: JOB_NAME=%JOB_NAME%
ECHO jenkinsbild.bat: BUILD_ID=%BUILD_ID%
ECHO jenkinsbild.bat: BUILD_TAG=%BUILD_TAG%
ECHO jenkinsbild.bat: JAVA_HOME=%JAVA_HOME%
ECHO jenkinsbild.bat: WORKSPACE=%WORKSPACE%
ECHO jenkinsbild.bat: +++++++++++++++++++++++++++++ 

REM JOB_NAME contains <JOB>\<NODES>=<NODE>
for /f "tokens=1 delims=/" %%A in ("%JOB_NAME%") do set JOB_LINK=%%A
echo jenkinsbild.bat: JOB Part of JOB_NAME=%JOB_LINK%

for %%A in ("%CD%") do set drive=%%~dA
set JOB_LINK=%drive%\%JOB_LINK%
echo jenkinsbild.bat: Adding drive letter... JOB_LINK=%JOB_LINK%
if exist %JOB_LINK% goto createlink else linkexistscontinue
:createlink
echo jenkinsbild.bat: Creating soft link with: mklink /D %JOB_LINK% %WORKSPACE% 
mklink /D %JOB_LINK% %WORKSPACE%
:linkexistscontinue
cd %JOB_LINK%

ECHO jenkinsbild.bat: Working in %CD%.
ECHO jenkinsbild.bat: Working in %CD%. >>jenkinsbild.log


C:\CYGWIN\bin\cygpath %CD% >temp.txt
set /p CYGWINDIR= < temp.txt
del temp.txt
rem ECHO CYGWINDIR= %CYGWINDIR%.
rem ECHO 2= %2
set JBILDERR=0
@ECHO on
C:\CYGWIN\bin\bash --login %CYGWINDIR%/bilder/jenkins/jenkinsbild %*
@ECHO off
if ERRORLEVEL 1 set JBILDERR=1

ECHO jenkinsbild.bat: completed with error = %JBILDERR%.
ECHO jenkinsbild.bat: completed with error = %JBILDERR%. >> jenkinsbild.log

EXIT /B %JBILDERR%

