#Copyright (c) 2014,2015,2018 Serguei Kouzmine
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


# http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver
param(
  [string]$browser = 'firefox',
  [int]$event_delay = 250,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

$verificationErrors = New-Object System.Text.StringBuilder

if ($host.Version.Major -le 2) {
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $selenium.Manage().Window.Size = New-Object System.Drawing.Size (600,400)
  $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
} else {
  $selenium.Manage().Window.Size = @{ 'Height' = 400; 'Width' = 600; }
  $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
}

$window_position = $selenium.Manage().Window.Position
$window_size = $selenium.Manage().Window.Size

$base_url = 'http://www.google.com/'

# TODO: invoke NLog assembly for quicker logging triggered by the events
# www.codeproject.com/Tips/749612/How-to-NLog-with-VisualStudio

$event_firing_selenium = New-Object -Type 'OpenQA.Selenium.Support.Events.EventFiringWebDriver' -ArgumentList @( $selenium)

$element_value_changing_handler = $event_firing_selenium.add_ElementValueChanging
$element_value_changing_handler.Invoke({
  param(
    [object]$sender,
    [OpenQA.Selenium.Support.Events.WebElementEventArgs]$eventargs
  )
  Write-Host 'Value Change handler' -foreground 'Yellow'
  if ($eventargs.Element.GetAttribute('id') -eq 'lst-ib') {
    $xpath1 = "//div[@class='sbsb_a']"
    try {
      [OpenQA.Selenium.IWebElement]$local:element = $sender.FindElement([OpenQA.Selenium.By]::XPath($xpath1))
    } catch [exception]{
    }
    Write-Host $local:element.Text -foreground 'Blue'
  }

})

$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://www.google.com'
$event_firing_selenium.Navigate().GoToUrl($base_url)

# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($event_firing_selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 50
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id("hplogo")))

$xpath = "//input[@id='lst-ib']"

# for mobile
# $xpath = "//input[@id='mib']"

[OpenQA.Selenium.IWebElement]$element = $event_firing_selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

# http://software-testing-tutorials-automation.blogspot.com/2014/05/how-to-handle-ajax-auto-suggest-drop.html
$element.SendKeys('Sele')
# NOTE:cannot use 
# [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($event_firing_selenium)
# $actions.SendKeys($element,'Sele')
Start-Sleep -Millisecond $event_delay
$element.SendKeys('nium')
Start-Sleep -Millisecond $event_delay
$element.SendKeys(' webdriver')
Start-Sleep -Millisecond $event_delay
$element.SendKeys(' C#')
Start-Sleep -Millisecond $event_delay
$element.SendKeys(' tutorial')
Start-Sleep -Millisecond $event_delay
$element.SendKeys([OpenQA.Selenium.Keys]::Enter)
Start-Sleep 10

# Cleanup
cleanup ([ref]$event_firing_selenium) 




