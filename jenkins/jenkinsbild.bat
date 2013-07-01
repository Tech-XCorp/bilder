@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsbild through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO jenkinsbild.bat: JENKINS_HOME=%JENKINS_HOME% 
ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*.
ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*. >> jenkinsbild.log


set origdir=%CD%
cd ..\..\..\..
set JENKINS_FSROOT=%CD%
cd %origdir%
ECHO jenkinsbild.bat: JENKINS_FSROOT=%JENKINS_FSROOT% 

rem save old dir
@ECHO on
set origdrive=%CD:~0,2%
subst j: %origdir%
j:
@ECHO off
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

@ECHO on
%origdrive%
subst j: /D
cd %origdir%
@ECHO off

EXIT /B %JBILDERR%

