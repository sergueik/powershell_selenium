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
  [string]$browser = 'chrome',
  [switch]$grid,
  [switch]$headless,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  write-debug 'Running on grid'
}
if ([bool]$PSBoundParameters['headless'].IsPresent) {
  write-debug 'Running headless'
}
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  # NOTE: can not simply pass a switch to the callee 
  # launch_selenium : Cannot process argument transformation on parameter 'version'.
  # Cannot convert the "True" value of type
  # "System.Management.Automation.SwitchParameter" to type "System.Int32".
  if ([bool]$PSBoundParameters['headless'].IsPresent) {
    $selenium = launch_selenium -browser $browser -grid -headless
  } else {
    $selenium = launch_selenium -browser $browser -grid
  }
} else {
  if ([bool]$PSBoundParameters['headless'].IsPresent) {
    $selenium = launch_selenium -browser $browser -headless
  } else {
    $selenium = launch_selenium -browser $browser
  }
}

$base_url = 'https://spb.rt.ru/packages/tariffs'

# NOTE: sporadic exeptions : 
# unknown error: DevToolsActivePort file doesn't exist
# when there i a chromedrivder version mismatch
# ChromeDriver 2.42.591088
# Chrome 69.0.3497.100 (Official Build) x64

$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("rtk-logo")))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
# Firefox is getting the  error of being redirected to the 
# https://spb.rt.ru/fault-browser/

$url = $selenium.url
if ($browser -eq 'firefox'){
[NUnit.Framework.StringAssert]::AreEqualIgnoringCase($url, 'https://spb.rt.ru/fault-browser/' )
}
# firefox
# https://spb.rt.ru/fault-browser/

if ($browser -eq 'chrome'){
[NUnit.Framework.StringAssert]::Contains($url, 'https://spb.rt.ru/packages/tariffs')
}
write-output $browser
write-output $url

# chrome
# https://spb.rt.ru/packages/tariffs

start-Sleep -Millisecond 100

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
