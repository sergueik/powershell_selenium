#Copyright (c) 2015 Serguei Kouzmine
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

# https://github.com/rkprajapat/webtester
# but without its dependencies on SQL server and on service install
# 


param(
  [string]$browser = '',
  [int]$version,
  [switch]$debug,
  [switch]$pause
)

function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}

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
$shared_assemblies = @(
  "WebDriver.dll",
  "WebDriver.Support.dll",
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$extra_assemblies = @(
'FiddlerCore4.dll'
)



$extra_assemblies_path  = 'C:\developer\sergueik\csharp\webtester\WebTester\bin\Debug'

if (($env:EXTRA_ASSEMBLIES_PATH -ne $null) -and ($env:EXTRA_ASSEMBLIES_PATH -ne '')) {
   $extra_assemblies_path = $env:extra_ASSEMBLIES_PATH
}

pushd $extra_assemblies_path


$extra_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

# http://fiddler.wikidot.com/fiddlercore-api


[Fiddler.CONFIG]::IgnoreServerCertErrors = $true
[Fiddler.CONFIG]::QuietMode = $true
[Fiddler.CONFIG]::bMITM_HTTPS = $true
[Fiddler.CONFIG]::bCaptureCONNECT = $true
[Fiddler.CONFIG]::DecryptWhichProcesses = [Fiddler.ProcessFilterCategories]::All

[Fiddler.FiddlerApplication]::Startup(8877, $true, $true)
write-output ([Fiddler.FiddlerApplication]::IsStarted())
$headless = $false 
if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability('version',$version.ToString());
    }
  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $headless = $true 
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$base_url = 'http://www.google.com/'
$selenium.Navigate().GoToUrl($base_url )
Start-Sleep -Seconds 4
if ([Fiddler.FiddlerApplication]::IsStarted()){
[Fiddler.FiddlerApplication]::Shutdown()
while ([Fiddler.FiddlerApplication]::isClosing){
write-output 'Waiting for fiddler to stop'
start-sleep -millisecond 500
}
}
# Cleanup
cleanup ([ref]$selenium)

<#
# http://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/ConfigureDotNETApp
# http://stackoverflow.com/questions/12772332/c-sharp-fiddlercore-api-to-capture-data
# http://weblog.west-wind.com/posts/2014/Jul/29/Using-FiddlerCore-to-capture-HTTP-Requests-with-NET
https://github.com/RickStrahl/WestWindWebSurge/blob/master/WebSurge/FiddlerCapture.cs
FiddlerCoreStartupFlags.RegisterAsSystemProxy
or
[Fiddler.CONFIG]::bRegisterAsSystemProxy ?

# http://fiddler.wikidot.com/fiddlercore-demo
# http://fiddler.wikidot.com/fiddlercore-demo2

#>
