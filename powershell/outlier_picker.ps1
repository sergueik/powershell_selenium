
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


# run monolythic script

$column_css_selector = 'td:nth-child(3)' 

$script = @"
  var table_selector = '${table_css_selector}';
  var row_selector = '${row_css_selector}';
  var column_selector = '${column_css_selector}';
  // var table_selector = 'html body div table.sortable';
  // var row_selector = 'tbody tr';
  // var column_selector = 'td:nth-child(3)';
  col_num = 0;
  var tables = window.document.querySelectorAll(table_selector);
  var git_hashes = {};
  for (table_cnt = 0; table_cnt != tables.length; table_cnt++) {
      var table = tables[table_cnt];
      // console.log("table " + table_cnt);
      if (table instanceof Element) {
          // console.log(table.innerHTML);
          var rows = table.querySelectorAll(row_selector);
          // skip first row
          for (row_cnt = 1; row_cnt != rows.length; row_cnt++) {
              var row = rows[row_cnt];
              //console.log("row " + row_cnt);
              if (row instanceof Element) {
                  // console.log(row.innerHTML)
                  // console.log(column_selector);        
                  var cols = row.querySelectorAll(column_selector);
                  if (cols.length > 0) {
                      // console.log(cols.size);
                      data = cols[0].innerHTML
                      if (!git_hashes[data]) {
                          git_hashes[data] = 0;
                      }
                      git_hashes[data]++;
                  }
              }
          }
      }
  }

  array_keys = [];
  array_values = [];
  var sortNumber = function(a, b) {
    return b - a;
  }


  for (var key in git_hashes) {
      array_keys.push(key);
      array_values.push(0 + git_hashes[key]);
  }
  max_freq = array_values.sort(sortNumber)[0]
  for (var key in git_hashes) {
      if (git_hashes[key] === max_freq) {
          delete git_hashes[key]
      }
  }

  array_keys = [];
  for (var key in git_hashes) {
      array_keys.push(key);
  }
  return array_keys.join();
"@

$result = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script)
write-output $result 
# Cleanup
cleanup ([ref]$selenium)

exit 
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

