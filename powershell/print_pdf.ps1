#Copyright (c) 2014,2020 Serguei Kouzmine
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
  [string]$browser = 'chrome'
)
# https://www.nuget.org/packages/Selenium.WebDriver/
# https://www.nuget.org/packages/Selenium.Support/
# https://www.nuget.org/packages/Selenium.WebDriver.ChromeDriver

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)

# default directory for .net assemblies
$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'
# SHARED_ASSEMBLIES_PATH overrides
# $env:SHARED_ASSEMBLIES_PATH = 'C:\developer\sergueik\csharp\SharedAssemblies'
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

# Convertfrom-JSON applies To: Windows PowerShell 3.0 and later
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -gt 2)

# http://stackoverflow.com/questions/15767066/get-session-id-for-a-selenium-remotewebdriver-in-c-sharp

Add-Type -TypeDefinition @'
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
'@ -ReferencedAssemblies 'System.dll',"${shared_assemblies_path}\WebDriver.dll","${shared_assemblies_path}\WebDriver.Support.dll"

# NOTE: 'webdriver.chrome.driver' alone does not appear to work
[Environment]::SetEnvironmentVariable( 'webdriver.chrome.driver', "c:\Users\${env:USERNAME}\Downloads\chromedriver.exe", [System.EnvironmentVariableTarget]::USER)
# NOTE: cannot use this syntax - Powershell tries to find property named 'driver' and fails to proceed
# $env:webdriver.chrome.driver = "c:\Users\${env:USERNAME}\Downloads\chromedriver.exe"

[Environment]::SetEnvironmentVariable( 'webdriver.chrome.logfile', "c:\Users\${env:USERNAME}\AppData\Local\Temp\chromedriver.log", [System.EnvironmentVariableTarget]::USER)
[Environment]::SetEnvironmentVariable( 'PATH', "${env:PATH};c:\Users\${env:USERNAME}\Downloads", [System.EnvironmentVariableTarget]::Process)

pushd env:
dir 'webdriver.chrome.driver', 'webdriver.chrome.logfile'
popd

# https://selenium.dev/selenium/docs/api/dotnet/html/T_OpenQA_Selenium_DriverOptions.htm
[OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
# $options.SetLoggingPreference('Driver', [OpenQA.Selenium.LogLevel]::All)
# intend to capture
# DevTools listening on ws://127.0.0.1:49450/devtools/browser/a9e3f841-1eec-40cf-b879-f08b964b20b4

$options.SetLoggingPreference('Browser', [OpenQA.Selenium.LogLevel]::All)
# $options.addArguments('start-maximized')
$options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))

$options.addArguments('--profile-directory=Default')
# [OpenQA.Selenium.Remote.CapabilityType.LoggingPreferences] $logPrefs = new-object OpenQA.Selenium.Remote.CapabilityType.LoggingPreferences
# $options.setCapability('goog:loggingPrefs', $logPrefs)
$selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver($options)
# NOTE: empty
write-output ('Current log path: "{0}"' -f [OpenQA.Selenium.Chrome.ChromeDriverService]::LogPath)
try {
$logs  = $selenium.Manage().Logs
$entries = $selenium.Manage().Logs.GetLog([OpenQA.Selenium.LogType]::Browser)
# https://github.com/SeleniumHQ/selenium/issues/7335
# https://github.com/SeleniumHQ/selenium/issues/7342
# Exception calling "GetLog" with "1" argument(s): "Object reference not set to an instance of an object."
$entries | foreach-object {
  $entry = $_
  write-output $entry.ToString()
}
} catch [Exception] {
  write-output 'Exception during log collection:'
  write-output $_.Exception.Message
}
# TODO: find the matching method
# [void]$selenium.manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(10))

[string]$base_url = $selenium.Url = 'https://www.wikipedia.org';

try {
	$selenium.Close()
	$selenium.Quit()
} catch [exception]{
	# Ignore errors if unable to close the browser
	Write-Output (($_.Exception.Message) -split "`n")[0]

}
return
