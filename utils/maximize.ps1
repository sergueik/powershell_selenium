# origin: http://www.cyberforum.ru/powershell/thread2441937.html

function Set-Maximized {
  [OutputType([Boolean])]
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
<#
    [ValidateScript({!!(
      $script:ps = Get-Process -Id $_ -ErrorAction 0
    ) -and $ps.MainWindowHandle -ne [IntPtr]::Zero
    })] #>
    [Int32]$Id
  )

  process {
    (Add-Type -AssemblyName System.Windows.Forms -PassThru |
    Where-Object {$_.Name -eq 'UnsafeNativeMethods'}).GetMethod(
      'PostMessage', [Type[]](
        [Runtime.InteropServices.HandleRef], [Int32], [IntPtr], [IntPtr]
      )
    ).Invoke($null, @(
      [Runtime.InteropServices.HandleRef](
      New-Object Runtime.InteropServices.HandleRef(
        (New-Object IntPtr), $ps.MainWindowHandle
      )), 0x0112, [IntPtr]0xF030, [IntPtr]::Zero
    ))
    $ps.Dispose()
  }
}
# Cannot convert null to type "System.IntPtr
# get-Process chrome* | Where-Object {$_.MainWindowHandle -ne [IntPtr]::Zero} | ForEach-Object {Set-Maximized -Id $_.Id}

# https://www.pinvoke.net/default.aspx/user32.postmessage
<#
[DllImport("user32.dll", SetLastError := true)]
class method PostMessage(hWnd: IntPtr; Msg: UInt32; wParam, lParam: IntPtr): Boolean; external;
#>

# origin http://www.cyberforum.ru/powershell/thread1460792.html
Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool PostMessage(IntPtr hWnd, uint message, IntPtr wParam, IntPtr lParam);
'@ -Name 'ClassPostMessage' -Namespace Win32Functions

$WM_MAXIMIZE = 0x0112
# get-Process chrome* | Where-Object {$_.MainWindowHandle -ne [IntPtr]::Zero}
foreach ($process in ([Diagnostics.Process]::GetProcessesByName('chrome')))  {
  if ($process.ProcessName -eq 'chrome') {
   $process = $_
    $status = [Win32Functions.ClassPostMessage]::PostMessage($process.MainWindowHandle,$WM_MAXIMIZE,[intptr]::Zero,[intptr]::Zero)
    if ($status) {
      Write-Output ('Maximize process name:{0} id:{1}' -f $process.ProcessName, $process.Id)
    }
}
}


