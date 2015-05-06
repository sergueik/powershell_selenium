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
  # in the current environment phantomejs is not installed 
  [string]$browser = 'chrome',
  [int]$version,
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

$base_url = 'http://www.carnival.com'

$selenium.Navigate().GoToUrl($base_url + '/')

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

Write-Output ('Started with {0}' -f $selenium.Title)


$selenium.Manage().Window.Maximize()


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
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500

  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)

  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 500

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  # TODO the css_selector needs refactoring

  $select_value_css_selector = ('div[class=option][data-param={0}] div.scrollable-content div.viewport div.overview ul li a' -f $select_name)
  $value_element = $null
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found...'
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null

  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
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
    Write-Output ('"{0}"' -f $option)
    $selecting_value = $choice_value_ref.Value[$option]
    Write-Output $selecting_value
  }
  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500
  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)
  $select_element.Click()
  Start-Sleep -Milliseconds 500
  $select_element = $null



  $select_value_css_selector = ('div[class=option][data-param={0}] a[data-id={1}]' -f $select_name,$selecting_value)
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))

  $wait.PollingInterval = 150

  $value_element = $null
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found value_element...'
    $value_element
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))

  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $wait = $null
  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
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
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  [NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'SEARCH'))
  Write-Output ('Clicking on ' + $element1.Text)
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
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  Write-Output ('Found ' + $element1.Text)
  $result_ref.Value = $element1.Text

}


function find_page_element_by_xpath {

  param(
    [System.Management.Automation.PSReference]$selenium_driver_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [string]$xpath,
    [int]$wait_seconds = 10

  )

  if ($xpath -eq '' -or $xpath -eq $null) {
    return
  }
  $local:element = $null
  [OpenQA.Selenium.Remote.RemoteWebDriver]$local:selenum_driver = $selenium_driver_ref.Value
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($local:selenum_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
  }

  $local:element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::XPath($xpath))
  $element_ref.Value = $local:element

}


# TODO :finish parameters
$fullstop = (($PSBoundParameters['pause']) -ne $null)

# Actual action .

$select_name = 'explore'
$select_value_css_selector1 = ('a[class*=canHover][data-ccl-flyout="{0}"]' -f $select_name)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

$value_element = $null
Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector1)
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector1)))
  Write-Output 'Found...'
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$wait = $null

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

$value_element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_value_css_selector1))
[OpenQA.Selenium.Interactions.Actions]$actions1 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions1.MoveToElement([OpenQA.Selenium.IWebElement]$value_element1).Build().Perform()
Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element1.Text,$value_element1.GetAttribute('class'))
# assert element has 'initialized'  and 'hover'  class attribute

$value_element1 = $null
Start-Sleep -Milliseconds 1500




function find_page_element_by_css_selector {

  param(
    [System.Management.Automation.PSReference]$selenium_driver_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [string]$css_selector,
    [int]$wait_seconds = 10

  )

  if ($css_selector -eq '' -or $css_selector -eq $null) {
    return
  }
  $local:element = $null
  [OpenQA.Selenium.Remote.RemoteWebDriver]$local:selenum_driver = $selenium_driver_ref.Value
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($local:selenum_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
  }

  $local:element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  $element_ref.Value = $local:element
}



$xpath_template = '//*[@id="ccl-refresh-header"]/DIV[2]/DIV[1]/DIV[1]/DIV[2]/UL[1]/LI[{0}]/A[1]/SPAN[1]/IMG[1]'

@( 1,2,3,4,5,6) | ForEach-Object { $link_count = $_;
  $image = $null

  find_page_element_by_xpath ([ref]$selenium) ([ref]$image) ($xpath_template -f $link_count)
  highlight ([ref]$selenium) ([ref]$image)
  @( 'alt','src') | ForEach-Object {
    $attr = $_
    Write-Output ('{0} = {1}' -f $attr,$image.GetAttribute($attr))
  }
}


$alt_texts = @( 'Onboard Activities','Dining','Accommodations','Our Ships','Shore Excursions')

$alt_texts | ForEach-Object { $link_alt_text = $_;

  $css_selector = ('img[alt="{0}"]' -f $link_alt_text)
  $image = $null

  find_page_element_by_css_selector ([ref]$selenium) ([ref]$image) $css_selector
  highlight ([ref]$selenium) ([ref]$image)
  @( 'alt','src') | ForEach-Object {
    $attr = $_
    Write-Output ('{0} = {1}' -f $attr,$image.GetAttribute($attr))
  }
}
<#
$src_files = @('snorkel%20png.ashx','plate%20png.ashx', 'bed%20png.ashx', 'microphone%20png.ashx', 'ship%20png.ashx' , 'map%20png.ashx')

$src_files  | foreach-object { $src_file = $_;

$css_selector = ('img[src*="{0}"]' -f $src_file)
$image= $null

find_page_element_by_css_selector ([ref]$selenium) ([ref]$image) $css_selector
highlight ([ref]$selenium) ([ref]$image)
@( 'alt','src') | ForEach-Object {
  $attr = $_
  Write-Output ('{0} = {1}' -f $attr,$image.GetAttribute($attr))
}
}
#>

# Continue with 
$link_alt_text = 'Shore Excursions'
$value_element2 = $null
$css_selector = ('img[alt="{0}"]' -f $link_alt_text)


find_page_element_by_css_selector ([ref]$selenium) ([ref]$value_element2) $css_selector
[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element2).Click().Build().Perform()
$value_element2 = $null
$actions2 = $null
$value_element3 = $null
$data_target = 'destinationModal'
$data_target_css_selector = ('button[class*="ca-primary-button"][data-target="#{0}"]' -f $data_target)

find_page_element_by_css_selector ([ref]$selenium) ([ref]$value_element3) $data_target_css_selector

[OpenQA.Selenium.Interactions.Actions]$actions3 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions3.MoveToElement([OpenQA.Selenium.IWebElement]$value_element3).Click().Build().Perform()
$value_element3 = $null
$actions3 = $null
# TODO Assert

$value_element4 = $null
$destination_data_val = 'PVR'
$destination_name = 'Puerto Vallarta'
$destination_css_selector = ('div#destinations a[data-val="{0}"]' -f $destination_data_val)

find_page_element_by_css_selector ([ref]$selenium) ([ref]$value_element4) $destination_css_selector
Write-Output ('Destinaton: {0}' -f ($value_element4.GetAttribute('innerHTML') -join ''))
Write-Output ('Link: {0}' -f $value_element4.GetAttribute('href'))
highlight ([ref]$selenium) ([ref]$value_element4)
[OpenQA.Selenium.Interactions.Actions]$actions4 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions4.MoveToElement([OpenQA.Selenium.IWebElement]$value_element4).Click().Build().Perform()
$value_element4 = $null
$actions4 = $null
# continued in shorex_browse_destination.ps1

custom_pause -fullstop $fullstop
# At the end of the run - do not close Browser / Selenium when executing from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
