@echo off
REM origin: https://github.com/gregzakh/sh-monsters
REM a silent alternative to C:\Windows\System32\choice.exe /T ...
setlocal enabledelayedexpansion
set i=0
for %%i in (%*) do set /a "i+=1"
if %i% neq 1 goto :HELP
if %~1 equ 0 goto :HELP
echo %~1| findstr.exe /rc:"[^0-9]" >nul
if ERRORLEVEL 1 goto :RUN
:HELP
echo Usage: %~n0 [seconds]
GOTO :EOF
:RUN
set /a "s=%~1/2+1"
w32tm.exe /stripchart /computer:localhost /period:1 /dataonly /samples:!s!>nul
GOTO :EOF
endlocal
exit /b
