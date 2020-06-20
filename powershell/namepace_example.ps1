#Copyright (c) 2020 Serguei Kouzmine
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

using namespace OpenQA.Selenium
# NOTE: a 'using' statement must appear before any other statements in a script.
# see also: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_using?view=powershell-7
#
using namespace System.Management.Automation
# NOTE: only one 'using' statement with a given assembly is allowed per script.
# doubling the statement leads to
# Type name 'Chrome.ChromeOptions' is ambiguous, it could be OpenQA.Selenium.Chrome.ChromeOptions or OpenQA.Selenium.Chrome.ChromeOptions.
# using namespace OpenQA.Selenium
using namespace System.Text
# Type name 'UnicodeEncoding' is ambiguous, it could be System.Text.UnicodeEncoding or System.Text.UnicodeEncoding.
# using namespace System.Text
using namespace System.IO
using namespace OpenQA.Selenium.Support.UI
using namespace NUnit.Framework
param(
  [string]$browser = 'chrome',
  [string]$base_url = 'http://www.seleniumeasy.com/test',
  [switch]$debug,
  [switch]$pause

)

function custom_pause {
  param(
    [bool]$fullstop,
    [int]$timeout = 1000
  )
  # Do not close Browser / Selenium when run from Powershell ISE
  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond $timeout
  }
}
# https://seleniumonlinetrainingexpert.wordpress.com/2012/12/03/how-to-automate-youtube-using-selenium-webdriver/

function cleanup
{
  param(
    [PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    # Ignore errors if unable to close the browser
    Write-Output (($_.Exception.Message) -split "`n")[0]
  }
}

# http://poshcode.org/2887
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
# https://msdn.microsoft.com/en-us/library/system.management.automation.invocationinfo.pscommandpath%28v=vs.85%29.aspx
function Get-ScriptDirectory {
  [string]$scriptDirectory = $null

  if ($host.Version.Major -gt 2) {
    $scriptDirectory = (Get-Variable PSScriptRoot).Value
    Write-Debug ('$PSScriptRoot: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
    Write-Debug ('$MyInvocation.PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    Write-Debug ('$PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
  } else {
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
      $scriptDirectory = $Invocation.PSScriptRoot
    } elseif ($Invocation.MyCommand.Path) {
      $scriptDirectory = Split-Path $Invocation.MyCommand.Path
    } else {
      $scriptDirectory = $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
    }
    return $scriptDirectory
  }
}

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
$shared_assemblies | foreach-object { unblock-file -Path $_; Add-Type -Path $_ }
popd

[string]$string = 'data'
[string]$algorithm = 'SHA256'

[byte[]]$stringbytes = [UnicodeEncoding]::Unicode.GetBytes($string)

$headless = $false

$verificationErrors = new-object System.Text.StringBuilder

if ($browser -ne $null -and $browser -ne '') {
  if ($browser -match 'chrome') {
    $capability = [Remote.DesiredCapabilities]::Chrome()

    [Chrome.ChromeOptions]$options = new-object Chrome.ChromeOptions

    $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))

    $options.addArguments('--profile-directory=Default')

    [Remote.DesiredCapabilities]$capabilities = [Remote.DesiredCapabilities]::Chrome()
    $capabilities.setCapability([Chrome.ChromeOptions]::Capability, $options)

    $selenium = new-object Chrome.ChromeDriver($options)
  }
}
$selenium.Navigate().GoToUrl($base_url)
[WebDriverWait]$wait = new-object WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
$xpath = '//div[@class="logo"]/a[@href="/"]/img'
try {
  [void]$wait.Until([ExpectedConditions]::ElementIsVisible([By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[IWebElement]$element = $selenium.FindElement([By]::XPath($xpath))
write-output $element.getAttribute('alt')

[Assert]::IsTrue(($element -ne $null))
custom_pause

if ($selenium -ne $null){
  try {
    $selenium.close()
    $selenium.quit()
  } catch [Exception]{
    # ignorehttps://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_using?view=powershell-7
  }
}
