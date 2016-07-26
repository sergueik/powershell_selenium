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
# # http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver
param(
  [switch]$browser
)

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
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.framework.dll'
)

$env:SHARED_ASSEMBLIES_PATH = 'c:\developer\sergueik\csharp\SharedAssemblies'

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://www.wikipedia.org/'
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

[void]$selenium.manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(10))
$selenium.Manage().Window.Size = new-Object System.Drawing.Size(600, 400)
$window_size = $selenium.Manage().Window.Size

write-output ('height={0},width={1}' -f $window_size.Height, $window_size.Width)
$selenium.Manage().Window.Position = new-Object System.Drawing.Point(0 , 0)
$window_position = $selenium.Manage().Window.Position
write-output ('x={0},y={1}' -f $window_position.X, $window_position.Y)
start-sleep -seconds 3

# Cleanup
cleanup ([ref]$selenium)

