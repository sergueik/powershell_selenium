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
  [string]$hub_host = '127.0.0.1',
  [string]$hub_port = '4444'
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port

<# 
pushd C:\tools 
mklink /D phantomjs C:\phantomjs-1.9.7-windows
symbolic link created for phantomjs <<===>> C:\phantomjs-1.9.7-windows
#>

$selenium.Navigate().GoToUrl($base_url)
# https://groups.google.com/forum/?fromgroups#!topic/selenium-users/V1eoFUMEPqI
[OpenQA.Selenium.Interactions.Actions]$builder = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# NOTE: failed in phantomjs
[OpenQA.Selenium.IWebElement]$canvas = $selenium.FindElement([OpenQA.Selenium.By]::Id("tutorial"))
[void]$builder.Build()
[void]$builder.MoveToElement($canvas,100,100)
Start-Sleep -Seconds 4
[void]$builder.clickAndHold()
[void]$builder.moveByOffset(40,60)
Start-Sleep -Seconds 4

[void]$builder.release()
[void]$builder.Perform()

Start-Sleep -Seconds 4

# Cleanup
cleanup ([ref]$selenium)

