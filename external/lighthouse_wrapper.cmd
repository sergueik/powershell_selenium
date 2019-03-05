@REM lighthouse wrapper script
@echo off
REM https://nodejs.org/download/release/latest-v11.x/node-v11.10.1-x86.msi
setLocal ENABLEDELAYEDEXPANSION
set TIMEOUT=3
for /f "delims=" %%a in (%USERPROFILE%\Documents\NTQ\lighthouse\urlsall.txt) DO (

set "urlName=%%~NXa"
set OUTPUT_FILE=!urlName!.json
echo Output to !OUTPUT_FILE!
REM https://developers.google.com/web/tools/lighthouse/
REM lighthouse is a nodejs app, launched by a batch file with the same name
REM this could ruin the setlocal setting
REM toggle comment / Uncomment of the following lines below to Start extra process for enhanced stability
REM start /wait /min cmd /c call lighthouse.cmd --quiet --output=json --output-path=!OUTPUT_FILE! --chrome-flags="--headless" %%a
call lighthouse.cmd --quiet --output=json --output-path=!OUTPUT_FILE! --chrome-flags="--headless" %%a
REM equivalent of sleep
REM NOTE: will print to the console: Waiting for 1 seconds, press a key to continue .
timeout.exe /NOBREAK /T !TIMEOUT!
dir !OUTPUT_FILE!
REM Count the lines in output file, raise an error when empty
set BAD_FILE=empty_file.json
type NUL > !BAD_FILE!
REM set OUTPUT_FILE=!BAD_FILE!
call :MEASURE_FILE !OUTPUT_FILE!
)
goto :EOF
:MEASURE_FILE
REM based on: https://blogs.msdn.microsoft.com/oldnewthing/20110825-00/?p=9803
set FILE=%1
if NOT EXIST !FILE! echo 1>&2 Warning: Missing !FILE!
for /F %%s in ('type !FILE! ^| find /c /v "" ^|findstr "\^<0\^>"') do set FILE_SIZE=%%s
if "!FILE_SIZE!" equ "0" echo 1>&2 Warning: Truncated !FILE!
goto :EOF
