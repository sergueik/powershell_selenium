@echo OFF
REM based on http://forum.oszone.net/thread-339798.html
REM pure cmd solution:

REM can only handle UTF16 
REM can successfully convert ONLY one
REM subsequent runs corrupt the data
REM Active code page: 437
chcp 1251
REM 
set "DATADIR=%~dp0"
set FILENAME=%1
if "%FILENAME%" equ "" set "FILENAME=text_utf16.txt"
pushd "%DATADIR%"
for /f "delims=" %%. in ('dir /b/s/a-d "%FILENAME%"') do (
  chcp 1251 > nul
  CMD /U /C Type "%%." > "%%.temp"
  del "%%."
  move "%%.temp" "%%."
)
chcp 437
goto :EOF