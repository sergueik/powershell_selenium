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
  [string]$browser = 'ie',
  [string]$base_url = 'http://www.msn.com/',
  [switch]$all_zones,
  [int]$version
)

if ($base_url -eq '') {
  $base_url = $env:BASE_URL
}

if (($base_url -eq '') -or ($base_url -eq $null)) {
  Write-Error 'The required parameter is missing : BASE_URL'
  exit (1)
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
    # Selenium quirks:
    # http://jimevansmusic.blogspot.com/2012/08/youre-doing-it-wrong-protected-mode-and.html
    $capability.SetCapability("IntroduceInstabilityByIgnoringProtectedModeSettings",$true);

    # REGISTRY tweaks:

    $zones = @( '4','3')

    if ($PSBoundParameters["all_zones"]) {
      # Proceed to two remaining zones

      $zones += @( '2','1')

    }

    $zones | ForEach-Object {

      $zone = $_
      $hive = 'HKCU:'
      $path = ('/Software/Microsoft/Windows/CurrentVersion/Internet Settings/Zones/{0}' -f $zone)

      $data = @{ '2500' = '3';
        '2707' = '0'
      }

      pushd $hive
      cd $path

      $description = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name 'DisplayName' -ErrorAction 'SilentlyContinue'
      if ($description -eq $null) {
        $description = '???'

      } else {
        $description = $description.DisplayName }

      Write-Output ('Configuring Zone {0} - "{1}"' -f $zone,$description)


      $data.Keys | ForEach-Object {
        $name = $_
        $value = $data.Item($name)
        Write-Output ('Writing Settings {0}' -f $name)
        $setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
        if ($setting -ne $null) {
          Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
        } else {
          if ($setting -ne $value) {
            New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD

          }
        }
      }
      popd

    }

  # For IE 11 also need to switch to Enterprise Mode and use a site list
  # http://msdn.microsoft.com/en-us/library/dn640699.aspx
  # http://msdn.microsoft.com/en-us/library/dn640687.aspx
  # Enterprise Mode Site List Manager tool 
  # https://www.linkedin.com/groups/Hi-All-I-am-observing-961927.S.5954303177544257537?view=&item=5954303177544257537&type=member&gid=961927&trk=eml-b2_anet_digest-hero-4-hero-disc-disc-0&midToken=AQGpqMsZZNuraw&fromEmail=fromEmail&ut=2Wrj0MXnSR3mA1
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

$selenium.Navigate().GoToUrl($base_url)
# $selenium.Manage().Window.Maximize()
Start-Sleep -Second 10

# Cleanup
cleanup ([ref]$selenium)

