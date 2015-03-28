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


# http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver
param(
  [switch]$browser,
  [switch]$pause

)

function set_timeouts {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [int]$explicit = 120,
    [int]$page_load = 600,
    [int]$script = 3000
  )

  [void]($selenium_ref.Value.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))

}

function netstat_check
{
  param(
    [string]$selenium_http_port = 4444
  )

  $results = Invoke-Expression -Command "netsh interface ipv4 show tcpconnections"

  $t = $results -split "`r`n" | Where-Object { ($_ -match "\s$selenium_http_port\s") }
  (($t -ne '') -and $t -ne $null)

}

function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {
  # Unblock-File -Path $_; 
  Add-Type -Path $_
}
popd

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$verificationErrors = New-Object System.Text.StringBuilder
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {

  if (-not (netstat_check)) {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\selenium.cmd"
    Start-Sleep -Seconds 4
  }

  [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

  [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
  [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
  $selected_profile_object.setPreference('general.useragent.override','Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16')
  $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
  [OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

  # [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
  [NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')

  $DebugPreference = 'Continue'

} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}
[void]$selenium.Manage().Timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(3000))


if ($host.Version.Major -le 2) {
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $selenium.Manage().Window.Size = New-Object System.Drawing.Size (480,600)
  $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
} else {
  $selenium.Manage().Window.Size = @{ 'Height' = 600; 'Width' = 480; }
  $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
}

$window_position = $selenium.Manage().Window.Position
$window_size = $selenium.Manage().Window.Size

$base_url = 'http://www.carnival.com/'
$selenium.Navigate().GoToUrl($base_url)
# set_timeouts ([ref]$selenium)


$css_selector = 'select[data-param=dest] option[disabled][selected]'
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Sail to')

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
$actions.MoveToElement($element).Click().Build().Perform()
Write-Output ('Processing : "{0}"' -f $element.Text)

if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}



$css_selector = 'select[data-param=dest] option[value=C]'

Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[NUnit.Framework.Assert]::AreEqual('Caribbean',$element.Text)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Click().Build().Perform()

Start-Sleep -Millisecond 200

$css_selector_header = 'h2.c-cruise-search__header'
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector_header)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}


if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}



##-
# re-select via http://stackoverflow.com/questions/15535069/select-each-option-in-a-dropdown-using-selenium
$text1 = 'Caribbean'
$css_selector = 'select[data-param=dest]'
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
$element
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($element)
$select_element
$availableOptions = $select_element.Options
$availableOptions
$index = 0
$max_count = 10
[bool]$found = $false
# http://stackoverflow.com/questions/15535069/select-each-option-in-a-dropdown-using-selenium
foreach ($item in $availableOptions)
{
  if ($index -gt $max_count) {
    continue
  }
  if ($found) {
    continue
  } else {

    [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions.MoveToElement($element).Build().Perform()
  }
  # $item
  if ($item.Text -eq $text1) {

    $found = $true

    $select_element.SelectByText($item.Text)
    $select_element.SelectByIndex($index)
    $select_element.SelectByValue($item.GetAttribute('value'))

    $result = $select_element.SelectedOption
    Write-Output $result.Text
    Write-Output $index

    [NUnit.Framework.Assert]::AreEqual($result.Text,$item.Text)

    $result.Click()
    Start-Sleep -Milliseconds 1000

    # NOTE: The [OpenQA.Selenium.Keys]::Enter,Space,Return do not work
    [void]$actions.SendKeys($item,[OpenQA.Selenium.Keys]::Enter)
    # Start-Sleep -Milliseconds 1000
    [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
    Start-Sleep -Milliseconds 1000
  }
  $index++
}


##-


[OpenQA.Selenium.IWebElement]$element_header = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector_header))
[NUnit.Framework.Assert]::AreEqual('FIND A CRUISE',$element_header.Text)
# TODO - debug

[OpenQA.Selenium.Interactions.Actions]$header_actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$header_actions.MoveToElement($element_header).Build().Perform()
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}


$css_selector = 'select[data-param=port] option[disabled][selected]'
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Sail from')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Click().Build().Perform()

Write-Output ('Processing : "{0}"' -f $element.Text)

if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}


$css_selector = 'select[data-param=port] option[value=MIA]'

Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

# [NUnit.Framework.Assert]::AreEqual('Fort Lauderdale, FL',$element.Text)
[NUnit.Framework.Assert]::AreEqual('Miami, FL',$element.Text)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Click().Build().Perform()

# TODO - debug
[OpenQA.Selenium.Interactions.Actions]$header_actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$header_actions.MoveToElement($element_header).Build().Perform()

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}


$css_selector = 'select[data-param=numGuests] option[disabled][selected]'
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Travelers')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
$header_actions.MoveToElement($element_header).Build().Perform()
Write-Output ('Processing : "{0}"' -f $element.Text)

if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}


$css_selector = 'select[data-param=numGuests] option[value="2"]'

Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[NUnit.Framework.Assert]::AreEqual('2 travelers',$element.Text)
# TODO - debug
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
Start-Sleep -Millisecond 200
[OpenQA.Selenium.Interactions.Actions]$header_actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$header_actions.MoveToElement($element_header).Build().Perform()

# $actions.MoveToElement($element_header).Build().Perform()
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

$css_selector = 'select[data-param=dat] option[disabled][selected]'
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Date')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
Start-Sleep -Milliseconds 200
$header_actions.MoveToElement($element_header).Build().Perform()
Write-Output ('Processing : "{0}"' -f $element.Text)

if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

$css_selector = 'select[data-param=dat] option[value="052015"]'

Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[NUnit.Framework.Assert]::AreEqual('May 2015',$element.Text)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
Start-Sleep -Milliseconds 200

$header_actions.MoveToElement($element_header).Build().Perform()

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}


[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
$name = 'Search'
$xpath = ("//button[contains(text(), '{0}')]" -f $name)

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
Write-Output ('Processing : "{0}"' -f $element.Text)

if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

Start-Sleep -Millisecond 10000


$css_selector = 'span.c-summary__value'

Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'itineraries found')


$css_selector1 = 'section#results_container article[class *="c-cruise-list-item"]'

Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector1)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait1 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait1.PollingInterval = 100
try {
  [void]$wait1.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))

# highlight the element
[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'border: 2px solid red;')
Start-Sleep -Millisecond 50
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element1,'')


$cnt_found = 0
$cnt_to_find = 5 # TODO compute

while ($cnt_found -lt $cnt_to_find) {

  $xpath2 = "following-sibling::article[contains(@class, 'c-cruise-list-item')][1]"


  [OpenQA.Selenium.IWebElement]$element2 = $element1.FindElement([OpenQA.Selenium.By]::XPath($xpath2))

  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element2,'border: 2px solid red;')
  Start-Sleep -Millisecond 50

  [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element2,'')
  $scroll_window = $element2.LocationOnScreenOnceScrolledIntoView.Y
  if ($scroll_window -eq 1) {
    $scroll_window = 10
  }
  if ($scroll_window -gt 0) {
    [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript(('scroll(0, {0})' -f $scroll_window),$null)
    Write-Output ('Scroll {0} px' -f $scroll_window)
    Start-Sleep -Millisecond 500
    # TODO ladder 
  }

  $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()

  $cnt_found = $cnt_found + 1
  $dest = ($element2.Text -split "`n")[0]
  $port_ship = ($element2.Text -split "`n")[1]
  Write-Output ('Saling to {0} {1}' -f $dest,$port_ship)

  $element1 = $element2
}

Write-Output ('Found {0}' -f $cnt_found)


if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}

$name = 'Show Dates'
$xpath = ("//span[contains(text(), '{0}')]" -f $name)
[OpenQA.Selenium.IWebElement]$element3 = $element1.FindElement([OpenQA.Selenium.By]::XPath($xpath))
Write-Output ('Processing : "{0}"' -f $element3.Text)


if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Click().Build().Perform()

$css_selector1 = 'div.c-price-table ul[class ="c-price-table__row"]'

Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector1)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait1 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait1.PollingInterval = 100

[OpenQA.Selenium.IWebElement]$element4 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
Write-Output ('Processing : "{0}"' -f $element4.Text)

# highlight the element
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'border: 2px solid red;')
Start-Sleep -Millisecond 50
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'')



$name = 'Book Now'

$css_selector1 = ''
# $xpath = ("//a [class*="c-button"][contains(text(), '{0}')]" -f $name)
$xpath = ("//a[contains(@class, '{0}')][contains(text(), '{1}')]" -f 'c-button',$name)
Write-Output ('Locating via XPATH: "{0}"' -f $xpath)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait1 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait1.PollingInterval = 100

[OpenQA.Selenium.IWebElement]$element6 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
Write-Output ('Processing : "{0}"' -f $element6.Text)

# highlight the element
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element6,'border: 2px solid red;')
Start-Sleep -Millisecond 50
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element6,'')
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element6).Click().Build().Perform()
Start-Sleep -Millisecond 10000

# Cleanup
cleanup ([ref]$selenium)

