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

# http://winsysadm.net/
# http://weblog.west-wind.com/posts/2007/May/21/Downloading-a-File-with-a-Save-As-Dialog-in-ASPNET
param(
  [string]$browser,
  [string]$hub_host = '127.0.0.1',
  [string]$hub_port = '4444'
)


$MODULE_NAME = 'selenium_utils.psd1'

Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

load_shared_assemblies

[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port

$base_url = 'http://www.freetranslation.com/'
$selenium.Navigate().GoToUrl($base_url)

# set_timeouts ([ref]$selenium)

[void]$selenium.Manage().Window.Maximize()


$element_title = 'Translate text, documents and websites for free'
$element = $null
$css_selector = 'a.brand'
find_page_element_by_css_selector ([ref]$selenium) ([ref]$element) $css_selector

[NUnit.Framework.Assert]::IsTrue($element.GetAttribute('title') -match $element_title)
$element.GetAttribute('title')

$text = 'good morning driver'
Write-Host ('Translating: "{0}"' -f $text)
$text_file = [System.IO.Path]::Combine((Get-ScriptDirectory),'testfile.txt')
Write-Output $text | Out-File -FilePath $text_file -Encoding ascii

$upload_button = $null
$css_selector = ('div[id = "{0}"]' -f 'upload-button')
find_page_element_by_css_selector ([ref]$selenium) ([ref]$upload_button) $css_selector
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$upload_button) -Delay 1500

$upload_element = $selenium.FindElement([OpenQA.Selenium.By]::ClassName('ajaxupload-input'))
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$upload_element) -Delay 1500

Write-Host ('Uploading the file "{0}".' -f $text_file)
$upload_element.SendKeys($text_file)

Start-Sleep 2

<#
Wait until the following element is present:
<a href="..." class="gw-download-link">
  <img class="gw-icon download" src="http://d2yxcfsf8zdogl.cloudfront.net/home-php/assets/home/img/pixel.gif"/>
  Download
</a>
#>


[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))

$element_text = 'Download'
$wait.PollingInterval = 500
[OpenQA.Selenium.Remote.RemoteWebElement]$element1 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("gw-download-link")))
[NUnit.Framework.Assert]::IsTrue($element1.Text -match $element_text)


$element_title = ''
$element2 = $null
$css_selector = 'div [class="status-text"] img[class *= "gw-icon"]'
find_page_element_by_css_selector ([ref]$selenium) ([ref]$element2) $css_selector


highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$element2) -Delay 3000

$text_url = $element1.GetAttribute('href')
write-host 'This version performs the direct upload of the translated text'

Write-Host ('Reading "{0}"' -f $text_url)

$result = Invoke-WebRequest -Uri $text_url
$result | get-member
$result.RawContent
$result_body = $result.ToString() -join '`r`n'


$transalted_text = $null
$capturing_match_expression = '^(?<all>.+)$'
extract_match -Source $result_body -capturing_match_expression $capturing_match_expression -label 'all' -result_ref ([ref]$transalted_text)
[NUnit.Framework.Assert]::IsTrue(($transalted_text -match 'Bonjour Driver'))
write-host 'Verified translation.'

# Cleanup
cleanup ([ref]$selenium)
