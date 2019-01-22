#Copyright (c) 2019 Serguei Kouzmine
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

# NOTE:  currently ol works right ith grid option
# NOTE:  copied from script that uses some profile and maximized the browses
#   . .\swagbucks_test.ps1 -pause -grid -password 12345
param(
  [string]$base_url = 'http://www.swagbucks.com/',
  [string]$username = 'kouzmine_serguei@yahoo.com',
  [string]$password,
  [string]$browser = 'chrome',
  [switch]$grid,
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


# log in
$login_id = 'sbLogInSignUpContainer'
$matching_rows = @()
$login_css_selector  = '#sbLogInCta'
# $login_element = find_element -Id $login_id
$login_element = find_element -css  $login_css_selector
write-debug ('Log in element' -f $login_element.getAttribute('outerHTML') )


highlight -element ([ref]$login_element) -color 'green' -selenium_ref ([ref]$selenium)
$login_element.Click()
# TODO: id
$email_css_selector = '#sbxJxRegEmail'
$email_element = find_element -css $email_css_selector
$email_element.sendKeys($username)

# TODO: ids DO look randomized too!
$password_css_selector = '#sbxJxRegPswd'
$password_element = find_element -css $password_css_selector
$password_element.sendKeys($password)


# recapcha sits in an iframe
$recapcha_iframe_css_selector = '#sbCaptcha iframe'
$recapcha_iframe_element = find_element -css $recapcha_iframe_css_selector
$recapcha_iframe = $selenium.SwitchTo().Frame($recapcha_iframe_element)

$recapcha_css_selector = '#recaptcha-anchor > div.recaptcha-checkbox-checkmark'
[OpenQA.Selenium.IWebElement]$recapcha_element = $recapcha_iframe.FindElement([OpenQA.Selenium.By]::cssSelector($recapcha_css_selector))
write-output $recapcha_element
highlight ([ref]$recapcha_iframe) ([ref]$recapcha_element) -timeout 3000

try{
$recapcha_element.sendKeys([OpenQA.Selenium.Keys]::SPACE <# ' ' #> ) # Space
} catch [Exception] {
	# slurp:
	# Exception calling "SendKeys" with "1" argument(s): "unknown error: cannot focus element"
}
try{
  $recapcha_element.Click()
} catch [Exception] {
	# NOTE: no exception
}

# will launche the unparsable recapcha dialog
custom_pause -fullstop $fullstop



if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}


