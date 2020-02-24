#Copyright (c) 2014-2019 Serguei Kouzmine
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

# see also: http://www.oszone.net/15060/ie9_tweaks
# https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver#required-configuration
param(
  [switch]$all # For clearing 'Protected Mode' for allInternet 'Zones'
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
  $local:setting = Get-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name $name -ErrorAction 'SilentlyContinue'
  if ($local:setting -ne $null) {
    if ([bool]$PSBoundParameters['debug'].IsPresent) {
      select-object -expandproperty $name -inputobject $local:setting
    }
    if ($local:setting -ne $value) {
      set-itemproperty -path ('{0}/{1}' -f $hive,$path) -name $name -value $value
    }
  } else {
    new-itemproperty -path ('{0}/{1}' -f $hive,$path) -name $name -value $value -propertytype $propertyType
  }
  popd

}

write-host -ForegroundColor 'green' @"
This call suppresses IE updates
"@

# Works OK for WOW6432

# found  tidbit for IE 10
# http://www.eightforums.com/tutorials/7996-internet-explorer-10-auto-update-enable-disable.html
# seems to work with IE 11 as well
# http://www.liutilities.com/products/registrybooster/tweaklibrary/tweaks/10290/

$path = '/SOFTWARE/Microsoft/Internet Explorer/Main'
$name = 'EnableAutoUpgrade'
$value = '0'
$propertyType = 'Dword'

@( 'HKCU:','HKLM:') | foreach-object {
  $hive = $_
  change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType
}

write-host -ForegroundColor 'green' @"
This call clears "Tell me if Internert Explorer is not the default web Browser" checkbox
"@

# https://www.technipages.com/ie-default-browser-prompt
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main'
$name = 'Check_Associations'
$value = 'no'
$hive = 'HKCU:'
$propertyType = 'String'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

write-host -ForegroundColor 'green' @"
This call clears "Display intranet sites in compatibility view" checkbox.
"@

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/BrowserEmulation'
$name = 'IntranetCompatibilityMode'
$value = '0'
$propertyType = 'Dword'

change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType


write-host -ForegroundColor 'green' @"
This call disables warning when multiple browser tabs is open checkbox.
"@

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/TabbedBrowsing'
$name = 'WarnOnClose'
$value = '0'
$propertyType = 'Dword'

write-host -ForegroundColor 'green' @"
These calls enable "Delete browsing History on exit" - checkbox
"@

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/ContinuousBrowsing'
$name = 'Enabled'
$value = '0'

# NOTE: keys may be absent:
# '/SOFTWARE/Microsoft/Internet Explorer/ContinuousBrowsing', '/SOFTWARE/Microsoft/Internet Explorer/Privacy'
pushd ('{0}/' -f $hive )
$registry_path_status = test-path -path $path -ErrorAction 'SilentlyContinue'
if ($registry_path_status -eq $true) {
  cd $path
  $setting = Get-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name $name ErrorAction 'SilentlyContinue'
  if ($setting -ne $null) {
    Set-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name $name -value $value
  } else {
    if ($setting -ne $value) {
      New-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name $name -value $value -PropertyType DWORD
    }
  }
}
popd
$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Privacy'
$name = 'ClearBrowsingHistoryOnExit'
$value = '1'
$propertyType = 'Dword'

change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType
# TODO: Ensure the subkeys under '/SOFTWARE/Microsoft/Internet Explorer/DOMStorage' to be destroyed:

write-host -ForegroundColor 'green' @"
This call clears 'Enable Protected Mode' checkboxes for the following internet 'Zones':
- 'Restricted sites' and 'Internet'
- when run with '-all' switch will clear for all 4 Zones
"@

$zones = @('4','3')

if ($PSBoundParameters['all']) {
  $zones += @( '2','1' , '0')
}


$zones | foreach-object {

  $zone = $_
  $hive = 'HKCU:'
  $path = ('/SOFTWARE/Microsoft/Windows/CurrentVersion/Internet Settings/Zones/{0}' -f $zone)
  $propertyType = 'Dword'
  $data = @{
    '2500' = '3';
    '2707' = '0'
  }

  pushd $hive
  cd $path

  $description = Get-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name 'DisplayName' -ErrorAction 'SilentlyContinue'
  if ($description -eq $null) {
    $description = '???'

  } else {
    $description = $description.DisplayName }

  write-host -ForegroundColor 'green' ('Configuring Zone {0} - "{1}"' -f $zone,$description)

  $data.Keys | foreach-object {
    $name = $_
    $value = $data.Item($name)
    write-host -ForegroundColor 'green' ('Writing Settings {0}' -f $name)
    change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType
  }
  popd

}
# see also: https://github.com/conceptsandtraining/modernie_selenium/blob/master/Tools/ie_protectedmode.reg

write-host -ForegroundColor 'green' @"
This call confirms 'Protected Mode is Turned Off' alert
"@

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main'
$name = 'NoProtectedModeBanner'
$value = '1'
$propertyType = 'Dword'

change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

write-host -ForegroundColor 'green' @"
This allows passing basic auth username and password through url
"@
# for current user
$hive = 'HKCU:'
# for all users
$hive = 'HKLM:'
# see also: http://forum.oszone.net/thread-339116.html (in Russian), listing them in the opposite order, probably by mistake
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main/FeatureControl/FEATURE_HTTP_USERNAME_PASSWORD_DISABLE'
$name = 'iexplore.exe'
$value = '0'
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main/FeatureControl'
$name = 'iexplore.exe'
$value = '0'
$propertyType = 'Dword'

$path_key = 'FEATURE_HTTP_USERNAME_PASSWORD_DISABLE'

# NOTE: keys may be absent:
pushd ('{0}/' -f $hive )
$registry_path_status = Test-Path -path ('{0}/{1}' -f $path, $path_key) -ErrorAction 'SilentlyContinue'
if ($registry_path_status -ne $true) {
new-item -path $path -name $path_key
}
popd
change_registry_setting -hive $hive -name $name -value $value -propertytype $propertyType -path ('{0}/{1}' -f $path, $path_key)


write-host -ForegroundColor 'green' @"
This call makes 'Allow active content to run files on My Computer'.
"@

# https://support.microsoft.com/en-us/help/2002093/allow-active-content-to-run-files-on-my-computer-group-policy-setting

$hive = 'HKLM:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main/FeatureControl/FEATURE_LOCALMACHINE_LOCKDOWN'
$name = 'iexplore.exe'
$value = '0'
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main/FeatureControl'
$name = 'iexplore.exe'
$value = '0'
$propertyType = 'Dword'

$path_key = 'FEATURE_LOCALMACHINE_LOCKDOWN'

# NOTE: keys may be absent:
pushd ('{0}/' -f $hive )
$registry_path_status = Test-Path -path ('{0}/{1}' -f $path, $path_key) -ErrorAction 'SilentlyContinue'
if ($registry_path_status -ne $true) {

new-item -path $path -name $path_key
# New-ItemProperty : Attempted to perform an unauthorized operation.
}
popd
change_registry_setting -hive $hive -name $name -value $value -propertytype $propertyType -path ('{0}/{1}' -f $path, $path_key)

write-host -ForegroundColor 'green' @"
This call removes the "Do you want to open or save this file?" prompt, though only partially.
"@

# https://9to5it.com/internet-explorer-disable-do-you-want-to-open-or-save-this-file-prompt/
# NOTE: unfinished
# TODO: combine with
# https://superuser.com/questions/246553/how-to-disable-file-download-popup-in-internet-explorer
# https://answers.microsoft.com/en-us/ie/forum/ie10-windows_7/how-can-i-disable-the-open-or-save-prompt-when-i/e490416d-7cb5-4661-9e9d-4881872ed29d

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Windows/Shell/AttachmentExecute/{0002DF01-0000-0000-C000-000000000046}'
# CompressedFolder does not work
$name = '{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}'
$value = ''
$propertyType = 'String'
# leads to change of the dialog
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

write-host -ForegroundColor 'green' @'
This call turns off Popup Blocker
'@

# NOTE: The registry 'HKCU:\Software\Microsoft\Internet Explorer\New Windows' does not exist for IE 8
$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/New Windows'
$name = 'PopupMgr'
$value = 'No'

# NOTE: keys may be absent:
pushd $hive
cd $path
$setting = Get-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  Set-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name $name -value $value
} else {
  if ($setting -ne $value) {
    New-ItemProperty -path ('{0}/{1}' -f $hive,$path) -name $name -value $value

  }
}
popd


write-host -ForegroundColor 'green' @'
This call Enables full SSL / TLS support
'@
$settings = @{

  'all' = 2728;
  'TLS 1.0' = 0x80;
  'TLS 1.1' = 0x200;
  'TLS 1.2' = 0x800;
  'SSL 2.0' = 0x08;
  'SSL 3.0' = 0x20;

}
# so e.g. TLS 1.0 + TLS 1.1 + TLS 1.2 is DWORD '0xa80'
# Alternatively, one may pass the setting on the command line:
# [System.Net.ServicePointManager]::SecurityProtocol = @('Tls12','Tls11','Tls','Ssl3')
# (Invoke-WebRequest -UseBasicParsing -Uri $url).Content
# see also: http://forum.oszone.net/thread-344128.html
$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Internet Settings'
$name = 'SecureProtocols'
$value = '2728'
$propertyType = 'Dword'

change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

# http://www.sevenforums.com/tutorials/112232-internet-explorer-change-default-download-location.html
$download_directory = 'C:\windows\temp'
write-host -ForegroundColor 'green' @"
This call sets default IE download location to ${download_directory}
"@

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main'
$name = 'Default Download Directory'
$value = $download_directory
change_registry_setting -hive $hive -name $name -path $path -value $value -PropertyType 'String'

# http://www.sevenforums.com/tutorials/271795-internet-explorer-notify-when-downloads-complete-turn-off.html?filter=&#91;2]=Networking%20Internet
write-host -ForegroundColor 'green' @'
This call suppresses IE download notifications
'@

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main'
$name = 'NotifyDownloadComplete'
$value = 'no'
change_registry_setting -hive $hive -name $name -path $path -value $value -PropertyType 'String'

write-host -ForegroundColor 'green' @'
This call applies misc. settings from
https://github.com/conceptsandtraining/modernie_selenium
'@
# IE11-only, on 64 bit Windows need to also handle
# $path = '/SOFTWARE/Wow6432Node/Microsoft/Internet Explorer/Main/FeatureControl/FEATURE_BFCACHE'
# see also https://automated-testing.info/t/internet-explorer-ne-mozhet-najti-element-na-stranicze/21972/8 (in Russian)
$hive = 'HKLM:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/MAIN/FeatureControl/FEATURE_BFCACHE'
$name = 'iexplore.exe'
$value = '0'
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Internet Explorer/Main'
$name = 'Start Page'
$value = 'about:blank'
change_registry_setting -hive $hive -name $name -path $path -value $value -PropertyType 'String'

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Internet Settings/CACHE'
$name = 'Persistent'
$value = '0'
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Internet Settings'
$name = 'SyncMode5'
$value = '3'
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Internet Settings/Url History'
$name = 'DaysToKeep'
$value = '0'
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Internet Settings/5.0/CACHE/Content'
$name = 'CacheLimit'
$value = '8192' # 0x2000
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

$hive = 'HKCU:'
$path = '/SOFTWARE/Microsoft/Windows/CurrentVersion/Internet Settings/CACHE/Content'
$name = 'CacheLimit'
$value = '8192' # 0x2000
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType

write-host -ForegroundColor 'green' @'
This sets IE9 Zoom factor
'@

# origin: https://support.microsoft.com/en-us/help/2689447/how-to-set-the-zoom-level-in-internet-explorer-9
# NOTE: the registry setting is still present with later versions of IE. May have no effect though
$path = '/SOFTWARE/Microsoft/Internet Explorer/Zoom'
$hive = 'HKCU:'
$name = 'ZoomFactor'
$value = '100000' # 0x186a0
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType
# See also: https://answers.microsoft.com/en-us/ie/forum/all/ie-11-how-do-i-get-a-default-zoom-to-stick/19510f5a-c339-45d1-b74e-edc885ef5517
# > "@C:\\Windows\\System32\\inetcpl.cpl,-4907"="Reset zoom level for new windows and tabs"
# > "ResetTextSizeOnStartup"=dword:00000000
# > "ResetZoomOnStartup2"=dword:00000001

write-host -ForegroundColor 'green' @'
This resets zoom level for new windows and tabs
'@
$path = '/SOFTWARE/Microsoft/Internet Explorer/AdvancedOptions/ACCESSIBILITY/ZOOMLEVEL'
$hive = 'HKLM:'
$name = 'CheckedValue'
$value = '1'
$propertyType = 'Dword'
change_registry_setting -hive $hive -name $name -path $path -value $value -propertytype $propertyType
# These registry settings describe "Advanced IE configuration"
# interesting that these setting contain other registry settiging, paths and values, e.g.:
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\AdvancedOptions\ACCESSIBILITY
<#
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\AdvancedOptions\ACCESSIBILITY\ZOOMLEVEL]
"UncheckedValue"=dword:00000000
"CheckedValue"=dword:00000001
"PlugUIText"="@C:\\Windows\\System32\\inetcpl.cpl,-4907"
"PlugUITextHideIE"="@C:\\Windows\\System32\\inetcpl.cpl,-6711"
"RegPath"="SOFTWARE\\Microsoft\\Internet Explorer\\Zoom"
"HKeyRoot"=dword:80000001
"HelpID"="iexplore.hlp#5990"
"DefaultValue"=dword:00000000
"TextHideIE"="Reset zoom level"
"ValueName"="ResetZoomOnStartup2"
"Text"="Reset zoom level for new windows and tabs"
"Type"="checkbox"

#>
# and there is a  matching user setting
<#
[HKEY_USERS\S-1-5-21-3828517485-1467542541-3583938822-1001\Software\Microsoft\Internet Explorer\Zoom]
"ZoomFactor"=dword:000186a0
"ResetTextSizeOnStartup"=dword:00000000
"ResetZoomOnStartup2"=dword:00000001

#>
# or
<#
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\AdvancedOptions\CRYPTO\CACHE_FLUSH]
"UncheckedValue"=dword:00000001
"CheckedValue"=dword:00000000
"PlugUIText"="@C:\\Windows\\System32\\inetcpl.cpl,-4750"
"RegPoliciesPath"="SOFTWARE\\Policies\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Cache"
"RegPath"="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Cache"
"HKeyRoot"=dword:80000001
"HelpID"="iexplore.hlp#50293"
"DefaultValue"=dword:00000001
"ValueName"="Persistent"
"Text"="Empty Temporary Internet Files folder when browser is closed"
"Type"="checkbox"
#>
# and there is a  matching user setting
<#
[HKEY_USERS\S-1-5-21-3828517485-1467542541-3583938822-1001\Software\Microsoft\Windows\CurrentVersion\Internet Settings\CACHE]
"Persistent"=dword:00002000
#>


# https://www.codeproject.com/Articles/1189642/Browser-Update-for-WebBrowser-control-in-VB-NET
# $hive = 'HKLM:'
# $path = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION'
# $name = 'Skype.exe'
# $value = '11001'
# 11001 (0x2AF9)
# Internet Explorer 11. Webpages are displayed in IE11 Standards mode, regardless of the !DOCTYPE directive.
#
# 11000 (0x2AF8)
# Internet Explorer 11. Webpages containing standards-based !DOCTYPE directives are displayed in IE9 mode.
#
# 10001 (0x2AF7)
# Internet Explorer 10. Webpages are displayed in IE10 Standards mode, regardless of the !DOCTYPE directive.
#
# 10000 (0x2710)
# Internet Explorer 10. Webpages containing standards-based !DOCTYPE directives are displayed in IE9 mode.
#
# 9999 (0x270F)
# Internet Explorer 9. Webpages are displayed in IE9 Standards mode, regardless of the !DOCTYPE directive.
#
# 9000 (0x2328)
# Internet Explorer 9. Webpages containing standards-based !DOCTYPE directives are displayed in IE9 mode.
#
# 8888 (0x22B8)
# Webpages are displayed in IE8 Standards mode, regardless of the !DOCTYPE directive.
#
# 8000 (0x1F40)
# Webpages containing standards-based !DOCTYPE directives are displayed in IE8 mode.
#
# 7000 (0x1B58)
# Webpages containing standards-based !DOCTYPE directives are displayed in IE7 Standards mode.

