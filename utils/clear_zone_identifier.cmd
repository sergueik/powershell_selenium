@echo OFF
REM origin: http://forum.oszone.net/thread-340041.html
REM see also: http://www.outsidethebox.ms/17918/#_Toc432346111
REM quick removal of zone indefier stream information
cd /D "%~1"
chcp 65001>nul
for /F "eol= tokens=1,*" %%a in ('dir /R /A:-D /-C /N ^| findStr.exe /c:"Zone.Identifier"') do (echo %%a %%b && echo.>"%%b")
REM 2 selenium-server-standalone-2.53.0.jar:Zone.Identifier:$DAT
REM 2 selenium-server-standalone-3.3.1.jar:Zone.Identifier:$DATA
