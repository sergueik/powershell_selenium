#Copyright (c) 2016,2019 Serguei Kouzmine
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
  [string]$browser = 'firefox',
  # default is to show.
  # NOTE: need to fix chrome from opening maximized
  [string]$base_url = 'http://httpbin.org',
  [string]$username,
  [string]$password,
  [switch]$grid,
  # TODO: default value for a switch type
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
  Start-Sleep -Millisecond 10000
} else {
  $selenium = launch_selenium -browser $browser
  Start-Sleep -Millisecond 500
}

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

# no about:blank for chrome
$selenium.Navigate().GoToUrl('http://www.google.com')
start-sleep -millisecond 1000
[object]$body = find_element -tag_name 'body'

Write-Output '--'
$body
Write-Output '--'
$urls = @()

$username_urlencoded = [System.Uri]::EscapeDataString($username)
$password_urlencoded = [System.Uri]::EscapeDataString($password)

@( 0..5) | ForEach-Object {
  $count = $_
  $username = 'testuser'
  $password = ('password_{0}' -f $count)
  $url = ('{0}/basic-auth/{1}/{2}' -f ($base_url -replace 'https?:\/\/',('https://{0}:{1}@' -f $username,$password)),$username,$password)
  Write-Output $url
  $urls += $url
}

@( 0..($urls.Count - 2)) | ForEach-Object {
  write-output 'Opening new tab'
  $body.SendKeys([OpenQA.Selenium.Keys]::Control + 't')
}


$initial_window_handle = $selenium.CurrentWindowHandle

write-output ("CurrentWindowHandle = {0}`n" -f $initial_window_handle)

$handles = @()
try {
  $handles = $selenium.WindowHandles
  $handles | format-list # NOTE: only shows one window handle
  write-output ('number of tabs: {0}' -f ($handles.count))
} catch [exception]{
  write-output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
if ($handles.Count -gt 1) {
  $handle_cnt = 0
  $handles | ForEach-Object {
    write-output ('swithing to tab # {0}' -f $handle_cnt)
    $switch_to_window_handle = $_
    if ($switch_to_window_handle -eq $initial_window_handle){
      [void]$selenium.switchTo().defaultContent()
    } else {
      [void]$selenium.switchTo().window($switch_to_window_handle)
      Start-Sleep -Milliseconds 500
      # write-output ([OpenQA.Selenium.Remote.RemoteTargetLocator]::DefaultContent)
    }
    $url = $urls[$handle_cnt]
    write-output ('Navigating to the url: {0}' -f $url)
    $selenium.Navigate().GoToUrl($url)
    $window_handle = $selenium.CurrentWindowHandle
    write-output ("Tab: {0} Handle:'{1}' Title: '{2}'" -f $handle_cnt,$window_handle,$selenium.Title)
    $handle_cnt++

  }
  [void]$selenium.switchTo().window($initial_window_handle)
  [void]$selenium.switchTo().defaultContent()

}

custom_pause -fullstop $fullstop

cleanup ([ref]$selenium)
