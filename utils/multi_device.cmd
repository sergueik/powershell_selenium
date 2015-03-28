@echo OFF

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
PATH=%PATH%;%LOCALAPPDATA%\Mozilla Firefox

where.exe firefox.exe
where.exe chrome.exe
where.exe iexplore.exe
CHOICE /T 1 /C ync /CS /D y


goto :START
REM http://kb.mozillazine.org/Opening_a_new_instance_of_Firefox_with_another_profile
REM http://stackoverflow.com/questions/7336246/adjust-the-size-of-the-browser-window-when-starting-firefox
%AppData%\Roaming\Mozilla\Firefox\Profiles

        0zn9djdu.channel_03
        6us7lrj6.Selenium
        dy0p9zio.channel_04
        ltl3sy0x.channel_01
        wfywwbuv.default
        x1ew92v3.channel_02

pudhd %appdata%\Mozilla\Firefox\Profiles
popd
:START
start cmd /c "c:\Program Files\Mozilla Firefox\firefox.exe" -no-remote -width 650 -height 350 -P channel_01 
start cmd /c "c:\Program Files\Mozilla Firefox\firefox.exe" -no-remote -width 650 -height 350 -P channel_02 
start cmd /c "c:\Program Files\Mozilla Firefox\firefox.exe" -no-remote -width 650 -height 350 -P channel_03
start cmd /c "c:\Program Files\Mozilla Firefox\firefox.exe" -no-remote -width 650 -height 350 -P channel_04


REM geometry arguments do not work.
REM use Selenium to position seems to be an easy option
REM wmctrl analog for win32 : p/invoke
REM http://www.pinvoke.net/default.aspx/user32.setwindowpos
REM http://msdn.microsoft.com/en-us/library/ms633545%28VS.85%29.aspx
REM http://stackoverflow.com/questions/3032246/c-sharp-opening-process-and-changing-window-position
