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

# http://stackoverflow.com/questions/6198947/how-to-get-text-from-each-cell-of-an-html-table
# http://sqa.stackexchange.com/questions/10342/how-to-find-element-using-contains-in-xpath

param(
  [string]$browser = '',
  [switch]$grid,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}


$base_url = 'https://datatables.net/examples/api/highlight.html'

$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

<#
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("sbn-logo")))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
#>
$table_id = 'example';


# Find a specific row, only choose the matching cells.

$cell_text = 'Software Engineer'

$matching_rows = @()
$table_element = find_element_new -Id $table_id
$table_row_relative_xpath = 'tbody/tr'
$row_cell_relative_xpath = 'td'

[OpenQA.Selenium.IWebElement[]]$table_row_collection = $table_element.FindElements([OpenQA.Selenium.By]::XPath($table_row_relative_xpath))
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

if ($table_row_collection -ne $null) {
  $row_num = 1
  Write-Output ("NUMBER OF ROWS = " + $table_row_collection.Count)
  $table_row_collection | ForEach-Object {

    $table_row = $_

    [NUnit.Framework.Assert]::IsTrue(($table_row -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($table_row.Displayed))
    [NUnit.Framework.Assert]::IsTrue(($table_row.getAttribute('role') -match $row_role_attribute),("Unexpected '{0}' attribute '{1}'" -f 'role',$table_row.getAttribute('role')))

    [OpenQA.Selenium.IWebElement[]]$table_cell_collection = $table_row.FindElements([OpenQA.Selenium.By]::XPath($row_cell_relative_xpath))
    $cell_num = 1

    Write-Output ("NUMBER OF COLUMNS = " + $table_cell_collection.Count)

    $table_cell_collection | ForEach-Object { $table_cell = $_

      if ($cell_num -eq 2) {
        if (-not ($table_cell.Text -match $cell_text)) {
          # http://www.powershelladmin.com/wiki/PowerShell_foreach_loops_and_ForEach-Object#A_Basic_ForEach-Object_Example
          return
        } else {
          Write-Output ('Found:  ' + $table_cell.Text)
          # compose XPath for this specific row
          $matching_rows += ('{0}[{1}]' -f $table_row_relative_xpath,$row_num)
          return
        }
      }
      $cell_num++;

    }
    $row_num++
  }
}

$matching_rows | ForEach-Object {
  $table_specicic_row_relative_xpath = $_
  [OpenQA.Selenium.IWebElement[]]$table_row = $table_element.FindElements([OpenQA.Selenium.By]::XPath($table_specicic_row_relative_xpath))
  $row_cell_relative_xpath = 'td'
  [OpenQA.Selenium.IWebElement[]]$table_cell_collection = $table_row.FindElements([OpenQA.Selenium.By]::XPath($row_cell_relative_xpath))

  $cell_num = 1

  $table_cell_collection | ForEach-Object {
    $table_cell = $_

    $actions.MoveToElement([OpenQA.Selenium.IWebElement]$table_cell).Build().Perform()
    highlight ([ref]$selenium) ([ref]$table_cell)

    Write-Output ("col # {0} text='{1}'" -f $cell_num,$table_cell.Text)
    $cell_num++;

  }

}

# Iterate the table cells end-to-end

[OpenQA.Selenium.IWebElement[]]$table_row_collection = $table_element.FindElements([OpenQA.Selenium.By]::XPath($table_row_relative_xpath))
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

if ($table_row_collection -ne $null) {
  $row_num = 1
  Write-Output ("NUMBER OF ROWS IN THIS TABLE = " + $table_row_collection.Count)
  $table_row_collection | ForEach-Object {

    $table_row = $_

    [NUnit.Framework.Assert]::IsTrue(($table_row -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($table_row.Displayed))
    [NUnit.Framework.Assert]::IsTrue(($table_row.getAttribute('role') -match $row_role_attribute),("Unexpected '{0}' attribute '{1}'" -f 'role',$table_row.getAttribute('role')))

    $row_cell_relative_xpath = 'td'
    [OpenQA.Selenium.IWebElement[]]$table_cell_collection = $table_row.FindElements([OpenQA.Selenium.By]::XPath($row_cell_relative_xpath))
    $cell_num = 1

    Write-Output ("NUMBER OF COLUMNS=" + $table_cell_collection.Count)
    $table_cell_collection | ForEach-Object { $table_cell = $_

      $actions.MoveToElement([OpenQA.Selenium.IWebElement]$table_cell).Build().Perform()
      highlight ([ref]$selenium) ([ref]$table_cell)

      Write-Output ("row # {0}, col # {1} text='{2}'" -f $row_num,$cell_num,$table_cell.Text)
      $cell_num++;

      $cell_num++
    }
    $row_num++
  }
}


[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}

