@echo OFF 
REM http://blog.chromium.org/2011/05/remote-debugging-with-chrome-developer.html
IF "%PROCESSOR_ARCHITECTURE%"=="x86" GOTO :PATH_x86
PATH=%PATH%;%ProgramFiles(x86)%\Google\Chrome\Application
PATH=%PATH%;%ProgramFiles(x86)%\Mozilla Firefox
PATH=%PATH%;%ProgramFiles(x86)%\Internet Explorer
GOTO :END_PATH
:PATH_x86
REM Browsers are installed in WOW6432
PATH=%PATH%;%ProgramFiles%\Google\Chrome\Application
PATH=%PATH%;%ProgramFiles%\Mozilla Firefox
PATH=%PATH%;%ProgramFiles%\Internet Explorer
GOTO :END_PATH
:END_PATH

REM  http://blog.chromium.org/2011/05/remote-debugging-with-chrome-developer.html
set CUSTOM_REMOTE_PROFILe=%LOCALAPPDATA%\remote-profile
mkdir "%CUSTOM_REMOTE_PROFILe%"
pushd "%LOCALAPPDATA%"
call chrome.exe --remote-debugging-port=9222 --user-data-dir="%CUSTOM_REMOTE_PROFILe%"

REM Run the Chrome instance that you will be debugging remotely with the remote debugging command line switches
REM Navigate to the pages you intend to debug.
REM Now run a regular (client) Chrome instance and navigate to http://localhost:9222 there
