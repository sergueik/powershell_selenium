#Copyright (c) 2014,15 Serguei Kouzmine
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
  [switch]$grid,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}


$base_url = 'http://www.seabourn.com/'

$selenium.Navigate().GoToUrl($base_url )


[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(360))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("sbn-logo")))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element0 = $selenium.FindElement([OpenQA.Selenium.By]::ClassName("sbn-logo"))
Write-Output ('Logo: ' + $element0.GetAttribute('alt'))

[NUnit.Framework.Assert]::IsTrue(($selenium.Title -match 'Seabourn'))
Write-Output $selenium.Title


function hover_menus {
  param([string]$value0,
    [bool]$pause)
  if ($value0 -eq '' -or $value0 -eq $null) {
    return
  }
  $css_selector0 = ('a#{0}' -f $value0)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector0)
  }

  $element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

  [OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  Start-Sleep -Millisecond 50
  Write-Output ('Hovering over ' + $element0.GetAttribute('title'))
  $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element0).Build().Perform()

  if ($pause) {
    Write-Output 'pause'
    try {
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Write-Output 'no pause'
    Start-Sleep -Millisecond 1000

  }
}

function click_menu {
  param(
    [string]$value0,
    [bool]$nested,
    [bool]$pause
  )
  if ($value0 -eq '' -or $value0 -eq $null) {
    return
  }
  $css_selector0 = ('a#{0}' -f $value0)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector0)
  }

  $element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

  [OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

  Write-Output ('Clicking over ' + $element0.GetAttribute('title'))
  $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element0).Click().Build().Perform()
  Start-Sleep -Millisecond 50
  if ($nested) { 
    explore_portaction
  }  
  if ($pause) {
    Write-Output 'pause'
    try {
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Write-Output 'no pause'
    Start-Sleep -Millisecond 1000
  }

}
# Explore Cruise Ports 
# http://www.seabourn.com/luxury-cruise-destinations/Ports.action?WT.ac=pnav_planPorts 

$base_url = 'http://www.seabourn.com/'
$selenium.Navigate().GoToUrl($base_url )
[bool]$pause = $false
if ($PSBoundParameters['pause']) {
  $pause = $true
} else {
  $pause = $false
}

function explore_portaction {

  Write-Output ('Title: {0}' -f $selenium.Title)
  $explicit = 10
  [void]($selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))


  $text1 = 'Pacific Northwest & Pacific Coast'

  $value0 = 'destinationsbox'
  $value0 = 'CruiseFinderDestinationSelectbox'

  $css_selector0 = ('select#{0}' -f $value0)
  $xpath0 = ('//select[@id="{0}"]' -f $value0)
  write-output ('finding {0}' -f $css_selector0 ) 
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 50

  try {
    $element =  $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector0)
  }
   write-output 'xxx1'
  $element
  write-output ('finding {0}' -f $xpath0 ) 
  try {
    $element =  $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath0)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector0)
  }

   write-output 'xxx2'
  $element
  [OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))
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

}


#  hover_menus -value0 'pnav-planACruise' -pause $pause

click_menu -value0 'pnav-planACruise' -nested $true -pause $pause
click_menu -value0 'pnav-planACruise' -nested $false  -pause $pause
explore_portaction
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
