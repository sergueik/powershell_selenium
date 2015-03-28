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
$verificationErrors = New-Object System.Text.StringBuilder

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
  Write-Debug "Running on ${browser}"
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
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Debug 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

# http://www.w3schools.com/xpath/xpath_axes.asp

$base_url = "file:///C:/developer/sergueik/powershell_ui_samples/external/example2.html"
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

# locator # 1

$name = ''
$class = 'money-out'
$xpath1 = ("//div[contains(@class,'{0}')]" -f $class)

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath1)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath1))


[NUnit.Framework.Assert]::IsTrue(($element1 -ne $null))
[NUnit.Framework.Assert]::IsTrue(($element1.Displayed))

# [OpenQA.Selenium.ILocatable]$loc = ([OpenQA.Selenium.ILocatable]$element)
#
# Write-Output ('{0} id = {1}' -f $element.TagName,$element.GetAttribute('id'))

$classname1 = 'transactionTable'

<#
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  [OpenQA.Selenium.IWebElement]$element2 = $element1.FindElement([OpenQA.Selenium.By]::ClassName($classname1))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
#>
[OpenQA.Selenium.IWebElement]$element2 = $element1.FindElement([OpenQA.Selenium.By]::ClassName($classname1))

$element2
[NUnit.Framework.Assert]::IsTrue(($element2 -ne $null))
[NUnit.Framework.Assert]::IsTrue(($element2.Displayed))

$classname2 = 'transactionItem'

[OpenQA.Selenium.IWebElement[]]$elements3 = $element2.FindElements([OpenQA.Selenium.By]::ClassName($classname2))
$elements3

if ($elements3 -ne $null) {
  Write-Output 'Iterate directly...'
  $elements3 | ForEach-Object { $element3 = $_

    [NUnit.Framework.Assert]::IsTrue(($element3 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element3.Displayed))

    $xpath = 'div/div/div/div/div'

    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element4 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element4 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element4.Displayed))

    $element4.GetAttribute('class')
    $element4.Text

    $xpath = ("div/div/div/div/div[@class]" -f 'transactionAmount')
    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element5 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element5 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element5.Displayed))
    $element5.GetAttribute('class')
    $element5.Text

    $xpath = ("div/div/div/div/div[contains(@class,'{0}')]" -f 'transactionAmount')
    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element6 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element6 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element6.Displayed))
    $element6.GetAttribute('class')
    $element6.Text

    $xpath = ("div/div/div/div/div[@class = '{0}']" -f 'transactionAmount')
    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element7 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element7 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element7.Displayed))
    $element7.GetAttribute('class')
    $element7.Text

  }
  $cnt++
}


# Cleanup
cleanup ([ref]$selenium)


