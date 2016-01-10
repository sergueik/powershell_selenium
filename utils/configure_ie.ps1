#Copyright (c) 2014,2015,2016 Serguei Kouzmine
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


param(
  [switch]$all # for clearing "Protected Mode" for internet "Zones" 
)


function change_registry_setting {

  param(
    [string]$hive,
    [string]$path,
    [string]$name,
    [string]$value,
    [string]$propertyType,
    # will be converted to 'Microsoft.Win32.RegistryValueKind' enumeration
    # 'String', 'ExpandString', 'Binary', 'DWord', 'MultiString', 'QWord'
    [switch]$debug

  )
  pushd $hive
  cd $path
  $local:setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
  if ($local:setting -ne $null) {
    if ([bool]$PSBoundParameters['debug'].IsPresent) {
      Select-Object -ExpandProperty $name -InputObject $local:setting
    }
    if ($local:setting -ne $value) {
      Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
    }
  } else {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType $propertyType
  }
  popd

}

Write-Host -ForegroundColor 'green' @"
This call suppresses IE updates
"@

# Works OK for WOW6432

# found  tidbit for IE 10 
# http://www.eightforums.com/tutorials/7996-internet-explorer-10-auto-update-enable-disable.html
# seems to work with IE 11 as well
# http://www.liutilities.com/products/registrybooster/tweaklibrary/tweaks/10290/

$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'EnableAutoUpgrade'
$value = '0'
$propertyType = 'Dword'

@( 'HKCU:','HKLM:') | ForEach-Object {
  $hive = $_
  change_registry_setting -hive $hive -Name $name -Value $value -PropertyType $propertyType
}

Write-Host -ForegroundColor 'green' @"
This call clears "Tell me if Internert Explorer is not the default web Browser" checkbox
"@

$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'Check_Associations'
$value = 'no'
$hive = 'HKCU:'
$propertyType = 'String'
change_registry_setting -hive $hive -Name $name -Value $value -PropertyType $propertyType


Write-Host -ForegroundColor 'green' @"
This call clears "Display intranet sites in compatibility view" checkbox.
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/BrowserEmulation'
$name = 'IntranetCompatibilityMode'
$value = '0'
$propertyType = 'Dword'

change_registry_setting -hive $hive -Name $name -Value $value -PropertyType $propertyType

Write-Host -ForegroundColor 'green' @"
This call enables "Delete browsing History on exit" - checkbox
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/ContinuousBrowsing'
$name = 'Enabled'
$value = '0'


# NOTE: keys may be absent: 
# '/Software/Microsoft/Internet Explorer/ContinuousBrowsing', '/Software/Microsoft/Internet Explorer/Privacy' 

pushd $hive
$registry_path_status = Test-Path -Path $path -ErrorAction 'SilentlyContinue'
if ($registry_path_status -eq $true) {
  cd $path
  $setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
  if ($setting -ne $null) {
    Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
  } else {
    if ($setting -ne $value) {
      New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD
    }
  }
}
popd
$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/Privacy'
$name = 'ClearBrowsingHistoryOnExit'
$value = '1'
$propertyType = 'Dword'

change_registry_setting -hive $hive -Name $name -Value $value -PropertyType $propertyType


# TODO: Ensure the subkeys under '/Software/Microsoft/Internet Explorer/DOMStorage' to be destroyed:


Write-Host -ForegroundColor 'green' @"
This call clears "Enable Protected Mode" - checkboxes - for specific internet "Zones" 
- "Restricted sites" and "Internet"
- or all 4 Zones when wun with '-all'switch 
"@

$zones = @( '4','3')

if ($PSBoundParameters["all"]) {
  # Proceed to two remaining zones
  $zones += @( '2','1')
}


$zones | ForEach-Object {

  $zone = $_
  $hive = 'HKCU:'
  $path = ('/Software/Microsoft/Windows/CurrentVersion/Internet Settings/Zones/{0}' -f $zone)
  $propertyType = 'Dword'
  $data = @{ '2500' = '3';
    '2707' = '0'
  }

  pushd $hive
  cd $path

  $description = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name 'DisplayName' -ErrorAction 'SilentlyContinue'
  if ($description -eq $null) {
    $description = '???'

  } else {
    $description = $description.DisplayName }

  Write-Host -ForegroundColor 'green' ('Configuring Zone {0} - "{1}"' -f $zone,$description)

  $data.Keys | ForEach-Object {
    $name = $_
    $value = $data.Item($name)
    Write-Host -ForegroundColor 'green' ('Writing Settings {0}' -f $name)
    change_registry_setting -hive $hive -Name $name -Value $value -PropertyType $propertyType
  }
  popd

}


Write-Host -ForegroundColor 'green' @"
This call confirms "Protected Mode is Turned Off" alert
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'NoProtectedModeBanner'
$value = '1'
$propertyType = 'Dword'

change_registry_setting -hive $hive -Name $name -Value $value -PropertyType $propertyType

Write-Host -ForegroundColor 'green' @"
This call turns off "Popup Blocker".
"@

# NOTE: The registry 'HKCU:\Software\Microsoft\Internet Explorer\New Windows' does not exist for IE 8 
$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/New Windows'
$name = 'PopupMgr'
$value = 'No'

pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
} else {
  if ($setting -ne $value) {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value

  }
}
popd


Write-Host -ForegroundColor 'green' @"
This call Enalbes full SSL / TLS  support.
"@
$settings = @{

  'all' = 2728;
  'TLS 1.0' = 128;
  'TLS 1.1' = 512;
  'TLS 1.2' = 2048;
  'SSL 2.0' = 8;
  'SSL 3.0' = 32;

}

$hive = 'HKCU:'
$path = '/Software/Microsoft/Windows/CurrentVersion/Internet Settings'
$name = 'SecureProtocols'
$value = '2728'
$propertyType = 'Dword'

change_registry_setting -hive $hive -Name $name -Value $value -PropertyType $propertyType

# http://www.sevenforums.com/tutorials/112232-internet-explorer-change-default-download-location.html
$download_directory = 'C:\windows\temp'
Write-Host -ForegroundColor 'green' @"
This call sets default IE download location to ${download_directory}
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'Default Download Directory'
$value = $download_directory
change_registry_setting -hive $hive -Name $name -Value $value -PropertyType 'String'

# http://www.sevenforums.com/tutorials/271795-internet-explorer-notify-when-downloads-complete-turn-off.html?filter=&#91;2]=Networking%20Internet
Write-Host -ForegroundColor 'green' @"
This call suppresses IE download notifications
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'NotifyDownloadComplete'
$value = 'no'
change_registry_setting -hive $hive -Name $name -Value $value -PropertyType 'String'
