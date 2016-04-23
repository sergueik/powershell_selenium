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
import-module -name ('{0}/{1}' -f '.',  $MODULE_NAME)

$selenium = launch_selenium -browser $browser


# Convertfrom-JSON applies To: Windows PowerShell 3.0 and above
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -gt 2)

[void]$selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(60))

[string]$base_url = 'http://www.naukri.com/'
$selenium.Navigate().GoToUrl($base_url)

$initial_window_handle = $selenium.CurrentWindowHandle

Write-Output ("CurrentWindowHandle = {0}`n" -f $initial_window_handle)

$handles = @()
try {
  $handles = $selenium.WindowHandles
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
if ($handles.Count -gt 1) {
  $handles | ForEach-Object {
    $switch_to_window_handle = $_
    if ($switch_to_window_handle -eq $initial_window_handle)
    {
      [void]$selenium.switchTo().defaultContent()
    } else {


      [void]$selenium.switchTo().window($switch_to_window_handle)
      Start-Sleep -Seconds 10
      $window_handle = $selenium.CurrentWindowHandle
      Write-Output ('WindowHandle : {0}' -f $window_handle)


      Write-Output ('Title: {0}' -f $selenium.Title)
      # write-output ([OpenQA.Selenium.Remote.RemoteTargetLocator]::DefaultContent)

      $window_size = $selenium.Manage().window.Size
      $window_position = $selenium.Manage().window.Position
      $selenium.Manage().window.Size = New-Object System.Drawing.Size (600,400)
      $selenium.Manage().window.Position = New-Object System.Drawing.Point (0,0)
      Start-Sleep -Seconds 10
      $selenium.Manage().window.Size = $window_size
      $selenium.Manage().window.Position = $window_position
      Start-Sleep -Seconds 10
      [void]$selenium.switchTo().window($initial_window_handle)
    }
  }
  [void]$selenium.switchTo().window($initial_window_handle)
  [void]$selenium.switchTo().defaultContent()

}
# Cleanup

cleanup ([ref]$selenium)
return
