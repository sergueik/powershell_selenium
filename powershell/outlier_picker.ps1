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

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser

# http://www.w3schools.com/xpath/xpath_axes.asp

$base_url = "file:///C:/developer/sergueik/powershell_selenium/powershell/data.html"
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

# rows
$modules = @{}

$table_css_selector = 'html body div table.sortable '

$row_css_selector = 'tbody tr'

# module
$module_column_number = 2
# git hash
$githash_column_number = 3
# puppet master server
$server_column_number = 1

$column_css_selector = ('td:nth-child({0})' -f $module_column_number)

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($row_css_selector)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}


[OpenQA.Selenium.IWebElement[]]$tables = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($table_css_selector))

$max_tables = 100
$table_cnt = 0
$tables | ForEach-Object {
  $table = $_
  # No need to skip first item in the set of tables
  # if ($table_cnt -eq 0) {
  #  $table_cnt++
  #  return
  #}
  if ($table_cnt -gt $max_tables) { return }
  $table_cnt++
  $css_selector = $row_css_selector
  $provider = $table
  try {
    [OpenQA.Selenium.IWebElement[]]$rows = $provider.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector))
    $max_rows = 100
    $row_cnt = 0
    $rows | ForEach-Object {
      $row = $_
      if ($row_cnt -eq 0) {
        # first row is table headers
        $row_cnt++
        return
      }
      if ($row_cnt -gt $max_rows) { return }
    # write-output ('row_cnt = {0}' -f $row_cnt )
    $hashes = @{}
    $column_css_selector = ('td:nth-child({0})' -f $module_column_number)
    $css_selector = $column_css_selector
    $provider = $row
    try {
      [OpenQA.Selenium.IWebElement[]]$column = $provider.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
      $module = $column.Text
      if ( -not $modules[$module]) {
        $modules[$module] = $true
        Write-Output ("Module = '{0}'" -f $module)
        # Write-Output ("Row innerHTML`r`n{0}" -f $row.getAttribute('innerHTML'))
      }
    } catch [exception]{
      # Exception is expected:
      # Unable to locate element: {"method":"css selector","selector":"td:nth-child(2)"} 
      # indicates row is the header row of the product
    }
    $column_css_selector = ('td:nth-child({0})' -f $githash_column_number)
    $css_selector = $column_css_selector
    $provider = $row
    try {
      [OpenQA.Selenium.IWebElement]$column = $provider.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
      $data = $column.Text
      if (-not $hashes[$data]) {
        $hashes[$data] = 1
      } else { 
        $hashes[$data] ++
      }
    } catch [exception]{
      # Exception is expected:
      # Unable to locate element: {"method":"css selector","selector":"td:nth-child(2)"} 
      # indicates row is the header row of the product
    }
    $row_cnt ++
    }
    write-output ($hashes.Keys -join ',')
    
  } catch [exception]{
    Write-Output ("Exception message={0}" -f (($_.Exception.Message) -split "`n")[0])
  }
}
# Cleanup
cleanup ([ref]$selenium)


