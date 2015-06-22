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
  [string]$browser = '',
  [int]$version,
  [string]$base_url = 'http://www.carnival.com/shore-excursions/costa-maya-mexico',# 3 PAGES 
  # 'http://www.carnival.com/shore-excursions/honolulu-hi', 2 PAGES 
  [switch]$pause

)


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

function paginate_destinations
{
  param(
    [string]$action = $null,
    [bool]$last = $false,
    [System.Management.Automation.PSReference]$result_ref
  )


  if (-not $action) {
    return
  }

  if ($action -eq 'count') {
    if ($last) {
      $pagination_result_css_selector = 'p[class*="ca-guest-visitor-pagination-result"][ng-show]'
      #                                                                                ^^^^^^^^^^ 
     <#
     <div class="ca-guest-visitor-pagination-container">
     <hr class="ca-divider ca-guest-visitor-divider">
     <p class="ca-guest-visitor-pagination-result ng-hide" ng-hide="vm.searchResultsLoaded">1 - 12 of 26 results</p>
     <p class="ca-guest-visitor-pagination-result ng-binding" ng-show="vm.searchResultsLoaded">13 - 24 of 26 results</p>
     #>
    } else {
      $pagination_result_css_selector = 'p[class*="ca-guest-visitor-pagination-result"]'
    }

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

    # highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$pagination_result_paragraph) -Delay 1500
    Write-Debug ('{0} -> {1}' -f $pagination_result_css_selector,$pagination_result)

    # custom_pause -fullstop $fullstop
    if ($pagination_result -match '\S') {
      $first_item = $null
      extract_match -Source $pagination_result -capturing_match_expression $capturing_match_expression -label 'first_item' -result_ref ([ref]$first_item)

      $last_item = $null
      extract_match -Source $pagination_result -capturing_match_expression $capturing_match_expression -label 'last_item' -result_ref ([ref]$last_item)


      $count_items = $null
      extract_match -Source $pagination_result -capturing_match_expression $capturing_match_expression -label 'count_items' -result_ref ([ref]$count_items)
      $local:result = @{ 'first_item' = $first_item; 'last_item' = $last_item; 'count_items' = $count_items; }
      $result_ref.Value = $local:result

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
    # highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$pagination_forward_link)
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

$MODULE_NAME = 'selenium_utils.psd1'
import-module -name ('{0}/{1}' -f '.',  $MODULE_NAME)

$selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies

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
  $result = @{
    'first_item' = $null; 'last_item' = $null; 'count_items' = $null; }
  paginate_destinations -Action 'count' -result_ref ([ref]$result)
  $result | Format-List

  while ($result.count_items -gt $result.last_item) {
    paginate_destinations -Action 'forward'
    paginate_destinations -Action 'count' -result_ref ([ref]$result) -Last $true
    $result | Format-List

  }

}


custom_pause -fullstop $fullstop


if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
