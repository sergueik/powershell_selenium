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

[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)

$MODULE_NAME = 'selenium_utils.psd1'
import-module -name ('{0}/{1}' -f '.',  $MODULE_NAME)

$selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies -hub_host $hub_host -hub_port $hub_port

$base_url = 'http://www.freetranslation.com/'
$selenium.Navigate().GoToUrl($base_url)

<# 
has the following fragment:
<div class="gw-upload-action clearfix">
  <div id="upload-button" class="btn"><img class="gw-icon upload" alt="" src="http://d2yxcfsf8zdogl.cloudfront.net/home-php/assets/home/img/pixel.gif"/>
         Choose File(s)                        
        <div class="ajaxupload-wrapper" style="width: 300px; height: 50px;"><input class="ajaxupload-input" type="file" name="file" multiple=""/></div>
    </div>
</div>
#>

$text_file = [System.IO.Path]::Combine( (Get-ScriptDirectory),'testfile.txt')
Write-Output 'good morning driver' | Out-File -FilePath $text_file -Encoding ascii

set_timeouts ([ref]$selenium)

[void]$selenium.Manage().Window.Maximize()
[void]$selenium.Navigate()


# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 10
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector('a.brand')))

$element = [OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector('a.brand'))
$element  | get-member


$upload_element = $selenium.FindElement([OpenQA.Selenium.By]::ClassName('ajaxupload-input'))
$upload_element.SendKeys($text_file)
<#
Wait until the following element is present:
<a href="..." class="gw-download-link">
  <img class="gw-icon download" src="http://d2yxcfsf8zdogl.cloudfront.net/home-php/assets/home/img/pixel.gif"/>
  Download
</a>
#>

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 100

[OpenQA.Selenium.Remote.RemoteWebElement]$element1 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("gw-download-link")))

[OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector('img.gw-icon')))
$text_url = $element1.getAttribute('href')
# http://winsysadm.net/
# http://weblog.west-wind.com/posts/2007/May/21/Downloading-a-File-with-a-Save-As-Dialog-in-ASPNET
$result = Invoke-WebRequest -Uri $text_url
[NUnit.Framework.Assert]::IsTrue(($result.RawContent -match 'Bonjour pilote'))

# Cleanup
cleanup ([ref]$selenium)
