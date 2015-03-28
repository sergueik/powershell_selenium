Write-Host -ForegroundColor 'green' @"
This call shows Mozila Version
"@

pushd 'HKLM:'
cd '\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$app_record = Get-ChildItem . | Where-Object { $_.Name -match 'Mozilla' } | Select-Object -First 1
$app_record_fields = $app_record.GetValueNames()

if (-not ($app_record_fields.GetType().BaseType.Name -match 'Array')) {
  Write-Output 'Unexpected result type'
}
# not good for mixed types 
$results = $app_record_fields | ForEach-Object { @{ 'name' = $_; 'expression' = & { $app_record.GetValue($_) } } };

$results_lookup = @{}
$results | ForEach-Object { $results_lookup[$_.Name] = $_.expression }
popd
$fields = @()
$fields += $results_lookup.Keys
$fields | ForEach-Object { $key = $_;
  if (-not (($key -match 'DisplayVersion') -or ($key -match 'DisplayName'))) {
    $results_lookup.Remove($key)
  }
}


$results_lookup | Format-Table -AutoSize
