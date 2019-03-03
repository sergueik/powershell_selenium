@echo off
setLocal ENABLEDELAYEDEXPANSION
set OUTPUT_FILE=%1

if "%OUTPUT_FILE%" equ "" set OUTPUT_FILE="bad.txt"
echo Checking the size of !OUTPUT_FILE!
for /F %%s in ('type !OUTPUT_FILE! ^| find /c /v "" ^|findstr "\^<0\^>"') do set OUTPUT_FILE_SIZE=%%s
if "!OUTPUT_FILE_SIZE!" equ "0" echo 1>&2 Warning: truncated !OUTPUT_FILE!
goto: EOF

