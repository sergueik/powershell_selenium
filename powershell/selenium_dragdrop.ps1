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
  [switch]$browser
)

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
#  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.core.dll',
  'nunit.framework.dll'

)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

<# 
pushd C:\tools 
mklink /D phantomjs C:\phantomjs-1.9.7-windows
symbolic link created for phantomjs <<===>> C:\phantomjs-1.9.7-windows
#>

$verificationErrors = New-Object System.Text.StringBuilder
# use Default Web Site to host the page. Enable Directory Browsing.
$base_url = "http://localhost/jOrgChart-master2/example.html"
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
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
#   $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
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


$selenium.Navigate().GoToUrl($base_url )
$selenium.Navigate().Refresh()
$selenium.Manage().Window.Maximize()

function test_drag_drop {
  param (
    [Object] $name 
  )


$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector('.ui-draggable'))

$elements | foreach-object { 
  if  ($_.Text -match $name ) {
    $element = $_
    write-output ('-->{0}' -f $element.Text)
  }
}


[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: yellow; border: 4px solid yellow;')
Start-Sleep 1
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')
[OpenQA.Selenium.Interactions.Actions]$builder = New-Object OpenQA.Selenium.Interactions.Actions($selenium);
# not chaining the actions, hence [void]
# see http://stackoverflow.com/questions/14210051/how-to-automate-drag-drop-functionality-using-selenium-web-driver
[void]$builder.Build();
[void]$builder.dragAndDrop($element,$elements[0])
[void]$builder.Perform()
Start-Sleep 1
}

@(
  'Pumpkin',
  'Apple',
  'Berries',
  'Granny Smith'
  'Blueberry',
  'Cucumber'
  ) | foreach-object { test_drag_drop -name $_ } 
Start-Sleep 3


try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}


