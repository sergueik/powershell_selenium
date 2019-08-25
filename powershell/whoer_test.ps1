#Copyright (c) 2019 Serguei Kouzmine
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
  [string]$browser = 'chrome',
  [string]$base_url = 'https://whoer.net',
  [switch]$debug,
  [switch]$pause

)
# https://www.blackhatworld.com/seo/fake-system-time-in-selenium-chromedriver.949581/
# cloned from
# ${env:HOMEPATH}\AppData\Local\Google\Chrome\User Data\Default\Extensions\nbofeaabhknfdcpoddmfckpokmncimpj\0.1.4_0
# ${env:HOMEPATH}\AppData\Local\Google\Chrome\User Data\Default\Local Extension Settings\nbofeaabhknfdcpoddmfckpokmncimpj
# https://github.com/plaa/TimeShift-js
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

# http://poshcode.org/2887
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
# https://msdn.microsoft.com/en-us/library/system.management.automation.invocationinfo.pscommandpath%28v=vs.85%29.aspx
function Get-ScriptDirectory
{
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
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$headless = $false

$verificationErrors = New-Object System.Text.StringBuilder
$env:PATH="${env:PATH};c:\java\selenium"

  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\node_with_timezone.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
    # override

    # Oveview of extensions 
    # https://sites.google.com/a/chromium.org/chromedriver/capabilities

    # Profile creation
    # https://support.google.com/chrome/answer/142059?hl=en
    # http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
    # using Profile 
    # http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195


    # origin:
    # http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

    [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions

    $options.addArguments('start-maximized')
    # no-op option - re-enforcing the default setting
    $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))
    # if you like to specify another profile parent directory:
    # $options.addArguments('user-data-dir=c:/TEMP'); 

    $options.addArguments('--profile-directory=Default')
<#


chrome.webNavigation.onCommitted.addListener(function (details) {
  if (config.addon.state === "ON") {
    var code = config.options;
    app.tab.inject(details.tabId, {
      "allFrames": false,
      "matchAboutBlank": true,
      "runAt": "document_start",
      "frameId": details.frameId,
      "code": "var timeZoneStorage = " + JSON.stringify(config.options.timezone) + ';'
    }, {
      "allFrames": false,
      "matchAboutBlank": true,
      "runAt": "document_start",
      "frameId": details.frameId,
      "file": "/data/content_script/inject.js"
    });
  }
});


#>
<#
var inject = function (o) {
  const convertToGMT = function (n) {
    const format = function (v) {return (v < 10 ? '0' : '') + v};
    return (n <= 0 ? '+' : '-') + format(Math.abs(n) / 60 | 0) + format(Math.abs(n) % 60);
  };
  //
  const resolvedOptions = Intl.DateTimeFormat().resolvedOptions();
  const {
    toJSON, getYear, getMonth, getHours, toString, getMinutes, getSeconds, getUTCMonth, getFullYear, getUTCHours,
    getUTCFullYear, getMilliseconds, getTimezoneOffset, getUTCMilliseconds, toLocaleTimeString, toLocaleDateString,
    toISOString, toGMTString, toUTCString, toTimeString, toDateString, getUTCSeconds, getUTCMinutes, toLocaleString,
    getDay, getUTCDate, getUTCDay, getDate
  } = Date.prototype;
  //
  Object.defineProperty(Date.prototype, '_offset', {"configurable": true, get() {return getTimezoneOffset.call(this)}});
  Object.defineProperty(Date.prototype, '_date', {"configurable": true, get() {
    return this._nd !== undefined ? this._nd : new Date(this.getTime() + (this._offset - o.value) * 60 * 1000);
  }});
  //
  Object.defineProperty(Date.prototype, 'toJSON', {"value": function () {return toJSON.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getDay', {"value": function () {return getDay.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getDate', {"value": function () {return getDate.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getYear', {"value": function () {return getYear.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getTimezoneOffset', {"value": function () {return Number(o.value)}});
  Object.defineProperty(Date.prototype, 'getMonth', {"value": function () {return getMonth.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getHours', {"value": function () {return getHours.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCDay', {"value": function () {return getUTCDay.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCDate', {"value": function () {return getUTCDate.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getMinutes', {"value": function () {return getMinutes.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getSeconds', {"value": function () {return getSeconds.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCMonth', {"value": function () {return getUTCMonth.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCHours', {"value": function () {return getUTCHours.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getFullYear', {"value": function () {return getFullYear.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toISOString', {"value": function () {return toISOString.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toGMTString', {"value": function () {return toGMTString.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toUTCString', {"value": function () {return toUTCString.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toDateString', {"value": function () {return toDateString.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toTimeString', {"value": function () {return toTimeString.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCSeconds', {"value": function () {return getUTCSeconds.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCMinutes', {"value": function () {return getUTCMinutes.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCFullYear', {"value": function () {return getUTCFullYear.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toLocaleString', {"value": function () {return toLocaleString.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getMilliseconds', {"value": function () {return getMilliseconds.call(this._date)}});
  Object.defineProperty(Date.prototype, 'getUTCMilliseconds', {"value": function () {return getUTCMilliseconds.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toLocaleTimeString', {"value": function () {return toLocaleTimeString.call(this._date)}});
  Object.defineProperty(Date.prototype, 'toLocaleDateString', {"value": function () {return toLocaleDateString.call(this._date)}});
  //
  Object.defineProperty(Intl.DateTimeFormat.prototype, 'resolvedOptions', {"value": function () {return Object.assign(resolvedOptions, {"timeZone": o.name})}});
  Object.defineProperty(Date.prototype, 'toString', {"value": function () {
    return toString.call(this._date).replace(convertToGMT(this._offset), convertToGMT(o.value)).replace(/\(.*\)/, '(' + o.name.replace(/\//g, ' ') + ' Standard Time)');
  }});
  //
  document.documentElement.dataset.ctzscriptallow = true;
};

var script_1 = document.createElement('script');
script_1.textContent = "(" + inject + ")(" + JSON.stringify(timeZoneStorage) + ")";
document.documentElement.appendChild(script_1);

if (document.documentElement.dataset.ctzscriptallow !== "true") {
  var script_2 = document.createElement('script');
  script_2.textContent = `{
    const iframes = window.top.document.querySelectorAll("iframe[sandbox]");
    for (var i = 0; i < iframes.length; i++) {
      if (iframes[i].contentWindow) {
        if (iframes[i].contentWindow.Date.prototype) {
          iframes[i].contentWindow.Date.prototype = Date.prototype;
        }
        if (iframes[i].contentWindow.Intl.DateTimeFormat.prototype) {
          iframes[i].contentWindow.Intl.DateTimeFormat.prototype = Intl.DateTimeFormat.prototype;
        }
      }
    }
  }`;
  window.top.document.documentElement.appendChild(script_2);
}

#>
$options.addArguments(@("--lang=en", "--disable-web-security", "--disable-local-storage",
                "--disable-system-timezone-automatic-detection", "--disable-webgl", "--dns-prefetch-disable",
                "--disable-plugins-discovery", "--local-timezone", "--disable-timezone-tracking-option",
                "--enable-virtualized-time"))

    [OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
    $capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability,$options)

    $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)


# Actual action .
$script_directory = Get-ScriptDirectory
<#

TIME
Zone:
America/New_York
Local:
Sat Aug 24 2019 19:52:49 GMT-0400 (EDT)
System:
Sat Aug 24 2019 16:52:49 GMT-0700 (Pacific Daylight Time)

#>
$selenium.Navigate().GoToUrl($base_url)

# Cleanup
start-sleep -seconds 1200
cleanup ([ref]$selenium)
