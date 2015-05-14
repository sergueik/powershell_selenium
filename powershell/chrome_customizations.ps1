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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
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
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://www.carnival.com/'

  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }


# Oveview of extensions 
# https://sites.google.com/a/chromium.org/chromedriver/capabilities

# Profile creation
# https://support.google.com/chrome/answer/142059?hl=en
# http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
# using Profile 
# http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195


# origin:
# http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

[OpenQA.Selenium.Chrome.ChromeOptions]$options = new-object OpenQA.Selenium.Chrome.ChromeOptions

    $options.addArguments('start-maximized')
   # no-op option - re-enforcing the default setting
   $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\' , '/' )))
   # if you like to specify another profile parent directory:
   # $options.addArguments('user-data-dir=c:/TEMP'); 

    $options.addArguments('--profile-directory=Default')

    [OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
    $capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability, $options)

    $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)


Add-Type @"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OpenQA.Selenium;

namespace WaitForExtensions
{
    public static class DocumentReadyState
    {
        static int cnt = 0;
        static string expected_state = "interactive";
        public static void Wait(/* this // no longer is an extension method  */ IWebDriver driver)
        {
            var wait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
            wait.PollingInterval = TimeSpan.FromSeconds(0.50);
            wait.Until(dummy => ((IJavaScriptExecutor)driver).ExecuteScript("return document.readyState").Equals(expected_state));
        }

        public static void Wait2(/* this // no longer is an extension method  */ IWebDriver driver)
        {
            var wait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
            wait.PollingInterval = TimeSpan.FromSeconds(0.50);
            wait.Until(dummy =>
            {
                string result = ((IJavaScriptExecutor)driver).ExecuteScript("return document.readyState").ToString();
                Console.Error.WriteLine(String.Format("result = {0}", result));
                Console.WriteLine(String.Format("cnt = {0}", cnt));
                cnt++;
                return (result.Equals(expected_state));
            });
        }
    }

}
"@ -ReferencedAssemblies 'System.dll','System.Data.dll','System.Data.Linq.dll',"${shared_assemblies_path}\WebDriver.dll","${shared_assemblies_path}\WebDriver.Support.dll"



$selenium.Navigate().GoToUrl($base_url)
[WaitForExtensions.DocumentReadyState]::Wait2($selenium)
$script = @"

var performance = 
      window.performance || 
      window.mozPerformance || 
      window.msPerformance || 
      window.webkitPerformance || {}; 

// performance.timing will not return anything with Chrome
var network = performance.getEntries() || {}; 
return network;



"@

# executeScript works fine with Chrome or Firefox 31, ie 10, but not IE 11.
# Exception calling "ExecuteScript" with "1" argument(s): "Unable to get browser
# https://code.google.com/p/selenium/issues/detail?id=6511  
# 
# https://code.google.com/p/selenium/source/browse/java/client/src/org/openqa/selenium/remote/HttpCommandExecutor.java?r=3f4622ced689d2670851b74dac0c556bcae2d0fe

$result = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script);
$result | foreach-object { 
$element_result  = $_ 
# $element_result | format-list
write-output $element_result.name
write-output $element_result.duration
} 


# Cleanup

cleanup ([ref]$selenium)


