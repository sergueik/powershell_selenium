@echo OFF 
REM Interactive way:
REM http://www.wikihow.com/Uninstall-Internet-Explorer-11-for-Windows-7

REM Comandline way
REM http://blogs.msdn.com/b/askie/archive/2014/03/28/command-line-options-available-to-uninstall-internet-explorer.aspx
(FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*11.*.mum /c "cmd /c echo C:\Windows\System32\PkgMgr.exe /up:@fname /norestart") >> uninstall.cmd
REM Modified to run commands in the same window, instead of launching the series of sibling windows waited for each
REM 
REM operation failed - asccess denied...
REM 800700005
REM 8000700b7
GOTO :EOF
REM original command:
FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*11.*.mum /c "C:\Windows\sysnative\cmd.exe /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart /l:C:\temp\IE11_uninstall
