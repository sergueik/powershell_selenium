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
  [string]$version,
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)


[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies

<#
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid -version $version
  Start-Sleep -Millisecond 500
} else {
  $selenium = launch_selenium -browser $browser -version $version
}
#>
$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$options.AddArgument('--user-agent=Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16')
$selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)

$selenium.Manage().Window.Size = @{ 'Height' = 800; 'Width' = 600; }
$selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }



$base_url = 'http://www.expedia.com/'
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
# set_timeouts ([ref]$selenium)


[string]$hotel_selector = 'li.hotels'
[object]$hotel_element =  find_element -css_selector $hotel_selector
highlight ([ref]$selenium) ([ref]$hotel_element)
[NUnit.Framework.Assert]::AreEqual('Hotels',$hotel_element.Text)

$hotel_element.Click()
Start-Sleep -Seconds 3

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100



[string]$calendar_selector = 'a.calendar-button'
[object]$calendar_element =  find_element -css_selector $calendar_selector
highlight ([ref]$selenium) ([ref]$calendar_element)


[NUnit.Framework.StringAssert]::Contains('Today',$calendar_element.Text,{})

$calendar_element.Click()

Start-Sleep -Seconds 4


[string]$calendar_today_selector = 'td#a-calendar-today'
[object]$calendar_today_element =  find_element -css_selector $calendar_today_selector
highlight ([ref]$selenium) ([ref]$calendar_today_element)

[NUnit.Framework.Assert]::IsTrue($calendar_today_element.Text -match 'Check-in')
Write-Output ('Check-in = {0}' -f (($calendar_today_element.Text -split "`n")[0]))

# Remember cell position 
$data_id = $calendar_today_element.GetAttribute('data-id')

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100


[string]$calendar_today_xpath = ("//td[@class= 'selected'][@data-id != '{0}']" -f $data_id)
Write-Output ('Trying XPath "{0}"' -f $calendar_today_xpath)

[object]$calendar_today_element =  find_element -xpath $calendar_today_xpath
highlight ([ref]$selenium) ([ref]$calendar_today_element)

$csspath = 'td.selected'
[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))

if ($elements -ne $null) {
  Write-Output 'Iterate directly...'
  $elements | ForEach-Object { $element3 = $_
    if (($element3.Text -ne $data_id)) {
      $element5 = $element3
    }
    $cnt++
  }
}
if ($element5 -ne $null) {
  [NUnit.Framework.Assert]::IsTrue(($element5 -ne $null))
  [NUnit.Framework.Assert]::IsTrue(($element5.Displayed))
  [NUnit.Framework.Assert]::IsTrue(($element5.GetAttribute('data-id') -gt 0))
  Write-Output ('Check-out = {0}' -f (($element5.Text -split "`n")[0]))
} else {
  throw 'Failed to find check-out date'
}
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100

$csspath1 = 'div#calendar'


try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath1)))

} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath1))

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
$csspath2 = 'button'

try {

  [OpenQA.Selenium.IWebElement]$element2 = $element1.FindElement([OpenQA.Selenium.By]::CssSelector($csspath2))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[NUnit.Framework.Assert]::IsTrue($element2.Text -match 'Done')
$element2.Click()


[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100

$csspath = 'input#a-city'

try {


  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
[NUnit.Framework.Assert]::IsTrue($element.GetAttribute('placeholder') -match 'City')

$element.SendKeys('Miami')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

[void]$actions.SendKeys($element,[OpenQA.Selenium.Keys]::Enter)
# Write-Output ('Check-in = {0}' -f (($element.GetAttribute -split "`n")[0]))
Start-Sleep -Seconds 1


try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $csspath = 'a[data-type="HOTEL"]'
  [OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

Start-Sleep -Seconds 1

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
$element.Text
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Miami International Airport Hotel')

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Build().Perform()
[void]$actions.SendKeys($element,[OpenQA.Selenium.Keys]::Space)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

try {
  $element.Click() }
catch [exception]{
  #  Exception calling "Click" with "0" argument(s): "timeout: Timed out receiving message from renderer: 0.000

}

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
$csspath = 'button#a-searchBtn'
try {

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($csspath)))

} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

Start-Sleep -Seconds 3

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Search')

Write-Output ('Highlighting element: {0} text={1}' -f $element.TagName,$element.Text)
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: #CC6600; border: 4px solid #CC3300;')
Start-Sleep 3
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.SendKeys($element,[OpenQA.Selenium.Keys]::Space)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
# $element.Click()


Start-Sleep -Seconds 50
# Cleanup
cleanup ([ref]$selenium)




