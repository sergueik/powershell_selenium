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
[object]$dates_element = find_element_new -css_selector $dates_selector
highlight ([ref]$selenium) ([ref]$dates_element)

# Select Checkin Month day
[string]$checkin_day_selector = "form#frm div[data-type='checkin'] div[class *='b-date-selector__control-dayselector'] select[class='b-selectbox__element']"
[object]$checkin_day_element = find_element_new -css_selector $checkin_day_selector
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
    $select_element.SelectByIndex($index)
    # Start-Sleep -Milliseconds 100
  } 
  $index++
}
$select_element.SelectByIndex($target_index)
$select_element = $null
Start-Sleep 1

# Select Checkin  Year, Month
[string]$checkin_month_selector = "form#frm div[data-type='checkin'] div[class *='b-date-selector__control-monthselector'] select[class='b-selectbox__element']"
[object]$checkin_month_element = find_element_new -css_selector $checkin_month_selector
highlight ([ref]$selenium) ([ref]$checkin_month_element)
Start-Sleep 1
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($selenium.FindElement([OpenQA.Selenium.By]::CssSelector($checkin_month_selector)))
$select_element.SelectByText('November 2015')
$select_element = $null

Start-Sleep 1


# Select Checkout Month day
[string]$checkout_day_selector = "form#frm div[data-type='checkout'] div[class *='b-date-selector__control-dayselector'] select[class='b-selectbox__element']"
[object]$checkout_day_element = find_element_new -css_selector $checkout_day_selector
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

Start-Sleep 1

# Select Checkout Year, Month
[string]$checkout_month_selector = "form#frm div[data-type='checkout'] div[class *='b-date-selector__control-monthselector'] select[class='b-selectbox__element']"
[object]$checkout_month_element = find_element_new -css_selector $checkout_month_selector
highlight ([ref]$selenium) ([ref]$checkout_month_element)
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($selenium.FindElement([OpenQA.Selenium.By]::CssSelector($checkout_month_selector)))
$select_element.SelectByText('November 2015')
$select_element = $null

Start-Sleep 1

# Select City
[string]$city_state_selector = "form#frm input#destination"
[string]$city_state_data = 'Flagstaff, AZ'
[object]$city_state_element = find_element_new -css_selector $city_state_selector
highlight ([ref]$selenium) ([ref]$city_state_element)
$city_state_element.Clear()
$city_state_element.SendKeys($city_state_data)

# TODO: Select travelling type
# form#frm.flexible_group_searchbox_justbox fieldset div.b-form-group.b-form__booker-type.b-form__booker-type--index div.b-form-group__content div.b-form-group-content__container.b-travel-purpose.b-form__booker-type--emphasized label.b-booker-type.b-booker-type--leisure.b-travel-purpose__label.b-travel-purpose__label--inline.b-travel-purpose__label--spacing.tracked input.b-booker-type__input.b-booker-type__input_leisure-booker

[string]$search_submit_selector = "form#frm button[class *='b-searchbox-button']"
[object]$search_submit_element = find_element_new -css_selector $search_submit_selector
highlight ([ref]$selenium) ([ref]$search_submit_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$search_submit_element).Click().Build().Perform()
Start-Sleep 3
Write-Output 'Starting search for hotels'





[string]$destination_name_selector = "div#cityWrapper div[class *='disambitem'] div.disname a[class *='destination_name']"
[object]$destination_name_element = find_element_new -css_selector $destination_name_selector
highlight ([ref]$selenium) ([ref]$destination_name_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$destination_name_element).Click().Build().Perform()
Start-Sleep 10

# Cleanup
cleanup ([ref]$selenium)
