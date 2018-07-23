#Copyright (c) 2018 Serguei Kouzmine
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
  [string]$hub_host = '127.0.0.1',
  [string]$browser = 'firefox',
  [switch]$pause
)

$shared_assemblies = @{
  'WebDriver.dll' = '2.53';
  'WebDriver.Support.dll' = '2.53';
  'nunit.core.dll' = $null;
  'nunit.framework.dll' = '2.6.3';
}

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$verificationErrors = New-Object System.Text.StringBuilder

if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}
$DebugPreference = 'Continue'
$base_url = 'http://store.demoqa.com/products-page/'

if ($host.Version.Major -le 2) {

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $selenium.Manage().Window.Size = New-Object System.Drawing.Size (800,600)
  $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
} else {
  $selenium.Manage().Window.Size = @{ 'Height' = 600; 'Width' = 800; }
  $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
}
set_timeouts ([ref]$selenium)
$selenium.Navigate().GoToUrl($base_url)
start-sleep -seconds 4
[NUnit.Framework.StringAssert]::Contains('store.demoqa.com', $selenium.url,{})

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait($selenium,[System.TimeSpan]::FromSeconds(120))
$wait.PollingInterval = 500
$css_selector = 'span.currentprice:nth-of-type(1)'
$css_selector = 'span.currentprice'

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  write-output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

$element = find_element -css_selector $css_selector
highlight -element ([ref]$element) -selenium_ref ([ref]$selenium)

$result = find_via_closest -ancestor_locator 'form' -target_element_locator 'input[type="submit"]' -element_ref ([ref]$element)

write-output ('Found {0}' -f $result)

if ($PSBoundParameters['pause']) {

  try {

    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}

} else {
  Start-Sleep -Millisecond 1000
}

# Cleanup
cleanup ([ref]$selenium)

