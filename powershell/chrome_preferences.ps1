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
  [string]$base_url = 'http://www.freetranslation.com/',
  [switch]$debug,
  [switch]$pause
)


$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies

# Probably will work with embedded only 
$selenium = launch_selenium -browser 'chrome'
# close and reload with the profie
cleanup ([ref]$selenium)


$capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
# override

# Oveview of extensions 
# https://sites.google.com/a/chromium.org/chromedriver/capabilities

# Profile creation
# https://support.google.com/chrome/answer/142059?hl=en
# http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
# using Profile 
# http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195
# http://www.wikihow.com/Change-Google-Chrome-Downloads-Settings
# https://sites.google.com/a/chromium.org/chromedriver/capabilities
# http://superuser.com/questions/149032/where-is-the-chrome-settings-file
# https://support.google.com/chrome/a/answer/187948?hl=en
# https://www.chromium.org/administrators/configuring-other-preferences
# https://jamfnation.jamfsoftware.com/discussion.html?id=10331
# http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

[OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions

$options.addArguments('start-maximized')
$options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))

# Custom profile parent directory:
# $options.addArguments('user-data-dir=c:/TEMP'); 


$options.addArguments('--profile-directory=Default')

# Remember initial setting from
$preferences_obj = ((get-content -path "${env:LocalAppData}\google\chrome\user data\Default\Preferences") -join '`r`n') | convertfrom-json 
$original_setting = $preferences_obj.'savefile'.'default_directory'
# TODO: restore initial setting

<#
# https://code.google.com/p/chromedriver/issues/detail?id=330
# http://stackoverflow.com/questions/15824996/how-to-set-chrome-preferences-using-selenium-webdriver-net-binding

$preferences = @{
  "savefile.default_directory" = "C:\\Users\\sergueik\\Downloads";
  "download.default_directory" = "C:\\Users\\sergueik\\Downloads";
  "download.prompt_for_download" = $false;
};

$options.AddAdditionalCapability('prefs',$preferences)
# Exception calling "AddAdditionalCapability" with "2" argument(s): 
# "There is already an option for the prefs capability. Please use that instead. 

$options.AddAdditionalCapability('chrome.prefs',$preferences)
# New-Object : Exception calling ".ctor" with "1" argument(s):
# "unknown error: cannot parse capability: chromeOptions from unknown error: unrecognized chrome option: chrome.prefs

#>

$download_path = 'c:\temp\xxx'
$options.AddUserProfilePreference('download', @{ 
                           'default_directory' = $download_path; 
                           'prompt_for_download' = $false; 
       })
# $options.AddUserProfilePreference('download.prompt_for_download',$false)

[OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
$capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability,$options)

$selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)

$script_directory = Get-ScriptDirectory

# Repeat the test case with translation

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
$hard_wait_interval = 3
Start-Sleep $hard_wait_interval

$element_text = 'Download'
$classname = 'gw-download-link'
$download_link_element = find_element -classname $classname
[NUnit.Framework.Assert]::IsTrue($download_link_element.Text -match $element_text)
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$download_link_element) -Delay 1200

$filename = 'testfile.txt'
Write-Host 'Cleaning dowload directory' .
Remove-Item -Path ([System.IO.Path]::Combine($download_path,$filename)) -ErrorAction 'silentlycontinue'

Write-Host 'click on "Download" link'
$download_link_element.Click()

$file_present = $false
Write-Host 'Check for file to be present in dowload directory' 

while (-not $file_present) {
  Start-Sleep -Milliseconds 1000
  $file_item = Get-ChildItem -Path $download_path -Name $filename -ErrorAction 'silentlycontinue'
  if ($file_item -ne $null) {
    $file_present = $true
  } else { 
   Write-Host 'Waiting for file to be found in dowload directory' 
  }
}
if ($file_present) {
  Write-Host 'Reading file contents.'
  $file_content = (Get-Content -Path ([System.IO.Path]::Combine($download_path,$filename )) -ErrorAction 'silentlycontinue') -join '`r`n'
  $transalted_text = $null
  $capturing_match_expression = '^(?<all>.+)$'
  extract_match -Source $file_content -capturing_match_expression $capturing_match_expression -label 'all' -result_ref ([ref]$transalted_text)
  [NUnit.Framework.Assert]::IsTrue(($transalted_text -match 'Bonjour Driver'))
  Write-Host 'Verified translation.'

}
Write-Debug 'Closing'
cleanup ([ref]$selenium)
