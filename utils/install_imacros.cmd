@REM 
REM This installs old IE plugin on Windows 2003 SP2 with IE8
mkdir "C:\Program Files\Ipswitch"
cd "C:\Program Files\Ipswitch"
xcopy "c:\Documents and Settings\Administrator\Desktop\Package\Ipswitch" . /s
cd "\Documents and Settings\All Users\Start Menu\Programs"
REM start menu links won't work across guests
xcopy "c:\Documents and Settings\Administrator\Desktop\Package\Start Menu\Programs\iMacros" . /s
cd "c:\Documents and Settings\Administrator\Desktop\Package"
for /F %%. in ('dir /b *.reg') do @echo %%. && reg.exe import %%.

