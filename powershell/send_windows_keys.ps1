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
  [string]$browser
)

$MODULE_NAME = 'selenium_utils.psd1'
import-module -name ('{0}/{1}' -f '.',  $MODULE_NAME)

$selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies

[void]$selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(60))

$selenium.url = $base_url = 'http://translation2.paralink.com/'
# $selenium.url = $base_url = 'http://www.freetranslation.com/'

$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()

[string]$xpath = "//frame[@id='topfr']"
$top_frame = $selenium.findElement([OpenQA.Selenium.By]::Xpath($xpath))
$frame_driver = $selenium.SwitchTo().Frame($top_frame)

$actions = New-Object OpenQA.Selenium.Interactions.Actions ($frame_driver)

$source_text = $frame_driver.FindElementByXPath("//textarea[@class='textus']")
$source_text = $frame_driver.findElement([OpenQA.Selenium.By]::Xpath("//textarea[@class='textus']"))
[NUnit.Framework.Assert]::IsTrue($source_text.Displayed)

# Input some text
$source_text.Clear()

Start-Sleep -Seconds 1
$source_text.SendKeys('good morning')

# does not work
# $actions.SendKeys($source_text,'good morning') | out-null


Start-Sleep -Seconds 1
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
# http://msdn.microsoft.com/en-us/library/system.windows.forms.sendkeys.send%28v=vs.110%29.aspx
[void]$actions.SendKeys($source_text,[System.Windows.Forms.SendKeys]::SendWait("^a"))

# Copy text
[void]$actions.SendKeys($source_text,[System.Windows.Forms.SendKeys]::SendWait("^x"))
Start-Sleep -Seconds 1
# Paste text
[void]$actions.SendKeys($source_text,[System.Windows.Forms.SendKeys]::SendWait("^v"))

[void]$actions.SendKeys($source_text,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
# Paste text second time 
[void]$actions.SendKeys($source_text,[System.Windows.Forms.SendKeys]::SendWait("^v"))

$button_image = $selenium.FindElementByXPath("//img[@alt='Translate']")
$button_image.Click()
Start-Sleep -Seconds 3
[void]$selenium.SwitchTo().DefaultContent()

$xpath = "//frame[@id='botfr']"
$bot_frame = $selenium.findElement([OpenQA.Selenium.By]::Xpath($xpath))
$frame_driver = $selenium.SwitchTo().Frame($bot_frame)

$actions = New-Object OpenQA.Selenium.Interactions.Actions ($frame_driver)

$target_text = $frame_driver.FindElementByXPath("//textarea[@name='target']")
$target_text = $frame_driver.findElement([OpenQA.Selenium.By]::Xpath("//textarea[@class='textus']"))
[NUnit.Framework.Assert]::IsTrue($target_text.Displayed)
Write-Output ('Translation: ' + $target_text.Text)
<#
# TODO : copy between frames
[void]$actions.SendKeys($target_text,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
# Paste text second time 
[void]$actions.SendKeys($target_text,[System.Windows.Forms.SendKeys]::SendWait("^v"))
#>
Start-Sleep 1

<#
$dirs_image = $selenium.FindElementByXPath("//div[@class='dirs']")
$dirs_image.Click()
$button_image.Click()
#>
cleanup ([ref]$selenium)
