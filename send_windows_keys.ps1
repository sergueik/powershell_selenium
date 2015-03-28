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

function cleanup
{
  param(
  [System.Management.Automation.PSReference]$selenium_ref 
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
  # Ignore errors if unable to close the browser
  Write-Output (($_.Exception.Message) -split "`n")[0]

  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

# Convertfrom-JSON applies To: Windows PowerShell 3.0 and above
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -gt 2)

$hub_host = '127.0.0.1'
$hub_port = '4444'

$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
    $connection.Close()
  } catch {
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\hub.cmd'
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\node.cmd'
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  # this example may not work with phantomjs 
  $phantomjs_executable_folder = "c:\tools\phantomjs"
  Write-Host 'Running on phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

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
