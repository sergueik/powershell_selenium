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

# https://www.linkedin.com/pulse/some-webdriver-tips-tricks-evgeny-tkachenko

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

load_shared_assemblies
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)

# use embedded driver
<# 
# TODO - enable profile in remote browser 
# see java/browsermob_proxy/src/main/java/com/mycompany/app/App.java
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
  $capability.SetCapability([OpenQA.Selenium.Firefox.FirefoxDriver]::Profile, $profile)
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
#>

$profile_name = 'test'
$profile = New-Object OpenQA.Selenium.Firefox.FirefoxProfile

$download_path = 'c:\temp\xxx'
[void]$profile.SetPreference('browser.helperApps.neverAsk.saveToDisk','text/csv, application/pdf, application/octet-stream')
[void]$profile.SetPreference('browser.download.dir',$download_path);
[void]$profile.SetPreference('browser.download.folderList',2)
try {
  [void]$profile.SetPreference('browser.download.manager.showWhenStarting','False')
} catch [exception]{
  <#

#>
}
Write-Debug 'Starting'
$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($profile)

# Repeat the test case with translation


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
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$upload_button) -Delay 1500

# Populate upload input
$upload_element = find_element -classname 'ajaxupload-input'
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$upload_element) -Delay 1500

Write-Host ('Uploading the file "{0}".' -f $text_file)
$upload_element.SendKeys($text_file)
# hard wait
Start-Sleep 10

$element_text = 'Download'
$classname = 'gw-download-link'
$download_link_element = find_element -classname $classname
[NUnit.Framework.Assert]::IsTrue($download_link_element.Text -match $element_text)
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$download_link_element) -Delay 1200


Write-Host 'Cleaning dowload directory' .
Remove-Item -Path ([System.IO.Path]::Combine($download_path,'testfile.txt')) -ErrorAction 'silentlycontinue'

Write-Host 'click on  "Download" link'
$download_link_element.Click()

$file_present = $false
while (-not $file_present) {
  Start-Sleep -Milliseconds 1000
  $file_item = Get-ChildItem -Path $download_path -Name 'testfile.txt' -ErrorAction 'silentlycontinue'
  if ($file_item -ne $null) {
    $file_present = $true
  }
}
if ($file_present) {
  Write-Host 'Reading file contents.'
  $file_content = (Get-Content -Path ([System.IO.Path]::Combine($download_path,'testfile.txt')) -ErrorAction 'silentlycontinue') -join '`r`n'
  $transalted_text = $null
  $capturing_match_expression = '^(?<all>.+)$'
  extract_match -Source $file_content -capturing_match_expression $capturing_match_expression -label 'all' -result_ref ([ref]$transalted_text)
  [NUnit.Framework.Assert]::IsTrue(($transalted_text -match 'Bonjour Driver'))
  Write-Host 'Verified translation.'

}
Write-Debug 'Closing'
cleanup ([ref]$selenium)
