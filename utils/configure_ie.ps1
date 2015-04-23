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


param(
  [switch]$all # for degrade6_ie.ps1
)

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



# Step 2   degrade2_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call clears "Tell me if Internert Explorer is not the default web Browser" checkbox
"@

$path = '/Software/Microsoft/Internet Explorer/Main'
$name = 'Check_Associations'
$value = 'no'
$hive = 'HKCU:'
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


 
# Step 3  degrade3_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call clears "Display intranet sites in compatibility view" checkbox.
"@

$hive = 'HKCU:'
$path = '/Software/Microsoft/Internet Explorer/BrowserEmulation'
$name = 'IntranetCompatibilityMode'
$value = '0'

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

 
# Step 4  degrade4_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This s cript is a stub. The
"Protected Mode is Turned Off - Don't show this message again" - semi-alert banner dialog.
is now done in 'degrade6_ie.ps1' 
"@
 
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

# TODO Ensure the subkeys under the following key are excpected to be destroyed:
# [HKEY_CURRENT_USER/Software/Microsoft/Internet Explorer/DOMStorage]

 
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

# Step 7 degrade8_ie.ps1  
Write-Host -ForegroundColor 'green' @"
This call turns off "Popup Blocker".
"@

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
