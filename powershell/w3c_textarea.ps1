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

param(
  [string]$browser = 'chrome',
  [string]$base_url = 'https://www.w3schools.com',
  [string]$filename = 'tryhtml_textarea',
  [switch]$debug,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies

if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser
}

$selenium.Navigate().GoToUrl($base_url + ('/tags/tryit.asp?filename={0}' -f $filename))

$script = @"
const element = arguments[0]; 
const debug = arguments[1]; 
return element.value;
"@
 
[string]$xpath = "//iframe[@name='iframeResult']"
[object]$frame_element = $null
find_page_element_by_xpath ([ref]$selenium) ([ref]$frame_element) $xpath
$iframe = $selenium.SwitchTo().Frame($frame_element)
$xpath = "//textarea[ @id='w3review']"
$element = $iframe.FindElement([OpenQA.Selenium.By]::XPath($xpath))
$result = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script,$element)
write-output ('Script (1): {0}' -f $result)
$result = get_value ([ref]$iframe) ([ref]$element)
write-output ('Script (2): {0}' -f $result)
$result = get_text -selenium_ref ([ref]$iframe) -element_ref ([ref]$element)
write-output ('Script (3): {0}' -f $result)
write-output ('Text: {0}' -f $element.text)
write-output ('innerHTML: {0}' -f $element.getAttribute('innerHTML'))

find_page_element_by_xpath ([ref]$selenium) ([ref]$element) $xpath
write-output ('innerHTML: {0}' -f $element.getAttribute('innerHTML'))

wait_alert -selenium_ref ([ref]$selenium) -wait_seconds 10
wait_alert_frame -selenium_ref ([ref]$selenium) -frame_locator 'frame' -accept_button_locator 'button' -run_debug
# Cleanup
cleanup ([ref]$selenium)
