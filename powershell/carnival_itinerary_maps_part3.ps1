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
  [string]$browser = $null,
  [string]$dest = 'Caribbean',
  [string]$port = 'Miami, FL',
  [switch]$all,
  [switch]$follow,
  [switch]$pause
)

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


function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    # Ignore errors if unable to close the browser
    Write-Debug (($_.Exception.Message) -split "`n")[0]

  }
}

function print_itinerary_link_info {
  param(
    [int]$position,
    [string]$destination,
    [string]$port,
    [string]$description,
    [string]$url,
    [string]$log_filename
  )

  Write-Output ('{0}|{1}|{2}|{3}|{4}' -f `
       $position,`
       $destination,`
       $port,`
       $description,`
       $url) | Out-File $log_filename -Append

}


function extract_itinerary_description {
  param([string]$text)

  $description = ($element1.Text -split "`r`n")[0]
  $port_ship = ($element1.Text -split "`r`n")[1]

}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'C:\selenium\csharp\sharedassemblies'

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
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\node.cmd"
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
    throw "unknown browser choice:${browser}"
  }
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
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

$script_directory = (Get-ScriptDirectory)
$script_directory = 'C:\developer\sergueik\powershell_selenium\powershell'
Write-Output '---' | Out-File ('{0}\{1}' -f $script_directory,'results.csv') -Append

$base_url = 'http://www.carnival.com'

$selenium.Navigate().GoToUrl($base_url + '/')

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

Write-Debug ('Started with {0}' -f $selenium.Title)


$selenium.Manage().Window.Maximize()

$destinations = @{
  'Alaska' = 'A';
  'Bahamas' = 'BH';
  'Bermuda' = 'BM';
  'Canada/New England' = 'NN';
  'Caribbean' = 'C';
  'Cruise To Nowhere' = 'CN';
  'Europe' = 'E';
  'Hawaii' = 'H'
  'Mexico' = 'M'
  'Transatlantic' = 'ET'
}
$ports = @{
  'Miami, FL' = 'MIA';
  'New York, NY' = 'NYC';
  'Seattle, WA' = 'SEA';
  'Los Angeles, CA' = 'LAX';
  'Fort Lauderdale, FL' = 'FLL';
  'Jacksonville, FL' = 'JAX';
  'Honolulu, HI' = 'HNL';
  'Galveston, TX' = 'GAL';
  'Athenes' = 'ATH';
  'Baltimore, MD' = 'BWI';
  'Barbados' = 'BDS';
  'Barcelona, Spain' = 'BCN';
  'Charleston, SC' = 'CHS';
  'New Orleans, LA' = 'MSY';
  'Norfolk, VA' = 'ORF';
  'Port Canaveral (Orlando), FL' = 'PCV';
  'San Juan, Puerto Rico' = 'SJU';
  'Tampa, FL' = 'TPA';
  'Trieste' = 'TRS';
  'Vancouver, BC, Canada' = 'YVR';
}



function select_first_option {
  param([string]$choice = $null,
    [string]$label = $null
  )

  $select_name = $choice

  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500

  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Debug ('Clicking on ' + $select_element.Text)

  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 500

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  # TODO the css_selector needs refactoring

  $select_value_css_selector = ('div[class=option][data-param={0}] div.scrollable-content div.viewport div.overview ul li a' -f $select_name)
  $value_element = $null
  Write-Debug ('Selecting CSS: "{0}"' -f $select_value_css_selector)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Debug 'Found...'
    Write-Debug ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null

  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  [void]$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  $value_element = $null

  $actions2 = $null
  Start-Sleep -Milliseconds 500
}


function select_speficic_option {

  param([string]$choice = $null,
    [string]$label = $null,
    [int]$position = 0
  )

  $select_name = $choice

  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500

  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Debug ('Clicking on ' + $select_element.Text)

  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 500

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  # TODO the css_selector needs refactoring

  $select_value_css_selector = ('div[class=option][data-param={0}] div.scrollable-content div.viewport div.overview ul li a' -f $select_name)
  $value_element = $null
  Write-Debug ('Selecting CSS: "{0}"' -f $select_value_css_selector)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Debug 'Found...'
    Write-Debug ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  [OpenQA.Selenium.Remote.RemoteWebElement[]]$value_elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($select_value_css_selector))
  if ($position -ge $value_elements.count) { $position = $value_elements.count - 1 }
  [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $value_elements[$position]
  $wait = $null

  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  [void]$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  $value_element = $null

  $actions2 = $null
  Start-Sleep -Milliseconds 500
}




function select_criteria {

  param([string]$choice = $null,
    [string]$label = $null,
    [string]$option = $null,
    [System.Management.Automation.PSReference]$choice_value_ref = ([ref]$null),
    [string]$value = $null # note formatting

  )

  $select_name = $choice

  if ($value) {
    $selecting_value = $value
  } else {
    Write-Debug ('"{0}"' -f $option)
    $selecting_value = $choice_value_ref.Value[$option]
    Write-Debug $selecting_value
  }
  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500
  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Debug ('Clicking on ' + $select_element.Text)
  $select_element.Click()
  Start-Sleep -Milliseconds 500
  $select_element = $null



  $select_value_css_selector = ('div[class=option][data-param={0}] a[data-id={1}]' -f $select_name,$selecting_value)
  Write-Debug ('Selecting CSS(2): "{0}"' -f $select_value_css_selector)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))

  $wait.PollingInterval = 150

  $value_element = $null
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Debug 'Found value_element...'
    # $value_element
    Write-Debug ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))

  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $wait = $null
  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  [void]$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  Start-Sleep -Milliseconds 500
  $wait = $null
  $actions2 = $null
  $value_element = $null

}

function search_cruises {
  $css_selector1 = 'div.actions > a.search'
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  [NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'SEARCH'))
  Write-Debug ('Clicking on ' + $element1.Text)
  $element1.Click()
  $element1 = $null

}
function count_cruises {
  param(
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)
  )

  $css_selector1 = "li[class*=num-found] strong"

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 500
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  Write-Debug ('Found ' + $element1.Text)
  $result_ref.Value = $element1.Text

}

# TODO :finish parameters
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
[bool]$all = [bool]$PSBoundParameters['all'].IsPresent
select_criteria -choice 'numGuests' -Value '"2"' -label 'TRAVELERS'
#Write-Debug ('Selecting Destination {0}' -f $dest )
#
if (-not $all) {
  select_criteria -choice 'dest' -label 'Sail To' -Option $dest -choice_value_ref ([ref]$destinations)
  #Write-Debug ('Selecting Port {0}' -f $port )
  select_criteria -choice 'port' -label 'Sail from' -Option $port -choice_value_ref ([ref]$ports)
}
# find first avail
select_speficic_option -choice 'dat' -label 'Date' -position 3
search_cruises
Start-Sleep -Milliseconds 1500
$cruises_count_text = $null
count_cruises -result_ref ([ref]$cruises_count_text)
Write-Host $cruises_count_text
$itins_found = 1
extract_match -Source $cruises_count_text -capturing_match_expression '\b(?<media>\d+)\b' -label 'media' -result_ref ([ref]$itins_found)

[NUnit.Framework.Assert]::IsTrue(($itins_found -match '\d+'))
Write-Output ('Found {0} itinear(ies)' -f $itins_found)

$css_selector1 = 'div#results_container div[class *="search-result"]'

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait1 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))

try {
  [void]$wait1.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element1).Build().Perform()
$actions = $null
$description = ($element1.Text -split "`r`n")[0]
$port_ship = ($element1.Text -split "`r`n")[1]

Write-Host ('Sailing to {0} {1}' -f $description,$port_ship)
# For debugging:
# $page_source = (($element1.GetAttribute("innerHTML")) -join '')

$css_selector3 = 'a[class *= "itin-select" ]'
[OpenQA.Selenium.IWebElement]$element3 = $element1.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector3))




$itins_to_find = $itins_found
$itins_found = 1


print_itinerary_link_info `
   -position $itins_found `
   -Destination $dest `
   -Port $port `
   -Description $description `
   -url $element3.GetAttribute('href') `
   -log_filename ('{0}\{1}' -f $script_directory,'results.csv')


while ($itins_found -lt $itins_to_find) {

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $xpath2 = "following-sibling::div[contains(@class, 'search-result')][1]"

  [OpenQA.Selenium.IWebElement]$element2 = $element1.FindElement([OpenQA.Selenium.By]::XPath($xpath2))

  $itins_found = $itins_found + 1

  $description = ($element2.Text -split "`r`n")[0]
  $port_ship = ($element2.Text -split "`r`n")[1]

  Write-Host ('Sailing to {0} {1}' -f $description,$port_ship)
  # For debugging:
  # $page_source = (($element1.GetAttribute("innerHTML")) -join '')

  $css_selector3 = 'a[class *= "itin-select" ]'
  [OpenQA.Selenium.IWebElement]$element3 = $element2.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector3))

  $adjust_vscroll = $element3.LocationOnScreenOnceScrolledIntoView.Y
  if ($adjust_vscroll -eq 1) {
    $adjust_vscroll = 10
  }
  if ($adjust_vscroll -gt 0) {
    [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript(('scroll(0, {0})' -f $adjust_vscroll),$null)
    Write-Debug ('Scroll {0} px' -f $adjust_vscroll)
    Start-Sleep -Millisecond 500
  }

  $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
  Start-Sleep -Millisecond 1000

  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'border: 2px solid red;')
  Start-Sleep -Millisecond 1000
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'')
  $url = $element3.GetAttribute('href')
  print_itinerary_link_info `
     -position $itins_found `
     -Destination $dest `
     -Port $port `
     -Description $description `
     -url $element3.GetAttribute('href') `
     -log_filename ('{0}\{1}' -f $script_directory,'results.csv')
  if (($PSBoundParameters['follow']) -ne $null) {
    $expect_url = 'http://www.carnival.com/itinerary/7-day-eastern-caribbean-cruise/miami/glory/7-days/cem/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA'
    $expect_url = 'http://www.carnival.com/itinerary/4-day-western-caribbean-cruise/miami/victory/4-days/kwp/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA'
    # TODO: mask datFrom ... datTo ...
    $expect_url = $expect_url -replace '\?','\?'

    if ($url -match $expect_url)
    {
      Write-Output 'need to pick XPATH'
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

      # Exception calling "ExecuteScript" with "3" argument(s): "element is null
      $result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$element3,'')).ToString()

      Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $element3.Text,$result)
      $xpath4 = ('//{0}' -f $result)
      [OpenQA.Selenium.IWebElement]$element4 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath4))

      $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element4).Click().Build().Perform()
      Start-Sleep -Millisecond 2000

      # Click on Book Now

      $book_now_css_selector = 'li[class = action-col] a[class *=btn-red]'

      try {
        [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($book_now_css_selector)))
      } catch [exception]{
        Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
      }

      $book_now_buttons = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($book_now_css_selector))
      $book_now_element = $null

      foreach ($element8 in $book_now_buttons) {
        if (!$book_now_element) {
          if ($element8.Text -match 'BOOK NOW') {
            Write-Output ('Selecting {0}' -f $element8.Text)
            $book_now_element = $element8
          }
        }
      }
      $element8 = $null
      [OpenQA.Selenium.Interactions.Actions]$actions4 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$book_now_element,'color: yellow; border: 4px solid yellow;')
      Start-Sleep -Millisecond 500
      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$book_now_element,'')

      $actions4.MoveToElement([OpenQA.Selenium.IWebElement]$book_now_element).Build().Perform()

      Start-Sleep -Millisecond 1000
      Write-Output ('Click : "{0}"' -f $book_now_element.Text)
      $book_now_element.Click()
      Start-Sleep -Milliseconds 2000
      # TODO: navigate through 'Book Now'
      Write-Output $selenium.url

      try {
        [NUnit.Framework.StringAssert]::Contains('http://www.carnival.com/BookingEngine/Stateroom',$selenium.url,{})
      } catch [exception]{
        Write-Output ("Unexpected redirect:`r`t{0}`rtAborting." -f $selenium.url)
        cleanup ([ref]$selenium)
        return
      }

      cleanup ([ref]$selenium)
      return
      #  exit iterator
    }
  }
  $actions = $null
  # next iterator 
  $element1 = $element2
}

custom_pause -fullstop $fullstop
# At the end of the run - do not close Browser / Selenium when executing from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
<#
# example output
sep=   
Num    Destination    Port    Description    Url
1	Caribbean	Miami, FL	Carnival Live Presents Smokey Robinson - 4 Day Western Caribbean	http://www.carnival.com/itinerary/4-day-western-caribbean-cruise/miami/ecstasy/4-days/dab/?evsel=SYR&numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA
2	Caribbean	Miami, FL	4 Day Western Caribbean	http://www.carnival.com/itinerary/4-day-western-caribbean-cruise/miami/ecstasy/4-days/kc3/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA
3	Caribbean	Miami, FL	4 Day Western Caribbean	http://www.carnival.com/itinerary/4-day-western-caribbean-cruise/miami/victory/4-days/kwp/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA
1	Caribbean	Galveston, TX	7 Day Eastern Caribbean	http://www.carnival.com/itinerary/7-day-eastern-caribbean-cruise/galveston/magic/7-days/ec2/?numGuests=2&destination=all-destinations&dest=any&datFrom=042015&datTo=042015&embkCode=GAL
#>
