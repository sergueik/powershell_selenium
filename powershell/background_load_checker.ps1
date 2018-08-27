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

# http://stackoverflow.com/questions/6198947/how-to-get-text-from-each-cell-of-an-html-table
# http://sqa.stackexchange.com/questions/10342/how-to-find-element-using-contains-in-xpath

param(
  [string]$browser = '',
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
$debugpreference = 'continue'

$base_url = 'https://www.intechnic.com/blog/20-beautiful-big-background-image-website-design-inspirations/'
$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

$image_link = '#hs_cos_wrapper_post_body > a:nth-child(3) > img'
$result = check_image_ready -selenium_ref ([ref]$selenium) -element_locator $image_link #  -debug 
write-output ('Result = {0}' -f $result) 

$base_url = 'http://ringvemedia.com/'

$selenium.Navigate().GoToUrl($base_url)

# hanging with exception:
# DOMException: Failed to execute 'postMessage' on 'Window': HTMLBodyElement object could not be cloned.
$result = check_image_ready -selenium_ref ([ref]$selenium) -element_locator 'body' #  -debug
write-output ('Result = {0}' -f $result) 
# NOTE:  with debug settings be ready tofail the main script with 
# Exception calling "ExecuteScript" with "3" argument(s): 
# "unexpected alert open: {Alert text : body}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop
$debugpreference = 'silentlycontinue'

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}