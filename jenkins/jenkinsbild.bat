@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsbild through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO   jenkinsbild: windows batch script starting up in %CD% with arguments, %*.
ECHO jenkinsbild.bat starting up in %CD% with arguments, %*. >> jenkinsbild.log

C:\CYGWIN\bin\cygpath %CD% >temp.txt
set /p CYGWINDIR= < temp.txt
del temp.txt
rem ECHO CYGWINDIR= %CYGWINDIR%.
rem ECHO 2= %2
set JENKINSBILDERROR=0
@ECHO on
C:\CYGWIN\bin\bash --login %CYGWINDIR%/bilder/jenkins/jenkinsbild %*
@ECHO off
if ERRORLEVEL 1 set JENKINSBILDERROR=1

ECHO   jenkinsbild: windows batch script completed with error = %JENKINSBILDERROR%.
ECHO jenkinsbild.bat completed with error = %JENKINSBILDERROR%. >> jenkinsbild.log

EXIT /B %JENKINSBILDERROR%

