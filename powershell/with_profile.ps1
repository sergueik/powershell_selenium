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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
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

# TODO: local connections only ?
function netstat_check
{
  param(
    [string]$selenium_http_port = 4444
  )

  $results = Invoke-Expression -Command "netsh interface ipv4 show tcpconnections"

  $t = $results -split "`r`n" | Where-Object { ($_ -match "\s$selenium_http_port\s") }
  (($t -ne '') -and $t -ne $null)

}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)
# TODO : leftover profile lock file
<#
 Directory of C:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\wfywwbuv.default

10/05/2014  06:21 PM                 0 parent.lock
#>
if (Get-Item -Path 'c:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\6us7lrj6.Selenium\parent.lock' -ErrorAction 'SilentlyContinue') {
  Remove-Item -Path 'c:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\6us7lrj6.Selenium\parent.lock'
}

try {
  $connection = (New-Object Net.Sockets.TcpClient)
  $connection.Connect("127.0.0.1",4444)
  $connection.Close()
} catch {
  Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\selenium.cmd"
  Start-Sleep -Seconds 10
}
[object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager
[OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

$profiles | ForEach-Object {
  $item = $_
  # TODO - find how to extract information about all profiles
  $item
}

[string]$profile_directory = 'c:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\6us7lrj6.Selenium'
$profile = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile_directory)
Write-Debug 'Adding extensions'
$profile.AddExtension("C:\developer\sergueik\powershell_ui_samples\external\java\capture\resources\firebug-2.0.8.xpi")
$profile.AddExtension("C:\developer\sergueik\powershell_ui_samples\external\java\capture\resources\netExport-0.9b7.xpi")
Write-Debug 'Settings'
try {
  [void]$profile.SetPreference("app.update.enabled",$false)
} catch [System.Management.Automation.MethodInvocationException]{
  Write-Output 'Ignored exception'
}

# Setting Firebug preferences
# http://getfirebug.com/wiki/index.php/Preferences

[void]$profile.SetPreference("general.useragent.override","Mozilla/5.0 (Windows NT 6.1; rv:15.0) Gecko/20100101 Firefox/15.0")
[void]$profile.SetPreference("extensions.firebug.addonBarOpened",$true)
[void]$profile.SetPreference("extensions.firebug.netexport.alwaysEnableAutoExport",$true)
[void]$profile.SetPreference("extensions.firebug.netexport.autoExportToFile",$true)
[void]$profile.SetPreference("extensions.firebug.netexport.Automation",$true)
[void]$profile.SetPreference("extensions.firebug.netexport.showPreview",$false)
[void]$profile.SetPreference("extensions.firebug.netexport.sendToConfirmation",$false)
[void]$profile.SetPreference("extensions.firebug.netexport.pageLoadedTimeout",0)
[void]$profile.SetPreference("extensions.firebug.netexport.Automation",$true)
[void]$profile.SetPreference("extensions.firebug.netexport.defaultLogDir","C:\temp")
[void]$profile.SetPreference("extensions.firebug.netexport.saveFiles",$true)

[void]$profile.SetPreference("extensions.firebug.currentVersion","2.08")
[void]$profile.SetPreference("extensions.firebug.addonBarOpened",$true)
[void]$profile.SetPreference("extensions.firebug.console.enableSites",$true)
[void]$profile.SetPreference("extensions.firebug.script.enableSites",$true)
[void]$profile.SetPreference("extensions.firebug.net.enableSites",$true)
[void]$profile.SetPreference("extensions.firebug.previousPlacement",1)
[void]$profile.SetPreference("extensions.firebug.allPagesActivation","on")
[void]$profile.SetPreference("extensions.firebug.onByDefault",$true)
[void]$profile.SetPreference("extensions.firebug.defaultPanelName","net")
  # TODO:
  # .AcceptUntrustedCertificates
  # .AlwaysLoadNoFocusLibrary
  # .EnableNativeEvents

Write-Debug 'Starting'
<# 
# This currently does not work:
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  $capability.SetCapability([OpenQA.Selenium.Firefox.FirefoxDriver]::Profile, $profile)
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
#>

$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($profile)

# $selenium | Get-Member
$base_url = 'http://www.wikipedia.org/'
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()


Start-Sleep 1
Write-Output 'Calling the script'
$timeout = 10


[string]$script = "window.setTimeout(function(){document.getElementById('searchInput').value = 'test'}, ${timeout});"

$start = (Get-Date -UFormat "%s")

try {
  [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeAsyncScript($script);

} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  # Ignore
  # Timed out waiting for async script result  (Firefox)
  # asynchronous script timeout: result was not received (Chrome)
  [NUnit.Framework.Assert]::IsTrue($_.Exception.Message -match '(?:Timed out waiting for async script result|asynchronous script timeout)')
}
catch [OpenQA.Selenium.NoSuchWindowException]{
  Write-Host $_.Exception.Message # Unable to get browser
  $_.Exception | Get-Member

}
$end = (Get-Date -UFormat "%s")
$elapsed = New-TimeSpan -Seconds ($end - $start)
Write-Output ('Elapsed time {0:00}:{1:00}:{2:00} ({3})' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds,($end - $start))


$script = 'window.NetExport.triggerExport("abcde")'
Write-Output "Calling the script:`r`n${script}"

$start = (Get-Date -UFormat '%s')

try {
  [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeAsyncScript($script);

} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  # Ignore the following:
  # Timed out waiting for async script result  (Firefox)
  # asynchronous script timeout: result was not received (Chrome)
  [NUnit.Framework.Assert]::IsTrue($_.Exception.Message -match '(?:Timed out waiting for async script result|asynchronous script timeout)')
}
catch [OpenQA.Selenium.NoSuchWindowException]{
  Write-Host $_.Exception.Message # Unable to get browser
  # $_.Exception | Get-Member

} catch [exception]{
  # http://blogs.msdn.com/b/mwories/archive/2009/06/08/powershell-tips-tricks-getting-more-detailed-error-information-from-powershell.aspx
  $error[0] | Format-List -Force

}
$end = (Get-Date -UFormat '%s')
$elapsed = New-TimeSpan -Seconds ($end - $start)
Write-Output ('Elapsed time {0:00}:{1:00}:{2:00} ({3})' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds,($end - $start))


Write-Debug 'Closing'
try {
  $selenium.Close()
  $selenium.Quit()
} catch [exception]{
  Write-Output (($_.Exception.Message) -split "`n")[0]
}


