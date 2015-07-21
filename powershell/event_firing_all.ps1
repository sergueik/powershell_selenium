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
  'WebDriver.Support.dll',# for Events
  'nunit.core.dll',
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
#

# TODO 
# invoke NLog assembly for proper logging triggered by the events
# www.codeproject.com/Tips/749612/How-to-NLog-with-VisualStudio

$event = New-Object -Type 'OpenQA.Selenium.Support.Events.EventFiringWebDriver' -ArgumentList @( $selenium)

# $event | get-member 
# Start-Sleep -Millisecond 1000
# Write-Output ($event | Get-Member -MemberType Event) #
#

$navigating_handler = $event.add_Navigating
$navigating_handler.Invoke(

  {

    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.WebDriverNavigationEventArgs]$eventargs
    )
    Write-Host ($eventargs | Get-Member -MemberType Property) # 
    [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null))

  })


$clicking_handler = $event.add_ElementClicking
$clicking_handler.Invoke(

  {

    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.WebDriverNavigationEventArgs]$eventargs
    )
    Write-Host ($eventargs | Get-Member -MemberType Property) # 
    [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
    #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))

  })


$navigating_back_handler = $event.add_NavigatingBack
$navigating_back_handler.Invoke(

  {

    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.WebDriverNavigationEventArgs]$eventargs
    )
    Write-Host ($eventargs | Get-Member -MemberType Property) # 
    [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
    #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))

  })

$element_value_changing_handler = $event.add_ElementValueChanging
$element_value_changing_handler.Invoke(

  {

    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.WebElementEventArgs]$eventargs
    )
    Write-Host ($eventargs | Get-Member -MemberType Property) # 
    [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
    #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))

  })

$script_executing_handler = $event.add_ScriptExecuting
$script_executing_handler.Invoke(

  {

    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.WebDriverScriptEventArgs]$eventargs

    )
    Write-Host ($eventargs | Get-Member -MemberType Property) # 
    [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
    #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))

  })

$finding_element_handler = $event.add_FindingElement
$finding_element_handler.Invoke(

  {

    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.FindElementEventArgs]$eventargs
    )
    Write-Host ($eventargs | Get-Member -MemberType Property) # 
    # [NUnit.Framework.Assert]::IsTrue(($eventargs.Driver.ToString() -eq 'OpenQA.Selenium.Support.Events.EventFiringWebDriver'))
    #    [NUnit.Framework.Assert]::IsTrue(($eventargs.Url -ne $null ))

  })



$event.Navigate().GoToUrl($base_url)


# -- fragment of pseudo_mobile2.ps1

$css_selector = 'select[data-param=dest] option[disabled][selected]'
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $event.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
##[NUnit.Framework.Assert]::IsTrue($event.Text -match 'Sail to')##
##
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
$actions.MoveToElement($element).Click().Build().Perform()
Write-Output ('Processing : "{0}"' -f $element.Text)


set_timeouts ([ref]$event)
# Cleanup
cleanup ([ref]$event)


