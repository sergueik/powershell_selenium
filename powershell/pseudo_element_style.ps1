#Copyright (c) 2020 Serguei Kouzmine
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
##
param(
  [string]$browser = 'firefox',

  [String]$base_url = 'https://www.w3schools.com/css/tryit.asp?filename=trycss_before',
  [switch]$headless,
  [switch]$grid,
  [switch]$pause
)

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)

# NOTE: managing chrome browser with Selenium assemblies 81 seem too be running into problems outside of the scope of this snippet
# common modules overhaus is required
#
# NOTE: "new" default directory for .net assemblies is not fully functional
<#
$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'
'c:\java\selenium\csharp\sharedassemblies.NEW'
'c:\java\selenium\csharp\sharedassemblies.BACKUP'
# SHARED_ASSEMBLIES_PATH envionment value overrides
# $env:SHARED_ASSEMBLIES_PATH='C:\developer\sergueik\csharp\SharedAssemblies'
#>
if  ($debugpreference -eq 'continue') { 
  $debug = $true
}
$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  write-debug 'Running on grid'
}
if ([bool]$PSBoundParameters['headless'].IsPresent) {
  write-debug 'Running headless'
}
if ([bool]$PSBoundParameters['grid'].IsPresent) {
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
set_timeouts -selenium_ref ([ref]$selenium) -page_load 120 -explicit 60 -script 300
# start-sleep -second  10
$selenium.Navigate().GoToUrl($base_url)

  [String]$frame_css = 'div#iframewrapper iframe[name="iframeResult"]'
  $frame_element = find_element -css_selector $frame_css
  write-output ('Frame container: {0}' -f $frame_element.getAttribute('outerHTML'))
  $frame = $selenium.SwitchTo().Frame($frame_element)
  $element_xpath = '//h1'
  $element = find_element -xpath $element_xpath
  print( $element.getAttribute('innerHTML'))
  $element = $null
  find_page_element_by_xpath ([ref]$frame) ([ref]$element) $element_xpath
  $script = 'return window.getComputedStyle(arguments[0],":before")'
  [string[]]$syles = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script, $element)
  write-output ('Loaded {0} styles' -f $syles.count)
  write-debug ('Result(raw) : {0}' -f $syles)
  if ($debug) { 
    $syles | foreach-object {
      $syles_key = $_
      write-debug ('Style: {0}' -f $syles_key)
    }
  }
  $script = 'return window.getComputedStyle(arguments[0],":before").getPropertyValue(arguments[1]);'
  $styles = @(
  'top', 'left', 'width', 'height', 'content'
  )
  $styles | foreach-object {
    $style_key = $_
    $style_value = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script, $element,$style_key)
    write-output ('element computed style {0} = {1}' -f $style_key, $style_value)
}
if ($PSBoundParameters['pause']) {

  try {

    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}

} else {
  Start-Sleep -Millisecond 1000
}

# Cleanup
cleanup ([ref]$selenium)

