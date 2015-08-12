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
  [string]$base_url = 'https://www.upwork.com/',
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

$selenium.Navigate().GoToUrl($base_url)


[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

[string]$login_css_selector = "div[class *='desktop-navbar'] a[class *='header-link-login']"
[object]$login_button_element = find_element_new -css_selector $login_css_selector

highlight ([ref]$selenium) ([ref]$login_button_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_button_element).Click().Build().Perform()


[string]$login_username_selector = "form#login input#username"
[string]$login_username_data = 'kouzmine_serguei@yahoo.com'
[object]$login_username_element = find_element_new -css_selector $login_username_selector
highlight ([ref]$selenium) ([ref]$login_username_element)
$login_username_element.SendKeys($login_username_data)

[string]$login_password_selector = "form#login input#password"
[string]$login_password_data = 'D0ss1aXML'
[object]$login_password_element = find_element_new -css_selector $login_password_selector
highlight ([ref]$selenium) ([ref]$login_password_element)
$login_password_element.SendKeys($login_password_data)


[string]$login_submit_selector = "form#login input#submit"
[object]$login_submit_element = find_element_new -css_selector $login_submit_selector
highlight ([ref]$selenium) ([ref]$login_submit_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_submit_element).Click().Build().Perform()


# log out
[string]$avatar_selector = "#simpleCompanySelector > span > img.oNavAvatar[alt='Serguei Kouzmine']"
[object]$avatar_element = find_element_new -css_selector $avatar_selector
highlight ([ref]$selenium) ([ref]$avatar_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$avatar_element).Click().Build().Perform()
[string]$logout_xpath = "//*[@id='simpleCompanySelector']/div/a[@title='Log out']"
[object]$logout_element = find_element_new -XPath $logout_xpath
highlight ([ref]$selenium) ([ref]$logout_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$logout_element).Click().Build().Perform()


<#

https://www.upwork.com/find-work-home/
#>
<#
input id="inMed" class="oInputText oLuceneSearchForm" type="text" value="" placeholder="Search for Jobs" name="q">
<input class="oBtn oBtnPrimary" type="submit" value="Search">
#>

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

# Cleanup
cleanup ([ref]$selenium)
