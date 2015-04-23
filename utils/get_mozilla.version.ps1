#Copyright (c) 2014,2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
# $DebugPreference = 'Continue'

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
