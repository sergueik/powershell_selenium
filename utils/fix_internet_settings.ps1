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
  [switch]$quick
)


Write-Host -ForegroundColor 'green' @"
This script disables automatic LAN  Setting detection and automatic 
and adds proxy address and proxy exceptions
"@

# To verify the quickest is to type in cmd window (but not in Powershell console)
# inetcpl.cpl,4
# http://msdn.microsoft.com/en-us/library/windows/desktop/cc144191(v=vs.85).aspx 
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}



if (-not $PSBoundParameters['quick']) {
  # Import registry fragment 
  $command = ('reg.exe import {0}' -f ('{0}\{1}' -f (Get-ScriptDirectory),'4.reg'))

  Write-Output "Running the command : ${command}"

  $tool_execution_status = Invoke-Expression -Command $command

  Write-Output $tool_execution_status

}


$hive = 'HKCU:'
$path = '/Software/Microsoft/Windows/CurrentVersion/Internet Settings'

$name = 'ProxyEnable'
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


$name = 'ProxyServer'
$value = 'proxy.carnival.com:8080'
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


$name = 'ProxyOverride'
$value = 'localhost;127.0.0.1;www1.syscarnival.com;secure1.syscarnival.com;www2.syscarnival.com;secure2.syscarnival.com;www3.syscarnival.com;secure3.syscarnival.com;www4.syscarnival.com;secure4.syscarnival.com;www1.uatcarnival.com;secure1.uatcarnival.com;www2.uatcarnival.com;secure2.uatcarnival.com;www3.uatcarnival.com;secure3.uatcarnival.com;www4.uatcarnival.com;secure4.uatcarnival.com;*.carnivalcorp.com;*.carnivalcruises.com;*.carnivalmeetings.com;*.bookccl.com;10.*.*.*;192.168.*.*;172.30.*.*;172.25.*.*;172.26.*.*;172.17.*.*;172.16.*.*;172.18.*.*;172.31.*.*;172.19.*.*;172.22.*.*;*.pcb;*.hq.halw.com;*.funships.com;*.costa.it;*.hal.com;*.pcb.com;*.carnivalmaritime.com;*.carnivalplc.com;*.poprincess.com;*.carnivaluk.com;navigator.carnivalaustralia.com;*.cruises.princess.com;*.cclinternet.com;*.princess.com;172.28.121.*;*.carnivalgroup.com;www.goccl.com;goccl3.uatcarnival.com;funpass.carnival.com;*.carnival.com;*.*carnival.com;uk1.uatcarnival.com;uk2.uatcarnival.com;uk3.uatcarnival.com;uk4.uatcarnival.com;*.carnival.co.uk;*.carnivalgiftcards.com;<local>'
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


pushd $hive
cd $path

$name = 'AutoConfigURL'
Remove-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
popd

<#
Write-Host -ForegroundColor 'Yellow' @"
You still need to run the scripts:

.\degrade6_ie.ps1
.\degrade7_ie.ps1

"@

#>

$proxy_manual_reg = @"
REGEDIT4

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings]
"IE5_UA_Backup_Flag"="5.0"
"User Agent"="Mozilla/4.0 (compatible; MSIE 8.0; Win32)"
"EmailName"="User@"
"PrivDiscUiShown"=dword:00000001
"EnableHttp1_1"=dword:00000001
"WarnOnIntranet"=dword:00000001
"MimeExclusionListForCache"="multipart/mixed multipart/x-mixed-replace multipart/x-byteranges "
"AutoConfigProxy"="wininet.dll"
"UseSchannelDirectly"=hex:01,00,00,00
"PrivacyAdvanced"=dword:00000000
"ProxyEnable"=dword:00000001
"EnableNegotiate"=dword:00000001
"MigrateProxy"=dword:00000001
"WarnOnPost"=hex:01,00,00,00
"UrlEncoding"=dword:00000000
"SecureProtocols"=dword:00000aa0
"ZonesSecurityUpgrade"=hex:84,65,ce,a0,47,b2,cf,01
"DisableCachingOfSSLPages"=dword:00000000
"WarnonZoneCrossing"=dword:00000000
"CertificateRevocation"=dword:00000001
"ProxyHttp1.1"=dword:00000001
"ShowPunycode"=dword:00000000
"EnablePunycode"=dword:00000001
"DisableIDNPrompt"=dword:00000000
"WarnonBadCertRecving"=dword:00000001
"WarnOnPostRedirect"=dword:00000001
"GlobalUserOffline"=dword:00000000
"EnableAutodial"=dword:00000000
"NoNetAutodial"=dword:00000000
"BackgroundConnections"=dword:00000001
"CreateUriCacheSize"=dword:00000050
"CoInternetCombineIUriCacheSize"=dword:00000050
"SecurityIdIUriCacheSize"=dword:0000001e
"SpecialFoldersCacheSize"=dword:00000008
"ProxyServer"="proxy.carnival.com:8080"
"ProxyOverride"="localhost;127.0.0.1;www1.syscarnival.com;secure1.syscarnival.com;www2.syscarnival.com;secure2.syscarnival.com;www3.syscarnival.com;secure3.syscarnival.com;www4.syscarnival.com;secure4.syscarnival.com;www1.uatcarnival.com;secure1.uatcarnival.com;www2.uatcarnival.com;secure2.uatcarnival.com;www3.uatcarnival.com;secure3.uatcarnival.com;www4.uatcarnival.com;secure4.uatcarnival.com;*.carnivalcorp.com;*.carnivalcruises.com;*.carnivalmeetings.com;*.bookccl.com;10.*.*.*;192.168.*.*;172.30.*.*;172.25.*.*;172.26.*.*;172.17.*.*;172.16.*.*;172.18.*.*;172.31.*.*;172.19.*.*;172.22.*.*;*.pcb;*.hq.halw.com;*.funships.com;*.costa.it;*.hal.com;*.pcb.com;*.carnivalmaritime.com;*.carnivalplc.com;*.poprincess.com;*.carnivaluk.com;navigator.carnivalaustralia.com;*.cruises.princess.com;*.cclinternet.com;*.princess.com;172.28.121.*;*.carnivalgroup.com;www.goccl.com;goccl3.uatcarnival.com;funpass.carnival.com;*.carnival.com;*.*carnival.com;uk1.uatcarnival.com;uk2.uatcarnival.com;uk3.uatcarnival.com;uk4.uatcarnival.com;*.carnival.co.uk;*.carnivalgiftcards.com;<local>"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache]
"Signature"="Client UrlCache MMF Ver 5.2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content]
"CachePrefix"=""
"CacheLimit"=dword:0003e800

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Cookies]
"CachePrefix"="Cookie:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\DOMStore]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,49,6e,74,65,72,6e,65,\
  74,20,45,78,70,6c,6f,72,65,72,5c,44,4f,4d,53,74,6f,72,65,00
"CachePrefix"="DOMStore"
"CacheLimit"=dword:000003e8
"CacheOptions"=dword:00000008
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\feedplat]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,46,65,65,64,73,20,43,\
  61,63,68,65,00
"CachePrefix"="feedplat:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000000
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\iecompat]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,43,6f,6d,70,61,74,43,61,63,68,65,00
"CachePrefix"="iecompat:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\iedownload]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,44,6f,77,6e,6c,6f,61,64,48,69,73,74,6f,72,79,\
  00
"CachePrefix"="iedownload:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014090120140908]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,30,31,32,30,31,34,30,39,30,38,00
"CachePrefix"=":2014090120140908: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014090820140915]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,30,38,32,30,31,34,30,39,31,35,00
"CachePrefix"=":2014090820140915: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014091520140922]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,31,35,32,30,31,34,30,39,32,32,00
"CachePrefix"=":2014091520140922: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014092220140923]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,32,32,32,30,31,34,30,39,32,33,00
"CachePrefix"=":2014092220140923: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014092320140924]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,32,33,32,30,31,34,30,39,32,34,00
"CachePrefix"=":2014092320140924: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014092420140925]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,32,34,32,30,31,34,30,39,32,35,00
"CachePrefix"=":2014092420140925: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\PrivacIE:]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,50,72,69,76,61,63,49,45,00
"CachePrefix"="PrivacIE:"
"CacheLimit"=dword:00000400
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\History]
"CachePrefix"="Visited:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache]
"Signature"="Client UrlCache MMF Ver 5.2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Content]
"CachePrefix"=""
"CacheLimit"=dword:0003e800

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Cookies]
"CachePrefix"="Cookie:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\DOMStore]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,4c,6f,77,5c,4d,69,63,72,6f,73,6f,66,74,5c,49,6e,74,65,\
  72,6e,65,74,20,45,78,70,6c,6f,72,65,72,5c,44,4f,4d,53,74,6f,72,65,00
"CachePrefix"="DOMStore"
"CacheLimit"=dword:000003e8
"CacheOptions"=dword:00000008
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\EmieSiteList]
"CachePrefix"="EmieSiteList:"
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,4c,6f,77,5c,45,6d,69,65,53,69,74,65,4c,69,73,74,00
"CacheOptions"=dword:00000300
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\EmieUserList]
"CachePrefix"="EmieUserList:"
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,4c,6f,77,5c,45,6d,69,65,55,73,65,72,4c,69,73,74,00
"CacheOptions"=dword:00000300
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\feedplat]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,46,65,65,64,73,20,43,\
  61,63,68,65,00
"CachePrefix"="feedplat:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000000
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\iecompat]
"CachePrefix"="iecompat:"
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,43,6f,6d,70,61,74,43,61,63,68,65,5c,4c,6f,77,\
  00
"CacheOptions"=dword:00000309
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\iecompatua]
"CachePrefix"="iecompatua:"
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,69,65,63,6f,6d,70,61,74,75,61,43,61,63,68,65,5c,4c,\
  6f,77,00
"CacheOptions"=dword:00000309
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\iedownload]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,44,6f,77,6e,6c,6f,61,64,48,69,73,74,6f,72,79,\
  00
"CachePrefix"="iedownload:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\ietld]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,54,6c,64,43,61,63,68,65,5c,4c,6f,77,00
"CachePrefix"="ietld:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\PrivacIE:]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,50,72,69,76,61,63,49,45,5c,4c,6f,77,00
"CachePrefix"="PrivacIE:"
"CacheLimit"=dword:00000400
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\History]
"CachePrefix"="Visited:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\NSCookieUpgrade]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\User Agent]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\User Agent\Post Platform]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Activities]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\CACHE]
"Persistent"=dword:00000000
"LastScavenge"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections]
"DefaultConnectionSettings"=hex:46,00,00,00,8b,04,00,00,03,00,00,00,17,00,00,\
  00,70,72,6f,78,79,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3a,38,30,38,30,19,\
  04,00,00,6c,6f,63,61,6c,68,6f,73,74,3b,31,32,37,2e,30,2e,30,2e,31,3b,77,77,\
  77,31,2e,73,79,73,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,\
  31,2e,73,79,73,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,32,2e,73,79,\
  73,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,32,2e,73,79,73,\
  63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,33,2e,73,79,73,63,61,72,6e,\
  69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,33,2e,73,79,73,63,61,72,6e,69,\
  76,61,6c,2e,63,6f,6d,3b,77,77,77,34,2e,73,79,73,63,61,72,6e,69,76,61,6c,2e,\
  63,6f,6d,3b,73,65,63,75,72,65,34,2e,73,79,73,63,61,72,6e,69,76,61,6c,2e,63,\
  6f,6d,3b,77,77,77,31,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,\
  65,63,75,72,65,31,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,\
  77,32,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,\
  32,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,33,2e,75,61,\
  74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,33,2e,75,61,74,\
  63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,34,2e,75,61,74,63,61,72,6e,\
  69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,34,2e,75,61,74,63,61,72,6e,69,\
  76,61,6c,2e,63,6f,6d,3b,2a,2e,63,61,72,6e,69,76,61,6c,63,6f,72,70,2e,63,6f,\
  6d,3b,2a,2e,63,61,72,6e,69,76,61,6c,63,72,75,69,73,65,73,2e,63,6f,6d,3b,2a,\
  2e,63,61,72,6e,69,76,61,6c,6d,65,65,74,69,6e,67,73,2e,63,6f,6d,3b,2a,2e,62,\
  6f,6f,6b,63,63,6c,2e,63,6f,6d,3b,31,30,2e,2a,2e,2a,2e,2a,3b,31,39,32,2e,31,\
  36,38,2e,2a,2e,2a,3b,31,37,32,2e,33,30,2e,2a,2e,2a,3b,31,37,32,2e,32,35,2e,\
  2a,2e,2a,3b,31,37,32,2e,32,36,2e,2a,2e,2a,3b,31,37,32,2e,31,37,2e,2a,2e,2a,\
  3b,31,37,32,2e,31,36,2e,2a,2e,2a,3b,31,37,32,2e,31,38,2e,2a,2e,2a,3b,31,37,\
  32,2e,33,31,2e,2a,2e,2a,3b,31,37,32,2e,31,39,2e,2a,2e,2a,3b,31,37,32,2e,32,\
  32,2e,2a,2e,2a,3b,2a,2e,70,63,62,3b,2a,2e,68,71,2e,68,61,6c,77,2e,63,6f,6d,\
  3b,2a,2e,66,75,6e,73,68,69,70,73,2e,63,6f,6d,3b,2a,2e,63,6f,73,74,61,2e,69,\
  74,3b,2a,2e,68,61,6c,2e,63,6f,6d,3b,2a,2e,70,63,62,2e,63,6f,6d,3b,2a,2e,63,\
  61,72,6e,69,76,61,6c,6d,61,72,69,74,69,6d,65,2e,63,6f,6d,3b,2a,2e,63,61,72,\
  6e,69,76,61,6c,70,6c,63,2e,63,6f,6d,3b,2a,2e,70,6f,70,72,69,6e,63,65,73,73,\
  2e,63,6f,6d,3b,2a,2e,63,61,72,6e,69,76,61,6c,75,6b,2e,63,6f,6d,3b,6e,61,76,\
  69,67,61,74,6f,72,2e,63,61,72,6e,69,76,61,6c,61,75,73,74,72,61,6c,69,61,2e,\
  63,6f,6d,3b,2a,2e,63,72,75,69,73,65,73,2e,70,72,69,6e,63,65,73,73,2e,63,6f,\
  6d,3b,2a,2e,63,63,6c,69,6e,74,65,72,6e,65,74,2e,63,6f,6d,3b,2a,2e,70,72,69,\
  6e,63,65,73,73,2e,63,6f,6d,3b,31,37,32,2e,32,38,2e,31,32,31,2e,2a,3b,2a,2e,\
  63,61,72,6e,69,76,61,6c,67,72,6f,75,70,2e,63,6f,6d,3b,77,77,77,2e,67,6f,63,\
  63,6c,2e,63,6f,6d,3b,67,6f,63,63,6c,33,2e,75,61,74,63,61,72,6e,69,76,61,6c,\
  2e,63,6f,6d,3b,66,75,6e,70,61,73,73,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,\
  3b,2a,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,2a,2e,2a,63,61,72,6e,69,76,\
  61,6c,2e,63,6f,6d,3b,75,6b,31,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,\
  6d,3b,75,6b,32,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,75,6b,33,\
  2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,75,6b,34,2e,75,61,74,63,\
  61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,2a,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,\
  2e,75,6b,3b,2a,2e,63,61,72,6e,69,76,61,6c,67,69,66,74,63,61,72,64,73,2e,63,\
  6f,6d,3b,00,00,00,68,74,74,70,3a,2f,2f,70,72,6f,78,79,2e,63,61,72,6e,69,76,\
  61,6c,2e,63,6f,6d,3a,38,30,38,30,2f,61,72,72,61,79,2e,64,6c,6c,3f,47,65,74,\
  2e,52,6f,75,74,69,6e,67,2e,53,63,72,69,70,74,01,00,00,00,27,00,00,00,68,74,\
  74,70,3a,2f,2f,70,72,6f,78,79,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3a,38,\
  30,38,30,2f,77,70,61,64,2e,64,61,74,0f,e1,e9,0a,04,d8,cf,01,00,00,00,00,00,\
  00,00,00,00,00,00,00,03,00,00,00,02,00,00,00,0a,f0,8c,0b,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,c0,a8,38,01,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,0a,f0,d0,aa,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"SavedLegacySettings"=hex:46,00,00,00,99,0a,00,00,03,00,00,00,17,00,00,00,70,\
  72,6f,78,79,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3a,38,30,38,30,19,04,00,\
  00,6c,6f,63,61,6c,68,6f,73,74,3b,31,32,37,2e,30,2e,30,2e,31,3b,77,77,77,31,\
  2e,73,79,73,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,31,2e,\
  73,79,73,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,32,2e,73,79,73,63,\
  61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,32,2e,73,79,73,63,61,\
  72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,33,2e,73,79,73,63,61,72,6e,69,76,\
  61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,33,2e,73,79,73,63,61,72,6e,69,76,61,\
  6c,2e,63,6f,6d,3b,77,77,77,34,2e,73,79,73,63,61,72,6e,69,76,61,6c,2e,63,6f,\
  6d,3b,73,65,63,75,72,65,34,2e,73,79,73,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,\
  3b,77,77,77,31,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,\
  75,72,65,31,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,32,\
  2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,32,2e,\
  75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,33,2e,75,61,74,63,\
  61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,33,2e,75,61,74,63,61,\
  72,6e,69,76,61,6c,2e,63,6f,6d,3b,77,77,77,34,2e,75,61,74,63,61,72,6e,69,76,\
  61,6c,2e,63,6f,6d,3b,73,65,63,75,72,65,34,2e,75,61,74,63,61,72,6e,69,76,61,\
  6c,2e,63,6f,6d,3b,2a,2e,63,61,72,6e,69,76,61,6c,63,6f,72,70,2e,63,6f,6d,3b,\
  2a,2e,63,61,72,6e,69,76,61,6c,63,72,75,69,73,65,73,2e,63,6f,6d,3b,2a,2e,63,\
  61,72,6e,69,76,61,6c,6d,65,65,74,69,6e,67,73,2e,63,6f,6d,3b,2a,2e,62,6f,6f,\
  6b,63,63,6c,2e,63,6f,6d,3b,31,30,2e,2a,2e,2a,2e,2a,3b,31,39,32,2e,31,36,38,\
  2e,2a,2e,2a,3b,31,37,32,2e,33,30,2e,2a,2e,2a,3b,31,37,32,2e,32,35,2e,2a,2e,\
  2a,3b,31,37,32,2e,32,36,2e,2a,2e,2a,3b,31,37,32,2e,31,37,2e,2a,2e,2a,3b,31,\
  37,32,2e,31,36,2e,2a,2e,2a,3b,31,37,32,2e,31,38,2e,2a,2e,2a,3b,31,37,32,2e,\
  33,31,2e,2a,2e,2a,3b,31,37,32,2e,31,39,2e,2a,2e,2a,3b,31,37,32,2e,32,32,2e,\
  2a,2e,2a,3b,2a,2e,70,63,62,3b,2a,2e,68,71,2e,68,61,6c,77,2e,63,6f,6d,3b,2a,\
  2e,66,75,6e,73,68,69,70,73,2e,63,6f,6d,3b,2a,2e,63,6f,73,74,61,2e,69,74,3b,\
  2a,2e,68,61,6c,2e,63,6f,6d,3b,2a,2e,70,63,62,2e,63,6f,6d,3b,2a,2e,63,61,72,\
  6e,69,76,61,6c,6d,61,72,69,74,69,6d,65,2e,63,6f,6d,3b,2a,2e,63,61,72,6e,69,\
  76,61,6c,70,6c,63,2e,63,6f,6d,3b,2a,2e,70,6f,70,72,69,6e,63,65,73,73,2e,63,\
  6f,6d,3b,2a,2e,63,61,72,6e,69,76,61,6c,75,6b,2e,63,6f,6d,3b,6e,61,76,69,67,\
  61,74,6f,72,2e,63,61,72,6e,69,76,61,6c,61,75,73,74,72,61,6c,69,61,2e,63,6f,\
  6d,3b,2a,2e,63,72,75,69,73,65,73,2e,70,72,69,6e,63,65,73,73,2e,63,6f,6d,3b,\
  2a,2e,63,63,6c,69,6e,74,65,72,6e,65,74,2e,63,6f,6d,3b,2a,2e,70,72,69,6e,63,\
  65,73,73,2e,63,6f,6d,3b,31,37,32,2e,32,38,2e,31,32,31,2e,2a,3b,2a,2e,63,61,\
  72,6e,69,76,61,6c,67,72,6f,75,70,2e,63,6f,6d,3b,77,77,77,2e,67,6f,63,63,6c,\
  2e,63,6f,6d,3b,67,6f,63,63,6c,33,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,\
  6f,6d,3b,66,75,6e,70,61,73,73,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,2a,\
  2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,2a,2e,2a,63,61,72,6e,69,76,61,6c,\
  2e,63,6f,6d,3b,75,6b,31,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,\
  75,6b,32,2e,75,61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,75,6b,33,2e,75,\
  61,74,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3b,75,6b,34,2e,75,61,74,63,61,72,\
  6e,69,76,61,6c,2e,63,6f,6d,3b,2a,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,2e,75,\
  6b,3b,2a,2e,63,61,72,6e,69,76,61,6c,67,69,66,74,63,61,72,64,73,2e,63,6f,6d,\
  3b,00,00,00,68,74,74,70,3a,2f,2f,70,72,6f,78,79,2e,63,61,72,6e,69,76,61,6c,\
  2e,63,6f,6d,3a,38,30,38,30,2f,61,72,72,61,79,2e,64,6c,6c,3f,47,65,74,2e,52,\
  6f,75,74,69,6e,67,2e,53,63,72,69,70,74,01,00,00,00,27,00,00,00,68,74,74,70,\
  3a,2f,2f,70,72,6f,78,79,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3a,38,30,38,\
  30,2f,77,70,61,64,2e,64,61,74,0f,e1,e9,0a,04,d8,cf,01,00,00,00,00,00,00,00,\
  00,00,00,00,00,03,00,00,00,02,00,00,00,0a,f0,8c,0b,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,c0,a8,38,01,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,0a,f0,d0,aa,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Http Filters]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\0]
@=""
"DisplayName"="Computer"
"PMDisplayName"="Computer [Protected Mode]"
"Description"="Your computer"
"Icon"="shell32.dll#0016"
"LowIcon"="inetcpl.cpl#005422"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000000
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000000
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000003
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000000
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1812"=dword:00000000
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000003
"2701"=dword:00000003
"2702"=dword:00000003
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\1]
@=""
"DisplayName"="Local intranet"
"PMDisplayName"="Local intranet [Protected Mode]"
"Description"="This zone contains all Web sites that are on your organization's intranet."
"Icon"="shell32.dll#0018"
"LowIcon"="inetcpl.cpl#005423"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000143
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000001
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000000
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000001
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000003
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1812"=dword:00000000
"1A00"=dword:00020000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000003
"2703"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\2]
@=""
"DisplayName"="Trusted sites"
"PMDisplayName"="Trusted sites [Protected Mode]"
"Description"="This zone contains Web sites that you trust not to damage your computer or data."
"Icon"="inetcpl.cpl#00004480"
"LowIcon"="inetcpl.cpl#005424"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000000
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000000
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1812"=dword:00000000
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000001
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000003
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000000
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000000
"2701"=dword:00000000
"2702"=dword:00000000
"2703"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\3]
@=""
"DisplayName"="Internet"
"PMDisplayName"="Internet [Protected Mode]"
"Description"="This zone contains all Web sites you haven't placed in other zones"
"Icon"="inetcpl.cpl#001313"
"LowIcon"="inetcpl.cpl#005425"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000001
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000003
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000003
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000000
"1601"=dword:00000001
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000001
"1806"=dword:00000001
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"1812"=dword:00000001
"1A00"=dword:00020000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000001
"1A06"=dword:00000000
"1A10"=dword:00000001
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000003
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001
"2301"=dword:00000000
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000000
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000000
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\4]
@=""
"DisplayName"="Restricted sites"
"PMDisplayName"="Restricted sites [Protected Mode]"
"Description"="This zone contains Web sites that could potentially damage your computer or data."
"Icon"="inetcpl.cpl#00004481"
"LowIcon"="inetcpl.cpl#005426"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000003
"1001"=dword:00000003
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000003
"1207"=dword:00000003
"1402"=dword:00000003
"1405"=dword:00000003
"1406"=dword:00000003
"1407"=dword:00000003
"1408"=dword:00000003
"1409"=dword:00000000
"1601"=dword:00000001
"1604"=dword:00000001
"1605"=dword:00000000
"1606"=dword:00000003
"1607"=dword:00000003
"1608"=dword:00000003
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000001
"1803"=dword:00000003
"1804"=dword:00000003
"1805"=dword:00000001
"1806"=dword:00000003
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"180B"=dword:00000003
"1812"=dword:00000001
"1A00"=dword:00010000
"1A02"=dword:00000003
"1A03"=dword:00000003
"1A04"=dword:00000003
"1A05"=dword:00000003
"1A06"=dword:00000003
"1A10"=dword:00000003
"1C00"=dword:00000000
"2000"=dword:00000003
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000003
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001
"2301"=dword:00000000
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000003
"2401"=dword:00000003
"2402"=dword:00000003
"2600"=dword:00000003
"2500"=dword:00000000
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000000
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\P3P]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Passport]
"NumRegistrationRuns"=dword:00000006
"LoginServerRealm"="Passport.Net"
"LoginServerUrl"="https://login.live.com/login2.srf"
"RegistrationUrl"="https://login.live.com/err.srf"
"Properties"="https://account.live.com/EditProf.aspx?lcid=%L"
"Privacy"="https://login.live.com/gls.srf?urlID=MSNPrivacyStatement&lc=%L"
"GeneralRedir"="http://nexusrdr.passport.com/redir.asp"
"Help"="https://account.live.com/?lcid=%L&dc=PPRDR_Help"
"ConfigVersion"=dword:0000000f

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Passport\DAMap]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Passport\LowDAMap]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Protocols]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Protocols\Mailto]
"UTF8Encoding"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\TemplatePolicies]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\TemplatePolicies\High]
"1400"=dword:00000003

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Url History]
"DaysToKeep"=dword:00000014

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad]
"WpadLastNetwork"="{463E95C8-B144-464B-B1A9-111DBFCE7526}_{D8081AC1-4B37-446F-90C7-FF45428651D7}"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{11A98A6D-A98B-458C-AC05-4E82EB12D308}_{D8081AC1-4B37-446F-90C7-FF45428651D7}]
"WpadDecisionReason"=dword:00000000
"WpadDecisionTime"=hex:70,65,f0,ca,43,c8,cf,01
"WpadDecision"=dword:00000001
"WpadNetworkName"="Unidentified network"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{463E95C8-B144-464B-B1A9-111DBFCE7526}_{645150DC-351F-4BF1-95E5-F6510AE1AC51}]
"WpadDecisionReason"=dword:00000001
"WpadDecisionTime"=hex:50,e0,58,42,29,d5,cf,01
"WpadDecision"=dword:00000000
"WpadNetworkName"="Unidentified network"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{463E95C8-B144-464B-B1A9-111DBFCE7526}_{D8081AC1-4B37-446F-90C7-FF45428651D7}]
"WpadDecisionReason"=dword:00000000
"WpadDecisionTime"=hex:b0,7a,28,c7,f9,d3,cf,01
"WpadDecision"=dword:00000001
"WpadNetworkName"="carnivalcorp.com"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{6CFC3AEE-A1C3-47FB-ACA9-B887174FBDA8}_{D8081AC1-4B37-446F-90C7-FF45428651D7}]
"WpadDecisionReason"=dword:00000000
"WpadDecisionTime"=hex:60,9f,4a,55,08,cd,cf,01
"WpadDecision"=dword:00000001
"WpadNetworkName"="carnivalcorp.com"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap]
@=""
"ProxyByPass"=dword:00000001
"IntranetName"=dword:00000001
"UNCAsIntranet"=dword:00000001
"AutoDetect"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains]
@=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\carnival.com]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\carnivalgroup.com]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\cclprdcmdp1]
"http"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\cclprdpfe]
"http"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\corporate-ir.net]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\intranet]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ux15.pcb]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\cclprdcmdp1]
"http"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\microsoft.com]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\microsoft.com\*.update]
"http"=dword:00000002
"https"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\ProtocolDefaults]
@=""
"http"=dword:00000003
"https"=dword:00000003
"ftp"=dword:00000003
"file"=dword:00000003
"@ivt"=dword:00000001
"shell"=dword:00000000
"knownfolder"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges]
@=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones]
@=""
"SelfHealCount"=dword:00000001
"SecuritySafe"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0]
"2004"=dword:00000000
"2001"=dword:00000000
@=""
"DisplayName"="My Computer"
"Description"="Your computer"
"Icon"="explorer.exe#0100"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1001"=dword:00000000
"1004"=dword:00000000
"1200"=dword:00000000
"1201"=dword:00000001
"1206"=dword:00000000
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"1800"=dword:00000000
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000000
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00020000
"1E05"=dword:00030000
"2100"=dword:00000000
"2101"=dword:00000003
"2102"=dword:00000000
"2200"=dword:00000000
"2201"=dword:00000000
"2300"=dword:00000001
"2000"=dword:00000000
"1207"=dword:00000000
"PMDisplayName"="Computer [Protected Mode]"
"LowIcon"="inetcpl.cpl#005422"
"2007"=dword:00000003
"1408"=dword:00000000
"1409"=dword:00000003
"160A"=dword:00000000
"1812"=dword:00000000
"2005"=dword:00000000
"1208"=dword:00000000
"1209"=dword:00000000
"120A"=dword:00000000
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000000
"2104"=dword:00000000
"2105"=dword:00000000
"2106"=dword:00000000
"2107"=dword:00000000
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000003
"2701"=dword:00000000
"2702"=dword:00000003
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1]
"2004"=dword:00000000
"2001"=dword:00000000
@=""
"DisplayName"="Local intranet"
"Description"="This zone contains all Web sites that are on your organization's intranet."
"Icon"="shell32.dll#0018"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00010000
"RecommendedLevel"=dword:00010500
"Flags"=dword:000000db
"1001"=dword:00000001
"1004"=dword:00000003
"1200"=dword:00000000
"1201"=dword:00000003
"1206"=dword:00000000
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000001
"1407"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"1800"=dword:00000001
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1A00"=dword:00020000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000000
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00020000
"1E05"=dword:00020000
"2100"=dword:00000000
"2101"=dword:00000000
"2102"=dword:00000000
"2200"=dword:00000000
"2201"=dword:00000000
"2300"=dword:00000001
"2000"=dword:00000000
"1207"=dword:00000000
"PMDisplayName"="Local intranet [Protected Mode]"
"LowIcon"="inetcpl.cpl#005423"
"2500"=dword:00000003
"2007"=dword:00010000
"2402"=dword:00000000
"2400"=dword:00000000
"2401"=dword:00000000
"1208"=dword:00000000
"1209"=dword:00000000
"120A"=dword:00000003
"2600"=dword:00000000
"2104"=dword:00000000
"160A"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000000
"2105"=dword:00000000
"1409"=dword:00000003
"1408"=dword:00000000
"2005"=dword:00000000
"2106"=dword:00000000
"2700"=dword:00000003
"2107"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000
"1812"=dword:00000000
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2701"=dword:00000000
"2702"=dword:00000003
"2703"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2]
"2001"=dword:00000000
"2004"=dword:00000000
@=""
"DisplayName"="Trusted sites"
"Description"="This zone contains Web sites that you trust not to damage your computer or data."
"Icon"="inetcpl.cpl#00004480"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00010000
"RecommendedLevel"=dword:00010000
"Flags"=dword:00000043
"1001"=dword:00000000
"1004"=dword:00000000
"1200"=dword:00000000
"1201"=dword:00000000
"1206"=dword:00000000
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000000
"1800"=dword:00000000
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000000
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00030000
"1E05"=dword:00030000
"2100"=dword:00000000
"2101"=dword:00000001
"2102"=dword:00000000
"2200"=dword:00000000
"2201"=dword:00000000
"2300"=dword:00000001
"2000"=dword:00000000
"1207"=dword:00000000
"PMDisplayName"="Trusted sites [Protected Mode]"
"LowIcon"="inetcpl.cpl#005424"
"1208"=dword:00000000
"1209"=dword:00000000
"120A"=dword:00000003
"1408"=dword:00000000
"1409"=dword:00000003
"160A"=dword:00000000
"2005"=dword:00000000
"2103"=dword:00000000
"2104"=dword:00000000
"2105"=dword:00000000
"2106"=dword:00000000
"2301"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2700"=dword:00000003
"2007"=dword:00010000
"2107"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000
"1812"=dword:00000000
"2500"=dword:00000003
"140A"=dword:00000000
"2302"=dword:00000003
"270B"=dword:00000000
"160B"=dword:00000000
"270C"=dword:00000003
"270D"=dword:00000000
"2701"=dword:00000000
"2702"=dword:00000003
"2703"=dword:00000000
"2704"=dword:00000000
"2108"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000003
"180C"=dword:00000000
"180D"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3]
"2004"=dword:00000000
"2001"=dword:00000000
@=""
"DisplayName"="Internet"
"Description"="This zone contains all Web sites you haven't placed in other zones"
"Icon"="inetcpl.cpl#001313"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00011000
"RecommendedLevel"=dword:00011000
"Flags"=dword:00000001
"1001"=dword:00000001
"1004"=dword:00000003
"1200"=dword:00000000
"1201"=dword:00000003
"1206"=dword:00000003
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000003
"1407"=dword:00000000
"1601"=dword:00000001
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"1800"=dword:00000001
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000001
"1806"=dword:00000001
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000001
"1A06"=dword:00000000
"1A10"=dword:00000001
"1C00"=dword:00010000
"1E05"=dword:00020000
"2100"=dword:00000000
"2101"=dword:00000000
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"2300"=dword:00000001
"2000"=dword:00000000
"{AEBA21FA-782A-4A90-978D-B72164C80120}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,1e,28,1a,04,1b,0c,3b,c2,21,27,53,0d,36,05,2c,05,\
  04,3d,4f,3a,4a,44,33,3a,0a,06,12,68,53,7c,20,13,35,5d,4c,10,27,01,56,7a,2d,\
  3f,38,4f,79,0f,16,26,75,53,1c,31,00,56,7a,3e,32,24,4f,79,1b,00,33,71,4d,23,\
  32,29,7c,6a,35,31,34,40,72,3b,01,2e,5d,4c,2a,07,15,48,72,38,12,00,56,7a,3e,\
  16,3c,71,4d,24,33,35,7c,72,35,0e,3c,1a,41,44,19,0f,31,3a,56,7a,2e,3e,31,0c,\
  7c,6a,10,27,0c,05,5d,4c,39,19,12,15,61,54,2e,00,33,32,40,52,03,25,1f,05,5d,\
  4c,2c,0c,0a,15,61,54,1a,26,1f,05,5d,4c,10,21,1d,1b,71,4d,3b,24,3a,21,6d,72,\
  24,16,3c,32,40,72,21,0f,3a,1a,41,44,1b,1e,01,01,71,4d,32,23,30,27,6d,4d,1f,\
  28,10,3c,56,7a,2f,2e,32,16,7c,6a,3a,12,3b,28,75,53,0b,3f,12,01,71,4d,23,32,\
  29,27,75,53,12,30,32,1e,4f,79,12,38,17,01,71,4d,30,3e,37,27,6d,72,38,12,3f,\
  04,41,44,0a,0e,32,28,49,5f,1c,24,0b,1b,36,21,41,7b,5b,24,39,31,7c,6a,2b,0e,\
  25,75,53,1a,2e,26,41,72,34,16,26,71,4d,30,30,3a,7c,6a,07,33,1a,56,7a,3a,00,\
  33,71,4d,23,32,29,7c,6a,1a,26,1a,40,52,24,3f,1a,6d,4d,1c,22,28,75,53,13,25,\
  20,41,44,0a,0e,32,75,53,08,07,20,71,4d,10,27,0d,05,5d,4c,24,1a,1e,1b,71,4d,\
  3f,20,3f,21,6d,4d,10,27,0c,05,5d,4c,39,19,12,3a,56,7a,3a,20,2c,0c,7c,6a,3e,\
  0c,37,07,75,53,12,30,32,3a,56,7a,25,2d,23,0c,7c,6a,2b,08,21,3a,56,7a,22,3a,\
  32,3a,56,72,24,1e,26,1a,41,44,07,1f,03,1b,75,53,1c,31,01,01,71,4d,32,23,30,\
  27,6d,72,34,1e,30,04,41,44,1b,1e,3b,28,49,5f,07,33,12,1b,5d,4c,35,0b,0a,1f,\
  75,53,0b,00,34,28,40,72,3b,01,2d,04,41,44,01,05,34,28,40,52,22,36,04,34,48,\
  72,38,12,3f,04,41,44,0a,0e,1f,01,71,4d,24,33,35,27,06,1c,68,53,49,14,21,01,\
  40,52,10,27,0d,40,52,2c,29,05,6d,4d,1f,28,05,56,7a,2f,2e,32,75,53,07,33,12,\
  40,52,3f,3a,19,6d,72,20,00,34,71,4d,1a,26,1a,40,52,24,3f,1a,6d,72,35,08,38,\
  5d,4c,2d,01,18,48,7a,27,23,1f,56,7a,3b,2f,3f,4f,79,08,39,01,1b,71,72,33,1f,\
  39,3a,56,7a,2e,3e,31,0c,7c,72,35,0e,3f,1a,41,44,0a,0a,35,3a,56,7a,3a,20,2c,\
  0c,7c,6a,03,25,1f,05,5d,4c,2c,0c,0a,15,61,54,27,05,34,32,40,52,10,21,09,05,\
  5d,4c,2d,01,18,15,61,54,07,37,17,05,5d,4c,1c,24,03,1b,71,4d,30,30,3b,27,6d,\
  72,33,17,3f,28,40,72,34,1e,30,04,41,44,1b,1e,00,01,71,4d,2f,2c,2c,27,6d,4d,\
  0b,26,3f,3c,56,7a,3a,20,23,16,7c,6a,35,05,33,28,75,53,12,30,17,01,71,4d,30,\
  3e,37,27,75,53,13,25,20,1e,4f,79,1f,29,1f,01,71,4d,24,33,35,27,06,21,41,7b,\
  5b,3d,24,37,7c,6a,2b,0e,25,40,72,33,1f,39,5d,72,34,1e,30,5d,4c,2a,0d,18,48,\
  7a,27,12,3b,71,4d,23,32,12,56,72,20,0c,2e,5d,4c,2c,0c,0a,75,53,1a,26,1f,40,\
  72,35,08,38,5d,4c,2d,01,18,75,53,0f,21,27,41,44,07,1f,3e,61,54,3d,06,22,32,\
  40,52,2c,29,05,32,48,72,34,1e,05,1b,71,4d,10,27,0c,05,5d,4c,39,19,1a,1b,71,\
  4d,23,32,24,21,6d,4d,03,25,1f,05,5d,4c,2c,0c,0a,3a,56,7a,25,2d,23,0c,7c,6a,\
  2b,08,21,07,75,53,13,25,20,3a,56,7a,3e,3e,3b,0c,7c,6a,3f,0f,23,3a,56,7a,2f,\
  2e,3d,3c,56,72,33,1f,39,04,41,44,1a,0e,05,01,75,53,1c,31,00,01,71,4d,2f,2c,\
  2c,27,6d,72,20,0c,2d,04,41,44,06,18,2a,28,49,5f,1a,26,1a,1b,5d,4c,2c,0c,0f,\
  1f,75,53,1c,1c,3e,28,40,72,38,12,3f,04,41,44,0a,16,3c,28,40,52,3e,39,06,34,\
  21,21,41,7b,5b,23,27,3c,7c,6a,17,37,17,40,52,32,24,05,6d,4d,0e,21,2c,75,53,\
  0b,31,31,75,53,08,3e,21,41,44,07,1e,3c,61,54,17,37,17,05,5d,4c,00,33,1e,1b,\
  71,4d,2e,39,3b,21,6d,72,20,06,32,32,40,72,21,0f,3c,1a,41,44,1a,0e,1f,01,71,\
  4d,20,2c,30,27,6d,4d,0e,21,2c,3c,56,7a,3a,2e,2d,16,7c,6a,3f,07,22,28,6e,02,\
  68,4a,7c,21,09,26,5d,4c,29,1d,1f,56,7a,3f,32,38,4f,79,1e,30,01,56,7a,3a,2e,\
  2d,4f,79,14,07,22,71,4d,24,30,3b,7c,6a,2a,1e,2f,07,75,53,0c,2d,26,3a,56,7a,\
  31,25,3d,0c,7c,6a,3e,0e,35,3a,56,7a,3b,2f,3d,3a,56,72,34,1e,26,04,41,44,0b,\
  0a,1e,01,75,53,0e,38,01,01,71,4d,23,30,2b,27,6d,72,21,0f,3c,04,28,1b,67,6b,\
  5f,00,22,10,75,53,1f,21,27,41,44,0b,0a,31,75,53,0e,1d,22,71,4d,03,27,1d,40,\
  52,3e,39,08,75,53,08,31,21,41,44,1a,0e,32,3a,56,7a,3f,32,38,0c,7c,6a,06,3e,\
  0d,05,5d,4c,35,0d,09,15,61,54,29,07,22,32,40,52,17,37,17,1b,5d,4c,3a,19,16,\
  1f,61,54,06,3e,0d,1b,5d,4c,03,27,11,01,71,4d,24,33,3b,27,06,21,41,73,41,11,\
  25,1d,56,7a,2e,3e,3b,4f,79,18,12,3f,71,4d,2e,39,3b,7c,6a,3e,0e,35,40,72,21,\
  0f,3c,5d,4c,36,0d,19,48,72,34,1e,1f,1b,71,4d,00,33,16,05,5d,4c,38,04,01,1b,\
  71,4d,23,30,2b,21,6d,4d,1c,24,0d,05,5d,4c,29,1d,17,3c,56,7a,3f,32,38,16,7c,\
  6a,39,09,25,09,75,53,0b,31,31,3c,56,7a,3b,2f,3d,16,15,39,5f,7b,42,03,38,02,\
  40,20,2c,1e,4f,37,41,7b,5b,23,27,3c,7c,14,07,22,6e,14,68,4a,7c,20,13,35,5d,\
  30,37,08,06,37,41,7b,5b,23,27,3c,7c,1b,39,1d,30,02,7c,50,68,3a,3b,34,4f,1b,\
  1e,3b,6e,14,68,73,41,0b,22,0a,56,12,30,32,28,09,67,73,41,0b,22,2a,41,2c,0c,\
  0f,21,37,41,7b,5b,23,27,3c,7c,08,1c,3e,66,0e,44,4f,56,06,13,05,61,27,23,1f,\
  4f,3f,5b,53,7c,20,13,35,5d,3e,39,06,06,0a,68,53,7c,21,09,26,5d,32,12,3f,6e,\
  14,68,4a,44,3e,37,02,6d,1c,24,01,4f,3f,5b,73,41,08,38,27,41,38,04,19,6e,14,\
  68,4a,44,3e,37,02,6d,3e,0e,35,3b,37,41,7b,5b,24,39,31,7c,08,39,00,4f,3f,7c,\
  50,68,3b,1d,3c,71,25,2d,2c,20,3a,7c,50,68,3b,25,3b,4f,01,1d,2a,6e,14,68,4a,\
  44,3e,37,02,6d,10,21,09,29,1f,5e,45,67,14,30,07,49,12,16,3c,66,0e,44,73,41,\
  08,38,27,41,36,0a,1b,21,3f,42,73,41,10,3b,2d,41,00,33,1e,4f,3f,5b,53,5e,2e,\
  07,1d,75,21,07,22,66,0e,7c,50,68,23,24,31,4f,0d,15,01,4f,3f,5b,53,5e,2e,07,\
  1d,48,0b,18,3c,6e,14,68,4a,44,26,36,0c,6d,2b,06,25,66,37,41,7b,5b,14,21,01,\
  40,3a,31,24,15,37,41,7b,5b,3c,3e,3f,7c,12,38,17,4f,3f,5b,53,5e,2e,07,1d,75,\
  35,08,38,36,03,56,76,74,37,08,19,40,07,37,17,29,1f,7c,50,68,23,24,31,4f,07,\
  1f,3e,16,17,7c,50,68,20,3a,39,75,25,12,3f,66,0e,44,4f,56,1c,12,1d,56,1c,24,\
  0d,29,37,41,7b,5b,3d,24,37,7c,1e,1d,22,66,0e,44,4f,56,1c,12,30,61,23,13,11,\
  4f,3f,5b,53,5e,2f,01,15,48,10,27,0c,6e,14,68,4a,7c,36,12,38,5d,24,3f,19,6e,\
  14,68,4a,44,21,2c,04,6d,35,05,34,66,0e,44,4f,56,1c,12,1d,56,1c,3b,25,28,09,\
  67,6b,5f,01,2c,28,75,24,1e,26,36,37,41,7b,5b,3d,24,37,7c,14,3a,0b,30,37,41,\
  7b,5b,36,0c,7c
"{A8A88C49-5EB2-4990-A1A2-0876022C854F}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,1e,28,1a,04,1b,0c,3b,c2,21,2d,53,49,07,25,0f,29,\
  01,7c,50,68,3a,3b,34,4f,79,08,39,0d,49,72,33,1f,39,5d,4c,17,37,05,56,7a,2f,\
  2e,32,4f,79,1f,12,3b,75,53,0b,3f,12,56,7a,3a,20,23,4f,79,12,05,33,71,4d,3a,\
  31,29,7c,6a,2b,08,21,40,72,38,12,3f,5d,4c,39,1d,17,48,72,21,0f,03,56,7a,2f,\
  06,22,32,40,52,2c,29,05,3a,56,7a,2e,3e,31,0c,7c,6a,2b,06,25,32,40,52,33,24,\
  01,32,75,53,0b,3f,32,04,4f,79,1b,3b,1f,0c,40,72,3b,01,2d,1a,75,53,12,30,3f,\
  04,4f,79,08,3f,09,0c,75,53,13,25,20,04,75,53,07,37,17,05,5d,4c,36,0a,1b,3a,\
  56,72,35,0e,3c,3c,56,7a,2d,3f,38,16,7c,6a,17,37,01,1b,5d,4c,2a,0d,18,1f,61,\
  54,12,12,3b,28,40,52,3f,3a,19,34,48,72,20,0c,17,01,71,4d,1a,26,1a,1b,5d,4c,\
  2c,0c,17,01,71,4d,30,3e,37,27,6d,4d,1b,3b,0c,1b,5d,4c,39,1d,17,3c,56,7a,3b,\
  2f,3f,16,15,39,5f,7b,42,29,1d,3c,71,4d,30,06,22,71,4d,32,23,30,7c,6a,2a,1e,\
  19,75,53,1c,31,20,41,72,24,12,3b,71,4d,23,32,24,7c,6a,03,25,17,56,7a,25,05,\
  33,71,4d,3a,31,29,7c,6a,10,21,09,40,52,27,2c,0b,6d,4d,0f,28,2a,75,53,08,3e,\
  23,41,44,1b,1e,3c,3a,56,7a,12,34,16,05,75,53,1f,21,2d,04,4f,79,10,27,0c,05,\
  5d,4c,39,19,12,15,75,53,0b,3f,32,04,4f,79,1b,00,34,32,40,52,24,3f,19,32,48,\
  7a,2c,10,17,1b,71,4d,30,1c,3e,32,40,52,27,2c,0b,32,48,7a,27,16,3c,32,40,52,\
  3e,07,20,3a,56,7a,2f,2e,3d,16,7c,6a,12,34,1e,01,71,4d,17,37,01,1b,5d,4c,2a,\
  0d,18,3c,56,7a,3e,32,24,16,7c,6a,3e,0c,34,09,75,53,0b,3f,3f,1e,4f,79,12,38,\
  12,01,71,72,3b,01,2e,3c,56,7a,2f,24,39,16,7c,72,38,12,3f,04,41,44,0a,0e,32,\
  3c,56,7a,3b,2f,3f,16,15,39,7c,50,68,23,24,31,4f,79,08,39,0d,49,5f,12,34,16,\
  40,52,17,37,01,40,52,22,38,0b,6d,4d,0f,34,1a,56,7a,3a,20,2c,75,53,03,25,1f,\
  40,52,24,3f,19,6d,72,3b,05,34,71,4d,10,21,09,40,52,27,2c,0b,6d,72,24,1e,26,\
  5d,4c,36,0a,1b,48,7a,36,13,01,1b,71,4d,32,23,30,21,6d,4d,17,37,01,3a,56,7a,\
  2f,06,25,32,40,52,33,24,01,3a,56,7a,3a,20,2c,0c,7c,6a,3e,00,34,32,40,52,24,\
  3f,19,32,75,53,12,30,3f,04,4f,79,08,3f,09,0c,40,72,38,12,3f,1a,75,53,0f,21,\
  27,04,4f,79,14,3a,0b,0c,75,53,1c,31,21,1e,75,53,12,34,16,1b,5d,4c,29,1d,1d,\
  3c,56,72,35,0e,3f,3c,56,7a,3e,32,24,16,7c,6a,03,25,1a,1b,5d,4c,35,0b,0f,1f,\
  61,54,27,05,33,28,40,52,24,3f,1a,34,48,72,35,08,1d,01,71,4d,1b,3b,0c,1b,5d,\
  4c,39,1d,1f,01,71,4d,24,33,35,27,06,1c,7c,50,68,20,3a,39,4f,79,08,06,22,71,\
  4d,32,23,30,7c,6a,2a,1e,19,40,72,35,0e,3f,5d,72,24,1a,25,5d,4c,35,0b,0a,48,\
  7a,23,00,34,71,4d,3a,31,12,56,72,3b,01,2e,5d,4c,2a,07,15,75,53,1b,3b,0c,40,\
  72,24,1e,26,5d,4c,36,0a,1b,75,53,1c,31,21,04,4f,79,0a,2a,06,0c,40,72,34,1e,\
  30,1a,41,44,1b,1e,3b,3a,56,7a,07,33,12,05,75,53,0b,3f,32,04,4f,79,03,25,1f,\
  05,5d,4c,2c,0c,0a,15,75,53,12,30,3f,04,4f,79,08,1c,3e,32,40,52,27,2c,0b,32,\
  48,7a,27,23,1f,1b,71,4d,24,07,20,32,40,52,22,38,08,34,48,7a,34,17,3f,28,40,\
  52,23,16,26,3c,56,7a,2f,2e,32,16,7c,6a,07,33,1a,01,71,4d,03,25,1a,1b,5d,4c,\
  35,0b,0f,3c,56,7a,25,2d,2c,16,7c,6a,35,31,37,09,75,53,1c,3b,25,1e,4f,79,13,\
  35,00,01,71,72,24,1e,26,3c,56,7a,3b,2f,3f,16,15,21,41,7b,5b,23,27,3c,7c,6a,\
  2a,16,3c,71,4d,20,2c,30,7c,6a,06,3e,0d,40,52,3f,38,18,6d,4d,08,27,2c,75,53,\
  08,31,21,75,53,1f,21,27,04,4f,79,18,2d,06,0c,75,53,0e,38,21,04,75,53,03,27,\
  1d,05,5d,4c,36,0a,19,3a,56,72,34,1e,26,3c,56,7a,3f,32,38,16,7c,6a,06,3e,0d,\
  1b,5d,4c,35,0d,09,1f,61,54,29,07,22,28,29,01,5e,45,67,14,30,1f,56,7a,17,37,\
  17,40,72,25,1a,39,5d,4c,38,04,01,56,7a,3a,2e,2d,4f,79,14,3a,01,56,7a,3b,2e,\
  3d,4f,79,0f,16,3c,32,40,52,32,24,05,32,48,7a,18,28,01,1b,71,4d,23,06,32,32,\
  40,52,3e,39,08,32,48,7a,37,16,3c,28,40,52,32,12,3f,3c,56,7a,31,25,3d,16,7c,\
  6a,03,27,11,01,71,4d,1c,24,0d,1b,36,1d,56,76,74,14,21,01,40,52,23,28,02,6d,\
  4d,0c,34,2b,75,53,0e,38,21,41,44,06,1e,2c,75,53,08,07,22,71,4d,1c,27,0d,40,\
  52,23,28,02,3a,56,7a,3f,32,38,0c,7c,6a,39,1d,22,32,40,52,3f,38,18,32,75,53,\
  08,3e,21,04,4f,79,0f,29,07,02,40,72,25,1a,39,04,75,53,0e,38,21,1e,4f,79,1b,\
  39,1d,02,75,53,08,3e,21,1e,6e,02,7c,50,68,20,3a,39,4f,79,0f,16,3c,75,53,0c,\
  2d,1e,56,7a,31,25,3d,4f,79,1b,06,32,71,4d,24,33,3b,7c,6a,3f,0e,25,40,72,34,\
  1e,26,1a,41,44,0b,0a,31,3a,56,7a,06,3e,0d,05,75,53,0b,31,31,04,4f,79,1c,24,\
  0d,05,5d,4c,29,1d,17,1f,75,53,0c,2d,26,1e,4f,79,1e,1d,22,28,40,52,3f,38,18,\
  34,48,7a,22,12,01,01,66,1c,44,73,41,0b,22,2a,41,3a,19,16,21,2d,42,73,41,0b,\
  22,2a,41,1c,24,01,4f,2d,5b,53,5e,35,1e,22,75,27,1d,22,66,1c,7c,50,68,3a,3b,\
  34,4f,06,1e,11,4f,2d,5b,53,5e,35,1e,22,48,1c,18,2d,6e,02,68,4a,44,3f,2d,31,\
  6d,35,05,33,66,21,41,7b,5b,03,38,02,40,3a,31,29,15,21,41,7b,5b,23,27,3c,7c,\
  08,3f,1d,4f,2d,5b,53,5e,35,1e,22,75,24,1e,26,36,1d,56,76,74,3e,03,1c,40,1c,\
  24,0b,29,01,7c,50,68,3b,25,3b,4f,0b,0a,31,16,05,7c,50,68,3b,25,3b,75,21,07,\
  22,66,1c,44,4f,56,07,15,1f,56,06,3e,0d,29,21,41,7b,5b,24,39,31,7c,1b,06,32,\
  66,1c,44,4f,56,07,15,32,61,36,13,00,4f,2d,5b,53,5e,36,04,17,48,1a,26,1a,6e,\
  02,68,4a,7c,21,09,26,5d,24,3f,1a,6e,02,68,4a,44,3e,37,02,6d,2b,1c,3e,66,1c,\
  44,4f,56,07,15,1f,56,0f,21,27,28,1b,67,6b,5f,08,21,2a,75,21,0f,3a,36,21,41,\
  7b,5b,3c,3e,3f,7c,18,2d,06,30,21,41,7b,5b,3c,3e,05,56,1c,24,0d,29,01,5e,45,\
  67,0c,1c,26,75,27,09,3c,6e,02,68,4a,44,26,36,0c,6d,03,27,1d,29,01,5e,45,67,\
  0c,3f,31,49,3d,06,25,66,1c,44,4f,56,1f,14,38,75,3b,01,12,4f,2d,5b,73,41,10,\
  3b,2d,41,2c,0c,17,4f,2d,5b,53,5e,2e,07,1d,48,10,21,09,29,01,5e,45,67,0c,1c,\
  26,71,3e,3e,3b,20,28,74,4e,68,2a,29,05,56,08,3e,23,6e,02,68,4a,44,21,2c,04,\
  6d,3b,1a,20,6e,02,68,4a,44,21,1a,3e,75,21,0f,3c,36,1d,56,76,74,15,3b,1d,56,\
  0e,38,01,4f,2d,5b,53,5e,2f,01,15,75,20,0e,2c,36,1d,56,76,74,28,02,21,40,10,\
  27,0c,29,01,5e,45,67,0d,35,1d,56,12,05,33,66,1c,7c,50,68,20,3a,39,4f,01,05,\
  34,66,1c,44,4f,56,1c,12,30,75,35,08,38,36,1d,56,76,74,15,3b,09,40,2f,20,31,\
  15,39,5f,7b,42,20,1a,3e,71,3b,2f,03,4f,2d,5b,53,5e,20,39,74
"1207"=dword:00000003
"PMDisplayName"="Internet [Protected Mode]"
"LowIcon"="inetcpl.cpl#005425"
"1208"=dword:00000000
"1209"=dword:00000003
"120A"=dword:00000003
"1408"=dword:00000000
"1409"=dword:00000000
"160A"=dword:00000000
"2005"=dword:00000000
"2103"=dword:00000000
"2104"=dword:00000000
"2105"=dword:00000000
"2106"=dword:00000000
"2301"=dword:00000000
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2700"=dword:00000003
"2007"=dword:00010000
"2107"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000
"1812"=dword:00000000
"2500"=dword:00000000
"140A"=dword:00000000
"2302"=dword:00000003
"270B"=dword:00000003
"160B"=dword:00000000
"270C"=dword:00000000
"270D"=dword:00000003
"2701"=dword:00000000
"2702"=dword:00000000
"2703"=dword:00000000
"2704"=dword:00000000
"120B"=dword:00000000
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4]
"2004"=dword:00000003
"2001"=dword:00000003
@=""
"DisplayName"="Restricted sites"
"Description"="This zone contains Web sites that could potentially damage your computer or data."
"Icon"="inetcpl.cpl#00004481"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00012000
"RecommendedLevel"=dword:00012000
"Flags"=dword:00000003
"1001"=dword:00000003
"1004"=dword:00000003
"1200"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000003
"1400"=dword:00000003
"1402"=dword:00000003
"1405"=dword:00000003
"1406"=dword:00000003
"1407"=dword:00000003
"1601"=dword:00000001
"1604"=dword:00000001
"1605"=dword:00000000
"1606"=dword:00000003
"1607"=dword:00000003
"1608"=dword:00000003
"1609"=dword:00000001
"1800"=dword:00000003
"1802"=dword:00000001
"1803"=dword:00000003
"1804"=dword:00000003
"1805"=dword:00000001
"1806"=dword:00000003
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"1A00"=dword:00010000
"1A02"=dword:00000003
"1A03"=dword:00000003
"1A04"=dword:00000003
"1A05"=dword:00000003
"1A06"=dword:00000003
"1A10"=dword:00000003
"1C00"=dword:00000000
"1E05"=dword:00010000
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"2300"=dword:00000003
"2000"=dword:00000003
"{AEBA21FA-782A-4A90-978D-B72164C80120}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,13,37,13,12,14,1a,15,39
"{A8A88C49-5EB2-4990-A1A2-0876022C854F}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,13,37,13,12,14,1a,15,39
"1207"=dword:00000003
"180B"=dword:00000001
"PMDisplayName"="Restricted sites [Protected Mode]"
"LowIcon"="inetcpl.cpl#005426"
"2007"=dword:00000003
"2500"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000000
"160A"=dword:00000003
"1812"=dword:00000001
"2005"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2301"=dword:00000000
"2400"=dword:00000003
"2401"=dword:00000003
"2402"=dword:00000003
"2600"=dword:00000003
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000000
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

"@

$proxy_autoconf = @"
REGEDIT4

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings]
"IE5_UA_Backup_Flag"="5.0"
"User Agent"="Mozilla/4.0 (compatible; MSIE 8.0; Win32)"
"EmailName"="IEUser@"
"PrivDiscUiShown"=dword:00000001
"EnableHttp1_1"=dword:00000001
"WarnOnIntranet"=dword:00000001
"MimeExclusionListForCache"="multipart/mixed multipart/x-mixed-replace multipart/x-byteranges "
"AutoConfigProxy"="wininet.dll"
"UseSchannelDirectly"=hex:01,00,00,00
"PrivacyAdvanced"=dword:00000000
"ProxyEnable"=dword:00000000
"EnableNegotiate"=dword:00000001
"MigrateProxy"=dword:00000001
"WarnOnPost"=hex:01,00,00,00
"UrlEncoding"=dword:00000000
"SecureProtocols"=dword:000000a0
"ZonesSecurityUpgrade"=hex:5d,64,af,bb,39,7f,cf,01
"DisableCachingOfSSLPages"=dword:00000000
"WarnonZoneCrossing"=dword:00000000
"CertificateRevocation"=dword:00000001
"ProxyHttp1.1"=dword:00000001
"ShowPunycode"=dword:00000000
"EnablePunycode"=dword:00000001
"DisableIDNPrompt"=dword:00000000
"WarnonBadCertRecving"=dword:00000001
"WarnOnPostRedirect"=dword:00000001
"GlobalUserOffline"=dword:00000000
"EnableAutodial"=dword:00000000
"NoNetAutodial"=dword:00000000
"BackgroundConnections"=dword:00000001
"CreateUriCacheSize"=dword:00000050
"CoInternetCombineIUriCacheSize"=dword:00000050
"SecurityIdIUriCacheSize"=dword:0000001e
"SpecialFoldersCacheSize"=dword:00000008
"AutoConfigURL"="http://proxy.carnival.com:8080/array.dll?Get.Routing.Script"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache]
"Signature"="Client UrlCache MMF Ver 5.2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content]
"CachePrefix"=""
"CacheLimit"=dword:0003e800

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Cookies]
"CachePrefix"="Cookie:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\DOMStore]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,49,6e,74,65,72,6e,65,\
  74,20,45,78,70,6c,6f,72,65,72,5c,44,4f,4d,53,74,6f,72,65,00
"CachePrefix"="DOMStore"
"CacheLimit"=dword:000003e8
"CacheOptions"=dword:00000008
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\feedplat]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,46,65,65,64,73,20,43,\
  61,63,68,65,00
"CachePrefix"="feedplat:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000000
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\iecompat]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,43,6f,6d,70,61,74,43,61,63,68,65,00
"CachePrefix"="iecompat:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\iedownload]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,44,6f,77,6e,6c,6f,61,64,48,69,73,74,6f,72,79,\
  00
"CachePrefix"="iedownload:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014090120140908]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,30,31,32,30,31,34,30,39,30,38,00
"CachePrefix"=":2014090120140908: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014090820140915]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,30,38,32,30,31,34,30,39,31,35,00
"CachePrefix"=":2014090820140915: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014091520140922]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,31,35,32,30,31,34,30,39,32,32,00
"CachePrefix"=":2014091520140922: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014092220140923]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,32,32,32,30,31,34,30,39,32,33,00
"CachePrefix"=":2014092220140923: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014092320140924]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,32,33,32,30,31,34,30,39,32,34,00
"CachePrefix"=":2014092320140924: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\MSHist012014092420140925]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,57,69,6e,64,6f,77,73,\
  5c,48,69,73,74,6f,72,79,5c,48,69,73,74,6f,72,79,2e,49,45,35,5c,4d,53,48,69,\
  73,74,30,31,32,30,31,34,30,39,32,34,32,30,31,34,30,39,32,35,00
"CachePrefix"=":2014092420140925: "
"CacheLimit"=dword:00002000
"CacheOptions"=dword:0000000b
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Extensible Cache\PrivacIE:]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,50,72,69,76,61,63,49,45,00
"CachePrefix"="PrivacIE:"
"CacheLimit"=dword:00000400
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\History]
"CachePrefix"="Visited:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache]
"Signature"="Client UrlCache MMF Ver 5.2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Content]
"CachePrefix"=""
"CacheLimit"=dword:0003e800

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Cookies]
"CachePrefix"="Cookie:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\DOMStore]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,4c,6f,77,5c,4d,69,63,72,6f,73,6f,66,74,5c,49,6e,74,65,\
  72,6e,65,74,20,45,78,70,6c,6f,72,65,72,5c,44,4f,4d,53,74,6f,72,65,00
"CachePrefix"="DOMStore"
"CacheLimit"=dword:000003e8
"CacheOptions"=dword:00000008
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\EmieSiteList]
"CachePrefix"="EmieSiteList:"
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,4c,6f,77,5c,45,6d,69,65,53,69,74,65,4c,69,73,74,00
"CacheOptions"=dword:00000300
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\EmieUserList]
"CachePrefix"="EmieUserList:"
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,4c,6f,77,5c,45,6d,69,65,55,73,65,72,4c,69,73,74,00
"CacheOptions"=dword:00000300
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\feedplat]
"CachePath"=hex(2):25,55,53,45,52,50,52,4f,46,49,4c,45,25,5c,41,70,70,44,61,74,\
  61,5c,4c,6f,63,61,6c,5c,4d,69,63,72,6f,73,6f,66,74,5c,46,65,65,64,73,20,43,\
  61,63,68,65,00
"CachePrefix"="feedplat:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000000
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\iecompat]
"CachePrefix"="iecompat:"
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,43,6f,6d,70,61,74,43,61,63,68,65,5c,4c,6f,77,\
  00
"CacheOptions"=dword:00000309
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\iecompatua]
"CachePrefix"="iecompatua:"
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,69,65,63,6f,6d,70,61,74,75,61,43,61,63,68,65,5c,4c,\
  6f,77,00
"CacheOptions"=dword:00000309
"CacheRepair"=dword:00000000
"CacheLimit"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\iedownload]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,44,6f,77,6e,6c,6f,61,64,48,69,73,74,6f,72,79,\
  00
"CachePrefix"="iedownload:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\ietld]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,49,45,54,6c,64,43,61,63,68,65,5c,4c,6f,77,00
"CachePrefix"="ietld:"
"CacheLimit"=dword:00002000
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\Extensible Cache\PrivacIE:]
"CachePath"=hex(2):25,41,50,50,44,41,54,41,25,5c,4d,69,63,72,6f,73,6f,66,74,5c,\
  57,69,6e,64,6f,77,73,5c,50,72,69,76,61,63,49,45,5c,4c,6f,77,00
"CachePrefix"="PrivacIE:"
"CacheLimit"=dword:00000400
"CacheOptions"=dword:00000009
"CacheRepair"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\LowCache\History]
"CachePrefix"="Visited:"
"CacheLimit"=dword:00002000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\NSCookieUpgrade]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\User Agent]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\User Agent\Post Platform]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Activities]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\CACHE]
"Persistent"=dword:00000000
"LastScavenge"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections]
"DefaultConnectionSettings"=hex:46,00,00,00,85,04,00,00,05,00,00,00,00,00,00,\
  00,00,00,00,00,3b,00,00,00,68,74,74,70,3a,2f,2f,70,72,6f,78,79,2e,63,61,72,\
  6e,69,76,61,6c,2e,63,6f,6d,3a,38,30,38,30,2f,61,72,72,61,79,2e,64,6c,6c,3f,\
  47,65,74,2e,52,6f,75,74,69,6e,67,2e,53,63,72,69,70,74,01,00,00,00,27,00,00,\
  00,68,74,74,70,3a,2f,2f,70,72,6f,78,79,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,\
  6d,3a,38,30,38,30,2f,77,70,61,64,2e,64,61,74,55,22,39,13,03,d8,cf,01,00,00,\
  00,00,00,00,00,00,00,00,00,00,03,00,00,00,02,00,00,00,0a,f0,8c,0b,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,c0,a8,38,01,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,0a,\
  f0,d0,aa,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"SavedLegacySettings"=hex:46,00,00,00,8b,0a,00,00,05,00,00,00,00,00,00,00,00,\
  00,00,00,3b,00,00,00,68,74,74,70,3a,2f,2f,70,72,6f,78,79,2e,63,61,72,6e,69,\
  76,61,6c,2e,63,6f,6d,3a,38,30,38,30,2f,61,72,72,61,79,2e,64,6c,6c,3f,47,65,\
  74,2e,52,6f,75,74,69,6e,67,2e,53,63,72,69,70,74,01,00,00,00,27,00,00,00,68,\
  74,74,70,3a,2f,2f,70,72,6f,78,79,2e,63,61,72,6e,69,76,61,6c,2e,63,6f,6d,3a,\
  38,30,38,30,2f,77,70,61,64,2e,64,61,74,55,22,39,13,03,d8,cf,01,00,00,00,00,\
  00,00,00,00,00,00,00,00,03,00,00,00,02,00,00,00,0a,f0,8c,0b,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,c0,a8,38,01,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,02,00,00,00,0a,f0,d0,\
  aa,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Http Filters]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\0]
@=""
"DisplayName"="Computer"
"PMDisplayName"="Computer [Protected Mode]"
"Description"="Your computer"
"Icon"="shell32.dll#0016"
"LowIcon"="inetcpl.cpl#005422"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000000
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000000
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000003
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000000
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1812"=dword:00000000
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000003
"2701"=dword:00000003
"2702"=dword:00000003
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\1]
@=""
"DisplayName"="Local intranet"
"PMDisplayName"="Local intranet [Protected Mode]"
"Description"="This zone contains all Web sites that are on your organization's intranet."
"Icon"="shell32.dll#0018"
"LowIcon"="inetcpl.cpl#005423"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000143
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000001
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000000
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000001
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000003
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1812"=dword:00000000
"1A00"=dword:00020000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000003
"2703"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\2]
@=""
"DisplayName"="Trusted sites"
"PMDisplayName"="Trusted sites [Protected Mode]"
"Description"="This zone contains Web sites that you trust not to damage your computer or data."
"Icon"="inetcpl.cpl#00004480"
"LowIcon"="inetcpl.cpl#005424"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000000
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000000
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1812"=dword:00000000
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000001
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000003
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000000
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000000
"2701"=dword:00000000
"2702"=dword:00000000
"2703"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\3]
@=""
"DisplayName"="Internet"
"PMDisplayName"="Internet [Protected Mode]"
"Description"="This zone contains all Web sites you haven't placed in other zones"
"Icon"="inetcpl.cpl#001313"
"LowIcon"="inetcpl.cpl#005425"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000001
"1001"=dword:00000001
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000003
"1207"=dword:00000003
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000003
"1407"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000000
"1601"=dword:00000001
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000001
"1806"=dword:00000001
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"1812"=dword:00000001
"1A00"=dword:00020000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000001
"1A06"=dword:00000000
"1A10"=dword:00000001
"1C00"=dword:00000000
"2000"=dword:00010000
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000003
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001
"2301"=dword:00000000
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000000
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000000
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\4]
@=""
"DisplayName"="Restricted sites"
"PMDisplayName"="Restricted sites [Protected Mode]"
"Description"="This zone contains Web sites that could potentially damage your computer or data."
"Icon"="inetcpl.cpl#00004481"
"LowIcon"="inetcpl.cpl#005426"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1200"=dword:00000003
"1400"=dword:00000003
"1001"=dword:00000003
"1004"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000003
"1207"=dword:00000003
"1402"=dword:00000003
"1405"=dword:00000003
"1406"=dword:00000003
"1407"=dword:00000003
"1408"=dword:00000003
"1409"=dword:00000000
"1601"=dword:00000001
"1604"=dword:00000001
"1605"=dword:00000000
"1606"=dword:00000003
"1607"=dword:00000003
"1608"=dword:00000003
"1609"=dword:00000001
"160A"=dword:00000003
"1802"=dword:00000001
"1803"=dword:00000003
"1804"=dword:00000003
"1805"=dword:00000001
"1806"=dword:00000003
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"180B"=dword:00000003
"1812"=dword:00000001
"1A00"=dword:00010000
"1A02"=dword:00000003
"1A03"=dword:00000003
"1A04"=dword:00000003
"1A05"=dword:00000003
"1A06"=dword:00000003
"1A10"=dword:00000003
"1C00"=dword:00000000
"2000"=dword:00000003
"2005"=dword:00000003
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000003
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001
"2301"=dword:00000000
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2400"=dword:00000003
"2401"=dword:00000003
"2402"=dword:00000003
"2600"=dword:00000003
"2500"=dword:00000000
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000000
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\P3P]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Passport]
"NumRegistrationRuns"=dword:00000006
"LoginServerRealm"="Passport.Net"
"LoginServerUrl"="https://login.live.com/login2.srf"
"RegistrationUrl"="https://login.live.com/err.srf"
"Properties"="https://account.live.com/EditProf.aspx?lcid=%L"
"Privacy"="https://login.live.com/gls.srf?urlID=MSNPrivacyStatement&lc=%L"
"GeneralRedir"="http://nexusrdr.passport.com/redir.asp"
"Help"="https://account.live.com/?lcid=%L&dc=PPRDR_Help"
"ConfigVersion"=dword:0000000f

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Passport\DAMap]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Passport\LowDAMap]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Protocols]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Protocols\Mailto]
"UTF8Encoding"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\TemplatePolicies]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\TemplatePolicies\High]
"1400"=dword:00000003

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Url History]
"DaysToKeep"=dword:00000014

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad]
"WpadLastNetwork"="{463E95C8-B144-464B-B1A9-111DBFCE7526}_{D8081AC1-4B37-446F-90C7-FF45428651D7}"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{11A98A6D-A98B-458C-AC05-4E82EB12D308}_{D8081AC1-4B37-446F-90C7-FF45428651D7}]
"WpadDecisionReason"=dword:00000000
"WpadDecisionTime"=hex:70,65,f0,ca,43,c8,cf,01
"WpadDecision"=dword:00000001
"WpadNetworkName"="Unidentified network"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{463E95C8-B144-464B-B1A9-111DBFCE7526}_{645150DC-351F-4BF1-95E5-F6510AE1AC51}]
"WpadDecisionReason"=dword:00000001
"WpadDecisionTime"=hex:50,e0,58,42,29,d5,cf,01
"WpadDecision"=dword:00000000
"WpadNetworkName"="Unidentified network"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{463E95C8-B144-464B-B1A9-111DBFCE7526}_{D8081AC1-4B37-446F-90C7-FF45428651D7}]
"WpadDecisionReason"=dword:00000000
"WpadDecisionTime"=hex:b0,7a,28,c7,f9,d3,cf,01
"WpadDecision"=dword:00000001
"WpadNetworkName"="carnivalcorp.com"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad\{6CFC3AEE-A1C3-47FB-ACA9-B887174FBDA8}_{D8081AC1-4B37-446F-90C7-FF45428651D7}]
"WpadDecisionReason"=dword:00000000
"WpadDecisionTime"=hex:60,9f,4a,55,08,cd,cf,01
"WpadDecision"=dword:00000001
"WpadNetworkName"="carnivalcorp.com"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap]
@=""
"ProxyByPass"=dword:00000001
"IntranetName"=dword:00000001
"UNCAsIntranet"=dword:00000001
"AutoDetect"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains]
@=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\carnival.com]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\carnivalgroup.com]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\cclprdcmdp1]
"http"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\cclprdpfe]
"http"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\corporate-ir.net]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\intranet]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ux15.pcb]
"*"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\cclprdcmdp1]
"http"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\microsoft.com]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\microsoft.com\*.update]
"http"=dword:00000002
"https"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\ProtocolDefaults]
@=""
"http"=dword:00000003
"https"=dword:00000003
"ftp"=dword:00000003
"file"=dword:00000003
"@ivt"=dword:00000001
"shell"=dword:00000000
"knownfolder"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges]
@=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones]
@=""
"SelfHealCount"=dword:00000001
"SecuritySafe"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0]
"2004"=dword:00000000
"2001"=dword:00000000
@=""
"DisplayName"="My Computer"
"Description"="Your computer"
"Icon"="explorer.exe#0100"
"CurrentLevel"=dword:00000000
"Flags"=dword:00000021
"1001"=dword:00000000
"1004"=dword:00000000
"1200"=dword:00000000
"1201"=dword:00000001
"1206"=dword:00000000
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"1800"=dword:00000000
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000000
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00020000
"1E05"=dword:00030000
"2100"=dword:00000000
"2101"=dword:00000003
"2102"=dword:00000000
"2200"=dword:00000000
"2201"=dword:00000000
"2300"=dword:00000001
"2000"=dword:00000000
"1207"=dword:00000000
"PMDisplayName"="Computer [Protected Mode]"
"LowIcon"="inetcpl.cpl#005422"
"2007"=dword:00000003
"1408"=dword:00000000
"1409"=dword:00000003
"160A"=dword:00000000
"1812"=dword:00000000
"2005"=dword:00000000
"1208"=dword:00000000
"1209"=dword:00000000
"120A"=dword:00000000
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000000
"2104"=dword:00000000
"2105"=dword:00000000
"2106"=dword:00000000
"2107"=dword:00000000
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2500"=dword:00000003
"2700"=dword:00000003
"2701"=dword:00000000
"2702"=dword:00000003
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1]
"2004"=dword:00000000
"2001"=dword:00000000
@=""
"DisplayName"="Local intranet"
"Description"="This zone contains all Web sites that are on your organization's intranet."
"Icon"="shell32.dll#0018"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00010000
"RecommendedLevel"=dword:00010500
"Flags"=dword:000000db
"1001"=dword:00000001
"1004"=dword:00000003
"1200"=dword:00000000
"1201"=dword:00000003
"1206"=dword:00000000
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000001
"1407"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"1800"=dword:00000001
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1A00"=dword:00020000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000000
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00020000
"1E05"=dword:00020000
"2100"=dword:00000000
"2101"=dword:00000000
"2102"=dword:00000000
"2200"=dword:00000000
"2201"=dword:00000000
"2300"=dword:00000001
"2000"=dword:00000000
"1207"=dword:00000000
"PMDisplayName"="Local intranet [Protected Mode]"
"LowIcon"="inetcpl.cpl#005423"
"2500"=dword:00000003
"2007"=dword:00010000
"2402"=dword:00000000
"2400"=dword:00000000
"2401"=dword:00000000
"1208"=dword:00000000
"1209"=dword:00000000
"120A"=dword:00000003
"2600"=dword:00000000
"2104"=dword:00000000
"160A"=dword:00000000
"2301"=dword:00000003
"2103"=dword:00000000
"2105"=dword:00000000
"1409"=dword:00000003
"1408"=dword:00000000
"2005"=dword:00000000
"2106"=dword:00000000
"2700"=dword:00000003
"2107"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000
"1812"=dword:00000000
"120B"=dword:00000000
"180A"=dword:00000000
"180C"=dword:00000000
"180D"=dword:00000000
"2701"=dword:00000000
"2702"=dword:00000003
"2703"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2]
"2001"=dword:00000000
"2004"=dword:00000000
@=""
"DisplayName"="Trusted sites"
"Description"="This zone contains Web sites that you trust not to damage your computer or data."
"Icon"="inetcpl.cpl#00004480"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00010000
"RecommendedLevel"=dword:00010000
"Flags"=dword:00000043
"1001"=dword:00000000
"1004"=dword:00000000
"1200"=dword:00000000
"1201"=dword:00000000
"1206"=dword:00000000
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000000
"1407"=dword:00000000
"1601"=dword:00000000
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000000
"1800"=dword:00000000
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000000
"1805"=dword:00000000
"1806"=dword:00000000
"1807"=dword:00000000
"1808"=dword:00000000
"1809"=dword:00000003
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000000
"1A05"=dword:00000000
"1A06"=dword:00000000
"1A10"=dword:00000000
"1C00"=dword:00030000
"1E05"=dword:00030000
"2100"=dword:00000000
"2101"=dword:00000001
"2102"=dword:00000000
"2200"=dword:00000000
"2201"=dword:00000000
"2300"=dword:00000001
"2000"=dword:00000000
"1207"=dword:00000000
"PMDisplayName"="Trusted sites [Protected Mode]"
"LowIcon"="inetcpl.cpl#005424"
"1208"=dword:00000000
"1209"=dword:00000000
"120A"=dword:00000003
"1408"=dword:00000000
"1409"=dword:00000003
"160A"=dword:00000000
"2005"=dword:00000000
"2103"=dword:00000000
"2104"=dword:00000000
"2105"=dword:00000000
"2106"=dword:00000000
"2301"=dword:00000003
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2700"=dword:00000003
"2007"=dword:00010000
"2107"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000
"1812"=dword:00000000
"2500"=dword:00000003
"140A"=dword:00000000
"2302"=dword:00000003
"270B"=dword:00000000
"160B"=dword:00000000
"270C"=dword:00000003
"270D"=dword:00000000
"2701"=dword:00000000
"2702"=dword:00000003
"2703"=dword:00000000
"2704"=dword:00000000
"2108"=dword:00000003
"120B"=dword:00000000
"180A"=dword:00000003
"180C"=dword:00000000
"180D"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3]
"2004"=dword:00000000
"2001"=dword:00000000
@=""
"DisplayName"="Internet"
"Description"="This zone contains all Web sites you haven't placed in other zones"
"Icon"="inetcpl.cpl#001313"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00011000
"RecommendedLevel"=dword:00011000
"Flags"=dword:00000001
"1001"=dword:00000001
"1004"=dword:00000003
"1200"=dword:00000000
"1201"=dword:00000003
"1206"=dword:00000003
"1400"=dword:00000000
"1402"=dword:00000000
"1405"=dword:00000000
"1406"=dword:00000003
"1407"=dword:00000000
"1601"=dword:00000001
"1604"=dword:00000000
"1605"=dword:00000000
"1606"=dword:00000000
"1607"=dword:00000000
"1608"=dword:00000000
"1609"=dword:00000001
"1800"=dword:00000001
"1802"=dword:00000000
"1803"=dword:00000000
"1804"=dword:00000001
"1805"=dword:00000001
"1806"=dword:00000001
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"1A00"=dword:00000000
"1A02"=dword:00000000
"1A03"=dword:00000000
"1A04"=dword:00000003
"1A05"=dword:00000001
"1A06"=dword:00000000
"1A10"=dword:00000001
"1C00"=dword:00010000
"1E05"=dword:00020000
"2100"=dword:00000000
"2101"=dword:00000000
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"2300"=dword:00000001
"2000"=dword:00000000
"{AEBA21FA-782A-4A90-978D-B72164C80120}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,1e,28,1a,04,1b,0c,3b,c2,21,27,53,0d,36,05,2c,05,\
  04,3d,4f,3a,4a,44,33,3a,0a,06,12,68,53,7c,20,13,35,5d,4c,10,27,01,56,7a,2d,\
  3f,38,4f,79,0f,16,26,75,53,1c,31,00,56,7a,3e,32,24,4f,79,1b,00,33,71,4d,23,\
  32,29,7c,6a,35,31,34,40,72,3b,01,2e,5d,4c,2a,07,15,48,72,38,12,00,56,7a,3e,\
  16,3c,71,4d,24,33,35,7c,72,35,0e,3c,1a,41,44,19,0f,31,3a,56,7a,2e,3e,31,0c,\
  7c,6a,10,27,0c,05,5d,4c,39,19,12,15,61,54,2e,00,33,32,40,52,03,25,1f,05,5d,\
  4c,2c,0c,0a,15,61,54,1a,26,1f,05,5d,4c,10,21,1d,1b,71,4d,3b,24,3a,21,6d,72,\
  24,16,3c,32,40,72,21,0f,3a,1a,41,44,1b,1e,01,01,71,4d,32,23,30,27,6d,4d,1f,\
  28,10,3c,56,7a,2f,2e,32,16,7c,6a,3a,12,3b,28,75,53,0b,3f,12,01,71,4d,23,32,\
  29,27,75,53,12,30,32,1e,4f,79,12,38,17,01,71,4d,30,3e,37,27,6d,72,38,12,3f,\
  04,41,44,0a,0e,32,28,49,5f,1c,24,0b,1b,36,21,41,7b,5b,24,39,31,7c,6a,2b,0e,\
  25,75,53,1a,2e,26,41,72,34,16,26,71,4d,30,30,3a,7c,6a,07,33,1a,56,7a,3a,00,\
  33,71,4d,23,32,29,7c,6a,1a,26,1a,40,52,24,3f,1a,6d,4d,1c,22,28,75,53,13,25,\
  20,41,44,0a,0e,32,75,53,08,07,20,71,4d,10,27,0d,05,5d,4c,24,1a,1e,1b,71,4d,\
  3f,20,3f,21,6d,4d,10,27,0c,05,5d,4c,39,19,12,3a,56,7a,3a,20,2c,0c,7c,6a,3e,\
  0c,37,07,75,53,12,30,32,3a,56,7a,25,2d,23,0c,7c,6a,2b,08,21,3a,56,7a,22,3a,\
  32,3a,56,72,24,1e,26,1a,41,44,07,1f,03,1b,75,53,1c,31,01,01,71,4d,32,23,30,\
  27,6d,72,34,1e,30,04,41,44,1b,1e,3b,28,49,5f,07,33,12,1b,5d,4c,35,0b,0a,1f,\
  75,53,0b,00,34,28,40,72,3b,01,2d,04,41,44,01,05,34,28,40,52,22,36,04,34,48,\
  72,38,12,3f,04,41,44,0a,0e,1f,01,71,4d,24,33,35,27,06,1c,68,53,49,14,21,01,\
  40,52,10,27,0d,40,52,2c,29,05,6d,4d,1f,28,05,56,7a,2f,2e,32,75,53,07,33,12,\
  40,52,3f,3a,19,6d,72,20,00,34,71,4d,1a,26,1a,40,52,24,3f,1a,6d,72,35,08,38,\
  5d,4c,2d,01,18,48,7a,27,23,1f,56,7a,3b,2f,3f,4f,79,08,39,01,1b,71,72,33,1f,\
  39,3a,56,7a,2e,3e,31,0c,7c,72,35,0e,3f,1a,41,44,0a,0a,35,3a,56,7a,3a,20,2c,\
  0c,7c,6a,03,25,1f,05,5d,4c,2c,0c,0a,15,61,54,27,05,34,32,40,52,10,21,09,05,\
  5d,4c,2d,01,18,15,61,54,07,37,17,05,5d,4c,1c,24,03,1b,71,4d,30,30,3b,27,6d,\
  72,33,17,3f,28,40,72,34,1e,30,04,41,44,1b,1e,00,01,71,4d,2f,2c,2c,27,6d,4d,\
  0b,26,3f,3c,56,7a,3a,20,23,16,7c,6a,35,05,33,28,75,53,12,30,17,01,71,4d,30,\
  3e,37,27,75,53,13,25,20,1e,4f,79,1f,29,1f,01,71,4d,24,33,35,27,06,21,41,7b,\
  5b,3d,24,37,7c,6a,2b,0e,25,40,72,33,1f,39,5d,72,34,1e,30,5d,4c,2a,0d,18,48,\
  7a,27,12,3b,71,4d,23,32,12,56,72,20,0c,2e,5d,4c,2c,0c,0a,75,53,1a,26,1f,40,\
  72,35,08,38,5d,4c,2d,01,18,75,53,0f,21,27,41,44,07,1f,3e,61,54,3d,06,22,32,\
  40,52,2c,29,05,32,48,72,34,1e,05,1b,71,4d,10,27,0c,05,5d,4c,39,19,1a,1b,71,\
  4d,23,32,24,21,6d,4d,03,25,1f,05,5d,4c,2c,0c,0a,3a,56,7a,25,2d,23,0c,7c,6a,\
  2b,08,21,07,75,53,13,25,20,3a,56,7a,3e,3e,3b,0c,7c,6a,3f,0f,23,3a,56,7a,2f,\
  2e,3d,3c,56,72,33,1f,39,04,41,44,1a,0e,05,01,75,53,1c,31,00,01,71,4d,2f,2c,\
  2c,27,6d,72,20,0c,2d,04,41,44,06,18,2a,28,49,5f,1a,26,1a,1b,5d,4c,2c,0c,0f,\
  1f,75,53,1c,1c,3e,28,40,72,38,12,3f,04,41,44,0a,16,3c,28,40,52,3e,39,06,34,\
  21,21,41,7b,5b,23,27,3c,7c,6a,17,37,17,40,52,32,24,05,6d,4d,0e,21,2c,75,53,\
  0b,31,31,75,53,08,3e,21,41,44,07,1e,3c,61,54,17,37,17,05,5d,4c,00,33,1e,1b,\
  71,4d,2e,39,3b,21,6d,72,20,06,32,32,40,72,21,0f,3c,1a,41,44,1a,0e,1f,01,71,\
  4d,20,2c,30,27,6d,4d,0e,21,2c,3c,56,7a,3a,2e,2d,16,7c,6a,3f,07,22,28,6e,02,\
  68,4a,7c,21,09,26,5d,4c,29,1d,1f,56,7a,3f,32,38,4f,79,1e,30,01,56,7a,3a,2e,\
  2d,4f,79,14,07,22,71,4d,24,30,3b,7c,6a,2a,1e,2f,07,75,53,0c,2d,26,3a,56,7a,\
  31,25,3d,0c,7c,6a,3e,0e,35,3a,56,7a,3b,2f,3d,3a,56,72,34,1e,26,04,41,44,0b,\
  0a,1e,01,75,53,0e,38,01,01,71,4d,23,30,2b,27,6d,72,21,0f,3c,04,28,1b,67,6b,\
  5f,00,22,10,75,53,1f,21,27,41,44,0b,0a,31,75,53,0e,1d,22,71,4d,03,27,1d,40,\
  52,3e,39,08,75,53,08,31,21,41,44,1a,0e,32,3a,56,7a,3f,32,38,0c,7c,6a,06,3e,\
  0d,05,5d,4c,35,0d,09,15,61,54,29,07,22,32,40,52,17,37,17,1b,5d,4c,3a,19,16,\
  1f,61,54,06,3e,0d,1b,5d,4c,03,27,11,01,71,4d,24,33,3b,27,06,21,41,73,41,11,\
  25,1d,56,7a,2e,3e,3b,4f,79,18,12,3f,71,4d,2e,39,3b,7c,6a,3e,0e,35,40,72,21,\
  0f,3c,5d,4c,36,0d,19,48,72,34,1e,1f,1b,71,4d,00,33,16,05,5d,4c,38,04,01,1b,\
  71,4d,23,30,2b,21,6d,4d,1c,24,0d,05,5d,4c,29,1d,17,3c,56,7a,3f,32,38,16,7c,\
  6a,39,09,25,09,75,53,0b,31,31,3c,56,7a,3b,2f,3d,16,15,39,5f,7b,42,03,38,02,\
  40,20,2c,1e,4f,37,41,7b,5b,23,27,3c,7c,14,07,22,6e,14,68,4a,7c,20,13,35,5d,\
  30,37,08,06,37,41,7b,5b,23,27,3c,7c,1b,39,1d,30,02,7c,50,68,3a,3b,34,4f,1b,\
  1e,3b,6e,14,68,73,41,0b,22,0a,56,12,30,32,28,09,67,73,41,0b,22,2a,41,2c,0c,\
  0f,21,37,41,7b,5b,23,27,3c,7c,08,1c,3e,66,0e,44,4f,56,06,13,05,61,27,23,1f,\
  4f,3f,5b,53,7c,20,13,35,5d,3e,39,06,06,0a,68,53,7c,21,09,26,5d,32,12,3f,6e,\
  14,68,4a,44,3e,37,02,6d,1c,24,01,4f,3f,5b,73,41,08,38,27,41,38,04,19,6e,14,\
  68,4a,44,3e,37,02,6d,3e,0e,35,3b,37,41,7b,5b,24,39,31,7c,08,39,00,4f,3f,7c,\
  50,68,3b,1d,3c,71,25,2d,2c,20,3a,7c,50,68,3b,25,3b,4f,01,1d,2a,6e,14,68,4a,\
  44,3e,37,02,6d,10,21,09,29,1f,5e,45,67,14,30,07,49,12,16,3c,66,0e,44,73,41,\
  08,38,27,41,36,0a,1b,21,3f,42,73,41,10,3b,2d,41,00,33,1e,4f,3f,5b,53,5e,2e,\
  07,1d,75,21,07,22,66,0e,7c,50,68,23,24,31,4f,0d,15,01,4f,3f,5b,53,5e,2e,07,\
  1d,48,0b,18,3c,6e,14,68,4a,44,26,36,0c,6d,2b,06,25,66,37,41,7b,5b,14,21,01,\
  40,3a,31,24,15,37,41,7b,5b,3c,3e,3f,7c,12,38,17,4f,3f,5b,53,5e,2e,07,1d,75,\
  35,08,38,36,03,56,76,74,37,08,19,40,07,37,17,29,1f,7c,50,68,23,24,31,4f,07,\
  1f,3e,16,17,7c,50,68,20,3a,39,75,25,12,3f,66,0e,44,4f,56,1c,12,1d,56,1c,24,\
  0d,29,37,41,7b,5b,3d,24,37,7c,1e,1d,22,66,0e,44,4f,56,1c,12,30,61,23,13,11,\
  4f,3f,5b,53,5e,2f,01,15,48,10,27,0c,6e,14,68,4a,7c,36,12,38,5d,24,3f,19,6e,\
  14,68,4a,44,21,2c,04,6d,35,05,34,66,0e,44,4f,56,1c,12,1d,56,1c,3b,25,28,09,\
  67,6b,5f,01,2c,28,75,24,1e,26,36,37,41,7b,5b,3d,24,37,7c,14,3a,0b,30,37,41,\
  7b,5b,36,0c,7c
"{A8A88C49-5EB2-4990-A1A2-0876022C854F}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,1e,28,1a,04,1b,0c,3b,c2,21,2d,53,49,07,25,0f,29,\
  01,7c,50,68,3a,3b,34,4f,79,08,39,0d,49,72,33,1f,39,5d,4c,17,37,05,56,7a,2f,\
  2e,32,4f,79,1f,12,3b,75,53,0b,3f,12,56,7a,3a,20,23,4f,79,12,05,33,71,4d,3a,\
  31,29,7c,6a,2b,08,21,40,72,38,12,3f,5d,4c,39,1d,17,48,72,21,0f,03,56,7a,2f,\
  06,22,32,40,52,2c,29,05,3a,56,7a,2e,3e,31,0c,7c,6a,2b,06,25,32,40,52,33,24,\
  01,32,75,53,0b,3f,32,04,4f,79,1b,3b,1f,0c,40,72,3b,01,2d,1a,75,53,12,30,3f,\
  04,4f,79,08,3f,09,0c,75,53,13,25,20,04,75,53,07,37,17,05,5d,4c,36,0a,1b,3a,\
  56,72,35,0e,3c,3c,56,7a,2d,3f,38,16,7c,6a,17,37,01,1b,5d,4c,2a,0d,18,1f,61,\
  54,12,12,3b,28,40,52,3f,3a,19,34,48,72,20,0c,17,01,71,4d,1a,26,1a,1b,5d,4c,\
  2c,0c,17,01,71,4d,30,3e,37,27,6d,4d,1b,3b,0c,1b,5d,4c,39,1d,17,3c,56,7a,3b,\
  2f,3f,16,15,39,5f,7b,42,29,1d,3c,71,4d,30,06,22,71,4d,32,23,30,7c,6a,2a,1e,\
  19,75,53,1c,31,20,41,72,24,12,3b,71,4d,23,32,24,7c,6a,03,25,17,56,7a,25,05,\
  33,71,4d,3a,31,29,7c,6a,10,21,09,40,52,27,2c,0b,6d,4d,0f,28,2a,75,53,08,3e,\
  23,41,44,1b,1e,3c,3a,56,7a,12,34,16,05,75,53,1f,21,2d,04,4f,79,10,27,0c,05,\
  5d,4c,39,19,12,15,75,53,0b,3f,32,04,4f,79,1b,00,34,32,40,52,24,3f,19,32,48,\
  7a,2c,10,17,1b,71,4d,30,1c,3e,32,40,52,27,2c,0b,32,48,7a,27,16,3c,32,40,52,\
  3e,07,20,3a,56,7a,2f,2e,3d,16,7c,6a,12,34,1e,01,71,4d,17,37,01,1b,5d,4c,2a,\
  0d,18,3c,56,7a,3e,32,24,16,7c,6a,3e,0c,34,09,75,53,0b,3f,3f,1e,4f,79,12,38,\
  12,01,71,72,3b,01,2e,3c,56,7a,2f,24,39,16,7c,72,38,12,3f,04,41,44,0a,0e,32,\
  3c,56,7a,3b,2f,3f,16,15,39,7c,50,68,23,24,31,4f,79,08,39,0d,49,5f,12,34,16,\
  40,52,17,37,01,40,52,22,38,0b,6d,4d,0f,34,1a,56,7a,3a,20,2c,75,53,03,25,1f,\
  40,52,24,3f,19,6d,72,3b,05,34,71,4d,10,21,09,40,52,27,2c,0b,6d,72,24,1e,26,\
  5d,4c,36,0a,1b,48,7a,36,13,01,1b,71,4d,32,23,30,21,6d,4d,17,37,01,3a,56,7a,\
  2f,06,25,32,40,52,33,24,01,3a,56,7a,3a,20,2c,0c,7c,6a,3e,00,34,32,40,52,24,\
  3f,19,32,75,53,12,30,3f,04,4f,79,08,3f,09,0c,40,72,38,12,3f,1a,75,53,0f,21,\
  27,04,4f,79,14,3a,0b,0c,75,53,1c,31,21,1e,75,53,12,34,16,1b,5d,4c,29,1d,1d,\
  3c,56,72,35,0e,3f,3c,56,7a,3e,32,24,16,7c,6a,03,25,1a,1b,5d,4c,35,0b,0f,1f,\
  61,54,27,05,33,28,40,52,24,3f,1a,34,48,72,35,08,1d,01,71,4d,1b,3b,0c,1b,5d,\
  4c,39,1d,1f,01,71,4d,24,33,35,27,06,1c,7c,50,68,20,3a,39,4f,79,08,06,22,71,\
  4d,32,23,30,7c,6a,2a,1e,19,40,72,35,0e,3f,5d,72,24,1a,25,5d,4c,35,0b,0a,48,\
  7a,23,00,34,71,4d,3a,31,12,56,72,3b,01,2e,5d,4c,2a,07,15,75,53,1b,3b,0c,40,\
  72,24,1e,26,5d,4c,36,0a,1b,75,53,1c,31,21,04,4f,79,0a,2a,06,0c,40,72,34,1e,\
  30,1a,41,44,1b,1e,3b,3a,56,7a,07,33,12,05,75,53,0b,3f,32,04,4f,79,03,25,1f,\
  05,5d,4c,2c,0c,0a,15,75,53,12,30,3f,04,4f,79,08,1c,3e,32,40,52,27,2c,0b,32,\
  48,7a,27,23,1f,1b,71,4d,24,07,20,32,40,52,22,38,08,34,48,7a,34,17,3f,28,40,\
  52,23,16,26,3c,56,7a,2f,2e,32,16,7c,6a,07,33,1a,01,71,4d,03,25,1a,1b,5d,4c,\
  35,0b,0f,3c,56,7a,25,2d,2c,16,7c,6a,35,31,37,09,75,53,1c,3b,25,1e,4f,79,13,\
  35,00,01,71,72,24,1e,26,3c,56,7a,3b,2f,3f,16,15,21,41,7b,5b,23,27,3c,7c,6a,\
  2a,16,3c,71,4d,20,2c,30,7c,6a,06,3e,0d,40,52,3f,38,18,6d,4d,08,27,2c,75,53,\
  08,31,21,75,53,1f,21,27,04,4f,79,18,2d,06,0c,75,53,0e,38,21,04,75,53,03,27,\
  1d,05,5d,4c,36,0a,19,3a,56,72,34,1e,26,3c,56,7a,3f,32,38,16,7c,6a,06,3e,0d,\
  1b,5d,4c,35,0d,09,1f,61,54,29,07,22,28,29,01,5e,45,67,14,30,1f,56,7a,17,37,\
  17,40,72,25,1a,39,5d,4c,38,04,01,56,7a,3a,2e,2d,4f,79,14,3a,01,56,7a,3b,2e,\
  3d,4f,79,0f,16,3c,32,40,52,32,24,05,32,48,7a,18,28,01,1b,71,4d,23,06,32,32,\
  40,52,3e,39,08,32,48,7a,37,16,3c,28,40,52,32,12,3f,3c,56,7a,31,25,3d,16,7c,\
  6a,03,27,11,01,71,4d,1c,24,0d,1b,36,1d,56,76,74,14,21,01,40,52,23,28,02,6d,\
  4d,0c,34,2b,75,53,0e,38,21,41,44,06,1e,2c,75,53,08,07,22,71,4d,1c,27,0d,40,\
  52,23,28,02,3a,56,7a,3f,32,38,0c,7c,6a,39,1d,22,32,40,52,3f,38,18,32,75,53,\
  08,3e,21,04,4f,79,0f,29,07,02,40,72,25,1a,39,04,75,53,0e,38,21,1e,4f,79,1b,\
  39,1d,02,75,53,08,3e,21,1e,6e,02,7c,50,68,20,3a,39,4f,79,0f,16,3c,75,53,0c,\
  2d,1e,56,7a,31,25,3d,4f,79,1b,06,32,71,4d,24,33,3b,7c,6a,3f,0e,25,40,72,34,\
  1e,26,1a,41,44,0b,0a,31,3a,56,7a,06,3e,0d,05,75,53,0b,31,31,04,4f,79,1c,24,\
  0d,05,5d,4c,29,1d,17,1f,75,53,0c,2d,26,1e,4f,79,1e,1d,22,28,40,52,3f,38,18,\
  34,48,7a,22,12,01,01,66,1c,44,73,41,0b,22,2a,41,3a,19,16,21,2d,42,73,41,0b,\
  22,2a,41,1c,24,01,4f,2d,5b,53,5e,35,1e,22,75,27,1d,22,66,1c,7c,50,68,3a,3b,\
  34,4f,06,1e,11,4f,2d,5b,53,5e,35,1e,22,48,1c,18,2d,6e,02,68,4a,44,3f,2d,31,\
  6d,35,05,33,66,21,41,7b,5b,03,38,02,40,3a,31,29,15,21,41,7b,5b,23,27,3c,7c,\
  08,3f,1d,4f,2d,5b,53,5e,35,1e,22,75,24,1e,26,36,1d,56,76,74,3e,03,1c,40,1c,\
  24,0b,29,01,7c,50,68,3b,25,3b,4f,0b,0a,31,16,05,7c,50,68,3b,25,3b,75,21,07,\
  22,66,1c,44,4f,56,07,15,1f,56,06,3e,0d,29,21,41,7b,5b,24,39,31,7c,1b,06,32,\
  66,1c,44,4f,56,07,15,32,61,36,13,00,4f,2d,5b,53,5e,36,04,17,48,1a,26,1a,6e,\
  02,68,4a,7c,21,09,26,5d,24,3f,1a,6e,02,68,4a,44,3e,37,02,6d,2b,1c,3e,66,1c,\
  44,4f,56,07,15,1f,56,0f,21,27,28,1b,67,6b,5f,08,21,2a,75,21,0f,3a,36,21,41,\
  7b,5b,3c,3e,3f,7c,18,2d,06,30,21,41,7b,5b,3c,3e,05,56,1c,24,0d,29,01,5e,45,\
  67,0c,1c,26,75,27,09,3c,6e,02,68,4a,44,26,36,0c,6d,03,27,1d,29,01,5e,45,67,\
  0c,3f,31,49,3d,06,25,66,1c,44,4f,56,1f,14,38,75,3b,01,12,4f,2d,5b,73,41,10,\
  3b,2d,41,2c,0c,17,4f,2d,5b,53,5e,2e,07,1d,48,10,21,09,29,01,5e,45,67,0c,1c,\
  26,71,3e,3e,3b,20,28,74,4e,68,2a,29,05,56,08,3e,23,6e,02,68,4a,44,21,2c,04,\
  6d,3b,1a,20,6e,02,68,4a,44,21,1a,3e,75,21,0f,3c,36,1d,56,76,74,15,3b,1d,56,\
  0e,38,01,4f,2d,5b,53,5e,2f,01,15,75,20,0e,2c,36,1d,56,76,74,28,02,21,40,10,\
  27,0c,29,01,5e,45,67,0d,35,1d,56,12,05,33,66,1c,7c,50,68,20,3a,39,4f,01,05,\
  34,66,1c,44,4f,56,1c,12,30,75,35,08,38,36,1d,56,76,74,15,3b,09,40,2f,20,31,\
  15,39,5f,7b,42,20,1a,3e,71,3b,2f,03,4f,2d,5b,53,5e,20,39,74
"1207"=dword:00000003
"PMDisplayName"="Internet [Protected Mode]"
"LowIcon"="inetcpl.cpl#005425"
"1208"=dword:00000000
"1209"=dword:00000003
"120A"=dword:00000003
"1408"=dword:00000000
"1409"=dword:00000000
"160A"=dword:00000000
"2005"=dword:00000000
"2103"=dword:00000000
"2104"=dword:00000000
"2105"=dword:00000000
"2106"=dword:00000000
"2301"=dword:00000000
"2400"=dword:00000000
"2401"=dword:00000000
"2402"=dword:00000000
"2600"=dword:00000000
"2700"=dword:00000003
"2007"=dword:00010000
"2107"=dword:00000000
"2708"=dword:00000000
"2709"=dword:00000000
"1812"=dword:00000000
"2500"=dword:00000000
"140A"=dword:00000000
"2302"=dword:00000003
"270B"=dword:00000003
"160B"=dword:00000000
"270C"=dword:00000000
"270D"=dword:00000003
"2701"=dword:00000000
"2702"=dword:00000000
"2703"=dword:00000000
"2704"=dword:00000000
"120B"=dword:00000000
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4]
"2004"=dword:00000003
"2001"=dword:00000003
@=""
"DisplayName"="Restricted sites"
"Description"="This zone contains Web sites that could potentially damage your computer or data."
"Icon"="inetcpl.cpl#00004481"
"CurrentLevel"=dword:00000000
"MinLevel"=dword:00012000
"RecommendedLevel"=dword:00012000
"Flags"=dword:00000003
"1001"=dword:00000003
"1004"=dword:00000003
"1200"=dword:00000003
"1201"=dword:00000003
"1206"=dword:00000003
"1400"=dword:00000003
"1402"=dword:00000003
"1405"=dword:00000003
"1406"=dword:00000003
"1407"=dword:00000003
"1601"=dword:00000001
"1604"=dword:00000001
"1605"=dword:00000000
"1606"=dword:00000003
"1607"=dword:00000003
"1608"=dword:00000003
"1609"=dword:00000001
"1800"=dword:00000003
"1802"=dword:00000001
"1803"=dword:00000003
"1804"=dword:00000003
"1805"=dword:00000001
"1806"=dword:00000003
"1807"=dword:00000001
"1808"=dword:00000000
"1809"=dword:00000000
"1A00"=dword:00010000
"1A02"=dword:00000003
"1A03"=dword:00000003
"1A04"=dword:00000003
"1A05"=dword:00000003
"1A06"=dword:00000003
"1A10"=dword:00000003
"1C00"=dword:00000000
"1E05"=dword:00010000
"2100"=dword:00000003
"2101"=dword:00000003
"2102"=dword:00000003
"2200"=dword:00000003
"2201"=dword:00000003
"2300"=dword:00000003
"2000"=dword:00000003
"{AEBA21FA-782A-4A90-978D-B72164C80120}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,13,37,13,12,14,1a,15,39
"{A8A88C49-5EB2-4990-A1A2-0876022C854F}"=hex:1a,37,61,59,23,52,35,0c,7a,5f,20,\
  17,2f,1e,1a,19,0e,2b,01,73,13,37,13,12,14,1a,15,39
"1207"=dword:00000003
"180B"=dword:00000001
"PMDisplayName"="Restricted sites [Protected Mode]"
"LowIcon"="inetcpl.cpl#005426"
"2007"=dword:00000003
"2500"=dword:00000000
"1408"=dword:00000003
"1409"=dword:00000000
"160A"=dword:00000003
"1812"=dword:00000001
"2005"=dword:00000003
"1208"=dword:00000003
"1209"=dword:00000003
"120A"=dword:00000003
"120B"=dword:00000003
"2103"=dword:00000003
"2104"=dword:00000003
"2105"=dword:00000003
"2106"=dword:00000003
"2107"=dword:00000003
"2301"=dword:00000000
"2400"=dword:00000003
"2401"=dword:00000003
"2402"=dword:00000003
"2600"=dword:00000003
"180A"=dword:00000003
"180C"=dword:00000003
"180D"=dword:00000001
"2700"=dword:00000000
"2701"=dword:00000003
"2702"=dword:00000000
"2703"=dword:00000003
"2708"=dword:00000000
"2709"=dword:00000000
"@
