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
# http://techlearn.in/content/web-page-zoom-inout-using-selenium-webdriver
param(
  [string]$browser = '',
  [switch]$grid
)


$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid -shared_assemblies $shared_assemblies

} else {
  $selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies

}


$selenium.Navigate().GoToUrl($base_url)
Start-Sleep -Milliseconds 4000

[void]$selenium.manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(10))
# $selenium.Manage().Window.Size = new-Object System.Drawing.Size(600, 400)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$logo = $selenium.FindElementByXPath("//img[@alt='Mozilla']")

highlight ([ref]$selenium) ([ref]$logo)

<#
# Some OpenQA.Selenium.Keys do not seem to work with C# client 
# chord is not available
$target_text.SendKeys(([OpenQA.Selenium.Keys]::Control +  [OpenQA.Selenium.Keys]::Substract))
start-sleep -milliseconds 300
#>


Write-Output 'Zoom in'
# zoom in does not seem to work on Chrome or Firefox
(1,2,3,4,5) | ForEach-Object {
  try{
  # https://msdn.microsoft.com/en-us/library/system.windows.forms.sendkeys.send%28v=vs.110%29.aspx
  [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait("^{+}"))
  # http://blogs.msdn.com/b/timid/archive/2014/08/05/send-keys.aspx
  # [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait("^{+}`0"))
  } catch [Exception] { 
    # ignore exception
    write-Debug $_.Exception.Message
  }
  Start-Sleep -Milliseconds 1100
}
Write-Output 'Zoom 100%'
try{
  [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^0'))
  } catch [Exception] { 
    # ignore exception
    write-Debug $_.Exception.Message
  }
Start-Sleep -Seconds 1

Write-Output 'Reload'
try{
[void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^R'))
  } catch [Exception] { 
    # ignore exception
    write-Debug $_.Exception.Message
  }

Start-Sleep -Seconds 3

Write-Output 'Zoom out'
(1,2,3,4,5) | ForEach-Object {
try{
  [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^-'))
  } catch [Exception] { 
    # ignore exception
    # key sequence to send must not be null
    write-Debug $_.Exception.Message
  }

  Start-Sleep -Milliseconds 1100
}
Write-Output 'Zoom 100%'

try{
  [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^0'))
  } catch [Exception] { 
    # ignore exception
    write-Debug $_.Exception.Message
  }
Start-Sleep -Seconds 3
<#
 NOTE: cannot send keys to img node: Exception calling "SendKeys" with "1" argument(s):  "unknown error: cannot focus element
#>

$target_text_field = $selenium.FindElementByXPath("//input[contains(@type,'email') or contains(@type, 'text') ]")

highlight ([ref]$selenium) ([ref]$target_text_field)

Write-Output 'Zoom in'
# zoom in does not seem to work on Chrome or Firefox
(1,2,3,4,5) | ForEach-Object {
  try{
  [void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait("^{+}"))
  Start-Sleep -Milliseconds 1100
  } catch [Exception] { 
   write-output $_.Exception.Message
  }
}
[void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^0'))
Start-Sleep -Seconds 1
Write-Output 'Reload'

[void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^R'))
Start-Sleep -Seconds 3

Write-Output 'Zoom out'
(1,2,3) | ForEach-Object {
  [void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^-'))
  Start-Sleep -Milliseconds 1100
}
Write-Output 'Zoom 100%'

[void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^0'))
Start-Sleep -Milliseconds 3000

Write-Output 'Done.'

# Cleanup
cleanup ([ref]$selenium)



