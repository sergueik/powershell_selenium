#Copyright (c) 2014 Serguei Kouzmine
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
  [string]$hub_host = '127.0.0.1',
  [string]$browser,
  [string]$version,
  [string]$profile = 'default'
)

function set_timeouts {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [int]$explicit = 10,
    [int]$page_load = 60,
    [int]$script = 30
  )

  [void]($selenium_ref.Value.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))

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
  "WebDriver.dll",
  "WebDriver.Support.dll",
  'nunit.framework.dll',
  'nunit.core.dll'
)


$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

$verificationErrors = New-Object System.Text.StringBuilder

# use Default Web Site to host the page. Enable Directory Browsing.

$hub_port = '4444'
$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

try {
  $connection = (New-Object Net.Sockets.TcpClient)
  $connection.Connect($hub_host,[int]$hub_port)
  $connection.Close()
} catch {
  Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\selenium.cmd"

  Start-Sleep -Seconds 3
}

$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$options.AddArgument('--user-agent=Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16')
$selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)

$selenium.Manage().Window.Size = @{ 'Height' = 600; 'Width' = 480; }
$selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }

$base_url = 'http://www.priceline.com/'
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
set_timeouts ([ref]$selenium)

[NUnit.Framework.Assert]::IsTrue(($selenium.url -match 'https://www.priceline.com/smartphone/'))

try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $css_selector = 'div.artwork'
  Write-Output ('Trying CSS Selector "{0}"' -f $css_selector)

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: yellow; border: 4px solid yellow;')
Start-Sleep 3
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')

# https://social.msdn.microsoft.com/Forums/vstudio/en-US/e7a6ad85-b965-490a-9f70-bee9eb47bd12/nunit-in-visual-studio-2010?forum=vsunittest
# older versions of nunit.framerowk.dll do not have stringassert
# http://nunit.org/?p=download
[NUnit.Framework.StringAssert]::Contains('artwork',$element.GetAttribute('class'),{})

[NUnit.Framework.Assert]::IsTrue($element.GetAttribute('class') -match 'artwork')

[OpenQA.Selenium.IWebElement]$element2 = $element.FindElement([OpenQA.Selenium.By]::CssSelector('span.image'))
$element2

try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $css_selector = 'a#btn_hotel'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
$element.Text
[NUnit.Framework.Assert]::AreEqual($element.Text,'Hotels')


$element.Click()

[NUnit.Framework.Assert]::AreEqual($selenium.Title,'Hotels')

# write-output $selenium.PageSource
$element = $null
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $xpath = "//h2[@role='heading']"
  Write-Output ('Trying XPath "{0}"' -f $xpath)

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}


[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100

# $css_selector = "h2[role=heading]"
$css_selector = "div#header_bar"

Write-Output ('Trying CSS Selector "{0}"' -f $css_selector)

try {


  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

if ($element -eq $null) {
  Write-Output 'Iterate directly...'
  $xpath = '//h2'
  [OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::XPath($xpath))
  $element5 = $null
  $elements | ForEach-Object { $element3 = $_
    if (($element3.Text -match 'Hotels')) {
      $element5 = $element3
    }
    $cnt++
  }

  [NUnit.Framework.Assert]::IsTrue(($element5 -ne $null))
  [NUnit.Framework.Assert]::IsTrue(($element5.Displayed))
  [NUnit.Framework.Assert]::IsTrue(($element5.GetAttribute('role') -match 'heading'))
  Write-Output 'Found Hotels title'
  Write-Output ('role= {0}' -f $element5.GetAttribute('role'))
}
$element = $null
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $css_selector = 'div > span.stay-col'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

if ($element -ne $null) {
  $element
} else {
  Write-Output 'Iterate directly over buttons...'
  $csspath = 'div'
  [OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))
  $element5 = $null
  $found = $false

  $elements | ForEach-Object { $element3 = $_
    if ($element5 -eq $null -and $element3.Displayed -and $element3.Text -match 'choose a location') {
      # Write-Output $element3
      $element5 = $element3
    }
    $cnt++
  }
  [OpenQA.Selenium.IWebElement[]]$elements2 = $element5.FindElements([OpenQA.Selenium.By]::CssSelector('span'))
  $element6 = $null
  $elements2 | ForEach-Object { $element2 = $_
    if ($element6 -eq $null -and $element2.Displayed -and $element2.Text -match 'choose a location') {
      # Write-Output $element3
      $element6 = $element2
    }
  }
}

[NUnit.Framework.Assert]::IsTrue(($element6.GetAttribute('class') -match 'stay-col'))

$element6.Click()
Start-Sleep 1
$element = $null
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'ul#city_search_top50'
  $csspath = 'ul'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}


if ($element -ne $null) {
  $element5 = $null
  [OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector('li'))
  $found = $false

  $elements | ForEach-Object { $element3 = $_
    if ($false -and $element3.Displayed) {
      # $element5 -eq $null 
      #  -and $element3.Text -match 'choose a location'
      Write-Output $element3.Text
      $element3
      $element5 = $element3
    }
    $cnt++
  }

} else {

  Write-Output 'Iterate directly over cities...'
  [OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector('li'))
  $element5 = $null
  $elements | ForEach-Object { $element3 = $_

    if (($element5 -eq $null)) {

      [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

      $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
    }
    if (($element3.Displayed)) {
      if ($element3.Text -match 'Miami') {
        Write-Output ('Selecting "{0}"' -f $element3.Text)


        $element5 = $element3

      }

    }
    $cnt++
  }


  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'color: yellow; border: 4px solid yellow;')
  Start-Sleep -Millisecond 2000
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'')

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element5).Click().Build().Perform()

}


$element = $null

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100

$csspath = "h2[role~=heading]"

$xpath = "//input[@category='HotelSearch']"
Write-Output ('Trying XPath "{0}"' -f $xpath)

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
if ($element -ne $null) {
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: yellow; border: 4px solid yellow;')
  Start-Sleep 3
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')
  $element.Text
  $element.GetAttribute('category')
  $element.Click()
}

#
# [void]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#
Start-Sleep 5

$element = $null

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100

$css_selector = "div.hotel-listview-item-thumbnail"

Write-Output ('Trying CSS "{0}"' -f $css_selector)
try {

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
if ($element -ne $null) {


  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: yellow; border: 4px solid yellow;')
  Start-Sleep 3
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')

  $element.Text
  $element.Click()
}

#
# [void]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#
Start-Sleep 3

<#
# scroll away from tool bar
[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript('scroll(0, 500)',$null)
Start-Sleep -Seconds 1

# var hasJQueryLoaded = (bool) js.ExecuteScript("return (window.jQuery != null) && (jQuery.active === 0);");

[int]$timeout = 4000
# change $timeout to see if the WevDriver is waiting on page  sctript to execute

[string]$script = "window.setTimeout(function(){document.getElementById('searchInput').value = 'test'}, ${timeout});"

$start = (Get-Date -UFormat "%s")

try {
  [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeAsyncScript($script);

} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  # Ignore
  # Timed out waiting for async script result  (Firefox)
  # asynchronous script timeout: result was not received (Chrome)
  [NUnit.Framework.Assert]::IsTrue($_.Exception.Message -match '(?:Timed out waiting for async script result|asynchronous script timeout)')
}
catch [OpenQA.Selenium.NoSuchWindowException]{
  Write-Host $_.Exception.Message # Unable to get browser
  $_.Exception | Get-Member

}
$end = (Get-Date -UFormat "%s")
$elapsed = New-TimeSpan -Seconds ($end - $start)
Write-Output ('Elapsed time {0:00}:{1:00}:{2:00} ({3})' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds,($end - $start))
#>

# Cleanup
cleanup ([ref]$selenium)




