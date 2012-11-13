@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinsabs through cygwin on windows.
rem
rem $Id$
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO jenkinsabs: windows batch script starting up in %CD% with arguments, %*.
ECHO jenkinsabs.bat starting up in %CD% with arguments, %*. >> jenkinsabs.log

C:\CYGWIN\bin\cygpath %CD% >temp.txt
set /p CYGWINDIR= < temp.txt
del temp.txt
rem ECHO CYGWINDIR= %CYGWINDIR%.
rem ECHO 2= %2
set JENKINSABSERROR=0
@ECHO on
C:\CYGWIN\bin\bash --login %CYGWINDIR%/bilder/jenkins/jenkinsabs %*
@ECHO off
if ERRORLEVEL 1 set JENKINSABSERROR=1

ECHO   jenkinsabs: windows batch script completed with error = %JENKINSABSERROR%.
ECHO jenkinsabs.bat completed with error = %JENKINSABSERROR%. >> jenkinsabs.log

EXIT /B %JENKINSABSERROR%

