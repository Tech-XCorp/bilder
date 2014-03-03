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

REM Find cygwinbasedir
set CYGWINBASEDIR=C:\cygwin64
if exist %CYGWINBASEDIR% goto cygwinbasedir64
  set CYGWINBASEDIR=C:\cygwin
:cygwinbasedir64

%CYGWINBASEDIR%\bin\cygpath %CD% >temp.txt
set /p CYGWINPROJDIR= < temp.txt
del temp.txt
rem ECHO CYGWINPROJDIR= %CYGWINPROJDIR%.
rem ECHO 2= %2
set JENKINSABSERROR=0
@ECHO on
%CYGWINBASEDIR%\bin\bash --login %CYGWINPROJDIR%/bilder/jenkins/jenkinsabs %*
@ECHO off
if ERRORLEVEL 1 set JENKINSABSERROR=1

ECHO   jenkinsabs: windows batch script completed with error = %JENKINSABSERROR%.
ECHO jenkinsabs.bat completed with error = %JENKINSABSERROR%. >> jenkinsabs.log

EXIT /B %JENKINSABSERROR%

