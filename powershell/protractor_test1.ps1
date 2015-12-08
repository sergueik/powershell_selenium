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
  [string]$base_url = 'http://www.way2automation.com/demo.html',
  [string]$login_url = 'http://way2automation.com/way2auto_jquery/index.php',
  [string]$username = 'sergueik',
  [string]$password,
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

} else {
  $selenium = launch_selenium -browser $browser
  start-sleep -millisecond 500
}
write-output $base_url
$selenium.Navigate().GoToUrl($base_url)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

<#

Write-Output 'Zoom 100%'
try{
  [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^0'))
  } catch [Exception] { 
    # ignore exception
    write-Debug $_.Exception.Message
  }

(1,2) | ForEach-Object {
try{
  write-output 'Zoom out'
  [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^-'))
  } catch [Exception] { 
    # ignore exception
    # key sequence to send must not be null
    write-Output $_.Exception.Message
  }
  Start-Sleep -Milliseconds 1100
}
#>

$selenium.Navigate().GoToUrl($login_url)



[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)



[string]$signup_css_selector = 'div#load_box.popupbox form#load_form a.fancybox[href="#login"]'
[object]$signup_button_element = find_element -css_selector $signup_css_selector
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$signup_button_element).Build().Perform()
highlight ([ref]$selenium) ([ref]$signup_button_element) -delay 1200

$signup_button_element.Click()
Write-Output 'Sign Up'


[string]$login_username_selector = "div#login.popupbox form#load_form input[name='username']"
[string]$login_username_data = $username
[object]$login_username_element = find_element -css_selector $login_username_selector
highlight ([ref]$selenium) ([ref]$login_username_element)
$login_username_element.SendKeys($login_username_data)

[string]$login_password_selector = "div#login.popupbox form#load_form input[type='password'][name='password']"
[string]$login_password_data = $password
[object]$login_password_element = find_element -css_selector $login_password_selector
highlight ([ref]$selenium) ([ref]$login_password_element)
$login_password_element.SendKeys($login_password_data)


[string]$login_css_selector = "div#login.popupbox form#load_form [value='Submit']"
[object]$login_button_element = find_element -css_selector $login_css_selector

highlight ([ref]$selenium) ([ref]$login_button_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_button_element).Click().Build().Perform()

Write-Output 'Log in'

$protractor_test_base_url = 'http://www.way2automation.com/protractor-angularjs-practice-website.html'

$selenium.Navigate().GoToUrl($protractor_test_base_url)


[string]$exercise_css_selector = "div.row div.linkbox ul.boxed_style li a[href='http://www.way2automation.com/angularjs-protractor/checkboxes']"
[object]$exercise_button_element = find_element -css_selector $exercise_css_selector
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$exercise_button_element).Build().Perform()
highlight ([ref]$selenium) ([ref]$exercise_button_element)
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('target', '')",$exercise_button_element )

[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$exercise_button_element).Click().Build().Perform()

custom_pause -fullstop $fullstop

# Cleanup
cleanup ([ref]$selenium)



