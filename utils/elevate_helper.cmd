@echo off

REM based on https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
REM see also: http://forum.oszone.net/thread-344409.html

SETLOCAL ENABLEDELAYEDEXPANSION
IF /I "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
  echo Running on 64 bit windows
  rem set "SYSTEM_CONFIG_DIR=%SYSTEMROOT%\SysWOW64\config\system"
  rem there is no %SYSTEMROOT%\Sys\config\system
  rem The system cannot find the path specified.
  set "SYSTEM_CONFIG_DIR=%SYSTEMROOT%\system32\config\system"
  set "SYSTEM_DIR=%SYSTEMROOT%\SysWOW64"
) else (
  echo Running on 32 bit windows
  set "SYSTEM_CONFIG_DIR=%SYSTEMROOT%\system32\config\system"
  set "SYSTEM_DIR=%SYSTEMROOT%\system32"
)
REM 2 The system cannot find the file specified.
REM 5 Access is denied
REM >nul 2>&1
echo "!SYSTEM_DIR!\cacls.exe" !SYSTEM_CONFIG_DIR!
"!SYSTEM_DIR!\cacls.exe" !SYSTEM_CONFIG_DIR!

if '%errorlevel%' NEQ '0' (
  echo Requesting administrative privileges...
  goto :UACPrompt
) else (
  goto :elevated
)

:UACPrompt
goto :eof
    echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%TEMP%\getadmin.vbs"

    REM call here will be a mistake - need to shell
    echo getadmin.vbs created
    REM call "%TEMP%\getadmin.vbs"
"%TEMP%\getadmin.vbs"
 rem   del "%TEMP%\getadmin.vbs"
    exit /B

:elevated
pushd "%CD%"
CD /D "%~dp0"

echo Done launching elevated
pause /?
