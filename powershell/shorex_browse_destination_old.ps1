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
  [int]$version,# unused
  [string]$destination = 'Curacao',
  [switch]$all,
  [int]$maxitems = 1000,
  [switch]$savedata,
  [switch]$pause
)

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

function insert_database2 {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = @"
INSERT INTO [excursions] (CODE, CAPTION, URL, DEST_CODE, STATUS )  VALUES(?, ?, ?, ?, ?)
"@,
    [psobject]$data
  )


  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  Write-Output $query
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $code = New-Object System.Data.SQLite.SQLiteParameter
  $caption = New-Object System.Data.SQLite.SQLiteParameter
  $url = New-Object System.Data.SQLite.SQLiteParameter
  $status = New-Object System.Data.SQLite.SQLiteParameter
  $dest_code = New-Object System.Data.SQLite.SQLiteParameter


  $command.Parameters.Add($code)
  $command.Parameters.Add($caption)
  $command.Parameters.Add($url)
  $command.Parameters.Add($dest_code)
  $command.Parameters.Add($status)

  $code.Value = $data.code
  $caption.Value = $data.caption
  $url.Value = $data.url
  $dest_code.Value = $data.dest_code
  $status.Value = $data.status
  $rows_inserted = $command.ExecuteNonQuery()
  $command.Dispose()
}

function query_database_basic {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = 'SELECT CAPTION, URL, CODE FROM [destinations]'
  )

  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  $datatSet = New-Object System.Data.DataSet

  $dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter ($query,$connection)
  [void]$dataAdapter.Fill($datatSet)
  $connection.Close()
  return $datatSet.Tables[0].Rows
}




function query_database {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = 'SELECT URL, CAPTION, CODE  FROM destinations WHERE CAPTION = ?',
    [string]$destination = 'Ensenada',
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null),
    [System.Management.Automation.PSReference]$fields_ref = ([ref]@()),
    [bool]$debug
  )

  [object]$fields = @()
  if ($fields_ref -ne $null) {
    try {
      $fields_ref.Value | ForEach-Object {
        $fields += $_
      }
    } catch [exception]{}
  }

  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  [void]$connection.Open()
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $caption = New-Object System.Data.SQLite.SQLiteParameter
  [void]$command.Parameters.Add($caption)
  $caption.Value = $destination

  [System.Data.SQLite.SQLiteDataReader]$sql_reader = $command.ExecuteReader()
  # http://www.devart.com/dotconnect/sqlite/docs/Devart.Data.SQLite~Devart.Data.SQLite.SQLiteDataReader_members.html 
  try
  {
    Write-Debug 'Reading'
    while ($sql_reader.Read())
    {
      if ($fields.count -gt 0) {
        $local:result = @{}
        Write-Debug 'Ordinal'
        $fields | ForEach-Object {
          $field = $_
          $local:result[$field] = $sql_reader.GetString($sql_reader.GetOrdinal($field))
          # $local:result[$field] = $sql_reader[$field]
        }
      } else {
        Write-Debug 'Field'
        $iterator = 0..($sql_reader.FieldCount - 1)
        $local:result = @()
        $iterator | ForEach-Object {
          $cnt = $_

          $local:result += $sql_reader.GetString($cnt)
        }
      }

    }
  }
  finally
  {
    $sql_reader.Close()
    $connection.Close()
  }
  $result_ref.Value = $local:result

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

function create_table {
  param([string]$database = 'shore_ex.db',

    # http://www.sqlite.org/datatype3.html
    [string]$create_table_query = @"
   CREATE TABLE IF NOT EXISTS [destinations]
      (CODE       CHAR(16) PRIMARY KEY     NOT NULL,
         URL      CHAR(1024),
         CAPTION   CHAR(256),
         STATUS    INTEGER   NOT NULL
      );

"@
  )
  [int]$version = 3
  $connection = New-Object System.Data.SQLite.SQLiteConnection ('Data Source={0};Version={1};' -f $database,$version)
  $connection.Open()
  Write-Output $create_table_query
  [System.Data.SQLite.SQLiteCommand]$sql_command = New-Object System.Data.SQLite.SQLiteCommand ($create_table_query,$connection)
  try {
    $sql_command.ExecuteNonQuery()
  } catch [exception]{
    <#
Currently ignoring 
Exception calling "ExecuteNonQuery" with "0" argument(s): "SQL logic error or missing database table excursions already exists"
#>
  }
  $connection.Close()


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

create_table -database "$script_directory\shore_ex.db" -create_table_query @"
   CREATE TABLE IF NOT EXISTS [excursions]
      (CODE       CHAR(16) PRIMARY KEY     NOT NULL,
         URL      CHAR(1024),
         CAPTION   CHAR(256),
         DEST_CODE   CHAR(256),
         STATUS    INTEGER   NOT NULL
      );

"@


$destinations = @()

if (($PSBoundParameters['all'].IsPresent)) {
  $cnt = 0
  $result = query_database_basic

  $result | ForEach-Object {
    $row = $_
    $destination = $row['CAPTION']
    $destinations += $destination
  }
} else {
  $destinations += $destination
}

$base_urls = @()

function collect_excursions {
  param([string]$base_url)


  $selenium.Navigate().GoToUrl($base_url)

  [void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
  # protect from blank page
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

  Write-Output ('Started with {0}' -f $selenium.Title)
  $selenium.Manage().Window.Maximize()

  $shoreex_box_css_selector = 'div[class*="ca-guest-visitor-right-image-box"]'

  $wait_seconds = 10
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait5 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait5.PollingInterval = 50

  try {
    [void]$wait5.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($shoreex_box_css_selector)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
  }

  $shoreex_boxes = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($shoreex_box_css_selector))
  $cnt = 0

  $data = @( @{
      'code' = $null;
      'url' = $null;
      'caption' = $null;
      'dest_code' = $null;
    })


  foreach ($value_element5 in $shoreex_boxes) {
    if ($false) {
      Write-Output $value_element5.Text
      Write-Output ("innerHTML:`r`n{0}" -f ($value_element5.GetAttribute('innerHTML') -join ''))
    }
    highlight ([ref]$selenium) ([ref]$value_element5)

    [OpenQA.Selenium.Interactions.Actions]$actions5 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions5.MoveToElement([OpenQA.Selenium.IWebElement]$value_element5).Build().Perform()

    $shoreex_link_css_selector = 'p[class="ca-guest-visitor-product-title"] a[href^="/shore-excursions"]'
    $value_element6 = $value_element5.FindElement([OpenQA.Selenium.By]::CssSelector($shoreex_link_css_selector))


    # Extract stuff: 
    # http://www.carnival.com/shore-excursions/st-kitts-wi/catamaran-fan-ta-sea-and-nevis-beach-break-431043

    $url = $value_element6.GetAttribute('href')
    # separately take away the path and the short name  from the URL
    $code = ($url -replace '^.+/.+\-','')
    $caption = $value_element6.Text
    # $dest_code =  
    Write-Output ('Title: {0}' -f $caption)
    Write-Output ('Code: {0}' -f $code)
    Write-Output ('Destination: {0}' -f $dest_code)
    Write-Output ('Link: {0}' -f $url)

    $data += @{
      'code' = $code;
      'url' = $url;
      'caption' = $caption;
      'dest_code' = $dest_code;
    }
    $value_element6 = $null
    $value_element5 = $null
    $actions5 = $null
  }


  0..($data.count - 1) | ForEach-Object {
    $cnt = $_
    $row = $data[$cnt]
    $base_url = $data[$cnt]['url']
    $o = New-Object PSObject
    $o | Add-Member Noteproperty 'code' $row['code']
    $o | Add-Member Noteproperty 'url' $row['url']
    $o | Add-Member Noteproperty 'caption' $row['caption']
    $o | Add-Member Noteproperty 'dest_code' $row['dest_code']
    $o | Add-Member Noteproperty 'status' 0
    $o | Format-List

    if (($PSBoundParameters['savedata'].IsPresent)) {
      insert_database2 -data $o -database "$script_directory\shore_ex.db"
    }
    $o = $null
  }

}
$destinations | ForEach-Object {

  $cnt++
  $destination = $_

  $result = @()

  $fields = @( 'URL','CODE')
  if ($cnt -gt $maxitems) { return }
  query_database -Destination $destination -result_ref ([ref]$result) -fields_ref ([ref]$fields)
  if ($DebugPreference -eq 'Continue') {
    Write-Output 'Result:'
    $result | Format-List
  }

  $base_url = $result['URL']
  $dest_code = $result['CODE']
  $base_urls += $base_url
}

$base_urls | ForEach-Object {
  $base_url = $_
  collect_excursions -base_url $base_url
}

# continue to shorex_carousel_box_image.ps1

custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
