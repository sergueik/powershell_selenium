#Copyright (c) 2015 Serguei Kouzmine
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
  [string]$base_url = 'http://www.stuller.com/products/build/122873/12130198/?groupId=192477#/center-stone',
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies


if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
  Start-Sleep -Millisecond 500
} else {
  $selenium = launch_selenium -browser $browser
}

$selenium.Navigate().GoToUrl($base_url)

# Method invocation failed because [OpenQA.Selenium.Remote.RemoteOptions] does not contain a method named 'deleteAllCookies'.
# $selenium.manage().deleteAllCookies()

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# 
[string]$stone_box_selector = "div.StoneBox div.Square"
[object]$stone_box_element = find_element -css_selector $stone_box_selector
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$stone_box_element).Build().Perform()
highlight ([ref]$selenium) ([ref]$stone_box_element) -delay 1500
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$stone_box_element).Click().Build().Perform()
start-sleep -millisecond 3500
[string]$stone_box_selector = "div.StoneBox div.Asscher"
[object]$stone_box_element = find_element -css_selector $stone_box_selector
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$stone_box_element).Build().Perform()
highlight ([ref]$selenium) ([ref]$stone_box_element) -delay 1500


[OpenQA.Selenium.Interactions.Actions]$builder = New-Object OpenQA.Selenium.Interactions.Actions($selenium);
[void]$builder.Build();
[void]$builder.clickAndHold($stone_box_element)
[void]$builder.release()
[void]$builder.Perform()



[string]$next_step_selector = "button.nextStepButton"
[object]$next_step_element = find_element -css_selector $next_step_selector
highlight ([ref]$selenium) ([ref]$next_step_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$next_step_element).Click().Build().Perform()

[string]$login_div_selector = 'div[class="image-zoom-container"]'
[object]$login_div_element = find_element -css_selector $login_div_selector
highlight ([ref]$selenium) ([ref]$login_div_element)


[string]$login_div_selector = 'div[class="image-zoom-container"] img[id="main-image"]'
[object]$login_div_element = find_element -css_selector $login_div_selector
highlight ([ref]$selenium) ([ref]$login_div_element)

<#

$login_div_element.GetAttribute("src")
http://stuller.scene7.com/is/image/Stuller?layer=0&src=ir(StullerRender/f00f8b8c-5f44-47cc-b125-a51100ebfe1f?obj=metals&show&color=e5c67b&rs=c..218.178.-24..e.250..255.-68..k.....131.133w...59...u8..121.......v8..153.130......&hei=640&wid=640&fmt=jpeg)&$standard$
#>

0..2| foreach-object {
  $cnt = $_
  [string]$carousel_selector = ('div.carousel a[id="carousel-selector-{0}"]' -f $cnt )
  [object]$carousel_element = find_element -css_selector $carousel_selector
  highlight ([ref]$selenium) ([ref]$carousel_element)
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$carousel_element).Click().Build().Perform()
  start-sleep -millisecond 250
}
custom_pause -fullstop $fullstop
cleanup ([ref]$selenium)
