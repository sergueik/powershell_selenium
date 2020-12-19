# based on https://social.technet.microsoft.com/Forums/en-US/4d257c80-557a-4625-aad3-f2aac6e9a1bd/get-active-window-info?forum=winserverpowershell
param(
  [int]$sleep = 10
)
start-sleep -second $sleep
add-type -name Utils -namespace Win32 -memberdefinition @'
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
'@
$windowHandle = [Win32.Utils]::GetForegroundWindow()
get-process | where-object { $_.mainWindowHandle -eq $windowHandle } |
  select-object -property processName, MainWindowTItle, MainWindowHandle
<#

Option Explicit
' NOTE: quite restrictive
on error resume next
Dim args: Set args = WScript.Arguments.Unnamed
if args.count = 0 then
  WScript.echo "No active windod handle ? "
  ' wscript.quit(1)
end if
Dim i
For i = 0 to args.count -1
  wscript.Echo "Argument " & i & " = " & args.item(i)
Next
Dim activeWindowHandle: activeWindowHandle = 0 + args.Item(0)
WScript.Sleep 1000
Dim objShellApplication: set objShellApplication = WScript.CreateObject("Shell.Application")
if err <> 0 then
  wscript.echo "Error: " & err.number & vbcrlf & err.description
  ' wscript.quit(2)
else
  wScript.echo "Filtering by Active window handle " & activeWindowHandle
end if

Dim objShellWindows
Set objShellWindows = objShellApplication.Windows()
if objShellWindows is nothing then
  wscript.echo "No active desktop? "
  wscript.quit(3)
else
  wscript.echo "enumerating...."
end if
On Error Goto 0
Dim handle
Dim objWindow
For Each objWindow In objShellApplication.Windows()
  handle = objWindow.hwnd
 ' wscript.echo "Checking Handle: " & handle
 ' wscript.echo "Active window handle " & activeWindowHandle
  if activeWindowHandle = handle Then
    wscript.echo "Found Active browser window: " & objWindow.Path
  end if
next

#>
