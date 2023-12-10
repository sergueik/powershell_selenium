#Copyright (c) 2023 Serguei Kouzmine
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

$webDriver_version = '4.8.2' 
# NOTE: on Windows 7 and Windows 8 this is the highest version one can use 
# because Chrome is Version 109.0.5414.168
# To get later Google Chrome updates, need OS upgrade to Windows 10 or later
add-type -path ".\packages\Selenium.WebDriver.4.8.2\lib\net45\WebDriver.dll"
# add-type -path "./packages/Selenium.Support.4.8.2/lib/net45/WebDriver.Support.dll"
$env:Path += ";${env:USERPROFILE}\Downloads"
$options = new-object OpenQA.Selenium.Chrome.ChromeOptions
$driver = new-object OpenQA.Selenium.Chrome.ChromeDriver($options)

# https://stackoverflow.com/questions/56857362/create-new-system-collections-generic-dictionary-object-fails-in-powershell  
[System.Collections.Generic.Dictionary[[string],[Object]]] $params = new-object "System.Collections.Generic.Dictionary[[string],[Object]]"
$params.Add('userAgent', $userAgent)

$params.Add('platform',  'Windows')

$tempPath =  "${env:TEMP}\test"
mkdir $tempPath -erroraction silentlycontinue
write-host ('Download to {0}' -f $tempPath)
$command = 'Browser.setDownloadBehavior'

$params.Add('behavior', 'allowAndName' )
$params.Add('downloadPath',  $tempPath )
$params.Add('eventsEnabled',  $true )
# NOTE: cast is not required with Powershell code
([OpenQA.Selenium.Chromium.ChromiumDriver]$driver).ExecuteCdpCommand($command, $params)

$url = 'https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx'
$driver.Navigate().GoToUrl($url)
start-sleep -seconds 5
write-host ('Listing files in {0}' -f $tempPath)
get-childitem -path $tempPath | select-object -property FullName| format-list

$driver.close()
$driver.quit()
get-childitem -path $tempPath | select-object -expandproperty FullName |
foreach-object {
  $x = $_ 
  remove-item -path $x 
}
remove-item -path $tempPath -force
