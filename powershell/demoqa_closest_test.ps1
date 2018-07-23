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
  [string]$browser = '',
  [switch]$grid,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

$base_url = 'http://store.demoqa.com/products-page/'

$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

# set_timeouts ([ref]$selenium)
# start-sleep -seconds 4
# [NUnit.Framework.StringAssert]::Contains('store.demoqa.com', $selenium.url,{})

$css_selector = 'span.currentprice:nth-of-type(1)'
$css_selector = 'span.currentprice'

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  write-output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

$element = find_element -css_selector $css_selector
highlight -element ([ref]$element) -selenium_ref ([ref]$selenium)

$result = find_via_closest -ancestor_locator 'form' -target_element_locator 'input[type="submit"]' -element_ref ([ref]$element)

write-output ('Found {0}' -f $result)

$element = find_element -css_selector $css_selector
highlight -element ([ref]$element) -selenium_ref ([ref]$selenium)

$xpath = 'ancestor::form'

[OpenQA.Selenium.IWebElement]$form_element = [OpenQA.Selenium.ILocatable]$element.FindElement([OpenQA.Selenium.By]::xpath($xpath))

$result = $form_element.getAttribute('innerHTML')

write-debug ('Found form {0}' -f $result)

$xpath = 'ancestor::form//input[@type="submit"]'


[OpenQA.Selenium.IWebElement]$button_element = [OpenQA.Selenium.ILocatable]$element.FindElement([OpenQA.Selenium.By]::xpath($xpath))
highlight -element ([ref]$element) -selenium_ref ([ref]$selenium) -color 'pink'
write-output ('Found button {0}' -f $button_element.getAttribute('value'))
highlight -element ([ref]$button_element) -selenium_ref ([ref]$selenium) -color 'pink'


[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector))
$elements| foreach-object {
  $element = $_
  highlight -element ([ref]$element) -selenium_ref ([ref]$selenium) -color 'green'
  $result = find_via_closest -ancestor_locator 'form' -target_element_locator 'input[type="submit"]' -element_ref ([ref]$element)
  write-output ('Found {0}' -f $result)
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

