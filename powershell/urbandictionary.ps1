#Copyright (c) 2014,2018 Serguei Kouzmine
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
  [string]$profile = 'Selenium',
  [switch]$pause
)

$shared_assemblies = @{
  'WebDriver.dll' = '2.53';
  'WebDriver.Support.dll' = '2.53';
  'nunit.core.dll' = $null;
  'nunit.framework.dll' = '2.6.3';
}

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

load_shared_assemblies_with_versions -path $shared_assemblies_path -shared_assemblies $shared_assemblies

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
[object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

[OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
[OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
$selected_profile_object.setPreference('general.useragent.override','Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16')

<#
$profile_raw64 = $selected_profile_object.ToBase64String()
$profile_raw64 | Out-File -FilePath 'a.txt'
$profile_raw = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($profile_raw64))
$profile_raw | Out-File -FilePath 'a.zip'
#>
# These preferences have no effect, need to find the correct syntax
# $selected_profile_object.setPreference('browser.window.width',480)
# $selected_profile_object.setPreference('browser.window.height',600)


# $selected_profile_object.UpdateUserPreferences()
# A lot of methods declared in Webdriver.xml do not work:
# Method invocation failed because [OpenQA.Selenium.Firefox.FirefoxProfile] does
# not contain a method named 'UpdateUserPreferences'.
#
# $selected_profile_object | get-member
#
# [OpenQA.Selenium.Firefox.Preferences] $p = $selected_profile_object.ReadExistingPreferences()

$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
[OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

# TODO: finish the syntax
# [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
[NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')

$DebugPreference = 'Continue'
$base_url = 'http://www.urbandictionary.com/'

if ($host.Version.Major -le 2) {

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $selenium.Manage().Window.Size = New-Object System.Drawing.Size (480,600)
  $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
} else {
  $selenium.Manage().Window.Size = @{ 'Height' = 600; 'Width' = 480; }
  $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
}
$selenium.Navigate().GoToUrl($base_url)
set_timeouts ([ref]$selenium)

[NUnit.Framework.StringAssert]::Contains('www.urbandictionary.com',$selenium.url,{})

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
$css_selector = 'a#logo'
Write-Debug ('Trying CSS Selector "{0}"' -f $css_selector)

try {

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))

} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'border: 2px solid red;')

Start-Sleep 3
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')


$css_selector = 'div#content'
Write-Debug ('Trying CSS Selector "{0}"' -f $css_selector)

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$container_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

$cnt_found = 0
$cnt_to_find = 7

while ($cnt_found -lt $cnt_to_find) {

  $css_selector = 'a.word'
  Write-Debug ('Trying CSS Selector "{0}" inside "{1}"' -f $css_selector, '')

  try {
    [OpenQA.Selenium.IWebElement[]]$elements2 = $container_element.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
  }
  $cnt = 0
  Write-Output ('inspecting {0} words' -f $elements2.count)
  $elements2 | ForEach-Object {
    $element2 = $_
    if (($element2 -ne $null -and $element2.Displayed)) {
      if ($cnt -ge $cnt_found) {
        assert_true ($element2 -ne $null)
        Write-Output ('{0} / {1} => {2}' -f $cnt,$cnt_found,$element2.Text)
      }

      [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    <#
      using this example testcase to exercise the newly added method
      #>
      $cssSelectorOfElement = cssSelectorOfElement -element_ref ([ref] $element2)
      # NOTE:without the parenthesis, get formatting error:
      # Locating for debugging by a#logo:nth-of-type(3)1
      # Exception calling "FindElement" with "1" argument(s): "The given selector
      # a#logo:nth-of-type(5)1 is either invalid or does not result in a WebElement.
      # The following error occurred:
      # InvalidSelectorError: An invalid or illegal selector was specified"
      # The selector like div.someclass may needs an "nth-of-type"
      # $css_selector2 = ('{0}:nth-of-type({1})' -f $cssSelectorOfElement, ($cnt + 1))
      $css_selector2 = $cssSelectorOfElement 
      write-output ('Locating for debugging by "{0}"' -f $css_selector2)
      [OpenQA.Selenium.IWebElement]$element3 = find_element2 -selector 'css_selector' -value $css_selector2
      write-output ('Located "{0}"' -f $element3.Text)
      [OpenQA.Selenium.IWebElement]$element4 = find_element2 -selector 'link_text' -value $element3.Text
      write-output ('Located "{0}"' -f $element4.Text)

      $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()

      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element2,'background-color:  blue;')

      Start-Sleep -Milliseconds 100
      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element2,'')

      highlight_new -element ([ref]$element2) -color 'magenta' -selenium_ref ([ref]$selenium)
      flash -element ([ref]$element2) -selenium_ref ([ref]$selenium)
      highlight -element ([ref]$element2) -color 'green' -selenium_ref ([ref]$selenium)

      $cnt++
    }
  }

  $cnt_found = $elements2.count
  Write-Output ('inspected {0} words' -f $cnt_found)
}

Write-Output ('Found {0}' -f $cnt_found)

if ($PSBoundParameters['pause']) {

  try {

    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}

} else {
  Start-Sleep -Millisecond 1000
}

# Cleanup
cleanup ([ref]$selenium)

