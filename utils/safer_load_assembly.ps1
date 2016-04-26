function safer_load_assembly
{
  param(
    [string]$shared_assembly_path = 'c:\developer\sergueik\csharp\SharedAssemblies',
    [string]$shared_assemby_name = ''
  )
  Write-Host -foreground 'Green' ('shared_assemby_name = "{0}"' -f $shared_assemby_name)
  try {
    $Error.Clear()
    Push-Location $shared_assembly_path
    Get-Item -Path $shared_assemby_name | ForEach-Object {
      Write-Host -ForegroundColor Yellow ('Loading "{0}"' -f $_.Name)
      $assembly = Add-Type -Path $_.FullName
    }
  } catch {
    Write-Host -foreground yellow "LoadException"
    $Error | Format-List -Force
    Write-Host -foreground red $Error[0].Exception.LoaderExceptions
  } finally {
    Pop-Location
  }
}
safer_load_assembly -shared_assemby_name 'nunit.core.dll'
Write-Host "Complete."
