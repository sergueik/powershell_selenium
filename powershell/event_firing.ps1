#Copyright (c) 2014,2015 Serguei Kouzmine
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


function netstat_check
{
  param(
    [string]$selenium_http_port = 4444
  )

  $results = Invoke-Expression -Command "netsh interface ipv4 show tcpconnections"

  $t = $results -split "`r`n" | Where-Object { ($_ -match "\s$selenium_http_port\s") }
  (($t -ne '') -and $t -ne $null)

}

function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',# for Events
  'nunit.core.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {
  # Unblock-File -Path $_; 
  Add-Type -Path $_
}
popd

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$verificationErrors = New-Object System.Text.StringBuilder
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}" -foreground 'Yellow'
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability("version",$version.ToString());
    }

  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Host 'Running on phantomjs' -foreground 'Yellow'
  $phantomjs_executable_folder = "C:\tools\phantomjs"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}


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
$element_value_changing_handler.Invoke(
  {
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




