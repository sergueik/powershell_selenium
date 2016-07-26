<#

# http://www.codeproject.com/Tips/884103/Write-automation-test-with-Selenium-WebDriver-exte
# Write Automation Test with Selenium WebDriver Extension for jQuery of RaYell Effectively - CodeProject

# 1. clone project

# https://github.com/RaYell/selenium-webdriver-extensionsray (Ray)
# downgrade to .net 4.0

# 2. build ignoring the warnings
# on certain machines with .net 4.0 installed partially

# 3. Add to reference:

Selenium.WebDriver.Extensions.dll
Selenium.WebDriver.Extensions.JQuery.dll
Selenium.WebDriver.Extensions.QuerySelect.dll
Selenium.WebDriver.Extensions.Shared.dll

#>

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
  [switch]$browser
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

$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd




$extra_assemblies = @(
'Selenium.WebDriver.Extensions.dll',
'Selenium.WebDriver.Extensions.JQuery.dll',
'Selenium.WebDriver.Extensions.QuerySelector.dll'
)



$extra_assemblies_path  = 'C:\developer\sergueik\csharp\selenium-webdriver-extensions\src\Selenium.WebDriver.Extensions\bin\Debug'

if (($env:EXTRA_ASSEMBLIES_PATH -ne $null) -and ($env:EXTRA_ASSEMBLIES_PATH -ne '')) {
   $extra_assemblies_path = $env:extra_ASSEMBLIES_PATH
}

pushd $extra_assemblies_path


$extra_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


$b = new-object -typeName 'Selenium.WebDriver.Extensions.JQuery.By'
$verificationErrors = New-Object System.Text.StringBuilder
$baseURL = "http://www.theautomatedtester.co.uk/demo1.html"
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}


[string]$Name = "div.test"
[object]$originalBy = [OpenQA.Selenium.By]::Name($Name)
[object]$wrappedBy = [Selenium.WebDriver.Extensions.JQuery.By]::Name($Name)

[NUnit.Framework.Assert]::AreEqual($wrappedBy ,$originalBy )
$selenium.Navigate().GoToUrl($baseURL + "")
# https://groups.google.com/forum/?fromgroups#!topic/selenium-users/V1eoFUMEPqI
[OpenQA.Selenium.Interactions.Actions]$builder = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$b2 = [Selenium.WebDriver.Extensions.JQuery.By]::JQuerySelector("input:visible")
$b2
# NOTE: failed in phantomjs
[OpenQA.Selenium.IWebElement]$canvas = $selenium.FindElement($b2)
$builder.Build();
$builder.MoveToElement($canvas,100,100)
$builder.clickAndHold()
$builder.moveByOffset(40,60)
$builder.release()
$builder.Perform()

Start-Sleep -Seconds 4

# Cleanup
cleanup ([ref]$selenium)

