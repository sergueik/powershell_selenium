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
param(
  [string]$browser = 'firefox',
  [int]$version,
  [string]$base_url = 'http://www.carnival.com/BookingEngine/Booking/Book/?embkCode=MIA&itinCode=WCB&durDays=4&shipCode=EC&subRegionCode=CW&sailDate=11092015&sailingID=71870&numGuests=2&showDbl=False&isOver55=N&isPastGuest=N&stateCode=&isMilitary=N&evsel=#/number-of-staterooms',
  [string]$title = '4 Day to Western Caribbean',
  [string]$port = 'Miami, FL',
  [string]$ship = 'Carnival Ecstasy',
  [string]$dest = 'Caribbean',
  [switch]$pause
)

function be2_button_process {
  param(
    [string]$data_tag_page_suffix = $null,
    [string]$button_text = 'Continue',
    [string]$check_header = $null
  )

  $local:css_header_selector = 'div.scrollable div.content h1'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$local:wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  Write-Output ('Wait for panel header: {0} ' -f $check_header)

  $local:wait.PollingInterval = 150
  [void]$local:wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($local:css_header_selector)))
  $local:header = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_header_selector))
  if ($check_header -ne $null) {
    [NUnit.Framework.Assert]::IsTrue(($local:header.Text -match $check_header),('expected: {0} got:{1}' -f $check_header,$local:header.Text))
    Write-Output ('Confirmed panel header: {0} ' -f $local:header.Text)
  }

  $local:click_button = $null

  $local:css_selector1 = ('a[data-tag-page-suffix*="{0}"]' -f $data_tag_page_suffix)

  $local:xpath_selector1 = ''
  Write-Output $local:css_selector1
  [bool]$local:found0 = $false

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
    $local:found0 = $true
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $local:buttons = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
  $local:button_count = 0
  $local:buttons | ForEach-Object {
    $local:button = $_
    if (($button_text -ne '') -and ($local:button.Text -match '\S') -and ($local:button.Text -match $button_text)) {

      Write-Output ('Clicking: {0} => {1}' -f $local:button.Text,($local:button.GetAttribute('data-tag-page-suffix')))

      [string]$script = @"
function getPathTo(element) {
    if (element.id!=='')
        return '*[@id="'+element.id+'"]';
    if (element===document.body)
        return element.tagName;

    var ix= 0;
    var siblings= element.parentNode.childNodes;
    for (var i= 0; i<siblings.length; i++) {
        var sibling= siblings[i];
        if (sibling===element)
            return getPathTo(element.parentNode)+'/'+element.tagName+'['+(ix+1)+']';
        if (sibling.nodeType===1 && sibling.tagName===element.tagName)
            ix++;
    }
}
return getPathTo(arguments[0]);
"@
      $local:xpath_selector1 = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$local:button,'')).ToString()

      Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $local:button.Text,$local:xpath_selector1)

      [OpenQA.Selenium.Interactions.Actions]$local:actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

      $local:actions.ClickAndHold([OpenQA.Selenium.IWebElement]$local:button).Build().Perform()

      $local:actions.MoveToElement([OpenQA.Selenium.IWebElement]$local:button).Build().Perform()
      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$local:button,'color: green; border: 4px solid green;')
      Start-Sleep -Milliseconds 150
      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$local:button,'')
      $local:actions.Release([OpenQA.Selenium.IWebElement]$local:button).Build().Perform()
    }
  }

}

function be2_button_process_select2 {
  param(
    [string]$data_tag_page_suffix,
    [string]$step_name,
    [string]$button_text,
    [string]$check_header = $null
  )

  Write-Output ('Begin {0}' -f $step_name)

  $local:click_button = $null

  $local:css_selector1 = ('a[data-tag-page-suffix*="{0}"]' -f $data_tag_page_suffix)
  Write-Output $local:css_selector1
  [OpenQA.Selenium.Support.UI.WebDriverWait]$local:wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $local:wait.PollingInterval = 150

  [void]$local:wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($local:css_selector1)))

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $local:button = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
  [OpenQA.Selenium.Interactions.Actions]$local:actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $local:actions.MoveToElement([OpenQA.Selenium.IWebElement]$local:button).Build().Perform()
  $local:button.Click()

  Write-Output ('End {0}' -f $step_name)

}

function be2_button_process_select {
  param(
    [string]$data_tag_page_suffix,
    [string]$step_name,
    [string]$button_text,
    [string]$check_header = $null
  )

  Write-Output ('Begin {0}' -f $step_name)

  $local:css_header_selector = 'div.scrollable div.content h1'
  Write-Output ('Wait for panel header: {0} ' -f $check_header)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$local:wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))

  $local:wait.PollingInterval = 150
  [void]$local:wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($local:css_header_selector)))
  $local:header = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_header_selector))
  if ($check_header -ne $null) {
    [NUnit.Framework.Assert]::IsTrue(($local:header.Text -match $check_header))
    Write-Output ('Confirmed panel header: {0} ' -f $local:header.Text)
  }

  $local:click_button = $null

  $local:css_selector1 = ('button[data-tag-page-suffix*="{0}"]' -f $data_tag_page_suffix)
  Write-Output $local:css_selector1

  [void]$local:wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($local:css_selector1)))

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $local:button = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
  # Todo: highlight

  $local:button.Click()

  Write-Output ('End {0}' -f $step_name)

}


function amend_itinerary_dates {

  param(
    [System.Management.Automation.PSReference]$url_ref = ([ref]$null),
    [int]$months_increment = 2
  )
  $local:url = $url_ref.Value
  $local:url
  [NUnit.Framework.Assert]::IsTrue((($local:url -ne $null) -and ($local:url -ne '')))

  $local:Date = Get-Date

  $local:Date = $local:Date.AddMonths($months_increment)
  $local:date_str = $local:Date.ToString('MMyyyy')
  $local:url = $local:url -replace 'datFrom=\d{4,4}',('datFrom={0}' -f $local:date_str)
  $local:url = $local:url -replace 'datTo=\d{4,4}',('datTo={0}' -f $local:date_str)
  $url_ref.Value = $local:url
  $local:url
}



function extract_match {

  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)

  )
  Write-Debug ('Extracting from {0}' -f $source)
  $local:results = {}
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  Write-Debug 'extract_match:'
  Write-Debug $local:results
  $result_ref.Value = $local:results.Media
}


function custom_pause {

  param([bool]$fullstop)
  # Do not close Browser / Selenium when run from Powershell ISE

  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
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


$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect('127.0.0.1',4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start /min cmd.exe /c c:\java\selenium\node.cmd"
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
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability("version",$version.ToString());
    }

  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice: '${browser}'"
  }
  $uri = [System.Uri]('http://127.0.0.1:4444/wd/hub')
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent',"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()
[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

Write-Output ('Started with {0}' -f $selenium.Title)

[NUnit.Framework.StringAssert]::Contains('/BookingEngine/Booking/Book/',$selenium.url,{})
[NUnit.Framework.StringAssert]::Contains('evsel=',$selenium.url,{})

$fullstop = (($PSBoundParameters['pause']) -ne $null)

# TODO: inspect ul.nav-list small.ng-binding Travelers,Rooms etc.

be2_button_process -data_tag_page_suffix ':number of rooms' -check_header 'HOW MANY STATEROOMS DO YOU NEED'
Start-Sleep -Millisecond 500

be2_button_process -data_tag_page_suffix ':number of travelers' -check_header 'HOW MANY PEOPLE ARE CRUISING'
Start-Sleep -Millisecond 500

be2_button_process -data_tag_page_suffix ':check for deals' -check_header 'CHECK FOR AVAILABLE DISCOUNTS'
Start-Sleep -Millisecond 3000

be2_button_process_select -data_tag_page_suffix ':stateroom category selection' -button_text 'Select' -step_name 'Select room part 1' -check_header 'WHICH TYPE OF ROOM IS RIGHT FOR YOU'
Start-Sleep -Millisecond 1000

be2_button_process_select2 -data_tag_page_suffix ':stateroom type selection' -button_text 'Select' -step_name 'Select room part 2' -check_header $null
Start-Sleep -Millisecond 1000

be2_button_process_select -data_tag_page_suffix ':choose rate' -button_text 'Select' -check_header 'HERE ARE SOME GREAT DEALS FOR YOU'
Start-Sleep -Millisecond 5000

be2_button_process -data_tag_page_suffix ':choose location' -button_text '' -check_header 'Which Section Do You Prefer'

be2_button_process_select -data_tag_page_suffix ':choose deck' -button_text 'Select' -check_header 'Which Deck Would You Like'

be2_button_process -data_tag_page_suffix ':choose room' -check_header 'Time To Pick Your Room'
custom_pause -fullstop $fullstop

# At the end of the run - do not close Browser / Selenium when executing from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}

