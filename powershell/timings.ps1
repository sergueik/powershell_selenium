#Copyright (c) 2014 Serguei Kouzmine
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

param(
  [string]$browser
)
function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    # Ignore errors if unable to close the browser
    Write-Output (($_.Exception.Message) -split "`n")[0]

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
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://www.carnival.com/'
$uri = [System.Uri]('http://127.0.0.1:4444/wd/hub')
if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
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
  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw ('Unknown browser choice: ' + $browser)
  }

  try {
    # TODO:
    # OpenQA.Selenium.Remote.CapabilityType.ForSeleniumServer possibly not available for C# port
    $capability.setCapability([OpenQA.Selenium.Remote.CapabilityType.ForSeleniumServer]::ENSURING_CLEAN_SESSION,$true)
  } catch [exception]{
  }

  try {
    $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
  } catch [exception]{
    throw
  }
} else {
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.setCapability('ssl-protocol','any')
  $selenium.Capabilities.setCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.setCapability('takesScreenshot',$true)
  $selenium.Capabilities.setCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

$selenium.Navigate().GoToUrl($base_url)
try {

  [OpenQA.Selenium.Remote.HttpCommandExecutor]$executor = New-Object OpenQA.Selenium.Remote.HttpCommandExecutor ($uri,[System.TimeSpan]::FromSeconds(10))
  $executor.Execute([OpenQA.Selenium.Remote.DriverCommand]::DeleteAllCookies)
  Write-Host -ForegroundColor 'Green' "Deleted cookies"
} catch [exception]{
  <#
 Cannot convert value of type
"OpenQA.Selenium.Remote.RemoteWebDriver" to type
"OpenQA.Selenium.Remote.ICommandExecutor".

 new-object : Cannot find type [OpenQA.Selenium.Remote.HttpCommandExecutor]:
 verify that the assembly containing this type is loaded.
#>
  # commenting the exception leads to the "Unable to get browser" error in the following code 
  # throw
}
# write-host -ForegroundColor 'Green' "Continue with the browser"

$selenium.Navigate().Refresh()

# http://www.theautomatedtester.co.uk/blog/2010/selenium-webtimings-api.html
<#

 
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using OpenQA.Selenium;

namespace AutomatedTester.PagePerf
{
    public static class Extensions
    {
        public static Dictionary<string,object> WebTimings(this IWebDriver driver)
        {
            var webTiming = (Dictionary<string, object>)((IJavaScriptExecutor)driver)
                .ExecuteScript(@"var performance = window.performance || window.webkitPerformance || window.mozPerformance || window.msPerformance || {};
                                 var timings = performance.timing || {};
                                 return timings;");
			/* The dictionary returned will contain something like the following.
             * The values are in milliseconds since 1/1/1970
             * 
             * connectEnd: 1280867925716
             * connectStart: 1280867925687
             * domainLookupEnd: 1280867925687
             * domainLookupStart: 1280867925687
             * fetchStart: 1280867925685
             * legacyNavigationStart: 1280867926028
             * loadEventEnd: 1280867926262
             * loadEventStart: 1280867926155
             * navigationStart: 1280867925685
             * redirectEnd: 0
             * redirectStart: 0
             * requestEnd: 1280867925716
             * requestStart: 1280867925716
             * responseEnd: 1280867925940
             * responseStart: 1280867925919
             * unloadEventEnd: 1280867925940
             */ 
            return webTiming;
        }
    }
}

#>

# https://msdn.microsoft.com/en-us/library/system.datetime.tolocaltime(v=vs.110).aspx
$BaseUTCED = [math]::Floor([decimal](Get-Date (Get-Date).ToUniversalTime() -UFormat "%s"))
# convert to millisecond 
$BaseUTCED *= 1000


$script = @"
var performance = window.performance ||  window.webkitPerformance ||   window.mozPerformance ||  window.msPerformance || {};
var timings = performance.timing || {};
return timings;
"@

# executeScript works fine with Chrome or Firefox 31, ie 10, but not IE 11.
# Exception calling "ExecuteScript" with "1" argument(s): "Unable to get browser
# https://code.google.com/p/selenium/issues/detail?id=6511  
# 
# https://code.google.com/p/selenium/source/browse/java/client/src/org/openqa/selenium/remote/HttpCommandExecutor.java?r=3f4622ced689d2670851b74dac0c556bcae2d0fe

$result = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script);

#  Convert the results from milliseconds since 1/1/1970


$navigation_ostart_offset_epoch = $result['navigationStart']


[string[]]($result.Keys) | ForEach-Object {
  if ($result[$_] -gt 0) {
    # This will not be correct.
    # $result[$_] = ( $result[$_] - $BaseUTCED) * 0.001
    $result[$_] = ($result[$_] - $navigation_ostart_offset_epoch) * 0.001
  }
}

$result

# Cleanup

cleanup ([ref]$selenium)
