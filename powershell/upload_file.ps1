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
  [string]$hub_port = '4444',
  [switch]$grid,
  [switch]$pause

)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies
# $selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
  Start-Sleep -Millisecond 500
} else {
  $selenium = launch_selenium -browser $browser
}

$base_url = 'http://www.freetranslation.com/'
$selenium.Navigate().GoToUrl($base_url)
[void]$selenium.Manage().Window.Maximize()

# Wait for page logo / title 
$element_title = 'Translate text, documents and websites for free'
$css_selector = 'a.brand'
$element = find_element -css_selector $css_selector

[NUnit.Framework.Assert]::IsTrue($element.GetAttribute('title') -match $element_title)
$element.GetAttribute('title')

$text = 'good morning driver'
Write-Host ('Translating: "{0}"' -f $text)
$text_file = [System.IO.Path]::Combine((Get-ScriptDirectory),'testfile.txt')
Write-Output $text | Out-File -FilePath $text_file -Encoding ascii


$upload_button = $null
$css_selector = ('div[id = "{0}"]' -f 'upload-button')
$upload_button = find_element -css_selector $css_selector
highlight_new -element $upload_button -Delay 1500

# Populate upload input
$upload_element = find_element -classname 'ajaxupload-input'
highlight_new -element $upload_element -Delay 1500

Write-Host ('Uploading the file "{0}".' -f $text_file)
# https://searchcode.com/codesearch/view/51339609/
# https://selenium.googlecode.com/git/docs/api/dotnet/html/T_OpenQA_Selenium_Remote_LocalFileDetector.htm
# http://www.whatisthis.top/questions/3270474/how-to-upload-image-to-web-page-in-saucelabs-test-by-selenium-in-c
# use Vagrant box-hosted Selenium for testing this feature
[OpenQA.Selenium.Remote.LocalFileDetector]$local_file_detector = new-object OpenQA.Selenium.Remote.LocalFileDetector
# parenthesis required
([OpenQA.Selenium.IAllowsFileDetection]$selenium).FileDetector  = $local_file_detector
$upload_element.SendKeys($text_file)
# hard wait
Start-Sleep 2

$element_text = 'Download'
$classname = 'gw-download-link'
$element1 = find_element -classname $classname 
[NUnit.Framework.Assert]::IsTrue($element1.Text -match $element_text)

$css_selector = 'div [class="status-text"] img[class *= "gw-icon"]'
$element2 = find_element -css_selector $css_selector
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$element2) -Delay 3000

$text_url = $element1.GetAttribute('href')
write-host 'This version performs the direct upload of the translated text'

Write-Host ('Reading "{0}"' -f $text_url)

$result = Invoke-WebRequest -Uri $text_url
$result_body = $result.ToString() -join '`r`n'

$transalted_text = $null
$capturing_match_expression = '^(?<all>.+)$'
extract_match -Source $result_body -capturing_match_expression $capturing_match_expression -label 'all' -result_ref ([ref]$transalted_text)
[NUnit.Framework.Assert]::IsTrue(($transalted_text -match 'Bonjour Driver'))
write-host 'Verified translation.'

cleanup ([ref]$selenium)
