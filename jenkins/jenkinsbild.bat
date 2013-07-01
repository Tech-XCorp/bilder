@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsbild through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*.
ECHO jenkinsbild.bat: starting up in %CD% with arguments, %*. >> jenkinsbild.log

rem save old dir
@ECHO on
set origdrive=%CD:~0,2%
set origdir=%CD%
subst j: %origdir%
j:
@ECHO off
ECHO jenkinsbil.bat: Working in %CD%.
ECHO jenkinsbil.bat: Working in %CD%. >>jenkinsbild.log


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

