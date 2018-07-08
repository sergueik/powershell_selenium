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
  [string]$browser,# = 'firefox'
  [switch]$highlight,
  [switch]$click,
  [switch]$download

)

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.core.dll',
  'nunit.framework.dll'

)

$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'

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

[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)


$hub_host = '127.0.0.1'
$hub_port = '4444'

$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

$verificationErrors = New-Object System.Text.StringBuilder

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Debug "Running on ${browser}"
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
  Write-Debug 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}
$base_url = "file:///C:/developer/sergueik/powershell_ui_samples/external/MyKeynoteDetails.htm"
$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()

[OpenQA.Selenium.Remote.RemoteWebElement]$link = $selenium.findElement([OpenQA.Selenium.By]::xpath("//a[contains(text(),'View Headers')]"))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$link).Build().Perform()

if ($PSBoundParameters['highlight']) {
  # optional highlight
  # need a different javascript.
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$link,'color: blue; border: 4px solid blue;')
  Start-Sleep 4
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$link,'')
}
$text_url = $link.GetAttribute('href')
if ($PSBoundParameters['click']) {
  # optional click
  $link.click()
}
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}

# RawContent is a mix of ascii header
# and a UTF16 body, 

$result = Invoke-WebRequest -Uri $text_url
[System.Text.Encoding]$out_encoding = [System.Text.Encoding]::ASCII
[System.Text.Encoding]$in_encoding = [System.Text.Encoding]::UNICODE
[byte[]]$bytes = $in_encoding.GetBytes($result.Content)
$bytes = [System.Text.Encoding]::Convert([System.Text.Encoding]::UNICODE,[System.Text.Encoding]::ASCII,$bytes)
# NOTE - THIS second conversion IS needed because the way $bytes is returned.
$bytes = [System.Text.Encoding]::Convert([System.Text.Encoding]::UNICODE,[System.Text.Encoding]::ASCII,$bytes)
$data = $out_encoding.GetString($bytes)

if ($PSBoundParameters['download']) {
  $out_file = $text_url
  $out_file = $out_file -replace '.+/',''
  write-host ('Saving "{0}"' -f $out_file )
  Remove-Item -Path $out_file -Force -ErrorAction 'SilentlyContinue'
  $data | Out-File -FilePath $out_file -Encoding ascii
}

[NUnit.Framework.Assert]::IsTrue(($data -match 'ASP.NET_SessionId'))
$data | ForEach-Object {
  $line = $_
  $found = $line -match 'ASP.NET_SessionId=([^; ]+);'
  if ($found) {
    $session_id = $matches[1]
  }

}

write-host ('ASP.NET_SessionId="{0}"' -f $session_id)


