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
  [int]$version,# unused
  [switch]$all,
  [int]$maxitems = 1000,
  [string]$base_url = 'https://www.indiegogo.com/explore#',
  [switch]$savedata,
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

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

# Actual action .
$script_directory = Get-ScriptDirectory

Write-Output 'Explore'
$selenium.Navigate().GoToUrl($base_url)


[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
0..10 | ForEach-Object {
  Write-Output ('{0} iteration' -f $_)

  $project_cards_selector = 'div[class="i-project-cards"]'
  [object]$project_cards_containter_element = find_element_new -css_selector $project_cards_selector
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_cards_containter_element).Build().Perform()
  highlight ([ref]$selenium) ([ref]$project_cards_containter_element)

  $project_card_selector = 'div[class*="i-project-card"]'
  [object[]]$project_card_elements = $project_cards_containter_element.FindElements([OpenQA.Selenium.By]::CssSelector($project_card_selector))

  Write-Output ('{0} project card found' -f $project_card_elements.count)
  $project_card_elements | ForEach-Object {
    $project_card_element = $_
    [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_card_element).Build().Perform()
    Write-Output $project_card_element.Text
    Write-Output '----'
    highlight ([ref]$selenium) ([ref]$project_card_element)
  }

  $project_show_more_selector = 'div[explore-show-more-www=""]'

  [object]$project_show_more_element = find_element_new -css_selector $project_show_more_selector
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_show_more_element).Build().Perform()
  highlight ([ref]$selenium) ([ref]$project_show_more_element)
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_show_more_element).Click().Build().Perform()

  Start-Sleep 10
}

Start-Sleep 120


# Cleanup
cleanup ([ref]$selenium)
