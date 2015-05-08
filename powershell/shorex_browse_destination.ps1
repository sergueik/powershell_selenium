# QT based SQLite browser see
# https://github.com/sqlitebrowser/sqlitebrowser/releases
param(
  [string]$browser = 'chrome',
  [int]$version,# unused
  [string]$destination = 'Curacao',
  [switch]$pause

)

function insert_database2 {
  param(
    [string]$database = "$script_directory\logs.db",
    [string]$query = @"
INSERT INTO [excursions] (CODE, CAPTION, URL, DEST_CODE, STATUS )  VALUES(?, ?, ?, ?, ?)
"@,
    [psobject]$data
  )


  $connectionStr = "Data Source = $database"
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connectionStr)
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
  Write-Output $rows_inserted
  $command.Dispose()
}



function query_database_basic {
  param(
    [string]$query = 'SELECT CAPTION, URL, CODE FROM destinations',
    [string]$database = "$script_directory\shore_ex.db"
  )
  $connectionStr = "Data Source = $database"
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connectionStr)
  $connection.Open()
  $datatSet = New-Object System.Data.DataSet

  $dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter ($query,$connection)
  [void]$dataAdapter.Fill($datatSet)
  $connection.Close()
  return $datatSet.Tables[0].Rows
}


function query_database {
  param(
    [string]$query = 'SELECT URL, CAPTION, CODE  FROM destinations WHERE CAPTION = ?',
    [string]$database = "$script_directory\shore_ex.db",
    [string]$destination = 'Ensenada',
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null),
    [object]$fields = @(),
    [bool]$debug
  )
  try {
    $fields | Get-Member
  } catch [exception]{}


  $connectionStr = "Data Source = $database"
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connectionStr)
  [void]$connection.Open()
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $local:result = @()
  $caption = New-Object System.Data.SQLite.SQLiteParameter
  [void]$command.Parameters.Add($caption)
  $caption.Value = $destination

  [System.Data.SQLite.SQLiteDataReader]$sql_reader = $command.ExecuteReader()
  <#     Exception calling "Fill" with "1" argument(s): "unknown error Insufficient parameters supplied to the command"
   #>

  try
  {
    Write-Debug 'Reading'
    while ($sql_reader.Read())
    {
      Write-Debug ($sql_reader.GetString(0))
      Write-Debug ($sql_reader.GetString(1))

      if ($fields.count -gt 0) {
        Write-Debug 'ordilnal'
        Write-Debug $fields.count
        $iterator = 0..($fields.count - 1)
        <#
         ForEach-Object : Cannot convert 'System.Object[]' to the type 'System.String' required by parameter 'Message'. Specified method is not supported.
        #>
        $iterator | ForEach-Object {
          $cnt = $_
          $field = $fields[$cnt]
          $debug_msg = ('ordilnal({0} = {1}',$field,$sql_reader.GetOrdinal($field))
          Write-Debug $debug_msg
          $local:result += $sql_reader.GetOrdinal($field)

        }
      } else {
        Write-Debug 'field'
        $local:result += $sql_reader.GetString(0)
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
   CREATE TABLE destinations
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
} catch [Exception] {
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

create_table -database "$script_directory\shore_ex.db" -create_table_query @"
   CREATE TABLE excursions
      (CODE       CHAR(16) PRIMARY KEY     NOT NULL,
         URL      CHAR(1024),
         CAPTION   CHAR(256),
         DEST_CODE   CHAR(256),
         STATUS    INTEGER   NOT NULL
      );

"@
# cleanup ([ref]$selenium)
# return


$result = @()

# NOTE: need to be careful when passing  -fields @()
query_database -Destination $destination -database "$script_directory\shore_ex.db" -result_ref ([ref]$result) -fields @()
if ($DebugPreference -eq 'Continue') {
  Write-Output 'Result:'
  $result | Format-List
}

$base_url = $result[0]
Write-Output ('base_url: "{0}"' -f $base_url)
<#
# NOTE: need to be careful when passing  -fields @()
query_database -Destination $destination -database "$script_directory\shore_ex.db" -result_ref ([ref]$result) -fields @( 'URL','CODE')
if ($DebugPreference -eq 'Continue') {
  Write-Output 'Result:'
  $result | Format-List
}

$base_url = $result['URL']
Write-Output ('base_url: "{0}"' -f $base_url)
cleanup ([ref]$selenium)
return
#>
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
  $code =  ($url -replace '^.+/.+\-', '' )
  $caption =  $value_element6.Text
  $dest_code = 'N/A' 
  Write-Output ('Title: {0}' -f $caption )
  Write-Output ('Code: {0}' -f $code )
  Write-Output ('Destination: {0}' -f $dest_code )
  Write-Output ('Link: {0}' -f  $url)

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


0..($data.Count - 1) | ForEach-Object {
  $cnt = $_
  $row = $data[$cnt]
  $base_url = $data[$cnt]['url']
  $array = New-Object System.Collections.ArrayList
  $o = New-Object PSObject
  $o | Add-Member Noteproperty 'code' $row['code']
  $o | Add-Member Noteproperty 'url' $row['url']
  $o | Add-Member Noteproperty 'caption' $row['caption']
  $o | Add-Member Noteproperty 'dest_code' $row['dest_code']
  $o | Add-Member Noteproperty 'status' 0
  $o | Format-List
  insert_database2 -data $o -database "$script_directory\shore_ex.db"
  $array.Add($o)
  $o = $null
}

# continue to shorex_carousel_box_image.ps1

custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
