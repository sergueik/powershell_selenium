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
  [string]$browser,
  [int]$version,
  [switch]$grid,
  [string]$hub_host = '127.0.0.1',
  [string]$hub_port = '4444'
)

# Convertfrom-JSON applies To: Windows PowerShell 3.0 and above
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -gt 2)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser

[void]$selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(60))

$selenium.url = $base_url = 'http://www.urbandictionary.com/'
$selenium.Navigate().GoToUrl($base_url)
$body = $selenium.FindElement([OpenQA.Selenium.By]::TagName('body'))
$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
Write-Output 'Navigating via keyboard'
@( 1,2) | ForEach-Object {
  # not stable
  Write-Output $_
  [void]$actions.SendKeys($body,[System.Windows.Forms.SendKeys]::SendWait('^r'))
}
Write-Output 'Navigating via browser function'
@( 1,2) | ForEach-Object {
  Write-Output $_
  $selenium.Navigate().GoToUrl($selenium.url)
}
  # Cleanup
  cleanup ([ref]$selenium)
