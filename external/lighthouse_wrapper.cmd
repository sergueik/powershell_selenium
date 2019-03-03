@REM lighthouse wrapper script
@echo off
@REM https://nodejs.org/download/release/latest-v11.x/node-v11.10.1-x86.msi
setLocal ENABLEDELAYEDEXPANSION
set TIMEOUT=5
for /f "delims=" %%a in (%USERPROFILE%\Documents\NTQ\lighthouse\urlsall.txt) DO (

set "urlName=%%~NXa"
set OUTPUT_FILE=!urlName!.json
echo Output to !OUTPUT_FILE!
@REM lighthouse https://developers.google.com/web/tools/lighthouse/ 
@REM itself is a nodejs app, appear to be a batch itself thus could ruin the setlocal
start /wait cmd /c call lighthouse.cmd --quiet --output=json --output-path=!OUTPUT_FILE! --chrome-flags="-headless" %%a
REM equivalent of sleep
CHOICE /T %TIMEOUT% /C ync /CS /D y
dir !OUTPUT_FILE!
REM Count the lines in output file, raise an error when empty
rem set OUTPUT_FILE="bad.txt"
for /F %%s in ('type !OUTPUT_FILE! ^| find /c /v "" ^|findstr "\^<0\^>"') do set OUTPUT_FILE_SIZE=%%s
if "!OUTPUT_FILE_SIZE!" equ "0" echo 1>&2 Warning: truncated !OUTPUT_FILE!
)

