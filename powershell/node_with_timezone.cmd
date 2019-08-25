@echo OFF
REM http://winitpro.ru/index.php/2014/09/08/smena-chasovogo-poyasa-v-windows-iz-komandnoj-stroki/
REM see also: https://www.windows-commandline.com/set-time-zone-from-command-line/
tzutil.exe /s "Pacific Standard Time"
REM the path already has  the backslash
echo call %~dp0node.cmd %1 %2 %3 %4 %5 %6 %7
call %~dp0node.cmd %1 %2 %3 %4 %5 %6 %7
pause
