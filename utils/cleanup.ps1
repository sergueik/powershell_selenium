#  origin http://www.cyberforum.ru/powershell/thread1460792.html 
Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool PostMessage(IntPtr hWnd, uint message, IntPtr wParam, IntPtr lParam);
'@ -Name 'ClassPostMessage' -Namespace Win32Functions

foreach ($process in ([Diagnostics.Process]::GetProcessesByName('chrome'))) {
  if ($process.ProcessName -eq 'chrome')
  {
    $WM_QUIT = 0x0012
    $status = [Win32Functions.ClassPostMessage]::PostMessage($process.MainWindowHandle,$WM_QUIT,[intptr]::Zero,[intptr]::Zero)
    if ($status) {
      Write-Output ('quit process name:{0} id:{1}' -f $process.ProcessName, $process.Id) 
    }
  }
}
