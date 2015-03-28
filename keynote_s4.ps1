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
  [string]$browser = 'firefox',
  [int]$version,
  [string]$base_url = 'https://my.keynote.com/newmykeynote/logon.do',
  [string]$username,
  [string]$password
)
[string]$device = 'CCL - Carnival.com'
if ($base_url -eq '') {
  $base_url = $env:BASE_URL
}

if (($base_url -eq '') -or ($base_url -eq $null)) {
  Write-Error 'The required parameter is missing : BASE_URL'
  exit (1)
}

if ($username -eq '') {
  $username = $env:USERNAME
}

if (($username -eq '') -or ($username -eq $null)) {
  Write-Error 'The required parameter is missing : USERNAME'
  exit (1)
}

if ($password -eq '') {
  $password = $env:PASSWORD
}

if (($password -eq '') -or ($password -eq $null)) {
  Write-Error 'The required parameter is missing : PASSWORD'
  exit (1)
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

[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)

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

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(120))
$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()

# Enter credentials
$value1 = 'un'
$css_selector1 = ('input#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 30
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))

[NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('type') -match 'text'))
$element1.SendKeys($username)


$value1 = 'pw'
$css_selector1 = ('input#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 30
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('type') -match 'password'))
$element1.SendKeys($password)


$value1 = 'loginbtn'
$css_selector1 = ('input#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('value') -match 'Sign In'))
Write-Output ('Clicking on "{0}"' -f $element1.GetAttribute('value'))

$element1.Click()

# Navigate the menu to select 'Analyze'

$value1 = 'graphsNavTab'
$css_selector1 = ('a#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 30
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Charts'))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element1).Build().Perform();


$value1 = 'graphsNavTab'
$css_selector1 = ('li#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 30
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
#   [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))

$css_selector2 = 'ul > li > a'
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 30
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$elements3 = $element1.FindElementsByCssSelector($css_selector2)
$element5 = $null

$cnt = 0

$elements3 | ForEach-Object { $element3 = $_
  if (($element3.GetAttribute('href') -match 'graph.asp') -and ($element3.Text -match 'Analyze')) {
    $element5 = $element3
  }
  $cnt++
}
[NUnit.Framework.Assert]::IsTrue(($element5.Text -match 'Analyze'))
[NUnit.Framework.Assert]::IsTrue(($element5.Displayed))


<#

# optional highlight
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'color: blue; border: 4px solid blue;')
Start-Sleep 1
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
#>

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element5).Build().Perform();

$element5.SendKeys([OpenQA.Selenium.Keys]::RETURN)
Start-Sleep 3

# Select device by first filtering
try {
  [OpenQA.Selenium.IWebElement]$web_element = $null
  $web_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector('input[name=regexp]'))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
[NUnit.Framework.Assert]::IsTrue(($web_element -ne $null))
$web_element.SendKeys($device)
[NUnit.Framework.Assert]::IsTrue(($element5.Text -match '')) # Text will be still blank
# NOTE: Do not send ENTER key
# $web_element.SendKeys([OpenQA.Selenium.Keys]::RETURN)
Start-Sleep -Seconds 3

[OpenQA.Selenium.IWebElement]$element1 = $null
try {
  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::Id('mlist'))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
[NUnit.Framework.Assert]::IsTrue(($element1 -ne $null))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match $device))

$element1.Click()

[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript("scroll(0, 200)", $null)
Start-Sleep -Seconds 1
[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript("scroll(0, 0)", $null)
Start-Sleep -Seconds 1

[OpenQA.Selenium.IWebElement]$element1 = $null

$css_selector1 = 'span.scatter'
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 100
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
$element5 = $element1

$element1.Click()

[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript("scroll(0, 500)", $null)
Start-Sleep -Seconds 1
[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript("scroll(0, 0)", $null)
Start-Sleep -Seconds 1


$css_selector1 = 'input[type=RADIO][name=TimeMode][value=Relative]'
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 100
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
// $element1.Click()
$element1.GetAttribute("Selected")

[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript("scroll(0, 500)", $null)
Start-Sleep -Seconds 1
[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript("scroll(0, 0)", $null)
Start-Sleep -Seconds 1

# Start-Sleep -Seconds 5

$css_selector1 = 'div#step4btn > a'
$id1= 'step4btn'
[OpenQA.Selenium.IWebElement]$element1 = $null
write-output ('Locate CSS SELECTOR {0}' -f  $css_selector1)
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 100
  # [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id($id1)))
  # $element1 = $selenium.FindElement([OpenQA.Selenium.By]::Id($id1))
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  $element1   
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1, (($_.Exception.Message) -split "`n")[0])
}
[NUnit.Framework.Assert]::IsTrue(($element1 -ne $null))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Generate Graph'))
if ($element1 -ne $null) {

[OpenQA.Selenium.IJavaScriptExecutor]$jscript = $selenium
[string]$title = $jscript.ExecuteScript("return document.title")
Write-Output $title

$element1.Click()

Start-Sleep -Seconds 10
} else { 
  $selenium.Quit()
}
$css_selector1 = 'path[fill="#f00"]'
[OpenQA.Selenium.IWebElement]$element1 = $null

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 100
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
$element1.Click()

$css_selector1 = 'div.screenshotTitle'
[OpenQA.Selenium.IWebElement]$element1 = $null
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(30))
  $wait.PollingInterval = 150
  $element1 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  $element1
  } catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
if ($element1 -ne $null) {
[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'color: yellow; border: 4px solid yellow;')
Start-Sleep 4
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'')
}
# [NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('href') -match "measure"))

<#
# needs more work
$link_text_value = 'View Headers'
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::LinkText($link_text_value)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::LinkText($link_text_value))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::LinkText($link_text_value))
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'color: yellow; border: 4px solid yellow;')
Start-Sleep 1
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'')

[NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('href') -match "measure"))
$element1.Click()
#>


# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}
