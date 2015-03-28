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
  [string]$browser,
  [int]$version,
  [int]$test

)
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
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability("version",$version.ToString());
    }
    # http://www.browserstack.com/automate/c-sharp   
  }

  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  try {
    $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
  } catch [exception]{
    Write-Output $_.Exception.Message
    exit
  }
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = "C:\tools\phantomjs"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

# http://stackoverflow.com/questions/6927229/context-click-in-selenium-2-2
# $base_url = "http://www.flickr.com/photos/davidcampbellphotography/4581594452"
# 

$base_url = "http://www.urbandictionary.com"


$selenium.Navigate().GoToUrl($base_url + "/")
$selenium.Manage().Window.Maximize()
# $element = $selenium.FindElement([OpenQA.Selenium.By]::ClassName("main-photo"))
Start-Sleep 5
$element = $selenium.FindElement([OpenQA.Selenium.By]::Id("logo"))

# Save Link as...
# Copy link location

if ($test -eq '1') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1

  [void]$context.Build().Perform()
  [void]$context.MoveByOffset(10,95)
  # [void]$context.MoveByOffset(10,100)
  [void]$context.Build().Perform()
  Start-Sleep -Seconds 3
  $keys = @(
    [OpenQA.Selenium.Keys]::RETURN
  )
  [void]$context.SendKeys(($keys -join ''))
  [void]$context.Build().Perform()

 # [void]$context.Click()
 # [void]$context.Build().Perform()
 # Start-Sleep 4

}
# 

if ($test -eq '2') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1
  [void]$context.SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).SendKeys([OpenQA.Selenium.Keys]::ARROW_DOWN).
  SendKeys([OpenQA.Selenium.Keys]::RETURN)
  [void]$context.Build().Perform()

  Start-Sleep 4

}
# 


if ($test -eq '3') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1

  [string]$keys = @(
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::RETURN
  )
  [void]$context.SendKeys(($keys -join ''))
  [void]$context.Build().Perform()

  Start-Sleep -Seconds 4

}

if ($test -eq '4') {
  Write-Output $test

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $context = $actions.ContextClick($element)
  Start-Sleep -Seconds 1

  [string]$keys = @(
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    # [OpenQA.Selenium.Keys]::ARROW_DOWN,
    # [OpenQA.Selenium.Keys]::ARROW_DOWN,
    # [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::ARROW_DOWN,
    [OpenQA.Selenium.Keys]::RETURN
  )
  $keys | ForEach-Object {
    [void]$context.SendKeys($_)
    Start-Sleep -Milliseconds 200
  }

  [void]$context.Build().Perform()

  Start-Sleep -Seconds 4

}

<# hmm

[void]$context.SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_DOWN).sendKeys(Keys.ARROW_DOWN).SendKeys(Keys.ARROW_RIGHT).SendKeys(Keys.ARROW_DOWN).perform();
[void]$context.Build().Perform()
#>
# Save Link as...
# $context.MoveByOffset(10,95)
# Copy link location
[void]$context.MoveByOffset(10,100)
[void]$context.Build().Perform()
Start-Sleep -Seconds 3

[void]$context.Click()
[void]$context.Build().Perform()

<#
Exception calling "Perform" with "0" argument(s): "stale element reference:
element is not attached to the page document
#>
# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  Write-Output (($_.Exception.Message) -split "`n")[0]
}

