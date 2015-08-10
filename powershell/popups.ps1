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
  [string]$hub_port = '4444',
  [string]$version
)
<#

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\WebDriver.dll' 
or one of its dependencies. This assembly is built by a runtime newer than the currently loaded runtime and cannot be loaded.

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\nunit.framework.dll' or one of its dependencies. 
Operation is not supported. (Exception from HRESULT: 0x80131515) 

use fixw2k3.ps1

Add-Type : Unable to load one or more of the requested types. Retrieve the LoaderExceptions property for more information.
#>

$verificationErrors = New-Object System.Text.StringBuilder


# use Default Web Site to host the page. Enable Directory Browsing.

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port

$base_url = 'file:///root/popup.html'
$base_url = 'file:///C:/developer/sergueik/powershell_selenium/assets/popup.html'

$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
# $selenium.Manage().Window.Maximize()

Start-Sleep 3

$xpath = "//input[@type='button']"

[OpenQA.Selenium.Remote.RemoteWebElement]$button = $selenium.findElement([OpenQA.Selenium.By]::XPath($xpath))

$button.click()
# http://www.programcreek.com/java-api-examples/index.php?api=org.openqa.selenium.Alert
# NOTE: do not explicitly declare the type here
# [OpenQA.Selenium.Remote.RemoteAlert]
$alert = $selenium.switchTo().alert()

Write-Output $alert.Text
$alert.accept()

# This works on FF, Chrome, IE 8 - 11
# http://seleniumeasy.com/selenium-tutorials/how-to-handle-javascript-alerts-confirmation-prompts
# e.g. need to be able to copy a url from a dialog box pop up and paste it into a new browser window

Start-Sleep 3

cleanup ([ref]$selenium)

