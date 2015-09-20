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
  [string]$base_url = 'https://www.freelancer.com',
  [string]$username = 'kouzmine_serguei@yahoo.com',
  [string]$password,
  [string]$secret = 'moscow',
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)

if ($password -eq '' -or $password -eq $null) {
  Write-Output 'Please specify password.'
  return
}
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

[string]$login_css_selector = "span[id='new-nav'] button[id='login-normal']"
[object]$login_button_element = find_element_new -css_selector $login_css_selector

highlight ([ref]$selenium) ([ref]$login_button_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_button_element).Click().Build().Perform()

Write-Output 'Log in'

[string]$login_div_selector = "form[id='login-form']"
[object]$login_div_element = find_element_new -css_selector $login_div_selector
highlight ([ref]$selenium) ([ref]$login_div_element)

[string]$login_username_selector = "form[id='login-form'] input.username"
[string]$login_username_data = $username

[object]$login_username_element = find_element_new -css_selector $login_username_selector
highlight ([ref]$selenium) ([ref]$login_username_element)
$login_username_element.Clear()
$login_username_element.SendKeys($login_username_data)



[string]$login_password_selector = "form[id='login-form'] input.password"
[string]$login_password_data = $password
[object]$login_password_element = find_element_new -css_selector $login_password_selector
highlight ([ref]$selenium) ([ref]$login_password_element)
$login_password_element.Clear()

$login_password_element.SendKeys($login_password_data)



[string]$login_submit_selector = "form[id='login-form'] button[id='login-bt']"
[object]$login_submit_element = find_element_new -css_selector $login_submit_selector
highlight ([ref]$selenium) ([ref]$login_submit_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_submit_element).Click().Build().Perform()

$wait_seconds = 10
$wait_polling_interval = 300
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
$wait.PollingInterval = $wait_polling_interval

[string]$profile_figure_selector = "figure[id='profile-figure'][class='profile-img']"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($profile_figure_selector)))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`ncss = '{1}'" -f (($_.Exception.Message) -split "`n")[0],$profile_figure_selector)
}
[object]$profile_figure_element = find_element_new -css_selector $profile_figure_selector

highlight ([ref]$selenium) ([ref]$profile_figure_element)
[NUnit.Framework.StringAssert]::Contains('www.freelancer.com/dashboard/',$selenium.url,{})
Start-Sleep -Millisecond 1000

1..2 | ForEach-Object {
  $page_count = $_
  Write-Host "Page count: ${page_count}"

  $selenium.Navigate().GoToUrl(('{0}/jobs/myskills/{1}/' -f $base_url,$page_count))

  [NUnit.Framework.StringAssert]::Contains(('{0}/jobs/myskills/{1}/' -f $base_url,$page_count),$selenium.url,{})

  [string]$project_table_selector = "table[id=project_table]"
  [object]$project_table_element = find_element_new -css_selector $project_table_selector
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_table_element).Build().Perform()

  highlight ([ref]$selenium) ([ref]$project_table_element)



  [string]$project_selector = "tr[class='project-description']"

  $project_elements = $project_table_element.FindElements([OpenQA.Selenium.By]::CssSelector($project_selector))


  $project_elements.Count
  # $project_elements[0].getAttribute('innerHTML')
  # $project_elements[0]
  $project_elements | ForEach-Object {
    $project_element = $_
    [string]$project_synopsis_selector = 'div[class="project-synopsis"]'
    $project_synopsis_element = $project_element.FindElement([OpenQA.Selenium.By]::CssSelector($project_synopsis_selector))
    $project_synopsis_text = ($project_synopsis_element.getAttribute('innerHTML') -join '')
    $project_synopsis_text = $project_synopsis_text -replace '<p>','' -replace '</p>','' -replace '<p class=".*" style=".*">','' -replace '\r?\n',' ' -replace ' +',' ' -replace '^ +',''
    Write-Host -ForegroundColor 'yellow' $project_synopsis_text
    # makes browser unstable
    #  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_synopsis_element).Build().Perform()

    [string]$project_actions_selector = 'div[class="project-actions"] a'
    $project_actions_element = $project_element.FindElement([OpenQA.Selenium.By]::CssSelector($project_actions_selector))
    Write-Host -ForegroundColor 'green' $project_actions_element.getAttribute('href')

  }

  # next page

  [string]$pagination_selector = "div[class*='dataTables_paginate']"
  [object]$pagination_element = find_element_new -css_selector $pagination_selector
  highlight ([ref]$selenium) ([ref]$pagination_element)
  Start-Sleep -Millisecond 1000

  [string]$project_next_page_selector = "div[class*='dataTables_paginate'] li[class*='next']"
  [object]$project_next_page_element = find_element_new -css_selector $project_next_page_selector
  highlight ([ref]$selenium) ([ref]$project_next_page_element)
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_next_page_element).Click().Build().Perform()
  Start-Sleep -Millisecond 1000


}

Start-Sleep -Millisecond 1000
[string]$profile_figure_selector = "figure[id='profile-figure'][class='profile-img']"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($profile_figure_selector)))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`ncss = '{1}'" -f (($_.Exception.Message) -split "`n")[0],$profile_figure_selector)
}
[object]$profile_figure_element = find_element_new -css_selector $profile_figure_selector

highlight ([ref]$selenium) ([ref]$profile_figure_element)

[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$profile_figure_element).Click().Build().Perform()
# TODO - click on logut



$selenium.Navigate().GoToUrl("{0}/users/onsignout.php" -f $base_url)
Start-Sleep -Millisecond 1000

# a class="primary-navigation-link is-active" ng-mouseenter="trackHover(navItem)" fl-analytics="MySkillsProjects" target="" ng-class="{ 'is-active': navItem.isCurrent }" ng-href="/jobs/myskills/1/" href="/jobs/myskills/1/"
# g-include class="ng-scope" src="templateDir + '/' + subNavItem.id + '.html'">
# <span class="ng-scope" i18n-id="3e50c7ab20ebe01229fc00e47250ca32" i18n-msg="Browse Projects">Browse Projects</span>
# https://www.freelancer.com/jobs/myskills/1/
cleanup ([ref]$selenium)
