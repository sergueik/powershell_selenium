#Copyright (c) 2014,2018 Serguei Kouzmine
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
  [string]$browser = 'chrome',
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$verificationErrors = New-Object System.Text.StringBuilder

if ($host.Version.Major -le 2) {
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $selenium.Manage().Window.Size = New-Object System.Drawing.Size (480,600)
  $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
} else {
  $selenium.Manage().Window.Size = @{ 'Height' = 600; 'Width' = 480; }
  $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
}

$window_position = $selenium.Manage().Window.Position
$window_size = $selenium.Manage().Window.Size

$base_url = 'http://www.carnival.com/'
#

# TODO
# invoke NLog assembly for proper logging triggered by the events
# www.codeproject.com/Tips/749612/How-to-NLog-with-VisualStudio

$event = New-Object -Type 'OpenQA.Selenium.Support.Events.EventFiringWebDriver' -ArgumentList @( $selenium)

# $event | get-member
# Start-Sleep -Millisecond 1000
# Write-Output ($event | Get-Member -MemberType Event) #
#

$navigating_handler = $event.add_Navigating
$navigating_handler.Invoke({
  param(
    [object]$sender,
    [OpenQA.Selenium.Support.Events.WebDriverNavigationEventArgs]$eventargs
  )
  Write-Host -foreground 'green' 'Navigating handler' #
  Write-Host ($eventargs | Get-Member -MemberType Property) #
  [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
  [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null))
})

$clicking_handler = $event.add_ElementClicking
$clicking_handler.Invoke({
  param(
    [object]$sender,
    [OpenQA.Selenium.Support.Events.WebDriverNavigationEventArgs]$eventargs
  )
  Write-Host -foreground 'green' 'Element Clicking Changing handler' #
  Write-Host ($eventargs | Get-Member -MemberType Property) #
  [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
  #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))
})


$navigating_back_handler = $event.add_NavigatingBack
$navigating_back_handler.Invoke({
  param(
    [object]$sender,
    [OpenQA.Selenium.Support.Events.WebDriverNavigationEventArgs]$eventargs
  )
  Write-Host -foreground 'green' 'Navigating Back handler' #
  Write-Host ($eventargs | Get-Member -MemberType Property) #
  [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
  #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))
})

$element_value_changing_handler = $event.add_ElementValueChanging
$element_value_changing_handler.Invoke({
  param(
    [object]$sender,
    [OpenQA.Selenium.Support.Events.WebElementEventArgs]$eventargs
  )
  Write-Host -foreground 'green' 'Element Value Changing handler' #
  Write-Host ($eventargs | Get-Member -MemberType Property) #
  [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
  #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))
})

$script_executing_handler = $event.add_ScriptExecuting
$script_executing_handler.Invoke( {
  param(
    [object]$sender,
    [OpenQA.Selenium.Support.Events.WebDriverScriptEventArgs]$eventargs
  )
  Write-Host -foreground 'green' 'Script Executing handler' #
  Write-Host ($eventargs | Get-Member -MemberType Property) #
  [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
  #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))
})
$finding_element_handler = $event.add_FindingElement
$finding_element_handler.Invoke( {
  param(
    [object]$sender,
    [OpenQA.Selenium.Support.Events.FindElementEventArgs]$eventargs
  )
  Write-Host -foreground 'green' 'Finding Element handler' #
  Write-Host ($eventargs | Get-Member -MemberType Property) #
  # [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
  #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))
})

$event.Navigate().GoToUrl($base_url)

# -- fragment of pseudo_mobile2.ps1

$xpath = '//span[contains(text(),"Sail From")]'
Write-Output ('Locating via XPath: "{0}"' -f $xpath)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Xpath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $event.FindElement([OpenQA.Selenium.By]::Xpath($xpath))
Write-Output ('Processing : "{0}"' -f $element.getAttribute('outerHTML'))
Write-Output ('Processing : "{0}"' -f $element.Text)
Write-Output ('Processing : "{0}"' -f $element.getAttribute('innerHTML'))

try{
  # NOTE: $element.Text is empty
  [NUnit.Framework.Assert]::IsTrue($event.Text -eq '')
  [NUnit.Framework.Assert]::IsTrue($event.getAttribute('innerHTML') -match 'Sail From')
} catch [Exception] {

}
##
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$actions.MoveToElement($element).Click().Build().Perform()
highlight ([ref]$selenium) ([ref]$element)
try{
  $element.click()
} catch [Exception] {
  # Exception calling "Click" with "0" argument(s): "Cannot convert the "OpenQA.Selenium.Support.Events.WebElementEventArgs" value of type "OpenQA.Selenium.Support.Events.WebElementEventArgs" to type"OpenQA.Selenium.Support.Events.WebDriverNavigationEventArgs"."
}
[void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
# Cleanup
# set_timeouts ([ref]$event) -exlicit 120 -page_load 180 -script 180
start-sleep -seconds 30
cleanup ([ref]$event)


