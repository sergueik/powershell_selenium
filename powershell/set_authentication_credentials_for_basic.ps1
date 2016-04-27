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

# http://stackoverflow.com/questions/5672407/how-to-perform-basic-authentication-for-firefoxdriver-chromedriver-and-iedriver
# java
# https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/Alert.html#authenticateUsing-org.openqa.selenium.security.Credentials-
# C#
# https://seleniumhq.github.io/selenium/docs/api/dotnet/html/M_OpenQA_Selenium_IAlert_SetAuthenticationCredentials.htm

param(
  [string]$browser = '',
  [string]$base_url = 'http://httpbin.org',
  [switch]$new,
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
if ([bool]$PSBoundParameters['debug'].IsPresent) {
  $debugpreference = 'Continue'
}


[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies -shared_assemblies $shared_assemblies

if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
  Start-Sleep -Millisecond 5000
} else {
  $selenium = launch_selenium -browser $browser
  Start-Sleep -Millisecond 500
}
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$selenium.Navigate().GoToUrl($base_url)
# NOTE - the following will fail with 
# Method invocation failed because [System.Web.HttpServerUtility] does not contain a method named 'UrlEncode'.
# or 
# Method invocation failed because [System.Web.WebUtility] does not contain a method named 'UrlEncode'.

try {
  $username_urlencoded = [System.Web.HttpServerUtility]::UrlEncode($username)
  $password_urlencoded = [System.Web.WebUtility]::UrlEncode($password)
} catch [exception]{

}

$username_urlencoded = [System.Uri]::EscapeDataString($username)
$password_urlencoded = [System.Uri]::EscapeDataString($password)

if (-not ([bool]$PSBoundParameters['new'].IsPresent)) {
  # Do it the old style

  $url = ('{0}/basic-auth/{1}/{2}' -f ($base_url -replace 'http:\/\/',('http://{0}:{1}@' -f $username_urlencoded,$password_urlencoded)),$username_urlencoded,$password_urlencoded)
  Write-Output $url
  $selenium.Navigate().GoToUrl($url)
  Start-Sleep -Millisecond 1000

} else {
  # Try newly added API 
  $url = ('{0}/basic-auth/{1}/{2}' -f $base_url,$username_urlencoded,$password_urlencoded)
  Write-Output $url
  $selenium.Navigate().GoToUrl($url)
  # appears to be failing
  Start-Sleep -Millisecond 1000
  try {
    [OpenQA.Selenium.Remote.RemoteAlert]$alert = $selenium.switchTo().alert()
    Write-Output $alert.Text
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
  }
  Write-Output 'Trying to SetAuthenticationCredentials(..)'
  ([OpenQA.Selenium.IAlert]$alert).SetAuthenticationCredentials($username,$password)

  # the rest is not tested, program is failing and the code below is not reached 
  Write-Output 'Trying to SendKeys(..)'
  $alert.SendKeys("tes{TAB}pass")
}

$page_source = (($selenium.PageSource) -join '')
Write-Output $page_source

@( '"authenticated": true','"user": "sergueik"') | ForEach-Object { $line = $_
  [NUnit.Framework.Assert]::IsTrue(($page_source -match $line))
}
$selenium.Navigate().back()

custom_pause -fullstop $fullstop

cleanup ([ref]$selenium)



