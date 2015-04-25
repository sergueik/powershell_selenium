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


<#
NOTE: This does not work with IE 8 
#>


Write-Host -ForegroundColor 'green' @"
This call shows 32-bit IE version
"@

if (-not [environment]::Is64BitProcess) {
  $path = '/SOFTWARE/Microsoft/Internet Explorer'

} else {
  $path = '/SOFTWARE/Wow6432Node/Microsoft/Internet Explorer' }

$hive = 'HKLM:'

$name = 'svcVersion'
$value = '0'


pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  $setting = $setting.svcVersion
}
popd

Write-Output $setting
write-output 'Detect Internet Explorer Developer Channel'
$hive = 'HKCU:'
$path = '/Software/Microsoft/AppV/Client/Integration/Packages/{9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1}'
$path = '/Software/Microsoft/AppV/Client/Integration/Packages'

$name = 'Integration Location'
$value = $null


pushd $hive
cd $path
$app_record = Get-ChildItem . | Where-Object { $_.Name -match '9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1' } | Select-Object -First 1
$app_record_fields = $app_record.GetValueNames()
if (-not ($app_record_fields.GetType().BaseType.Name -match 'Array')) {
  Write-Output 'Unexpected result type'
}
# not good for mixed types 
$results = $app_record_fields | ForEach-Object { @{ 'name' = $_; 'expression' = & { $app_record.GetValue($_) } } };

$results_lookup = @{}
$results | ForEach-Object { $results_lookup[$_.Name] = $_.expression }
$fields = @()
$fields += $results_lookup.Keys
$fields | ForEach-Object { $key = $_;
  if (-not ($key -match '(?:Staged|Integration) Location')) {
    $results_lookup.Remove($key)
  }
}

popd

$results_lookup | Format-Table -AutoSize

if (-not [environment]::Is64BitProcess) {
  $path = '/SOFTWARE/Microsoft/AppV/Client/Packages/9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1/Versions/681E2361-2C6F-4D47-A8B7-D3F7B288CB45/REGISTRY/MACHINE/Software/Microsoft/Internet Explorer'

} else {
# TODO:
#  $path = '/SOFTWARE/Wow6432Node/Microsoft/Internet Explorer' 
}

$hive = 'HKLM:'

$name = 'svcVersion'
$value = '0'


pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  $setting = $setting.svcVersion
}
popd

Write-Output $setting


# Detect Internet Explorer Developer Channel
# "${env:LOCALAPPDATA}\Microsoft\AppV\Client\Integration\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\Root\VFS\ProgramFiles\Internet Explorer\iexplore.exe"
# HKEY_CLASSES_ROOT\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1
# HKEY_CURRENT_USER\Software\Classes\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1
# HKEY_CURRENT_USER\Software\Microsoft\AppV\Client\Integration\Ownership\SOFTWARE\Microsoft\AppV\Client\Packages\9bd02eed-6c11-4ff0-8a3e-0b4733ee86a1
# HKEY_CURRENT_USER\Software\Microsoft\AppV\Client\Integration\Packages\{9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1}
# "Integration Location" "%LOCALAPPDATA%\Microsoft\AppV\Client\Integration\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1"
# "Staged Location" "C:\ProgramData\App-V\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\681E2361-2C6F-4D47-A8B7-D3F7B288CB45"
# HKEY_CURRENT_USER\Software\Microsoft\AppV\Client\Packages\9bd02eed-6c11-4ff0-8a3e-0b4733ee86a1\REGISTRY\USER\S-1-5-21-440999728-2294759910-2183037890-1000\Software\Microsoft\Internet Explorer
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\Versions\681E2361-2C6F-4D47-A8B7-D3F7B288CB45\REGISTRY\MACHINE\Software\Microsoft\Internet Explorer
# "svcVersion" "DC1"
# HKEY_USERS\S-1-5-21-440999728-2294759910-2183037890-1000\Software\Classes\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\REGISTRY\USER\S-1-5-21-440999728-2294759910-2183037890-1000_Classes
