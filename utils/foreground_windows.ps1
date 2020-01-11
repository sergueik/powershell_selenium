
# https://stackoverflow.com/questions/9722252/how-can-i-get-the-current-active-window-at-the-time-a-batch-script-is-run
# see also: https://www.reddit.com/r/PowerShell/comments/2onpdm/get_active_window_titles_of_remote_comput

Add-Type -Name Utils -Namespace user32 -memberDefinition @'
  // https://www.pinvoke.net/default.aspx/user32.getactivewindow
  // https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getactivewindow
  // returs handle to active window attached to the caller's message queue
  [DllImport("user32.dll")]
  public static extern IntPtr GetActiveWindow();

  // https://www.pinvoke.net/default.aspx/user32/GetForegroundWindow.html
  // https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow
  // returs handle to window receiving input focus
  [DllImport("user32.dll")]
  public static extern IntPtr GetForegroundWindow();
'@

$handles = @{}
while ($true) {
  $handle = [user32.Utils]::GetForegroundWindow()
  # NOTE: cannot use read-host for debugging here: it switches the active window
  # $readhost = read-host ' ( anykey ) '
  start-sleep -millisecond 100
  if ( -not $handles.ContainsKey($handle)) {
    $handles = @{ $handle = $null;
    }
    $process_data = get-process | where-object { $_.mainWindowHandle -eq $handle } |
    select-object -property processName,MainWindowTItle,MainWindowHandle
    format-list -inputobject $process_data
  }
}