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
  [string]$browser = 'chrome',
  [int]$version,
  [switch]$many,
  [string]$destination = 'Ensenada',
  [switch]$pause
)


function init_database {
  param([string]$database = 'shore_ex.db'
  )

  [System.Data.SQLite.SQLiteConnection]::CreateFile($database)
  [int]$version = 3
  $connection = New-Object System.Data.SQLite.SQLiteConnection (('Data Source={0};Version={1};' -f $database,$version))
  $connection.Open()
  $command = $connection.CreateCommand()
  # $command.getType() | format-list
  $connection.Close()
}

function create_table {
  param([string]$database = 'shore_ex.db',

    # http://www.sqlite.org/datatype3.html
    [string]$sdl_query = @"
   CREATE TABLE IF NOT EXISTS [destinations]
      (CODE        CHAR(16) PRIMARY KEY     NOT NULL,
         URL       CHAR(1024),
         CAPTION   CHAR(256),
         STATUS    INTEGER   NOT NULL
      );

"@
  )
  [int]$version = 3
  $connection = New-Object System.Data.SQLite.SQLiteConnection ('Data Source={0};Version={1};' -f $database,$version)
  $connection.Open()
  Write-Output $sdl_query
  [System.Data.SQLite.SQLiteCommand]$sql_command = New-Object System.Data.SQLite.SQLiteCommand ($sdl_query,$connection)
  $sql_command.ExecuteNonQuery()
  $connection.Close()


}

function insert_database {
  param(
    [string]$database = "$script_directory\shore_ex.db",
    [string]$query = @"
INSERT INTO [destinations] (CODE, CAPTION, URL, STATUS )  VALUES(?, ?, ?, ?)
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


  $command.Parameters.Add($code)
  $command.Parameters.Add($caption)
  $command.Parameters.Add($url)
  $command.Parameters.Add($status)

  $code.Value = $data.code
  $caption.Value = $data.caption
  $url.Value = $data.url
  $status.Value = $data.status
  $rows_inserted = $command.ExecuteNonQuery()
  Write-Output $rows_inserted
  $command.Dispose()
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
init_database -database "$script_directory\destinations.db"
# full path  has to be provided
create_table -database "$script_directory\destinations.db"


$base_url = 'http://www.carnival.com/'

$selenium.Navigate().GoToUrl($base_url)

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

Write-Output ('Started with {0}' -f $selenium.Title)
$selenium.Manage().Window.Maximize()

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
# TODO: Assert element has 'initialized'  and 'hover'  class attribute

$value_element1 = $null

# Continue with 'Shore Excursions'
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

# get al destinations 

$value_element4a = $null
$destination_container_css_selector = 'div#destinations'

find_page_element_by_css_selector ([ref]$selenium) ([ref]$value_element4a) $destination_container_css_selector

$value_element4a
$shoreex_destinations_modal_raw_xmldata = ('<?xml version="1.0"?><dummy>{0}</dummy>' -f ($value_element4a.GetAttribute('innerHTML') -join ''))
highlight ([ref]$selenium) ([ref]$value_element4a)
Write-Output ("`XML:`r`n{0}" -f $shoreex_destinations_modal_raw_xmldata)

#  http://www.powershellmagazine.com/2014/06/30/pstip-using-xpath-in-powershell-part-4/
$s1 = [xml]$shoreex_destinations_modal_raw_xmldata

$cnt = 0

$data = @( @{
    'code' = $null;
    'url' = $null;
    'description' = $null;
  })

$attribute = 'ca-home-modal-list-destination'

$xpath_links = '//div[@id="destinationModal"]//ul//li//a'
$xpath_links = ("//div[contains(@class,'{0}')]//ul//li//a" -f $attribute)

# https://www.simple-talk.com/sysadmin/powershell/powershell-data-basics-xml/
Select-Xml -Xml $s1 -XPath $xpath_links | ForEach-Object {
  $node = $_;
  $o = $node.Node;
  if ($cnt -eq 0) {
    $cnt = 1
    Write-Output ($o | Get-Member | Format-List)
  }
  $data += @{
    'code' = $o.'data-val';
    'url' = $o.href;
    'description' = $o.'#text';
  }
}
$skip_destinations = @"
europe
caribbean
south america
Canada / New England
hawaii
Bermuda
Bahamas
Alaska
Mexico
"@
$skip_destinations_regex = '(' + ($skip_destinations -replace "`r`n",'|') + ')'
0..($data.Count - 1) | ForEach-Object {
  $cnt = $_
  $row = $data[$cnt]

  $value_element4 = $null

  $destination_data_val = $row['code']
  $destination_name = $row['description']

  if (-not $destination_data_val) { return }
  if (-not ($destination_name -match $skip_destinations_regex)) {

    Write-Output ('will find "{0}"' -f $destination_data_val)

    $destination_css_selector = ('div#destinations a[data-val="{0}"]' -f $destination_data_val)

    find_page_element_by_css_selector ([ref]$selenium) ([ref]$value_element4) $destination_css_selector
    Write-Output ('Destinaton: {0}' -f ($value_element4.GetAttribute('innerHTML') -join ''))
    $data[$cnt]['url'] = $value_element4.GetAttribute('href')
    Write-Output ('Link: {0}' -f $value_element4.GetAttribute('href'))
    highlight ([ref]$selenium) ([ref]$value_element4) -Delay 30
    # TODO Assert url

    $value_element4 = $null
  }
}

0..($data.Count - 1) | ForEach-Object {
  $cnt = $_
  $row = $data[$cnt]
  $base_url = $data[$cnt]['url']
  $array = New-Object System.Collections.ArrayList
  $o = New-Object PSObject
  $o | Add-Member Noteproperty 'code' $row['code']
  $o | Add-Member Noteproperty 'url' $base_url
  $o | Add-Member Noteproperty 'caption' $row['description']
  $o | Add-Member Noteproperty 'status' 0
  $o | Format-List
  insert_database -data $o -database "$script_directory\destinations.db"
  $array.Add($o)
  $o = $null
}



if (($PSBoundParameters['many'].IsPresent)) {
  0..($data.Count - 1) | ForEach-Object {
    $cnt = $_
    $row = $data[$cnt]
    $base_url = $data[$cnt]['url']

    if (-not $base_url) { return }
    $selenium.Navigate().GoToUrl($base_url)

    # TODO assert page ready!
  }
} else {
  # continue to shorex_browse_destination.ps1
}
custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
