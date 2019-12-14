@echo OFF
REM based on https://stackoverflow.com/questions/30534273/simple-inputbox-function
REM NOTE: the following will not work
REM set RESULT=
REM powershell.exe -command "& {param($title, $message)[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic'); $text = [Microsoft.VisualBasic.Interaction]::InputBox($message, $title); [System.Environment]::SetEnvironmentVariable('RESULT',$text ,[System.EnvironmentVariableTarget]::User) }" test message
REM echo RESULT=%RESULT%
REM the changes in environment will disappear
for /F "usebackq" %%_ in (`powershell.exe -command "& {param($title, $message)[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic'); $text = [Microsoft.VisualBasic.Interaction]::InputBox($message, $title); write-output $text}" test message`) do echo %%_
REM 
REM see also: https://ss64.com/vb/inputbox.html
REM https://gerrywilliams.net/2016/12/ps-gui-commands/
REM https://jdhitsolutions.com/blog/powershell/5816/a-powershell-input-tool/
