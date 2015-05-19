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

# http://www.carnival.com/shore-excursions/honolulu-hi
# destinations_paginator.ps1 

# update  the number of items per page
# move th n'th page
# assert the results display

param(
  [string]$browser = '',
  [int]$version,# unused
  [string]$destination = 'Curacao',
  [string]$base_url = 'http://www.carnival.com/shore-excursions/costa-maya-mexico',# 3 PAGES 
  # 'http://www.carnival.com/shore-excursions/honolulu-hi', 2 PAGES 

  [switch]$all,
  [int]$maxitems = 1000,
  [switch]$savedata,
  [switch]$pause

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


function extract_match {
  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)
  )
  Write-Debug ('Extracting from: "{0}"' -f $source)
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

function paginate_destinations
{
  param(
    [string]$action = $null
  )


  if (-not $action) {
    return
  }

  if ($action -eq 'count') {

    $pagination_result_css_selector = 'p[class*="ca-guest-visitor-pagination-result"][ng-show]'
    #                                                                                ^^^^^^^^^^ 
    <#
    <div class="ca-guest-visitor-pagination-container">
    <hr class="ca-divider ca-guest-visitor-divider">
    <p class="ca-guest-visitor-pagination-result ng-hide" ng-hide="vm.searchResultsLoaded">1 - 12 of 26 results</p>
    <p class="ca-guest-visitor-pagination-result ng-binding" ng-show="vm.searchResultsLoaded">13 - 24 of 26 results</p>
    #>

    $wait_seconds = 10
    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait5 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
    $wait5.PollingInterval = 50

    try {
      [void]$wait5.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($pagination_result_css_selector)))
    } catch [exception]{
      Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$pagination_result_css_selector)
    }
    $wait_seconds = $null

    $pagination_result_paragraph = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($pagination_result_css_selector))

    $capturing_match_expression = '(?<first_item>\d+)\s+\-\s+(?<last_item>\d+)\s+of\s+(?<count_items>\d+)\s+results'
    $pagination_result = (' {0}' -f $pagination_result_paragraph.Text)

    [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$pagination_result_paragraph).Build().Perform()

    highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$pagination_result_paragraph) -delay 1500
    Write-Host ( '{0} -> {1}' -f $pagination_result_css_selector, $pagination_result ) 

    $pagination_result_paragraph
    custom_pause -fullstop $fullstop
   if ( $pagination_result -match '\S' ) {
    $first_item = $null
    extract_match -Source $pagination_result -capturing_match_expression $capturing_match_expression -label 'first_item' -result_ref ([ref]$first_item)

    $last_item = $null
    extract_match -Source $pagination_result -capturing_match_expression $capturing_match_expression -label 'last_item' -result_ref ([ref]$last_item)


    $count_items = $null
    extract_match -Source $pagination_result -capturing_match_expression $capturing_match_expression -label 'count_items' -result_ref ([ref]$count_items)

    Write-Output (@{ 'first_item' = $first_item; 'last_item' = $last_item; 'count_items' = $count_items; } | Format-List)
}
  }
  if ($action -eq 'forward') {
    Write-Debug 'forward'
    $pagination_forward_css_selector = 'a[class*="ca-pagination-next"]'

    $wait_seconds = 10
    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait5 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
    $wait5.PollingInterval = 50

    try {
      [void]$wait5.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($pagination_forward_css_selector)))
    } catch [exception]{
      Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$pagination_forward_css_selector)
    }

    $pagination_forward_link = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($pagination_forward_css_selector))
    # $pagination_forward_link
    [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$pagination_forward_link).Build().Perform()
    highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$pagination_forward_link)
    [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$pagination_forward_link).click().Build().Perform()
    # TODO page.ready
    custom_pause -fullstop $fullstop

  }

}


# Setup 
$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'System.Data.SQLite.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

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
      $capability.SetCapability('version',$version.ToString());
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
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

# Actual action .
$script_directory = Get-ScriptDirectory

if ($base_url -eq '') {
  # $destinations iterator is in
  # shorex_browse_destination.ps1
} else {
  Write-Output ('base_url: "{0}"' -f $base_url)


  $selenium.Navigate().GoToUrl($base_url)
  [void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
  # protect from blank page
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

  Write-Output ('Started with {0}' -f $selenium.Title)
  # $selenium.Manage().Window.Maximize()

  paginate_destinations -Action 'count'

  paginate_destinations -Action 'forward'
  paginate_destinations -action 'count'
  paginate_destinations -Action 'forward'
  # TODO: bug 
  paginate_destinations -action 'count'
  
}


custom_pause -fullstop $fullstop


if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
