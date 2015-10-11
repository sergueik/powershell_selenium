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


# http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver

param(
  [string]$browser = 'firefox',
  [string]$base_url = 'http://stackoverflow.com',
  [int]$event_delay = 250,
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



[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
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

# https://github.com/yizeng/EventFiringWebDriverExamples
$event_firing_selenium = New-Object -Type 'OpenQA.Selenium.Support.Events.EventFiringWebDriver' -ArgumentList @( $selenium)

$exception_handler = $event_firing_selenium.add_ExceptionThrown
$exception_handler.Invoke({
    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.WebDriverExceptionEventArgs]$eventargs
    )
    Write-Host 'Taking screenshot' -foreground 'Yellow'
    $filename = 'test'
    # Take screenshot identifying the browser
    [OpenQA.Selenium.Screenshot]$screenshot =  $sender.GetScreenshot()
    $screenshot.SaveAsFile([System.IO.Path]::Combine((Get-ScriptDirectory),('{0}.{1}' -f $filename,'png')),[System.Drawing.Imaging.ImageFormat]::Png)
    # initiate browser close  event from the exception handler? 
  })
$event_firing_selenium.Navigate().GoToUrl($base_url)
$event_firing_selenium.Manage().Window.Maximize()

Start-Sleep -Millisecond 3000
$event_firing_selenium.FindElement([OpenQA.Selenium.By]::CssSelector("#hlogo > a")).Displayed
Start-Sleep -Millisecond 3000
$event_firing_selenium.FindElement([OpenQA.Selenium.By]::CssSelector("#hlogo > a > b > c")).Displayed

custom_pause -fullstop $fullstop
cleanup ([ref]$selenium)

