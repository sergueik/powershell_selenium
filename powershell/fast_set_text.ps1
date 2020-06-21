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
  [string]$base_url = 'http://www.seleniumeasy.com/test',
  [string]$text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum',
  [string]$browser = 'chrome',
  [switch]$headless,
  [switch]$pause
)

$debugpreference='continue'
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
write-debug ('Full Stop: {0}' -f $fullstop )
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

$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

[string]$url = 'https://www.seleniumeasy.com/test/input-form-demo.html'
$selenium.Navigate().GoToUrl($url)
# TODO: wait

start-sleep -millisecond 1000
[String]$selector = 'form#contact_form > fieldset div.form-group div.input-group textarea.form-control'

$element = find_element -css  $selector

write-debug ('Element: {0}' -f $element.getAttribute('outerHTML') )

highlight -element ([ref]$element) -color 'green' -selenium_ref ([ref]$selenium)

setValue -element_ref ([ref]$element) -text $text -selenium_ref ([ref]$selenium) -run_debug
write-output ('Element Value: ' + $element.getAttribute('value'))
# TODO: take element screenshot
custom_pause
# https://www.dotnetperls.com/reverse-string
[char[]] $arr = $text.ToCharArray()
[System.Array]::Reverse($arr)
# new-object : Exception calling ".ctor" with "3" argument(s): "Index was out of range. Must be non-negative and less than the size of the collection.
# $text1 = new-object System.String($arr)
[String]$text1 = $arr -join ''

setValueWithLocator -element_locator $selector -text $text1 -selenium_ref ([ref]$selenium) -run_debug
# cannot leave off the -element_ref ([ref]$element) argument
# setValue : Cannot process argument transformation on parameter 'element_ref'. Reference type is expected in argument.
# cannot set a null ref for -element_ref ([ref]$null)
# setValue : Parameter set cannot be resolved using the specified named parameters.
custom_pause -fullstop $fullstop
$selenium.close()
$selenium.quit()
