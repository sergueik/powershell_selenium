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
  [string]$browser,
  [string]$hub_host = '127.0.0.1',
  [string]$hub_port = '4444'
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port

# http://mikaelkoskinen.net/post/kendoui-dataviz-tips-and-tricks
$base_url = 'http://demos.telerik.com/kendo-ui/bar-charts/column'

$base_url = ('file:///{0}\{1}' -f (Get-ScriptDirectory),'../assets/barchart.html') -replace '\\','/'

Write-Output $base_url

$verificationErrors = New-Object System.Text.StringBuilder

# http://www.w3schools.com/xpath/xpath_axes.asp

$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
Start-Sleep 3


$element = $null
$css_selector = 'div#chart svg'

find_page_element_by_css_selector ([ref]$selenium) ([ref]$element) $css_selector
# highlight ([ref]$selenium) ([ref]$element )
$result = get_xpath_of ([ref]$element)
# next : path
Write-Output ('Javascript-generated XPath = "{0}"' -f $result)
$path_css_selector = 'path[fill = "#fff"]'
$paths = $element.FindElements([OpenQA.Selenium.By]::CssSelector($path_css_selector))
$delay = 2000
Start-Sleep 1
$paths | ForEach-Object {
  $path_element = $_
  Write-Output ('{{X = {0}; Y = {1}}}' -f $path_element.Location.X,$path_element.Location.Y)
  $result = get_css_path_of ([ref]$path_element)
  Write-Output ('CSS "{0}"' -f $result)
  $assert_element = $null
  find_page_element_by_css_selector ([ref]$selenium) ([ref]$assert_element) $result

  Write-Output $assert_element.GetAttribute('fill')

  $result = get_xpath_of ([ref]$path_element)

  Write-Output ('XPath "{0}"' -f $result)


  # fails.
  $assert_element = $null
  try {
    find_page_element_by_xpath ([ref]$selenium) ([ref]$assert_element) $result
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('fill', arguments[1]);",$path_element,'#AAA')
  Start-Sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('fill', arguments[1]);",$path_element,'#fff')
  Write-Output $path_element.GetAttribute('fill')
  Start-Sleep -Millisecond $delay



}

# Cleanup
cleanup ([ref]$selenium)

