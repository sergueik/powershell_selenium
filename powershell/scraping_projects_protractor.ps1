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
  [string]$base_url = 'https://www.indiegogo.com/explore#',
  [switch]$savedata,
  [switch]$grid,
  [switch]$pause
)

# Setup 
$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Protractor.dll',
  'nunit.framework.dll'
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid -shared_assemblies $shared_assemblies

} else {
  $selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies

}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
$titles = @{}
# Actual action .
$script_directory = Get-ScriptDirectory

$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$area = 'technology'

Write-Output ('Explore {0}' -f $area)
$area_xpath = ('//a[@href="/explore/{0}"]' -f $area)


[object]$area_link_element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($area_xpath))
$area_link_element.getAttribute('innerHTML')
[void]$actions.MoveToElement($area_link_element).Build().Perform()
highlight ([ref]$selenium) ([ref]$area_link_element)
try {
  $area_link_element.Click()
} catch [exception]{
  # Exception calling "Click" with "0" argument(s): "Element is not currently visible and so may not be interacted with"

}
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].click();",$area_link_element)
Start-Sleep 4
[NUnit.Framework.StringAssert]::Contains(('explore/{0}' -f $area),$selenium.url)


[Protractor.NgWebDriver]$ng_driver = New-Object Protractor.NgWebDriver ($selenium)

0..10 | ForEach-Object {
  Write-Output ('{0} iteration' -f $_)


  $rows = $ng_driver.FindElements([Protractor.NgBy]::Repeater("campaignRow in explore.campaignRows"))
  $rows | ForEach-Object {
    $row = $_
    [OpenQA.Selenium.IWebElement]$row_element = $row.WrappedElement
    $cols = $row.FindElements([Protractor.NgBy]::Repeater("campaign in campaignRow"))
    $cols | ForEach-Object {
      $col = $_
      [OpenQA.Selenium.IWebElement]$col_element = $col.WrappedElement

      $header_selector = 'a[class *="i-category-header"] span[class="ng-binding"]'
      [object]$header_element = $col_element.FindElement([OpenQA.Selenium.By]::CssSelector($header_selector))
      if ($header_element.Text -match 'TECHNOLOGY') {
        # Write-Output ("---`n{0}`n---" -f $header_element.Text) 
        [void]$actions.MoveToElement($col_element).Build().Perform()

        $project_selector = 'div[class*="i-project-card"] a[class="i-project"] div[class="i-content"]'

        [object]$project_element = $col_element.FindElement([OpenQA.Selenium.By]::CssSelector($project_selector))

        $project_title = $null
        $capturing_match_expression = '(?<firstitem>.+)\r?\n'
        extract_match -Source $project_element.Text -capturing_match_expression $capturing_match_expression -label 'firstitem' -result_ref ([ref]$project_title)

        # $project_title = $project_element.Text
        if (-not $titles.ContainsKey($project_title)) {
          $titles.Add($project_title,$null)
          highlight ([ref]$selenium) ([ref]$project_element)
          $href_selector = 'a[class*="i-project"][href^="/projects/"]'
          [object]$href_element = $col_element.FindElement([OpenQA.Selenium.By]::CssSelector($href_selector))
          $project_href = $href_element.GetAttribute('href') 
          $titles[$project_title] = $project_href 
          Write-Output ("---`n{0}`n{1}`n---" -f $project_title, $project_href)

        }
      }
    }
  }

  $project_show_more_selector = 'div[explore-show-more-www=""]'

  [object]$project_show_more_element = find_element -css_selector $project_show_more_selector
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_show_more_element).Build().Perform()
  highlight ([ref]$selenium) ([ref]$project_show_more_element)
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_show_more_element).Click().Build().Perform()

  Start-Sleep 10
}

# Cleanup
cleanup ([ref]$selenium)
