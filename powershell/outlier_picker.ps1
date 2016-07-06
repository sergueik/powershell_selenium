#Copyright (c) 2016 Serguei Kouzmine
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
  [string]$browser
  # TODO: version
)


function removeFrequentKey {
  param(
    [object]$frequencies
  )
  # for Javascript 
  # http://stackoverflow.com/questions/1669190/javascript-min-max-array-values
  # Powershell does not have this
  $max_freq = $frequencies.Values | Sort-Object -Descending | Select-Object -First 1
  # Collection was modified; enumeration operation may not execute..
  # $frequencies.Keys | foreach-object { if ( $frequencies.Item($_) -eq $max_freq ) {$frequencies.Remove($_)}}

  $result = @{}
  $frequencies.Keys | ForEach-Object { if ($frequencies.Item($_) -ne $max_freq) { $result[$_] = $frequencies.Item($_) } }
  return $result
}

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$base_url = "file:///C:/developer/sergueik/powershell_selenium/powershell/data.html"
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

$modules = @{}

# module tables locator
$table_css_selector = 'html body div table.sortable'

# rows locator (relative to table)
$row_css_selector = 'tbody tr'

# columns locators (relative to row)
# puppet master server
$server_column_number = 1
# module
$module_column_number = 2
# git hash
$githash_column_number = 3

# wait for the page to load
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($row_css_selector)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}

# iterate over modules 
foreach ($table in ($selenium.FindElements([OpenQA.Selenium.By]::CssSelector($table_css_selector))) ) {
  $max_rows = 100
  $row_cnt = 0
  $hashes = @{}
  $module = $null
  
  # iterate overs Puppet master server r10k hashes
  foreach ($row in ($table.FindElements([OpenQA.Selenium.By]::CssSelector($row_css_selector))) ) {
    if ($row_cnt -eq 0) {
      # skil first row (table headers) 
      $row_cnt++
      continue
    }
    if ($row_cnt -gt $max_rows) { break }
    $githash = $row.FindElement([OpenQA.Selenium.By]::CssSelector(('td:nth-child({0})' -f $githash_column_number))).Text
    if ( -not $hashes[$githash] ) {
      $hashes[$githash] = 1
      $module = $row.FindElement([OpenQA.Selenium.By]::CssSelector(('td:nth-child({0})' -f $module_column_number))).Text
      if (-not $modules[$module]) {
        $modules[$module] = $true
      }
    } else {
      $hashes[$githash]++
    }
    $row_cnt++
  }
  # Workaround Powershell flexible types
  $keys = @()
  $hashes.Keys | ForEach-Object { $keys += $_ }
  if ($keys.Length -gt 1) {
    Write-Output ("Module = '{0}'" -f $module)
    # Write-Output ('Hashes found: {0}' -f ($hashes.Keys -join "`r`n"))
    $hashes_amended = removeFrequentKey ($hashes)
    $row2_cnt = 0
    foreach ($row2 in ($table.FindElements([OpenQA.Selenium.By]::CssSelector($row_css_selector))) ) {
      if ($row2_cnt -eq 0) {
        # first row is table headers
        $row2_cnt++
        continue 
      }
      [OpenQA.Selenium.IWebElement]$githash_column = $row2.FindElement([OpenQA.Selenium.By]::CssSelector(('td:nth-child({0})' -f $githash_column_number)))
      if ($hashes_amended[$githash_column.Text]) {
        [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$githash_column).Build().Perform()
        highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$githash_column) -color 'red'
        [OpenQA.Selenium.IWebElement]$server_column = $row2.FindElement([OpenQA.Selenium.By]::CssSelector(('td:nth-child({0})' -f $server_column_number)))
        highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$server_column) -color 'blue'
        Write-Output $server_column.Text
      }
    }
  }
}
# Cleanup
cleanup ([ref]$selenium)

