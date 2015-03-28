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
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
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


# http://stackoverflow.com/questions/15767066/get-session-id-for-a-selenium-remotewebdriver-in-c-sharp
Add-Type -TypeDefinition @"
using System;
using OpenQA.Selenium;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Support.UI;
public class CustomeRemoteDriver : RemoteWebDriver
{
    // OpenQA.Selenium.WebDriver  ?
    public CustomeRemoteDriver(ICapabilities desiredCapabilities)
        : base(desiredCapabilities)
    {
    }

    public CustomeRemoteDriver(ICommandExecutor commandExecutor, ICapabilities desiredCapabilities)
        : base(commandExecutor, desiredCapabilities)
    {
    }

    public CustomeRemoteDriver(Uri remoteAddress, ICapabilities desiredCapabilities)
        : base(remoteAddress, desiredCapabilities)
    {
    }

    public CustomeRemoteDriver(Uri remoteAddress, ICapabilities desiredCapabilities, TimeSpan commandTimeout)
        : base(remoteAddress, desiredCapabilities, commandTimeout)
    {
    }

    public string GetSessionId()
    {
        return base.SessionId.ToString();
    }
} 
"@ -ReferencedAssemblies 'System.dll',"${shared_assemblies_path}\WebDriver.dll","${shared_assemblies_path}\WebDriver.Support.dll"



try {
  $connection = (New-Object Net.Sockets.TcpClient)
  $connection.Connect('127.0.0.1',4444)
  $connection.Close()
}
catch {
  $selemium_driver_folder = 'c:\java\selenium'
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\hub.cmd"
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\node.cmd"
  Start-Sleep 10
}


$hub_host = '127.0.0.1'
$hub_port = '4444'

$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

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
  $driver = New-Object CustomeRemoteDriver ($uri,$capability)
} else {
  $phantomjs_executable_folder = "c:\tools\phantomjs"
  Write-Host 'Running on phantomjs'
  $driver = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $driver.Capabilities.SetCapability("ssl-protocol","any")
  $driver.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $driver.Capabilities.SetCapability("takesScreenshot",$true)
  $driver.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}


[void]$driver.manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(10))
[string]$base_url = $driver.Url = 'http://www.google.com';
$driver.Navigate().GoToUrl($base_url)

# Unable to find type [OpenQA.Selenium.Remote.RemoteCookieJar].

$cookies = $driver.manage().Cookies.AllCookies

$cookies.Name -split '`n' | ForEach-Object {
  $cookie_name = $_
  Write-Output ('->{0}' -f $cookie_name)

  try {

    $cookie = $driver.manage().Cookies.GetCookieNamed($cookie_name)
    Write-Output '---'
    Write-Output ('domain = "{0}"' -f $cookie.Domain)
    Write-Output ('Name = "{0}"' -f $cookie.Name)
    Write-Output ('Value = "{0}"' -f $cookie.Value)
    Write-Output '---'

    [void]$driver.manage().Cookies.DeleteCookieNamed($cookie.Name)
    [void]$driver.manage().Cookies.AddCookie($cookie)
  } catch [exception]{
    Write-Output (( $_.Exception.Message ) -split "`n" )[0]
    # Ignore errors if unable to close the browser
  }

}


# Cleanup
cleanup ([ref]$selenium)

