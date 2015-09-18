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
  [string]$base_url = 'https://www.freelancer.com',
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

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

[string]$login_css_selector = "span[id='new-nav'] button[id='login-normal']"
[object]$login_button_element = find_element_new -css_selector $login_css_selector

highlight ([ref]$selenium) ([ref]$login_button_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_button_element).Click().Build().Perform()

Write-Output 'Log in'

[string]$login_div_selector = "form[id='login-form']"
[object]$login_div_element = find_element_new -css_selector $login_div_selector
highlight ([ref]$selenium) ([ref]$login_div_element)

[string]$login_username_selector = "form[id='login-form'] input.username"
[string]$login_username_data = $username

[object]$login_username_element = find_element_new -css_selector $login_username_selector
highlight ([ref]$selenium) ([ref]$login_username_element)
$login_username_element.Clear()
$login_username_element.SendKeys($login_username_data)



[string]$login_password_selector = "form[id='login-form'] input.password"
[string]$login_password_data = $password
[object]$login_password_element = find_element_new -css_selector $login_password_selector
highlight ([ref]$selenium) ([ref]$login_password_element)
$login_password_element.Clear()

$login_password_element.SendKeys($login_password_data)



[string]$login_submit_selector =  "form[id='login-form'] button[id='login-bt']"
[object]$login_submit_element = find_element_new -css_selector $login_submit_selector
highlight ([ref]$selenium) ([ref]$login_submit_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_submit_element).Click().Build().Perform()

$wait_seconds =  10
$wait_polling_interval = 300  
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = $wait_polling_interval

[string]$profile_figure_selector = "figure[id='profile-figure'][class='profile-img']"
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($profile_figure_selector)))
    } catch [exception]{
      Write-Debug ("Exception : {0} ...`ncss = '{1}'" -f (($_.Exception.Message) -split "`n")[0],$profile_figure_selector)
    }
[object]$profile_figure_element = find_element_new -css_selector $profile_figure_selector

highlight ([ref]$selenium) ([ref]$profile_figure_element)

Start-Sleep -millisecond 1000
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$profile_figure_element).Click().Build().Perform()


[NUnit.Framework.StringAssert]::Contains('www.freelancer.com/dashboard/',$selenium.url,{})

$selenium.Navigate().GoToUrl("{0}/users/onsignout.php" -f $base_url)
Start-Sleep -millisecond 1000


cleanup ([ref]$selenium)
