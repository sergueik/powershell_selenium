#Copyright (c) 2019 Serguei Kouzmine
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
  # TODO: fix chrome from opening maximized when run without the grid
  [string]$base_url = 'http://stackoverflow.com/',
  [switch]$grid,
  [int]$num_tabs = 2,
  # TODO:  find compatible versions of chrome browser, Selenium driver
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

# based on: https://github.com/adamdriscoll/selenium-powershell/blob/master/Selenium.psm1
function map_keys {
 [OpenQA.Selenium.Keys] |
 get-member -MemberType Property -Static |
 select-object -property Name, @{N = "ObjectString"; E = { "[OpenQA.Selenium.Keys]::$($_.Name)" } }
}

function send_keys {
  param(
  # [OpenQA.Selenium.IWebElement]$element,
    [System.Management.Automation.PSReference]$element_ref,
    [string]$message
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  # NOTE: which is Powershell version needed for that DSL?
  foreach ($Key in @(map_keys).Name) {
    $message = $message -replace "{{$Key}}", [OpenQA.Selenium.Keys]::$Key
  }
  $local:element.SendKeys($message)
}


[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

# no about:blank for chrome
$selenium.Navigate().GoToUrl($base_url)

start-sleep -millisecond 1000
# [object]$logo = find_element2 -selector 'css_selector' -value 'a.-logo'
[OpenQA.Selenium.IWebElement]$logo = find_element2 -selector 'css_selector' -value 'a.-logo'
write-output ('located: {0}'-f $logo.getAttribute('outerHTML'))
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$logo) -delay 1500 -color 'red'

@( 0..($num_tabs-1)) | ForEach-Object {
  $count = $_
  write-output 'Opening new tab'
  # send_keys -element $logo -message '{{Control}}{{Return}}'
  send_keys -element_ref ([ref]$logo) -message '{{Control}}{{Return}}'
  Write-Output $count
}

$initial_window_handle = $selenium.CurrentWindowHandle

write-output ("CurrentWindowHandle = {0}`n" -f $initial_window_handle)

try {
  $handles = $selenium.WindowHandles
  $handles | format-list

  write-output ('number of tabs: {0}' -f ($handles.count))
} catch [exception]{
  write-output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}


@( 0..($num_tabs-1)) | ForEach-Object {
  [object]$body = find_element -tag_name 'body'
  send_keys -element_ref ([ref]$body) -message '{{Control}}{{Tab}}'
  write-output ('Another tab: {0}' -f $selenium.CurrentWindowHandle )
}

@( 0..($num_tabs-1)) | ForEach-Object {
  [object]$body = find_element -tag_name 'body'
  send_keys -element_ref ([ref]$body) -message '{{Control}}{{Shift}}{{Tab}}'
  write-output ('Another tab: {0}' -f $selenium.CurrentWindowHandle )
}

[void]$selenium.switchTo().window($initial_window_handle)
[void]$selenium.switchTo().defaultContent()


<#
# This navigation does not work with WebDriver.dll 2.53.0 - assembly upgrade needed
$handles = @()
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
#>

custom_pause -fullstop $fullstop

cleanup ([ref]$selenium)
