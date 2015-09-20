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
  [string]$base_url = 'http://www.booking.com',
  [string]$city = 'Flagstaff',
  [string]$state = 'AZ',
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies


if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser
  Start-Sleep -Millisecond 500
}

$selenium.Navigate().GoToUrl($base_url)

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

[string]$dates_selector = "div [class='b-form__dates b-form-group']"
[object]$dates_element = find_element -css_selector $dates_selector
highlight ([ref]$selenium) ([ref]$dates_element)

Write-output 'Select Checkin Month day'
[string]$checkin_day_selector = "form#frm div[data-type='checkin'] div[class *='b-date-selector__control-dayselector'] select[class='b-selectbox__element']"
[object]$checkin_day_element = find_element -css_selector $checkin_day_selector
highlight ([ref]$selenium) ([ref]$checkin_day_element)

[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($selenium.FindElement([OpenQA.Selenium.By]::CssSelector($checkin_day_selector)))

$availableOptions = $select_element.Options
$index = 0
$max_count = 100
$target_input = '10'
$target_index = 0

[bool]$found = $false
foreach ($item in $availableOptions)
{
  if ($item.Text -match $target_input) {
    $found = $true
    $target_index = $index
    # $select_element.SelectByIndex($index)
  } 
  $index++
}
$select_element.SelectByIndex($target_index)
$select_element = $null
Start-Sleep -millisecond 300

Write-output 'Select Checkin Year, Month'
[string]$checkin_month_selector = "form#frm div[data-type='checkin'] div[class *='b-date-selector__control-monthselector'] select[class='b-selectbox__element']"
[object]$checkin_month_element = find_element -css_selector $checkin_month_selector
highlight ([ref]$selenium) ([ref]$checkin_month_element)

[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($selenium.FindElement([OpenQA.Selenium.By]::CssSelector($checkin_month_selector)))
$select_element.SelectByText('November 2015')
$select_element = $null

Start-Sleep -millisecond 300


Write-output 'Select Checkout Month day'
[string]$checkout_day_selector = "form#frm div[data-type='checkout'] div[class *='b-date-selector__control-dayselector'] select[class='b-selectbox__element']"
[object]$checkout_day_element = find_element -css_selector $checkout_day_selector
highlight ([ref]$selenium) ([ref]$checkout_day_element)
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($selenium.FindElement([OpenQA.Selenium.By]::CssSelector($checkout_day_selector)))
$availableOptions = $select_element.Options
$index = 0
$max_count = 100
$target_input = '15'
$target_index = 0
[bool]$found = $false
foreach ($item in $availableOptions)
{
  if ($item.Text -match $target_input) {
    $found = $true
    $target_index = $index 
    # Start-Sleep -Milliseconds 100
  } 
  $index++
}
$select_element.SelectByIndex($target_index)
$select_element = $null
Start-Sleep -millisecond 300

Write-output 'Select Checkout Year, Month'
[string]$checkout_month_selector = "form#frm div[data-type='checkout'] div[class *='b-date-selector__control-monthselector'] select[class='b-selectbox__element']"
[object]$checkout_month_element = find_element -css_selector $checkout_month_selector
highlight ([ref]$selenium) ([ref]$checkout_month_element)
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($selenium.FindElement([OpenQA.Selenium.By]::CssSelector($checkout_month_selector)))
$select_element.SelectByText('November 2015')
$select_element = $null
Start-Sleep -millisecond 300

Write-output 'Select travelling type'
[string]$travelling_type_selector = "form#frm input[class *='b-booker-type__input'][class *='b-booker-type__input_leisure-booker']"
[object]$travelling_type_element = find_element -css_selector $travelling_type_selector
highlight ([ref]$selenium) ([ref]$travelling_type_element)
$travelling_type_element.Click()
Start-Sleep -millisecond 300

Write-output 'Select City'
[string]$city_state_selector = "form#frm input#destination"
[string]$city_state_data = ('{0}, {1}' -f $city, $state)
[object]$city_state_element = find_element -css_selector $city_state_selector
highlight ([ref]$selenium) ([ref]$city_state_element)
$city_state_element.Clear()
$city_state_element.SendKeys($city_state_data)

Write-Output 'Starting search for hotels'
[string]$search_submit_selector = "form#frm button[class *='b-searchbox-button']"
[object]$search_submit_element = find_element -css_selector $search_submit_selector
highlight ([ref]$selenium) ([ref]$search_submit_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$search_submit_element).Click().Build().Perform()
Start-Sleep -millisecond 2000

Write-Output 'Confirm the city'
# TODO: iterate over cities selecting by the text
[string]$destination_name_selector = "div#cityWrapper div[class *='disambitem'] div.disname a[class *='destination_name']"
[object]$destination_name_element = find_element -css_selector $destination_name_selector
highlight ([ref]$selenium) ([ref]$destination_name_element)
[NUnit.Framework.StringAssert]::AreEqualIgnoringCase($city, $destination_name_element.Text)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$destination_name_element).Click().Build().Perform()
Start-Sleep -millisecond 1000

# Cleanup
cleanup ([ref]$selenium)
