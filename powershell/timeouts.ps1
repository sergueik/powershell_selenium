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

function set_timeouts{ 
  param(
  [System.Management.Automation.PSReference]$selenium_ref ,
  [int]$explicit = 10 ,
  [int]$page_load = 60 ,
  [int]$script = 30 
  )

[void]($selenium_ref.Value.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
[void]($selenium_ref.Value.Manage().Timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
[void]($selenium_ref.Value.Manage().Timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))

}


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
#   'Selenium.WebDriverBackedSelenium.dll',
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

$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://www.wikipedia.org'
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
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = "C:\tools\phantomjs"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.setCapability("ssl-protocol","any")
  $selenium.Capabilities.setCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.setCapability("takesScreenshot",$true)
  $selenium.Capabilities.setCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}




$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

set_timeouts ([ref]$selenium)
# var hasJQueryLoaded = (bool) js.ExecuteScript("return (window.jQuery != null) && (jQuery.active === 0);");

[int]$timeout = 4000
# change $timeout to see if the WevDriver is waiting on page  sctript to execute

[string]$script = "window.setTimeout(function(){document.getElementById('searchInput').value = 'test'}, ${timeout});"

$start = (Get-Date -UFormat "%s")

try {
  [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeAsyncScript($script);

} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  # Ignore
  # Timed out waiting for async script result  (Firefox)
  # asynchronous script timeout: result was not received (Chrome)
  [NUnit.Framework.Assert]::IsTrue($_.Exception.Message -match '(?:Timed out waiting for async script result|asynchronous script timeout)')
}
catch [OpenQA.Selenium.NoSuchWindowException]{
  Write-Host $_.Exception.Message # Unable to get browser
  $_.Exception | Get-Member

}
$end = (Get-Date -UFormat "%s")
$elapsed = New-TimeSpan -Seconds ($end - $start)
Write-Output ('Elapsed time {0:00}:{1:00}:{2:00} ({3})' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds,($end - $start))
<#
Exception calling "ExecuteAsyncScript" with "1" argument(s): 
"Unable to get browser (WARNING: The server did not provide any stacktrace information)

#>
Start-Sleep 3

# Cleanup
cleanup ([ref]$selenium)
