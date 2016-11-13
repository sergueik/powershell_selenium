<# :
  @echo off
  REM origin http://forum.oszone.net/thread-320616.html
    setlocal
      powershell /noprofile /executionpolicy bypass^
      "&{[ScriptBlock]::Create((Get-Content '%~f0') -join [Char]10).Invoke(@(&{$args}%*))}"
    endlocal
  exit /b
#>
Add-Type -AssemblyName System.Drawing

try {
  $ico = [Drawing.Icon]::ExtractAssociatedIcon($args[0])
  
  $ms = New-Object IO.MemoryStream
  $ico.Save($ms)
  [IO.File]::WriteAllBytes($args[1], $ms.ToArray())
}
catch { $_ }
finally {
  if ($ms) { $ms.Dispose() }
  if ($ico ) { $ico.Dispose() }
}