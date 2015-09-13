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
  [string]$base_url = 'https://www.elance.com',
  [string]$username = 'kouzmine_serguei@yahoo.com',
  [string]$password,
  [string]$secret = 'moscow',
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)

if ($password -eq '' -or $password -eq $null) {
  Write-Output 'Please specify password.'
  return
}
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies


if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
  start-sleep -millisecond 500
} else {
  $selenium = launch_selenium -browser $browser
}

$selenium.Navigate().GoToUrl($base_url)

# Method invocation failed because [OpenQA.Selenium.Remote.RemoteOptions] does not contain a method named 'deleteAllCookies'.
# $selenium.manage().deleteAllCookies()

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

[string]$login_css_selector = "div[id='nav-v-csr'] a[class*='hpg-sign-in']"
[object]$login_button_element = find_element_new -css_selector $login_css_selector

highlight ([ref]$selenium) ([ref]$login_button_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_button_element).Click().Build().Perform()

Write-Output 'Log in'

[string]$login_div_selector = "div[id = 'login-form']"
[object]$login_div_element = find_element_new -css_selector $login_div_selector
highlight ([ref]$selenium) ([ref]$login_div_element)

[string]$login_username_selector = "div[id = 'login-form'] form#loginForm input[id='login_name']"
[string]$login_username_data = $username

[object]$login_username_element = find_element_new -css_selector $login_username_selector
highlight ([ref]$selenium) ([ref]$login_username_element)
$login_username_element.Clear()
$login_username_element.SendKeys($login_username_data)

[string]$login_password_selector = "div[id = 'login-form'] form#loginForm input#passwd"
[string]$login_password_data = $password
[object]$login_password_element = find_element_new -css_selector $login_password_selector
highlight ([ref]$selenium) ([ref]$login_password_element)
$login_password_element.Clear()

$login_password_element.SendKeys($login_password_data)

[string]$login_submit_selector = "form#loginForm a[id='spr-sign-in-btn-standard']"
[object]$login_submit_element = find_element_new -css_selector $login_submit_selector
highlight ([ref]$selenium) ([ref]$login_submit_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_submit_element).Click().Build().Perform()

# TODO - assert

Write-Output 'Secret question page'

[string]$secret_answer_selector = "form[id ='sa-securityForm'] input#challengeAnswerId"
$secret_answer = $secret
[string]$secret_answer_data = $secret_answer
[object]$secret_answer_element = find_element_new -css_selector $secret_answer_selector
highlight ([ref]$selenium) ([ref]$secret_answer_element)
$secret_answer_element.SendKeys($secret_answer_data)

[string]$continue_login_selector = "form[id ='sa-securityForm'] a#ContinueLogin"
[object]$continue_login_element = find_element_new -css_selector $continue_login_selector
highlight ([ref]$selenium) ([ref]$continue_login_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$continue_login_element).Click().Build().Perform()

Start-Sleep 1

Write-Output 'Signoff'

[string]$navigate_account_selector = "div[id='nav-account'] div[id='nav-account-menu'] a[class *='nav-account-tab']"
[object]$navigate_account_element = find_element_new -css_selector $navigate_account_selector
highlight ([ref]$selenium) ([ref]$navigate_account_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$navigate_account_element).Click().Build().Perform()

[string]$dialog_c_selector = "div[id='nav-myaccount']"
[object]$dialog_c_element = find_element_new -css_selector $dialog_c_selector
highlight ([ref]$selenium) ([ref]$dialog_c_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$dialog_c_element).Build().Perform()

[object]$signoff_element = $dialog_c_element.FindElement([OpenQA.Selenium.By]::LinkText('Sign Out'))
highlight ([ref]$selenium) ([ref]$signoff_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$signoff_element).Click().Build().Perform()

Start-Sleep -millisecond 100

$selenium.Navigate().GoToUrl("{0}/logout" -f $base_url)

cleanup ([ref]$selenium)
