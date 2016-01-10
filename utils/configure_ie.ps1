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
  [switch]$all # for degrade6_ie.ps1
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
    Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
  } else {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType $propertyType
  }

  popd


}

# Step 1  :  degrade1_ie.ps1  


Write-Host -ForegroundColor 'green' @"
This call suppresses IE updates
"@

# Works OK for WOW6432

# found  tidbit for IE 10 
# http://www.eightforums.com/tutorials/7996-internet-explorer-10-auto-update-enable-disable.html
# seems to work with IE 11 as well
# http://www.liutilities.com/products/registrybooster/tweaklibrary/tweaks/10290/

$hives = @( 'HKCU:','HKLM:')
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'EnableAutoUpgrade'
$value = '0'
$propertyType = 'Dword'

$hives | ForEach-Object {
  $hive = $_
  change_registry_setting -hive $hive -Name $name -Value $value -propertyType $propertyType # -debug
}
<#
$hives = @( 'HKCU:','HKLM:')
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'EnableAutoUpgrade'
$value = '0'
$hives | ForEach-Object {
  $hive = $_
  pushd $hive
  cd $path
  $setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
  if ($setting -ne $null) {
    Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
  } else {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD
  }
  popd
}

#>

# Step 2   degrade2_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call clears "Tell me if Internert Explorer is not the default web Browser" checkbox
"@

$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'Check_Associations'
$value = 'no'
$hive = 'HKCU:'
$propertyType = 'String'
change_registry_setting -hive $hive -Name $name -Value $value -propertyType $propertyType # -debug
<#
pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
} else {
  if (-not ($setting -match $value)) {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
  }
}
popd
#>


# Step 3  degrade3_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call clears "Display intranet sites in compatibility view" checkbox.
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/BrowserEmulation'
$name = 'IntranetCompatibilityMode'
$value = '0'
$propertyType = 'Dword'

change_registry_setting -hive $hive -Name $name -Value $value -propertyType $propertyType # -debug

<#
pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
} else {
  if ($setting -ne $value) {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD

  }
}
popd
#>

# Step 5 degrade5_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call enables "Delete browsing History on exit" - checkbox
"@



$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/ContinuousBrowsing'
$name = 'Enabled'
$value = '0'


# NOTE: script is aware that the  keys may not be present.
<#
cd : Cannot find path 'HKCU:\Software\Microsoft\Internet Explorer\ContinuousBrowsing' because it does not exist.
cd : Cannot find path 'HKCU:\Software\Microsoft\Internet Explorer\Privacy'  because it does not exist.
#>


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

change_registry_setting -hive $hive -Name $name -Value $value -propertyType $propertyType # -debug

<#
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
#>

# TODO Ensure the subkeys under the following key are expected to be destroyed:
# [/Software/Microsoft/Internet Explorer/DOMStorage]


# Step 6 degrade6_ie.ps1  
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

  Write-Output ('Configuring Zone {0} - "{1}"' -f $zone,$description)


  $data.Keys | ForEach-Object {
    $name = $_
    $value = $data.Item($name)
    Write-Output ('Writing Settings {0}' -f $name)
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

}


# Step 7 degrade7_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call confirms "Protected Mode is Turned Off - Don't show this message again" - semi-alert banner dialog.
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'NoProtectedModeBanner'
$value = '1'
$propertyType = 'Dword'

change_registry_setting -hive $hive -Name $name -Value $value -propertyType $propertyType # -debug
<#
pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
} else {
  if ($setting -ne $value) {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD

  }
}
popd
#>

# Step 7 degrade8_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call turns off "Popup Blocker".
"@

<#

With IE 8  this does not exist in the registry
This call turns off "Popup Blocker".
cd : Cannot find path 'HKCU:\Software\Microsoft\Internet Explorer\New Windows'
because it does not exist.
At C:\scripts\configure1_ie.ps1:246 char:1
#>
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

$hive = 'HKCU:'
$path = '/Software/Microsoft/Windows/CurrentVersion/Internet Settings'
$name = 'SecureProtocols'
$value = '2728'
<#
pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'

if ($setting -ne $null) {
  # write-output $setting.SecureProtocols 
  Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
} else {
  New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD
}

popd
#>
<#
 
all: 2728
Use TLS 1.0 128
Use TLS 1.1 512
Use TLS 1.2 2048
Use SSL 2.0 8
Use SSL 3.0 32 
 
#>

$propertyType = 'Dword'

change_registry_setting -hive $hive -Name $name -Value $value -propertyType $propertyType # -debug


# http://www.sevenforums.com/tutorials/112232-internet-explorer-change-default-download-location.html
$download_directory = 'C:\windows\temp'
Write-Host -ForegroundColor 'green' @"
This call sets default IE download location to ${download_directory}
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'Default Download Directory'
$value = $download_directory
change_registry_setting -hive $hive -Name $name -Value $value -propertyType 'String' # -debug

# http://www.sevenforums.com/tutorials/271795-internet-explorer-notify-when-downloads-complete-turn-off.html?filter=&#91;2]=Networking%20Internet
Write-Host -ForegroundColor 'green' @"
This call suppresses IE download notifications
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'NotifyDownloadComplete'
$value = 'no'
change_registry_setting -hive $hive -Name $name -Value $value -propertyType 'String' # -debug
