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
  [string]$username = 'kouzmine_serguei@yahoo.com',
  [string]$password = 'd1emW02m_@'
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
$title = $selenium.Title
[NUnit.Framework.Assert]::IsTrue(($title.IndexOf('Logon Page - MyKeynote') -gt -1),$title)
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

$title = $selenium.Title
[NUnit.Framework.Assert]::IsTrue(($title.IndexOf('Home - MyKeynote') -gt -1),$title)

<#
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



# optional highlight
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'color: blue; border: 4px solid blue;')
Start-Sleep 1
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

#>

# Log off 

$value1 = 'settingsNavTab'
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
# optional highlight
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'color: blue; border: 4px solid blue;')
Start-Sleep 1
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

# TODO: find attributes to assert  
Write-Output $element1.ToString()
$element1
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match ''),$element1.Text)

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element1).Build().Perform()

$css_selector2 = ('li#{0} > ul > li > a' -f $value1)
Write-Output ('Navigating to CSS SELECTOR {0}' -f $css_selector2)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(5))
  $wait.PollingInterval = 100
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
  # [void]$selenium.FindElementsByCssSelector($css_selector2)
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  throw
}

# Relative does not work
$css_selector_relative_2 = 'ul > li > a'
$elements3 = $element1.FindElementsByCssSelector($css_selector_relative_2)
# $elements3 
$elements3 = $selenium.FindElementsByCssSelector($css_selector2)
# $elements3
$element5 = $null
# $elements3 | get-member
$cnt = 0

$elements3 | ForEach-Object { $element3 = $_
  # optional highlight
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'color: blue; border: 4px solid blue;')
  Start-Sleep -Milliseconds 200
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'')
  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

  if ($element3.GetAttribute('href') -match 'mylogout.aspx') {
    $element5 = $element3
  }
  $cnt++
}
[NUnit.Framework.Assert]::IsTrue(($element5.Text -match 'Sign out'))
[NUnit.Framework.Assert]::IsTrue(($element5.Displayed))
$element5.SendKeys([OpenQA.Selenium.Keys]::RETURN)
Start-Sleep 4
$title = $selenium.Title
[NUnit.Framework.Assert]::IsTrue(($title.IndexOf('Logon Page - MyKeynote') -gt -1),$title)

# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}
# d1emW02m_@
