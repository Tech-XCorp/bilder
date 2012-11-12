@ECHO off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem Purpose: This starts jenkinstest through cygwin on windows.
rem
rem $Id: jenkinstest.bat 5798 2012-04-15 12:27:43Z cary $
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem rem

ECHO jenkinstest.bat starting up in %CD% with arguments, %*.
ECHO jenkinstest.bat starting up in %CD% with arguments, %*. >jenkinstest.log

C:\CYGWIN\bin\cygpath %CD% >temp.txt
set /p CYGWINDIR= < temp.txt
del temp.txt
rem ECHO CYGWINDIR= %CYGWINDIR%.
rem ECHO 2= %2
@ECHO on
set JENKINSTESTERROR=0
rem Is this right?
C:\CYGWIN\bin\bash --login %CYGWINDIR%/jenkinstest %*
if ERRORLEVEL 1 set JENKINSTESTERROR=1
@ECHO off

ECHO jenkinstest completed with error = %JENKINSTESTERROR%.
ECHO jenkinstest completed with error = %JENKINSTESTERROR%. >>jenkinstest.log

EXIT /B %JENKINSTESTERROR%

