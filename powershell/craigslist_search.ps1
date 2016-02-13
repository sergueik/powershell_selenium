#Copyright (c) 2016 Serguei Kouzmine
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
  [string]$base_url = 'https://miami.craigslist.org/search/cps',
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
  start-sleep -millisecond 500
}

$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)



[string]$query_css_selector = "input#query"
[string]$query_data = $query = 'Designer'
[object]$query_element = find_element -css_selector $query_css_selector
highlight ([ref]$selenium) ([ref]$query_element)
$query_element.Clear()
$query_element.SendKeys($query_data)

[string]$searchicon_css_selector = "#searchform > div.rightpane > div.querybox > button > span.searchicon"
[object]$searchicon_button_element = find_element -css_selector $searchicon_css_selector
highlight ([ref]$selenium) ([ref]$searchicon_button_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$searchicon_button_element).Click().Build().Perform()


  $project_cards_selector = 'body.search.desktop.list section#pagecontainer form#searchform'
  [object]$project_cards_containter_element = find_element -css_selector $project_cards_selector
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_cards_containter_element).Build().Perform()
  highlight ([ref]$selenium) ([ref]$project_cards_containter_element)


  $project_card_selector = 'div.content a.hdrlnk'
  [object[]]$project_card_elements = $project_cards_containter_element.FindElements([OpenQA.Selenium.By]::CssSelector($project_card_selector))
  $projects = @()
  $max_count = 3 
  $count = 0
  Write-Output ('{0} project card found' -f $project_card_elements.count)
  $project_card_elements | ForEach-Object {
    $count ++ 
    if ($count -gt $max_count ) { return }
    $project_card_element = $_
    [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_card_element).Build().Perform()
    Write-Output $project_card_element.Text
    Write-Output $project_card_element.GetAttribute('href')
    Write-Output '----'
    highlight ([ref]$selenium) ([ref]$project_card_element)
    $projects += @{'title' = $project_card_element.Text ; 'url' = $project_card_element.GetAttribute('href') }
  }


$projects | foreach-object { 

$project = $_ 

    Write-Output $project['title']
    Write-Output $project['url']
    $selenium.Navigate().GoToUrl($project['url'])

    'section#pagecontainer section.body header.dateReplyBar button.reply_button'
    # wait
 }
# https://miami.craigslist.org/mdc/cps/5386568039.html
custom_pause -fullstop $fullstop
# Cleanup
cleanup ([ref]$selenium)
