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
  [int]$version,  # TODO: version
  [switch]$many,
  [string]$destination = 'Ensenada',
  [switch]$pause
)

function init_database {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db"
  )
  [int]$version = 3
  [System.Data.SQLite.SQLiteConnection]::CreateFile($database)
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version )
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  $command = $connection.CreateCommand()
  # $command.getType() | format-list
  $connection.Close()
}

function create_table {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$create_table_query = @"
   CREATE TABLE IF NOT EXISTS [destinations]
      (
         CODE      CHAR(16) PRIMARY KEY     NOT NULL,
         URL       CHAR(1024),
         CAPTION   CHAR(256),
         STATUS    INTEGER   NOT NULL
      );
"@ # http://www.sqlite.org/datatype3.html
  )
  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version )
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  Write-Debug $create_table_query
  [System.Data.SQLite.SQLiteCommand]$sql_command = New-Object System.Data.SQLite.SQLiteCommand ($create_table_query,$connection)
  $sql_command.ExecuteNonQuery()
  $connection.Close()
}

function insert_database {
  param(
    [string]$database = "$(Get-ScriptDirectory)\shore_ex.db",
    [string]$query = @"
INSERT INTO [destinations] (CODE, CAPTION, URL, STATUS )  VALUES(?, ?, ?, ?)
"@,
    [psobject]$data
  )

  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version )
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  Write-Debug $query
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $code = New-Object System.Data.SQLite.SQLiteParameter
  $caption = New-Object System.Data.SQLite.SQLiteParameter
  $url = New-Object System.Data.SQLite.SQLiteParameter
  $status = New-Object System.Data.SQLite.SQLiteParameter


  [void]$command.Parameters.Add($code)
  [void]$command.Parameters.Add($caption)
  [void]$command.Parameters.Add($url)
  [void]$command.Parameters.Add($status)

  $code.Value = $data.code
  $caption.Value = $data.caption
  $url.Value = $data.url
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
init_database -database "$script_directory\shore_ex.db"
# full path  has to be provided
create_table -database "$script_directory\shore_ex.db"


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
if ($value_element3 -ne $null){
[OpenQA.Selenium.Interactions.Actions]$actions3 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions3.MoveToElement([OpenQA.Selenium.IWebElement]$value_element3).Click().Build().Perform()
$value_element3 = $null
$actions3 = $null
}
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
<#
examle: save the page element as HTML manually:

$shoreex_destinations_modal_raw_xmldata = @'
<?xml version="1.0"?>
<dummy>
  <!-- # Load the destinations modal contents and grab all of it, one entry at a time .  Visualize the process -->
  <!-- Modal Dialog : Destination -->
  <div class="modal fade" id="destinationModal">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-body">
          <div id="destinations" class="row dest">
            <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
              <ul>
                <li class="ca-home-destination-title">
                  <span>Departure Ports</span>
                </li>
                <li>
                  <a href="/shore-excursions/athens-greece" data-val="ATH">Athens, Greece</a>
                </li>
                <li>
                  <a href="/shore-excursions/baltimore-md" data-val="BWI">Baltimore, MD</a>
                </li>
                <li>
                  <a href="/shore-excursions/barbados" data-val="BDS">Barbados</a>
                </li>
                <li>
                  <a href="/shore-excursions/barcelona-spain" data-val="BCN">Barcelona, Spain</a>
                </li>
                <li>
                  <a href="/shore-excursions/charleston-sc" data-val="CHS">Charleston, SC</a>
                </li>
                <li>
                  <a href="/shore-excursions/galveston-tx" data-val="GAL">Galveston, TX</a>
                </li>
                <li>
                  <a href="/shore-excursions/honolulu-hi" data-val="HNL">Honolulu, HI</a>
                </li>
                <li>
                  <a href="/shore-excursions/jacksonville-fl" data-val="JAX">Jacksonville, FL</a>
                </li>
                <li>
                  <a href="/shore-excursions/miami-fl" data-val="MIA">Miami, FL</a>
                </li>
                <li>
                  <a href="/shore-excursions/new-orleans-la" data-val="MSY">New Orleans, LA</a>
                </li>
                <li>
                  <a href="/shore-excursions/new-york-ny" data-val="NYC">New York, NY</a>
                </li>
                <li>
                  <a href="/shore-excursions/port-canaveral-orlando-fl" data-val="PCV">Port Canaveral (Orlando), FL</a>
                </li>
                <li>
                  <a href="/shore-excursions/san-juan-puerto-rico" data-val="SJU">San Juan, Puerto Rico</a>
                </li>
                <li>
                  <a href="/shore-excursions/seattle-wa" data-val="SEA">Seattle, WA</a>
                </li>
                <li>
                  <a href="/shore-excursions/tampa-fl" data-val="TPA">Tampa, FL</a>
                </li>
                <li>
                  <a href="/shore-excursions/vancouver-bc-canada" data-val="YVR">Vancouver, Bc, Canada</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/alaska" data-val="A">Alaska</a>
                </li>
                <li>
                  <a href="/shore-excursions/juneau-ak" data-val="JNU">Juneau</a>
                </li>
                <li>
                  <a href="/shore-excursions/ketchikan-ak" data-val="KTN">Ketchikan</a>
                </li>
              </ul>
            </div>
            <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
              <ul>
                <li>
                  <a href="/shore-excursions/skagway-ak" data-val="SKY">Skagway</a>
                </li>
                <li>
                  <a href="/shore-excursions/victoria-bc-canada" data-val="YYJ">Victoria</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/bahamas" data-val="BH">Bahamas</a>
                </li>
                <li>
                  <a href="/shore-excursions/freeport-the-bahamas" data-val="FPO">Freeport</a>
                </li>
                <li>
                  <a href="/shore-excursions/grand-turk" data-val="GDT">Grand Turk</a>
                </li>
                <li>
                  <a href="/shore-excursions/half-moon-cay-the-bahamas" data-val="HMC">Half Moon Cay</a>
                </li>
                <li>
                  <a href="/shore-excursions/nassau-the-bahamas" data-val="NAS">Nassau</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/bermuda" data-val="BM">Bermuda</a>
                </li>
                <li>
                  <a href="/shore-excursions/bermuda" data-val="WRF">Bermuda</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/caribbean" data-val="C">Caribbean</a>
                </li>
                <li>
                  <a href="/shore-excursions/amber-cove-dominican-republic" data-val="DOP">Amber Cove</a>
                </li>
                <li>
                  <a href="/shore-excursions/antigua" data-val="ATG">Antigua</a>
                </li>
                <li>
                  <a href="/shore-excursions/aruba" data-val="ARB">Aruba</a>
                </li>
                <li>
                  <a href="/shore-excursions/belize" data-val="BZE">Belize</a>
                </li>
                <li>
                  <a href="/shore-excursions/bonaire" data-val="BON">Bonaire                       </a>
                </li>
                <li>
                  <a href="/shore-excursions/colon-panama" data-val="CLN">Colon</a>
                </li>
                <li>
                  <a href="/shore-excursions/curacao" data-val="CUR">Curacao</a>
                </li>
                <li>
                  <a href="/shore-excursions/dominica" data-val="DOM">Dominica</a>
                </li>
                <li>
                  <a href="/shore-excursions/falmouth-jamaica" data-val="FJM">Falmouth</a>
                </li>
                <li>
                  <a href="/shore-excursions/grand-cayman-cayman-islands" data-val="CAY">Grand Cayman</a>
                </li>
              </ul>
            </div>
            <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
              <ul>
                <li>
                  <a href="/shore-excursions/grenada" data-val="JGU">Grenada</a>
                </li>
                <li>
                  <a href="/shore-excursions/la-romana-dominican-republic" data-val="LRM">La Romana</a>
                </li>
                <li>
                  <a href="/shore-excursions/limon-costa-rica" data-val="LMO">Limon</a>
                </li>
                <li>
                  <a href="/shore-excursions/mahogany-bay-isla-roatan" data-val="RTN">Mahogany Bay</a>
                </li>
                <li>
                  <a href="/shore-excursions/martinique-fwi" data-val="MTK">Martinique</a>
                </li>
                <li>
                  <a href="/shore-excursions/montego-bay-jamaica" data-val="MTB">Montego Bay</a>
                </li>
                <li>
                  <a href="/shore-excursions/ocho-rios-jamaica" data-val="OCJ">Ocho Rios</a>
                </li>
                <li>
                  <a href="/shore-excursions/key-west-fl" data-val="KEY">Key West</a>
                </li>
                <li>
                  <a href="/shore-excursions/st-croix-usvi" data-val="STX">St. Croix</a>
                </li>
                <li>
                  <a href="/shore-excursions/st-thomas-usvi" data-val="STT">St. Thomas</a>
                </li>
                <li>
                  <a href="/shore-excursions/st-kitts-wi" data-val="STK">St Kitts</a>
                </li>
                <li>
                  <a href="/shore-excursions/st-maarten-na" data-val="SXM">St. Maarten</a>
                </li>
                <li>
                  <a href="/shore-excursions/tortola-british-virgin-islands" data-val="TOR">Tortola</a>
                </li>
                <li>
                  <a href="/shore-excursions/ft-lauderdale-pt-evrglds-fl" data-val="EGL">Ft Lauderdale (Pt Evrglds)</a>
                </li>
                <li>
                  <a href="/shore-excursions/st-lucia" data-val="SLC">St. Lucia</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/europe" data-val="E">Europe</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/hawaii" data-val="H">Hawaii</a>
                </li>
                <li>
                  <a href="/shore-excursions/hilo-hi" data-val="ITO">Hilo</a>
                </li>
                <li>
                  <a href="/shore-excursions/kona-hi" data-val="KOA">Kona</a>
                </li>
                <li>
                  <a href="/shore-excursions/kauai-nawiliwili-hi" data-val="LIH">Kauai (Nawiliwili)</a>
                </li>
                <li>
                  <a href="/shore-excursions/maui-kahului-hi" data-val="OGG">Maui (Kahului)</a>
                </li>
              </ul>
            </div>
            <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
              <ul>
                <li class="ca-home-destination-title">
                  <a href="/shore-excursions/mexico" data-val="M">Mexico</a>
                </li>
                <li>
                  <a href="/shore-excursions/cabo-san-lucas-mexico" data-val="CSL">Cabo San Lucas</a>
                </li>
                <li>
                  <a href="/shore-excursions/puerto-vallarta-mexico" data-val="PVR">Puerto Vallarta</a>
                </li>
                <li>
                  <a href="/shore-excursions/catalina-island-ca" data-val="CAT">Catalina Island</a>
                </li>
                <li>
                  <a href="/shore-excursions/mazatlan-mexico" data-val="MZT">Mazatlan</a>
                </li>
                <li>
                  <a href="/shore-excursions/los-angeles-long-beach-ca" data-val="LGB">Los Angeles (Long Beach)</a>
                </li>
                <li>
                  <a href="/shore-excursions/manzanillo-mexico" data-val="MAN">Manzanillo</a>
                </li>
                <li>
                  <a href="/shore-excursions/ensenada-mexico" data-val="ENS">Ensenada</a>
                </li>
                <li>
                  <a href="/shore-excursions/cozumel-mexico" data-val="CZM">Cozumel</a>
                </li>
                <li>
                  <a href="/shore-excursions/costa-maya-mexico" data-val="CMZ">Costa Maya</a>
                </li>
                <li>
                  <a href="/shore-excursions/yucatan-progreso-mexico" data-val="PGR">Yucatan (Progreso)</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/canada-new-england" data-val="NN">Canada / New England</a>
                </li>
                <li>
                  <a href="/shore-excursions/boston-ma" data-val="BOS">Boston</a>
                </li>
                <li>
                  <a href="/shore-excursions/portland-me" data-val="PWM">Portland</a>
                </li>
                <li>
                  <a href="/shore-excursions/halifax-ns-canada" data-val="YHZ">Halifax</a>
                </li>
                <li>
                  <a href="/shore-excursions/saint-john-nb-canada" data-val="YSJ">Saint John</a>
                </li>
                <li class="ca-home-destination-title ca-home-destination-list-row">
                  <a href="/shore-excursions/south-america" data-val="S">South America</a>
                </li>
                <li>
                  <a href="/shore-excursions/santa-marta-colombia" data-val="SRT">Santa Marta</a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
      <a class="ca-top-icon-button close pull-left" data-dismiss="modal" aria-hidden="true">&#xF057;</a>
    </div>
  </div>
</dummy>
'@

#  http://www.powershellmagazine.com/2014/06/30/pstip-using-xpath-in-powershell-part-4/
$s1 = [xml]$shoreex_destinations_modal_raw_xmldata
$cnt = 0

$data = @( @{
    'code' = $null;
    'url' = $null;
    'description' = $null;

  })
Select-Xml -Xml $s1 -XPath '//div[@id="destinationModal"]//ul//li//a' | ForEach-Object {
  $node = $_;

  if ($cnt -eq 0) {
    $cnt = 1
    $o = $node.Node;
    Write-Output ($o | Get-Member | Format-List)

  }

  $data += @{
    'code' = $o.'data-val';
    'url' = $o.href;
    'description' = $o.'#text';
  }

write-output $o.'data-val'
write-output $o.href
write-output $o.'#text'

}


#>
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
  if ($destination_name -match $skip_destinations_regex) { return }
  if ($headless) {  
      $row | format-list
 return } 
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

0..($data.Count - 1) | ForEach-Object {
  $cnt = $_
  $row = $data[$cnt]
  $base_url = $data[$cnt]['url']
  $o = New-Object PSObject
  $o | Add-Member Noteproperty 'code' $row['code']
  $o | Add-Member Noteproperty 'url' $base_url
  $o | Add-Member Noteproperty 'caption' $row['description']
  $o | Add-Member Noteproperty 'status' 0
  insert_database -data $o -database "$script_directory\shore_ex.db"
  <#
  TODO: prevent
  Exception calling "ExecuteNonQuery" with "0" argument(s): constraint failed 
   NOT NULL constraint failed: destinations.CODE
   UNIQUE constraint failed: destinations.CODE
  #>
  $o = $null
}



if (($PSBoundParameters['many'].IsPresent)) {

$result = query_database_basic

  $result | ForEach-Object {
    $row = $_
    $base_url = $row['url']

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
