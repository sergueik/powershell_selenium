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


Write-Host -ForegroundColor 'Yellow' @"
You still need to run the scripts:

.\degrade6_ie.ps1
.\degrade7_ie.ps1

"@
