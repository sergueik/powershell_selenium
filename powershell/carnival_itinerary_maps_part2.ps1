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
  [int]$sailing_num = 0,
  [switch]$pause

)
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

$sailings = @(
  @{
    'text' = '4 Day Europe';
    'url' = 'http://www.carnival.com/BookingEngine/Stateroom/Stateroom2/?embkCode=TRS&itinCode=MEB&durDays=13&shipCode=VS&subRegionCode=E&sailDate=05012016&sailingID=70762&numGuests=2&showDbl=False&isOver55=N&isPastGuest=N&stateCode=&isMilitary=N&evsel=&be_version=1';
  },

  @{
    'text' = '4 Day Western Caribbean';
    'url' = 'http://www.carnival.com/itinerary/4-day-western-caribbean-cruise/miami/ecstasy/4-days/kc3/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA';
  },
  @{
    'text' = 'Carnival Live Presents Smokey Robinson - 4 Day Western Caribbean';
    'url' = 'http://www.carnival.com/itinerary/4-day-western-caribbean-cruise/miami/ecstasy/4-days/dab/?evsel=SYR&numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA';
  },
  @{

    'text' = '4 Day Western Caribbean';
    'url' = 'http://www.carnival.com/itinerary/4-day-western-caribbean-cruise/miami/victory/4-days/kwp/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA';
  },
  @{

    'text' = '5 Day Eastern Caribbean';
    'url' = 'http://www.carnival.com/itinerary/5-day-eastern-caribbean-cruise/miami/victory/5-days/ec0/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA';
  },
  @{

    'text' = '5 Day Western Caribbean';
    'url' = 'http://www.carnival.com/itinerary/5-day-western-caribbean-cruise/miami/victory/5-days/wcn/?numGuests=2&destination=caribbean&dest=C&datFrom=042015&datTo=042015&embkCode=MIA';
  },
  @{

    'text' = '4 Day Canada/New England';
    'url' = 'http://www.carnival.com/itinerary/4-day-canada-new-england-cruise/new-york/splendor/4-days/cac/?numGuests=2&destination=canada-new-england&dest=NN&datFrom=062015&datTo=062015&embkCode=NYC';
  },
  @{

    'text' = '10 Day Europe';
    'url' = 'http://www.carnival.com/itinerary/10-day-europe-cruise/barcelona/vista/10-days/meb/?numGuests=2&destination=europe&dest=E&datFrom=052016&datTo=052016&embkCode=BCN';
  },
  @{

    'text' = '10 Day Europe';
    'url' = 'http://www.carnival.com/itinerary/10-day-europe-cruise/athens/vista/10-days/mea/?numGuests=2&destination=europe&dest=E&datFrom=052016&datTo=052016&embkCode=BCN';
  },
  @{

    'text' = '13 Day Europe';
    'url' = 'http://www.carnival.com/itinerary/13-day-europe-cruise/trieste/vista/13-days/meb/?numGuests=2&destination=europe&dest=E&datFrom=052016&datTo=052016&embkCode=BCN';
  },
  @{


    'text' = '8 Day Glacier Bay';
    'url' = 'http://www.carnival.com/itinerary/8-day-glacier-bay-cruise/vancouver/legend/8-days/glb/?numGuests=2&destination=alaska&dest=A&datFrom=052015&datTo=052015&embkCode=SEA';
  },
  @{

    'text' = '7 Day Glacier Bay';
    'url' = 'http://www.carnival.com/itinerary/7-day-glacier-bay-cruise/seattle/legend/7-days/glm/?numGuests=2&destination=alaska&dest=A&datFrom=052015&datTo=052015&embkCode=SEA';
  }
)



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


$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path


$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder

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
    throw "unknown browser choice: ${browser}"
  }
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = "C:\tools\phantomjs"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

write-output $sailings[$sailing_num]['text']
$base_url = 'http://www.carnival.com/BookingEngine/Stateroom/Stateroom2/?embkCode=LAX&itinCode=LAF&durDays=3&shipCode=IM&subRegionCode=MB&sailDate=05072015&sailingID=69542&numGuests=2&showDbl=False&isOver55=N&isPastGuest=N&stateCode=&isMilitary=N&evsel=&be_version=1
'
$base_url = $sailings[$sailing_num]['url']


$selenium.Navigate().GoToUrl($base_url + '/')

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page

$selenium.Manage().Window.Maximize()


        # Click on Book Now

        $book_now_css_selector = 'li[class = action-col] a[class *=btn-red]'

        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($book_now_css_selector)))
        } catch [exception]{
          Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
        }

        $book_now_buttons = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($book_now_css_selector))
        $book_now_element = $null

        foreach ($element8 in $book_now_buttons) {
          if (!$book_now_element) {
            if ($element8.Text -match 'BOOK NOW') {
              Write-Output ('Selecting {0}' -f $element8.Text)
              $book_now_element = $element8
            }
          }
        }
        $element8 = $null
        [OpenQA.Selenium.Interactions.Actions]$actions4 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

        [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$book_now_element,'color: yellow; border: 4px solid yellow;')
        Start-Sleep 3
        [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$book_now_element,'')

        $actions4.MoveToElement([OpenQA.Selenium.IWebElement]$book_now_element).Build().Perform()

        Start-Sleep -Millisecond 1000
        Write-Output ('Click : "{0}"' -f $book_now_element.Text)
        $book_now_element.Click()
        Start-Sleep -Milliseconds 1000
        try {
          [NUnit.Framework.StringAssert]::Contains('http://www.carnival.com/BookingEngine/Stateroom',$selenium.url,{})
        } catch [exception]{
          write-output ("Unexpected redirect:`r`t{0}`rtAborting." -f $selenium.url )
          cleanup ([ref]$selenium)
          return
        }



# Write-Output $selenium.url

$summary_css_selector = 'div.summary h2#title'
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($summary_css_selector)))
  #          Write-Output 'Found ...'
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$summary_area = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($summary_css_selector))
Write-Output ('Started with {0}' -f $summary_area.Text)
Start-Sleep -Milliseconds 200
$wait = $null

$view_itin_css_selector = 'h2 span.viewitin'
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($view_itin_css_selector)))
  #          Write-Output 'Found ...'
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$view_itin_button = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($view_itin_css_selector))
Write-Output ('Clicked {0}' -f $view_itin_button.GetAttribute('class'))
$view_itin_button.Click()
Start-Sleep -Milliseconds 2000

[string]$xpath = "//iframe[@id='fancybox-frame']"
[object]$top_frame = $null
find_page_element_by_xpath ([ref]$selenium) ([ref]$top_frame) $xpath
$current_frame = $selenium.SwitchTo().Frame($top_frame)


# role=presentation 
# div#fancybox-content  is parent of iframe

$map_css_selector = 'a[href="#map-view"]'
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait_map = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($current_frame,[System.TimeSpan]::FromSeconds(3))
$wait_map.PollingInterval = 500

try {
  [void]$wait_map.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($map_css_selector)))
  $found_presentation = $true
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  $found_presentation = $false
}
if ($found_presentation) {
  $map_button = $current_frame.FindElement([OpenQA.Selenium.By]::CssSelector($map_css_selector))

  if ($map_button.Displayed) {
    Write-Output 'This itinerary has a map'
    $map_button.Click()
    Start-Sleep -Millisecond 1000
  }
}

$inner_pages_itinerary_css_selector = 'form[action *="ItineraryLightbox.aspx"]'
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait_inner_pages_itinerary = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($current_frame,[System.TimeSpan]::FromSeconds(30))
$wait_inner_pages_itinerary.PollingInterval = 500

try {
  [void]$wait_inner_pages_itinerary.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($inner_pages_itinerary_css_selector)))
  $found_inner_pages_itinerary = $true
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  $found_inner_pages_itinerary = $false
}
if ($found_inner_pages_itinerary) {
  $inner_pages_itinerary_button = $current_frame.FindElement([OpenQA.Selenium.By]::CssSelector($inner_pages_itinerary_css_selector))




  Write-Output 'trying iframe source'
  $page_source = (($inner_pages_itinerary_button.GetAttribute("innerHTML")) -join '')

  if ($page_source -match '/~/media/Images/Itineraries/Maps') {

    $result = $null
    extract_match -Source $page_source -capturing_match_expression '(?<media>/~/media/Images/Itineraries/Maps[^\"]+)' -label 'media' -result_ref ([ref]$result)
    Write-Output ('Found media images: {0}' -f $result)
  } else {
    Write-Output ('No media images found')
  }

  Start-Sleep -Millisecond 1000
}
# take and stamp screenshot
[void]$selenium.SwitchTo().DefaultContent()

# TODO :finish parameters
$fullstop = (($PSBoundParameters['pause']) -ne $null)

custom_pause -fullstop $fullstop
# At the end of the run - do not close Browser / Selenium when executing from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
