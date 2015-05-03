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

param(
  [string]$browser
)

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

$hub_host = '127.0.0.1'
$hub_port = '4444'
$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
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
    throw "unknown browser choice:${browser}"
  }
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

$verificationErrors = New-Object System.Text.StringBuilder
Add-Type @"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OpenQA.Selenium;

namespace WaitForExtensions
{
    public static class DocumentReadyState
    {
        static int cnt = 0;
        public static void Wait(/* this // no longer is an extension method  */ IWebDriver driver)
        {
            var wait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
            wait.Until(dummy => ((IJavaScriptExecutor)driver).ExecuteScript("return document.readyState").Equals("complete"));
        }

        public static void Wait2(/* this // no longer is an extension method  */ IWebDriver driver)
        {
            var wait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
            wait.PollingInterval = TimeSpan.FromSeconds(0.50);
            wait.Until(dummy =>
            {
                string result = ((IJavaScriptExecutor)driver).ExecuteScript("return document.readyState").ToString();
                Console.Error.WriteLine(String.Format("result = {0}", result));
                Console.WriteLine(String.Format("cnt = {0}", cnt));
                cnt++;
                return (cnt >= 3);
            });
        }
    }

}
"@ -ReferencedAssemblies 'System.dll','System.Data.dll','System.Data.Linq.dll',"${shared_assemblies_path}\WebDriver.dll","${shared_assemblies_path}\WebDriver.Support.dll"

# http://briarbird.com/archives/worst-websites-worth-a-visit/
$base_url = 'http://arngren.net/'

# $base_url = 'http://www.google.com/'
$selenium.Navigate().GoToUrl($base_url)

 [WaitForExtensions.DocumentReadyState]::Wait2($selenium)

[NUnit.Framework.Assert]::AreEqual($verificationErrors.Length,0)

$global:selenium = [OpenQA.Selenium.Remote.RemoteWebDriver]($selenium)
<#
$result = Invoke-Command -ScriptBlock {
  param([OpenQA.Selenium.Remote.RemoteWebDriver]$dummy)
  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [string]$script = 'return document.readyState'
  # document.readyState = "interactive"
  # document.readyState = "complete"
  $result = ([OpenQA.Selenium.IJavaScriptExecutor]$global:selenium).ExecuteScript($script,$null,'')
  # write-Debug ('document.readyState = "{0}" ' -f $result )
  # return [bool]( $result -match 'complete' )
  [OpenQA.Selenium.IWebElement]$element = $global:selenium.FindElement([OpenQA.Selenium.By]::Id("hplogo"))
  # write-host 'sss3'
  return $element
}
$result.GetType()
$cnt = 0
$result | ForEach-Object {

  $element = $_
  if ($element.GetType().ToString() -match 'RemoteWebElement') {
    Write-Output ('cnt = {0}' -f $cnt)
    $element

  }
  $cnt++
}
#>
<#
try {
# $debugpreference=continue
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 50
$status = $false
  write-debug $status
  [OpenQA.Selenium.IWebElement]$status = $wait.Until((Invoke-Command -ScriptBlock {
        param([OpenQA.Selenium.IWebDriver]$dummy)
        [OpenQA.Selenium.IWebElement]$element = $global:selenium.FindElement([OpenQA.Selenium.By]::Id("hplogo"))
        return $element
      }))
  
} catch [exception]{
  Write-Output ("Exception (ignored):`r`n{0}" -f $_.Exception.Message)
  # TODO: scriptblock is being called but the signature is still wrong:
  # Cannot find an overload for "Until" and the argument count: "1".
write-debug $status
}
#>
# $debugpreference=silentlycontinue
try {
#  $debugpreference=continue
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 50
  [bool]$status = $wait.Until((Invoke-Command -ScriptBlock {
        param([OpenQA.Selenium.IWebDriver]$dummy)
        # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
        [string]$script = 'return document.readyState'
        # document.readyState = "interactive"
        # document.readyState = "complete"
        $result = ([OpenQA.Selenium.IJavaScriptExecutor]$global:selenium).ExecuteScript($script,$null,'')
        Write-Debug ('document.readyState = "{0}" ' -f $result)
        return [bool]($result -match 'complete')
      }))


} catch [exception]{
  Write-Output ("Exception (ignored):`r`n{0}" -f $_.Exception.Message)
  # TODO: scriptblock is being called but the signature is still wrong:
  # Cannot find an overload for "Until" and the argument count: "1".
}
#$debugpreference=silentlycontinue
<#
TODO:
TitleIs()
TitleContains()
ElementExists()
ElementIsVisible()
#>
try {
  $selenium.Quit()
} catch [exception]{
  Write-Output (($_.Exception.Message) -split "`n")[0]

}
