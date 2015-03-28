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
  [string]$browser = 'chrome',
  [switch]$pause
)

function custom_pause { 

if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}

} 

function highlight {

  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [int]$delay = 300
  )

  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'color: yellow; border: 4px solid yellow;')
  Start-Sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'')


}

function find_page_element_by_css_selector {

  param(
    [System.Management.Automation.PSReference]$selenium_driver_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [string] $css_selector,
    [int]$wait_seconds = 10

  )

   if ($css_selector -eq '' -or $css_selector -eq $null ) {
  return 
}
  $local:element = $null 
  [OpenQA.Selenium.Remote.RemoteWebDriver]$local:selenum_driver = $selenium_driver_ref.Value
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($local:selenum_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0], $css_selector )
  }

  $local:element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  $element_ref.Value =  $local:element

}

function find_page_element_by_xpath {

  param(
    [System.Management.Automation.PSReference]$selenium_driver_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [string] $xpath,
    [int]$wait_seconds = 10

  )

   if ($xpath -eq '' -or $xpath -eq $null ) {
  return 
}
  $local:element = $null 
  [OpenQA.Selenium.Remote.RemoteWebDriver]$local:selenum_driver = $selenium_driver_ref.Value
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($local:selenum_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0], $css_selector )
  }

  $local:element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::XPath($xpath))
  $element_ref.Value =  $local:element

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
  'nunit.core.dll',
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
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$DebugPreference = 'Continue'
# Convertfrom-JSON applies To: Windows PowerShell 3.0 and above
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -gt 2)

$hub_host = '127.0.0.1'
$hub_port = '4444'

$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
    $connection.Close()
  } catch {
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\hub.cmd'
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\node.cmd'
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  # this example may not work with phantomjs 
  $phantomjs_executable_folder = "c:\tools\phantomjs"
  Write-Host 'Running on phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

[void]$selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(60))

$selenium.url = $base_url = 'http://translation2.paralink.com'
$selenium.Navigate().GoToUrl(($base_url + '/'))

[string]$text  = 'Spanish-Russian translation' 
[string]$xpath = "//frame[@id='topfr']"
[Object]$top_frame = $null
find_page_element_by_xpath ([ref]$selenium) ([ref]$top_frame) $xpath
$current_frame = $selenium.SwitchTo().Frame($top_frame)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newtop.asp'),$current_frame.url)
Write-Debug ('Switched to {0} {1}' -f $current_frame.url,$xpath)
$top_frame = $null 

$css_selector = 'select#directions > option[value="es/ru"]'
[OpenQA.Selenium.IWebElement]$element = $null 
find_page_element_by_css_selector ([ref]$current_frame) ([ref]$element)  $css_selector
[NUnit.Framework.Assert]::AreEqual($text, $element.Text, $element.Text)
$element.Click()
$element = $null 

custom_pause

[string]$xpath2 = "//textarea[@id='source']"

[OpenQA.Selenium.IWebElement]$element = $null 
find_page_element_by_xpath ([ref]$current_frame) ([ref]$element) $xpath2
highlight ([ref]$current_frame) ([ref]$element)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($current_frame)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

$text = @"
Yo, Juan Gallo de Andrada, escribano de Cámara del Rey nuestro señor, de los que residen en su Consejo, certifico y doy fe que, habiendo visto por los señores dél un libro intitulado El ingenioso hidalgo de la Mancha, compuesto por Miguel de Cervantes Saavedra, tasaron cada pliego del dicho libro a tres maravedís y medio; el cual tiene ochenta y tres pliegos, que al dicho precio monta el dicho libro docientos y noventa maravedís y medio, en que se ha de vender en papel;.
"@
[void]$element.SendKeys($text)
$element = $null

Start-Sleep -Milliseconds 1000
$css_selector = 'img[src*="btn-en-tran.gif"]'


find_page_element_by_css_selector ([ref]$current_frame) ([ref]$element)  $css_selector
[NUnit.Framework.Assert]::AreEqual('Translate' , $element.GetAttribute('title'),$element.GetAttribute('title'))
highlight ([ref]$current_frame) ([ref]$element)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($current_frame)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

$element = $null 
custom_pause

[void]$selenium.SwitchTo().DefaultContent()

[string]$xpath = "//frame[@id='botfr']"
[Object]$bot_frame = $null
find_page_element_by_xpath ([ref]$selenium) ([ref]$bot_frame) $xpath
$current_frame = $selenium.SwitchTo().Frame($bot_frame)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newbot.asp'),$current_frame.url)
Write-Debug ('Switched to {0}' -f $current_frame.url)
$bot_frame = $null 

[string]$xpath2 = "//textarea[@id='target']"

[OpenQA.Selenium.IWebElement]$element = $null 
find_page_element_by_xpath ([ref]$current_frame) ([ref]$element) $xpath2
highlight ([ref]$current_frame) ([ref]$element)
Write-Output $element.Text

custom_pause

#
# https://code.google.com/p/selenium/source/browse/java/client/src/org/openqa/selenium/remote/HttpCommandExecutor.java?r=3f4622ced689d2670851b74dac0c556bcae2d0fe
# write-output $frame.PageSource
[void]$selenium.SwitchTo().DefaultContent()

$current_frame = $selenium.SwitchTo().Frame(1)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newbot.asp'),$current_frame.url)

custom_pause

[void]$selenium.SwitchTo().DefaultContent()
$current_frame = $selenium.SwitchTo().Frame(0)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newtop.asp'),$current_frame.url)
Write-Debug ('Switched to {0}' -f $current_frame.url)
custom_pause

[void]$selenium.SwitchTo().DefaultContent()
Write-Debug ('Switched to {0}' -f $selenium.url)

# TODO:
# [void]$selenium.SwitchOutOfIFrame()

# Cleanup
cleanup ([ref]$selenium)
