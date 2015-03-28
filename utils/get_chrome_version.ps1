Write-Host -ForegroundColor 'green' @"
This call shows Chrome Version
"@


if (-not [environment]::Is64BitProcess) {
  $path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/Google Chrome'
} else {
  $path = '/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall/Google Chrome'
}

$hive = 'HKLM:'
[string]$name = $null
pushd $hive
cd $path
$fields = @( 'DisplayName','Version','UninstallString')
$fields | ForEach-Object {
  $name = $_
  # write-output $name
  $result = Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)
  # $result

  # $result.ToString()
  [string]$DisplayName = $null
  [string]$Version = $null
  try {
    $Version = $result.Version
    $DisplayName = $result.DisplayName
    $UninstallString = $result.UninstallString
  } catch [exception]{

  }
  if (($DisplayName -ne $null) -and ($DisplayName -ne '')) {
    Write-Output ('DisplayName :  {0}' -f $DisplayName)
  }
  if (($Version -ne $null) -and ($Version -ne '')) {
    Write-Output ('Version :  {0}' -f $Version)
  }
  if (($UninstallString -ne $null) -and ($UninstallString -ne '')) {
    Write-Output ('UninstallString :  {0}' -f $UninstallString)
  }

}
popd


