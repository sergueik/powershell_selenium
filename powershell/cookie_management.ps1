#Copyright (c) 2014,2019 Serguei Kouzmine
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
  [string]$hub_host = '127.0.0.1',
  [String]$base_url = 'http://www.wikipedia.org',
  [string]$browser,
  [switch]$headless,
  [switch]$grid,
  # NOTE:  currently ol works right ith grid option - locally launched Chrome opens in a full screen mode, working but annoying
  # NOTE: this is because  this is a replica of the table_tnery.ps1 which apatently sets some profile and maximized the browser
  [switch]$pause
)
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
write-debug ('Full Stop: {0}' -f $fullstop )

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  write-debug 'Running on grid'
}
if ([bool]$PSBoundParameters['headless'].IsPresent) {
  write-debug 'Running headless'
}
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  if ([bool]$PSBoundParameters['headless'].IsPresent) {
    $selenium = launch_selenium -browser $browser -grid -headless
  } else {
    $selenium = launch_selenium -browser $browser -grid
  }
} else {
  if ([bool]$PSBoundParameters['headless'].IsPresent) {
    $selenium = launch_selenium -browser $browser -headless
  } else {
    $selenium = launch_selenium -browser $browser
  }
}

$selenium.Navigate().GoToUrl($base_url)
try { 

  [OpenQA.Selenium.Remote.HttpCommandExecutor]$executor = new-object OpenQA.Selenium.Remote.HttpCommandExecutor($uri, [System.TimeSpan]::FromSeconds(10))
   $executor.Execute([OpenQA.Selenium.Remote.DriverCommand]::DeleteAllCookies)
   write-host -ForegroundColor 'Green' "Deleted cookies"
} catch [Exception]{
<#
 Cannot convert value of type
"OpenQA.Selenium.Remote.RemoteWebDriver" to type
"OpenQA.Selenium.Remote.ICommandExecutor".

 new-object : Cannot find type [OpenQA.Selenium.Remote.HttpCommandExecutor]:
 verify that the assembly containing this type is loaded.
#>
# commenting the exception leads to the "Unable to get browser" error in the following code 
# throw
}
# write-host -ForegroundColor 'Green' "Continue with the browser"

$selenium.Navigate().Refresh()

<#

# http://www.milincorporated.com/a2_cookies.html
 pushd "${env:USERPROFILE}\AppData\Roaming\Microsoft\Windows\Cookies"
 pushd "${env:USERPROFILE}\AppData\Roaming\Microsoft\Windows\Cookies\Low\"
NOTE: Recent Files in the latter directory  are present even before the browser is open first time after the cold boot.
# Session cookies ?
 pushd "${env:USERPROFILE}\Local Settings\Temporary Internet Files\Content.IE5"
#>

# http://stackoverflow.com/questions/7413966/delete-cookies-in-webdriver 
<#

$target_server = '...'
function clear_cookies{

$command = 'C:\Windows\System32\rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 2'
[void](invoke-expression -command $command  )
} 

$remote_run_step = invoke-command -computer $target_server -ScriptBlock ${function:clear_cookies}
# note one may try to do the same using java runtime:
http://girixh.blogspot.com/2013/10/how-to-clear-cookies-from-internet.html
try {
  Runtime.getRuntime().exec("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2");
 } catch (IOException e) {
  // TODO Auto-generated catch block
  e.printStackTrace();
#>

<#

caps.setCapability(CapabilityType.ForSeleniumServer.ENSURING_CLEAN_SESSION, true); 
WebDriver driver = new InternetExplorerDriver(caps);

Once initialized, you can use:

driver.manage().deleteAllCookies()

#>

# NOTE: these are very very old post, and some answers are ranked "low-quality or spam":
# http://stackoverflow.com/questions/595228/how-can-i-delete-all-cookies-with-javascript
# http://stackoverflow.com/questions/2144386/javascript-delete-cookie


$script = @'

function createCookie(name, value, days) {
  if (days) {
    var date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    var expires = "; expires=" + date.toGMTString();
  } else var expires = "";
  document.cookie = name + "=" + value + expires + "; path=/";
}

function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
  }
  return null;
}

function eraseCookie(name) {
  createCookie(name, "", -1);
}

var cookies = document.cookie.split(";");
for (var i = 0; i < cookies.length; i++) {
  eraseCookie(cookies[i].split("=")[0]);
}

'@

# executeScript works fine with Chrome or Firefox 31, ie 10, but not IE 11.
# Exception calling "ExecuteScript" with "1" argument(s): "Unable to get browser
# https://code.google.com/p/selenium/issues/detail?id=6511  

[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script)

# Cleanup
if ($PSBoundParameters['pause']) {

  try {

    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}

} else {
  Start-Sleep -Millisecond 1000
}

# Cleanup
cleanup ([ref]$selenium)

