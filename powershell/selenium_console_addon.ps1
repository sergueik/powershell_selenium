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
  [switch]$browser
)

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  # 'Selenium.WebDriverBackedSelenium.dll',
  # TODO - resolve dependencies
  'nunit.core.dll',
  'nunit.framework.dll'

)
<#

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\WebDriver.dll' 
or one of its dependencies. This assembly is built by a runtime newer than the currently loaded runtime and cannot be loaded.

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\nunit.framework.dll' or one of its dependencies. 
Operation is not supported. (Exception from HRESULT: 0x80131515) 

use fixw2k3.ps1

Add-Type : Unable to load one or more of the requested types. Retrieve the LoaderExceptions property for more information.
#>

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { 
 if ($host.Version.Major -gt 2){
   Unblock-File -Path $_;
 }
 write-output $_
 Add-Type -Path $_ 
 }
popd

$verificationErrors = New-Object System.Text.StringBuilder
# use Default Web Site to host the page. Enable Directory Browsing.
# NOTE: http://stackoverflow.com/questions/25646639/firefox-webdriver-doesnt-work-with-firefox-32

$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
#  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
   $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
#  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()

  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
  [int] $version_major = [int][math]::Round([double]$selenium.Capabilities.Version ) 
  #  http://stackoverflow.com/questions/25646639/firefox-webdriver-doesnt-work-with-firefox-32
  [NUnit.Framework.Assert]::IsTrue($version_major -lt 32)
} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

$base_url = 'file:///C:/developer/sergueik/powershell_ui_samples/external/grid-console.html'
# $base_url = 'http://localhost/selenium-grid/console.html'
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
$selenium.Manage().Window.Maximize()


$selenium.Navigate().Refresh()
$selenium.Manage().Window.Maximize()
[OpenQA.Selenium.Remote.RemoteWebElement]$proxy_id = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("p[class='proxyid']"))
write-host ( "<<<" + $proxy_id.Text )

<# jquery works in FireBug but not Selenium
[string]$script = @"
return
`$("p[class='proxyid']").innerHTML
"@

# write-output $script
[string]$result = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script)
# write-host $result
#>

# http://www.w3schools.com/xpath/xpath_examples.asp
$script = @"
function SelectSingleNode(xmlDoc, elementPath) {
      if (xmlDoc.evaluate) {
        var nodes = xmlDoc.evaluate(elementPath, xmlDoc, null, XPathResult.ANY_TYPE, null);
        var results = nodes.iterateNext();
        return results;
      }
      else
        return xmlDoc.selectSingleNode(elementPath); 
    }


var result = SelectSingleNode(window.document, "//p[@class='proxyid']") ;

var p = document.createElement('div');
var t = document.createTextNode('DNS Data from Powershell');
p.appendChild(t); 
// t.style.background-color = '#f00'; 
// result.parentNode.appendChild(p); 
result.appendChild(p); 
"@
[string]$result = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script)


start-sleep 4
[OpenQA.Selenium.Remote.RemoteWebElement]$proxy_id = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("p[class='proxyid']"))
write-host ( ">>>" + $proxy_id.Text )
[NUnit.Framework.Assert]::IsTrue($proxy_id.Text -match 'Data from Powershell' )

start-sleep 6

<#

https://www.youtube.com/watch?v=bwQqz3cb1Jc

# inject the  output of 
$ipv4_address = '10.240.140.11'
# what is better ?
$host_entry  = [System.Net.DNS]::GetHostEntry( $ipv4_address )  
$host_entry  =  [System.Net.Dns]::GetHostbyAddress( $ipv4_address )  
$host_entry.HostName
$ipv4_address  =  ( [System.Net.Dns]::GetHostAddresses( $host_entry.HostName  ))[0].IPAddressToString
# write into <p class="proxyid">
# via asyncexecscript

#>

function add_info {
  param (
    [Object] $name ,
    [Object] $index 

  )
# reserved for future use ...
return 
}

start-sleep 3

try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}

