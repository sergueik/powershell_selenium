#Copyright (c) 2016 Serguei Kouzmine
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
  [string]$browser = '',
  [string]$base_url = 'http://httpbin.org',
  [switch]$custom, 
  [string]$username,
  [string]$password,
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)

$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll',
      'nunit.core.dll'
      )

$debugpreference = 'Continue'
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies -shared_assemblies $shared_assemblies

if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser
  Start-Sleep -Millisecond 500
}
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$selenium.Navigate().GoToUrl($base_url)
$url = ('{0}/basic-auth/{1}/{2}' -f  $base_url, $username, $password)
write-output $url
$selenium.Navigate().GoToUrl($url)
start-sleep 1000
try {
[OpenQA.Selenium.Remote.RemoteAlert]$alert = $selenium.switchTo().alert()
} catch [Exception] {

}
write-output 'Trying to SetAuthenticationCredentials(..)'
([OpenQA.Selenium.IAlert] $alert).SetAuthenticationCredentials($username,$password)
# appears to be failing
write-output 'Trying to SendKeys(..)'
$alert.SendKeys("tes{TAB}pass")
start-sleep -millisecond 1000
$page_source = (($selenium.PageSource) -join '')
write-output $page_source
custom_pause -fullstop $fullstop
# Cleanup
cleanup ([ref]$selenium)



