$debug = $true
$cnt = 0
$status_confirmed = $false
while (($cnt -lt 3) -and (-not $status_confirmed)) {

  $result = Invoke-Expression -Command 'netsh winhttp show proxy'
  if ($result -match 'Direct access') {
    Write-Output 'confirmed direct access'
    if ($debug) {
      Write-Output $result
    }
    $status_confirmed = $true
  } else {
    Write-Output 'unexpected result:'
    if ($debug) {
      Write-Output $result
    }
    $command = @"
[void](invoke-expression -command 'netsh winhttp reset proxy')
"@
    $cnt = $cnt + 1
    Write-Output ("Running command : `n{0}" -f $command)

  }
}
