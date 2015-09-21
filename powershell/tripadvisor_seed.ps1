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
  [string]$base_url = 'http://www.tripadvisor.com/',
  [int]$max_pages = 3,
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
  Start-Sleep -Millisecond 500
} else {
  $selenium = launch_selenium -browser $browser
}

$selenium.Navigate().GoToUrl($base_url)

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

write-output 'Input main search'
$password = 'restaurant'
[string]$login_password_selector = "input#mainSearch"
[string]$login_password_data = $password
[object]$login_password_element = find_element -css_selector $login_password_selector
highlight ([ref]$selenium) ([ref]$login_password_element)
$login_password_element.Clear()

$login_password_element.SendKeys($login_password_data)


write-output 'Input search of interest'
$username = 'Prague, Czech Republic, Europe'
[string]$login_username_selector = "input[id='GEO_SCOPED_SEARCH_INPUT']"
[string]$login_username_data = $username + [OpenQA.Selenium.Keys]::Enter
# [OpenQA.Selenium.Keys]::Tab +
[object]$login_username_element = find_element -css_selector $login_username_selector
highlight ([ref]$selenium) ([ref]$login_username_element)
$login_username_element.Clear()
$login_username_element.SendKeys($login_username_data)

Start-Sleep -Millisecond 100


[string]$div_geoscoped_selector = "div[id='GEO_SCOPE_CONTAINER'] > div[class *='geoScopeDisplay']"
[object]$div_geoscoped_element = find_element -css_selector $div_geoscoped_selector

# highlight ([ref]$selenium) ([ref]$div_geoscoped_element)


# $div_geoscoped_element.GetAttribute('innerHTML') 
<#
<ul class="resultContainer">
  <li class="displayItem result selected">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Prague</span>
    <span class="geo-name secondaryText">Czech Republic, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Bohemia</span>
    <span class="geo-name secondaryText">Czech Republic, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Czech Republic</span>
    <span class="geo-name secondaryText">Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Republic of Macedonia</span>
    <span class="geo-name secondaryText">Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Republic of Tatarstan</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Republic of Bashkortostan</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Republic of Buryatia</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Republic of Karelia</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Udmurt Republic</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Chuvash Republic</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Sakha (Yakutia) Republic</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
  <li class="displayItem result">
    <div class="sprite-image leftIcon sprite-typeahead-destination"/>
    <span class="poi-name primaryText">Republic of Altai</span>
    <span class="geo-name secondaryText">Russia, Europe</span>
  </li>
</ul>

#>
Start-Sleep -Millisecond 1000


# $element_css_selector = "span[class='poi-name']"
$element_css_selector = "li[class*='displayItem'][class *= 'result']"
$elements = $div_geoscoped_element.FindElements([OpenQA.Selenium.By]::CssSelector($element_css_selector))
$elements.count
$max_count = 10
$element_count = 0
$element_found = $false
$elements | ForEach-Object {
  $element_count++
  if ($element_found -or ($element_count -gt $max_count)) {
    return
  }

  $element = $_
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Build().Perform()

  highlight_new -element $element
  Start-Sleep -Millisecond 100
  $element.Text
  if ($element.Text -match 'Bohemia') {
    [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
    write-output 'Selected point ot interest'
    $element_found = $true
    return
  }
}

write-output 'Search'
[string]$login_submit_selector = "button[id='SEARCH_BUTTON']"
[object]$login_submit_element = find_element -css_selector $login_submit_selector
highlight ([ref]$selenium) ([ref]$login_submit_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_submit_element).Click().Build().Perform()
Start-Sleep -Millisecond 3000
write-output 'Search results'
[NUnit.Framework.StringAssert]::Contains('/Restaurants',$selenium.url,{})
[NUnit.Framework.StringAssert]::Contains('Bohemia',$selenium.url,{})

# div#EATERY_SEARCH_RESULTS a.property_title
custom_pause -fullstop $fullstop

Start-Sleep -Millisecond 10000

cleanup ([ref]$selenium)
