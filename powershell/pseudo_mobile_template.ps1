#Copyright (c) 2015 Serguei Kouzmine
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

# http://yizeng.me/2013/08/10/set-user-agent-using-selenium-webdriver-c-and-ruby/#chrome-c-sharp
# http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver
# TODO: switch to RemoteDriver
# https://metacpan.org/pod/Selenium::Remote::Driver::UserAgent
param(
  [string]$browser,
  [int]$version,
  [int]$width = 480,
  [int]$height = 600,
  [string]$base_url,
  [switch]$mobile,
  [switch]$pause
)

function custom_pause {

  param([bool]$fullstop)

  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }
}

function netstat_check
{
  param(
    [string]$selenium_http_port = 4444
  )
  $results = Invoke-Expression -Command "netsh interface ipv4 show tcpconnections"
  $port_check = $results -split "`r`n" | Where-Object { ($_ -match "\s$selenium_http_port\s") }
  (($port_check -ne '') -and $port_check -ne $null)

}

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
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {
  # Unblock-File -Path $_; 
  Add-Type -Path $_
}
popd

[string]$user_agent = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
# $user_agent = 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10'
$phantomjs_executable_folder = 'C:\tools\phantomjs'

if ($browser -ne $null -and $browser -ne '') {

  if (-not (netstat_check)) {
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start /min cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }

  Write-Host "Running on ${browser}"
  if ($browser -match 'firefox') {

    [OpenQA.Selenium.Firefox.FirefoxProfile]$profile = New-Object OpenQA.Selenium.Firefox.FirefoxProfile
    if ($PSBoundParameters['mobile'].IsPresent) {
      $profile.setPreference('general.useragent.override',$user_agent)
    }
    $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($profile)

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
    [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
    $options.AddArgument(('--user-agent={0}' -f $user_agent));

    $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)

  }
  elseif ($browser -match 'ie') {
    # The IE driver does not support changing the user-agent
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability('version',$version.ToString())
    }
  }
  elseif ($browser -match 'safari') {
    # with Safari driver it is not possible to change the user-agent 
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }

  else {
    throw "unknown browser choice:${browser}"
  }
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
  if ($PSBoundParameters['mobile'].IsPresent) {
    $options.AddAdditionalCapability('phantomjs.page.settings.userAgent',$user_agent);
    $selenium.Capabilities.SetCapability('userAgent',$user_agent)
  }
}


$verificationErrors = New-Object System.Text.StringBuilder

if ($PSBoundParameters['mobile'].IsPresent) {
  if ($host.Version.Major -le 2) {
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $selenium.Manage().Window.Size = New-Object System.Drawing.Size ($width,$height)
    $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
  } else {
    $selenium.Manage().Window.Size = @{ 'Height' = $height; 'Width' = $width; }
    $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
  }

  $window_position = $selenium.Manage().Window.Position
  $window_size = $selenium.Manage().Window.Size
}
$selenium.Navigate().GoToUrl($base_url)
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop
# Cleanup
cleanup ([ref]$selenium)
