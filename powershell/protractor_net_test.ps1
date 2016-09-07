
#Copyright (c) 2015,2016 Serguei Kouzmine
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

# https://github.com/bbaia/protractor-net/tree/master/src/Protractor
# https://github.com/sergueik/protractor-net
# https://github.com/anthonychu/Protractor-Net-Demo

param(
  [string]$browser = '',
  [switch]$grid,
  [switch]$pause
)

# Setup 
# copy ../csharp/protractor-net/Program/bin/Debug/Protractor.dll to 
# ../../csharp/sharedassemblies
$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Protractor.dll',
  'nunit.framework.dll'
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid -shared_assemblies $shared_assemblies
} else {
  $selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies
}
[Protractor.NgWebDriver]$ng_driver = New-Object Protractor.NgWebDriver ($selenium)
$base_url = 'http://juliemr.github.io/protractor-demo/'

$selenium.Navigate().GoToUrl($base_url)

$ng_driver.Url = $base_url
$title = $ng_driver.Title
[NUnit.Framework.Assert]::AreEqual($title,"Super Calculator")

$first = $ng_driver.FindElement([Protractor.NgBy]::Input('first'))
$second = $ng_driver.FindElement([Protractor.NgBy]::Input('second'))
$goButton = $ng_driver.FindElement([OpenQA.Selenium.By]::Id('gobutton'))
$first.SendKeys("1")
$second.SendKeys("2")
$goButton.Click()
[int]$wait_seconds = 10
# Exception calling "FindElement" with "1" argument(s): "asynchronous script timeout: result was not received in 0 seconds
# Start-Sleep -Millisecond 2000
$script_timeout = 120
[void]($selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script_timeout)))

$wait_seconds = 10
$wait_polling_interval = 50

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
$wait.PollingInterval = $wait_polling_interval
$wait.IgnoreExceptionTypes([OpenQA.Selenium.WebDriverTimeoutException],[OpenQA.Selenium.WebDriverException])

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([Protractor.NgBy]::Binding('latest')))
} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  Write-Debug ("Exception : {0} ...`n{1}" -f (($_.Exception.Message) -split "`n")[0],$_.Exception.Type)
} catch [exception]{
  Write-Debug ("Exception : {0} ...`n{1}" -f (($_.Exception.Message) -split "`n")[0],$_.Exception.Type)
}
$latest_element = $ng_driver.FindElement([Protractor.NgBy]::Binding('latest'))
$element = $latest_element.WrappedElement

highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$element) -Delay 150

try {
  highlight ([ref]$selenium) ([ref]$latest_element) }
catch [exception]{
  Write-Debug ("Exception : {0}`n" -f (($_.Exception.Message) -split "`n")[0])
  # from OpenQA.Selenium.IJavaScriptExecutor
  # Exception calling "ExecuteScript" with "3" argument(s): "Argument is of anillegal typeProtractor.NgWebElement
}
[NUnit.Framework.Assert]::AreEqual($latest_element.Text,"3")
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
