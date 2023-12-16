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

param(
  [string]$browser = 'chrome',
  [switch]$debug,
  [switch]$pause

)

function localPageURI {
  param(
    [string]$fileName = $null,
    [string]$scriptDirectory = (resolve-path -path '.').path,
    [switch]$debug
  )
  if ($fileName -eq $null) {
    throw [System.IO.FileNotFoundException] 'Script name can not be null.'
  }

  $local:filePath = ("{0}\{1}" -f $scriptDirectory, $fileName)
  if ( test-path -path $local:filePath){
    write-debug ('Found page in "{0}"' -f $local:filePath)
    $local:fileURI = ('file:///{0}' -f ($local:filePath -replace '\\', '/' ) )
  } else {
    throw [System.IO.FileNotFoundException] "Page file ${filePath} was not be found."
  }
  return $local:fileURI
}

$webDriver_version = '4.8.2' 
# NOTE: on Windows 7 and Windows 8 this is the highest version one can use 
# because Chrome is Version 109.0.5414.168
# To get later Google Chrome updates, need OS upgrade to Windows 10 or later
add-type -path ".\packages\Selenium.WebDriver.4.8.2\lib\net45\WebDriver.dll"
# add-type -path "./packages/Selenium.Support.4.8.2/lib/net45/WebDriver.Support.dll"
$env:Path += ";${env:USERPROFILE}\Downloads"
$options = new-object OpenQA.Selenium.Chrome.ChromeOptions
$driver = new-object OpenQA.Selenium.Chrome.ChromeDriver($options)


$command = 'Page.setBypassCSP'
# $params  = @{}
# https://stackoverflow.com/questions/56857362/create-new-system-collections-generic-dictionary-object-fails-in-powershell  
[System.Collections.Generic.Dictionary[[string],[Object]]] $params = new-object "System.Collections.Generic.Dictionary[[string],[Object]]"
$params.Add('enabled', $true)
# NOTE: cast is not needed with Powershell code
([OpenQA.Selenium.Chromium.ChromiumDriver]$driver).ExecuteCdpCommand($command, $params)


$fileURI = localPageURI -fileName 'Samples\test1.html'
$driver.Navigate().GoToUrl($fileURI)

start-sleep -millisecond 1000

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($driver,[System.TimeSpan]::FromSeconds(10))

$wait.PollingInterval = 150

# NOTE: signature-sensitive
[OpenQA.Selenium.IWebElement]$element = $wait.until([System.Func[[OpenQA.Selenium.IWebDriver],[OpenQA.Selenium.IWebElement]]] <# follows the code block #> {

  $elements = $driver.FindElements([OpenQA.Selenium.By]::XPath('//img'))
  $element =  $elements | where-object { $_.Displayed } | select-object -first 1
  return $element
})

write-output ('Fluent wait element: {0}' -f $element.getAttribute('outerHTML'))

function highlight {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [String]$color = 'yellow',
    [int]$delay = 300
  )
  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$local:executor = [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value
  $local:executor.ExecuteScript('arguments[0].setAttribute("style", arguments[1]);', $element_ref.Value, ('color: ${0}; border: 4px solid ${0};' -f $color))

  start-sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript('arguments[0].setAttribute("style", arguments[1]);', $element_ref.Value,'')
}

highlight -selenium_ref ([ref]$driver) -element_ref ([ref]$element) -delay 3000 -color 'green'

start-sleep -millisecond 1000
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$command = 'Page.setBypassCSP'
# $params  = @{}
# https://stackoverflow.com/questions/56857362/create-new-system-collections-generic-dictionary-object-fails-in-powershell  
[System.Collections.Generic.Dictionary[[string],[Object]]] $params = new-object "System.Collections.Generic.Dictionary[[string],[Object]]"
$params.Add('enabled', $false)
# NOTE: cast is not needed with Powershell code
([OpenQA.Selenium.Chromium.ChromiumDriver]$driver).ExecuteCdpCommand($command, $params)

$driver.Navigate().Refresh() 
<#
$fileURI = localPageURI -fileName 'Samples\test1.html'
$driver.Navigate().GoToUrl($fileURI)
#>

start-sleep -millisecond 1000
$driver.close()
$driver.quit()
