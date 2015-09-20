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
  [switch]$grid,
  [switch]$pause
)

$verificationErrors = New-Object System.Text.StringBuilder

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

$DebugPreference = 'Continue'

$base_url = 'http://www.carnival.com'

$selenium.Navigate().GoToUrl($base_url + '/')

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

Write-Output ('Started with {0}' -f $selenium.Title)


$selenium.Manage().Window.Maximize()


function select_first_option {
  param([string]$choice = $null,
    [string]$label = $null
  )

  $select_name = $choice

  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500

  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)

  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 500

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  # TODO the css_selector needs refactoring

  $select_value_css_selector = ('div[class=option][data-param={0}] div.scrollable-content div.viewport div.overview ul li a' -f $select_name)
  $value_element = $null
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found...'
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null

  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  $value_element = $null

  $actions2 = $null
  Start-Sleep -Milliseconds 500



}
function select_criteria {

  param([string]$choice = $null,
    [string]$label = $null,
    [string]$option = $null,
    [System.Management.Automation.PSReference]$choice_value_ref = ([ref]$null),
    [string]$value = $null # note formatting

  )

  $select_name = $choice

  if ($value) {
    $selecting_value = $value
  } else {
    Write-Output ('"{0}"' -f $option)
    $selecting_value = $choice_value_ref.Value[$option]
    Write-Output $selecting_value
  }
  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500
  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)
  $select_element.Click()
  Start-Sleep -Milliseconds 500
  $select_element = $null



  $select_value_css_selector = ('div[class=option][data-param={0}] a[data-id={1}]' -f $select_name,$selecting_value)
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))

  $wait.PollingInterval = 150

  $value_element = $null
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found value_element...'
    $value_element
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))

  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $wait = $null
  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  Start-Sleep -Milliseconds 500
  $wait = $null
  $actions2 = $null
  $value_element = $null

}

function search_cruises {
  $css_selector1 = 'div.actions > a.search'
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  [NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'SEARCH'))
  Write-Output ('Clicking on ' + $element1.Text)
  $element1.Click()
  $element1 = $null


}
function count_cruises {
  param(
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)
  )

  $css_selector1 = "li[class*=num-found] strong"

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 500
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  Write-Output ('Found ' + $element1.Text)
  $result_ref.Value = $element1.Text

}


# TODO :finish parameters
$fullstop = (($PSBoundParameters['pause']) -ne $null)

# Actual action .

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
# assert element has 'initialized'  and 'hover'  class attribute

$value_element1 = $null
Start-Sleep -Milliseconds 1500

$xpath_template = '//*[@id="ccl-refresh-header"]/DIV[2]/DIV[1]/DIV[1]/DIV[2]/UL[1]/LI[{0}]/A[1]/SPAN[1]/IMG[1]'

@( 1,2,3,4,5,6) | ForEach-Object { $link_count = $_;

  $image = $null
  $image = find_element -xpath ($xpath_template -f $link_count)
  # $image = $null
  # find_page_element_by_xpath ([ref]$selenium) ([ref]$image) ($xpath_template -f $link_count)
  highlight ([ref]$selenium) ([ref]$image)
  @( 'alt','src') | ForEach-Object {
    $attr = $_
    Write-Output ('{0} = {1}' -f $attr,$image.GetAttribute($attr))
  }
}


$alt_texts = @( 'Onboard Activities','Dining','Accommodations','Our Ships','Shore Excursions')

$alt_texts | ForEach-Object { $link_alt_text = $_;

  $css_selector = ('img[alt="{0}"]' -f $link_alt_text)
#  $image = $null
#  find_page_element_by_css_selector ([ref]$selenium) ([ref]$image) $css_selector

  $image = $null
  $image = find_element -css $css_selector

  highlight ([ref]$selenium) ([ref]$image)
  @( 'alt','src') | ForEach-Object {
    $attr = $_
    Write-Output ('{0} = {1}' -f $attr,$image.GetAttribute($attr))
  }
}
<#
$src_files = @('snorkel%20png.ashx','plate%20png.ashx', 'bed%20png.ashx', 'microphone%20png.ashx', 'ship%20png.ashx' , 'map%20png.ashx')

$src_files  | foreach-object { $src_file = $_;

$css_selector = ('img[src*="{0}"]' -f $src_file)
$image= $null

find_page_element_by_css_selector ([ref]$selenium) ([ref]$image) $css_selector
highlight ([ref]$selenium) ([ref]$image)
@( 'alt','src') | ForEach-Object {
  $attr = $_
  Write-Output ('{0} = {1}' -f $attr,$image.GetAttribute($attr))
}
}
#>

# Continue with 
$link_alt_text = 'Shore Excursions'
$css_selector = ('img[alt="{0}"]' -f $link_alt_text)


# $value_element2 = $null
# find_page_element_by_css_selector ([ref]$selenium) ([ref]$value_element2) $css_selector

$value_element2 = $null
$value_element2 = find_element -css $css_selector

[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element2).Click().Build().Perform()
$value_element2 = $null

custom_pause -fullstop $fullstop
# At the end of the run - do not close Browser / Selenium when executing from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
