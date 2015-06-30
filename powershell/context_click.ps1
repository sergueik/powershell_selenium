#Copyright (c) 2014 Serguei Kouzmine
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
  [string]$browser,
  [int]$version,
  [switch]$grid,
  [string]$hub_host = '127.0.0.1',
  [string]$hub_port = '4444',
  [int]$test
)

$verificationErrors = New-Object System.Text.StringBuilder


# http://stackoverflow.com/questions/6927229/context-click-in-selenium-2-2
# $base_url = "http://www.flickr.com/photos/davidcampbellphotography/4581594452"
# 

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies


$base_url = "http://www.urbandictionary.com"


$selenium.Navigate().GoToUrl($base_url + "/")
$selenium.Manage().Window.Maximize()
# $element = $selenium.FindElement([OpenQA.Selenium.By]::ClassName("main-photo"))
Start-Sleep 5
$element = $selenium.FindElement([OpenQA.Selenium.By]::Id("logo"))

# Save Link as...
# Copy link location

if ($test -eq '1') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1

  [void]$context.Build().Perform()
  [void]$context.MoveByOffset(10,95)
  # [void]$context.MoveByOffset(10,100)
  [void]$context.Build().Perform()
  Start-Sleep -Seconds 3
  $keys = @(
    [OpenQA.Selenium.Keys]::RETURN
  )
  [void]$context.SendKeys(($keys -join ''))
  [void]$context.Build().Perform()

 # [void]$context.Click()
 # [void]$context.Build().Perform()
 # Start-Sleep 4

}
# 

if ($test -eq '2') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1
  [void]$context.SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).
  SendKeys([OpenQA.Selenium.Keys]::RETURN)
  [void]$context.Build().Perform()

  Start-Sleep 4

}
# 


if ($test -eq '3') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1

  [string]$keys = @(
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::RETURN
  )
  [void]$context.SendKeys(($keys -join ''))
  [void]$context.Build().Perform()

  Start-Sleep -Seconds 4

}

if ($test -eq '4') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1

  [string]$keys = @(
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    # [OpenQA.Selenium.Keys]::ARROW_DOWN,
    # [OpenQA.Selenium.Keys]::ARROW_DOWN,
    # [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::RETURN
  )
  $keys | ForEach-Object {
    [void]$context.SendKeys($_)
    Start-Sleep -Milliseconds 200
  }

  [void]$context.Build().Perform()

  Start-Sleep -Seconds 4

}

<# hmm

[void]$context.SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).sendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_RIGHT).SendKeys(Keys.ARROW_DOWN).perform();
[void]$context.Build().Perform()
#>
# Save Link as...
# $context.MoveByOffset(10,95)
# Copy link location
[void]$context.MoveByOffset(10,100)
[void]$context.Build().Perform()
Start-Sleep -Seconds 3

[void]$context.Click()
[void]$context.Build().Perform()

<#
Exception calling "Perform" with "0" argument(s): "stale element reference:
element is not attached to the page document
#>
# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  Write-Output (($_.Exception.Message) -split "`n")[0]
}

