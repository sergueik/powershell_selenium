@echo off
REM origin: https://github.com/gregzakh/sh-monsters
setlocal enabledelayedexpansion
set i=0
for %%i in (%*) do set /a "i+=1"
if %i% neq 1 goto :HELP

(echo:%~1|>nul findstr /xrc:"[0-9].*")&&(
if %~1 equ 0 goto:man
set /a "s=%~1/2+1"
w32tm /stripchart /computer:localhost /period:1 /dataonly /samples:!s!>nul
)||(
:HELP
echo Usage: %~n0 [seconds]
GOTO :EOF
)
endlocal
exit /b
