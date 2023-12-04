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
  [switch]$headless
)

$webDriver_version = '4.8.2' 
# NOTE: on Windows 7 and Windows 8 this is the highest version one can use 
# because Chrome is Version 109.0.5414.168
# To get later Google Chrome updates, need OS upgrade to Windows 10 or later
add-type -path ".\packages\Selenium.WebDriver.4.8.2\lib\net45\WebDriver.dll"
add-type -path "./packages/Selenium.Support.4.8.2/lib/net45/WebDriver.Support.dll"
$env:Path += ";${env:USERPROFILE}\Downloads"
$options = new-object OpenQA.Selenium.Chrome.ChromeOptions
if( $PSBoundParameters['headless'].IsPresent) {
  $options.AddArgument('--headless')
}
$driver = new-object OpenQA.Selenium.Chrome.ChromeDriver($options)
$command = 'Browser.getVersion'
$result = $driver.executeCdpCommand($command,@{})
$userAgent =  $result['userAgent']
write-host ('Actual Browser User Agent: {0}' -f $userAgent)
$userAgent = 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25'
$command = 'Network.setUserAgentOverride'

$params_hash = @{
  userAgent = $userAgent;
  platform  =  'Windows';
}
<#
# NOTE:
  Cannot convert argument "commandParameters", with value:
  "System.Collections.Hashtable", for "ExecuteCdpCommand" to type
  "System.Collections.Generic.Dictionary`2[System.String,System.Object]":
  The userAgent property was not found for the
  System.Collections.Generic.Dictionary`2[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral,
  PublicKeyToken=b77a5c561934e089],[System.Object, mscorlib, Version=4.0.0.0,
  Culture=neutral, PublicKeyToken=b77a5c561934e089]] object. 
  The available property is:
  [Comparer<System.Collections.Generic.IEqualityComparer`1[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]>] , 
  [Count<System.Int32>] , 
  [Keys<System.Collections.Generic.Dictionary`2+KeyCollection[[System.String,mscorlib, Version=4.0.0.0, Culture=neutral,PublicKeyToken=b77a5c561934e089],[System.Object, mscorlib, Version=4.0.0.0Culture=neutral, PublicKeyToken=b77a5c561934e089]]>] , 
  [Values<System.Collections.Generic.Dictionary`2+ValueCollection[[System.String,mscorlib, Version=4.0.0.0, Culture=neutral,PublicKeyToken=b77a5c561934e089],[System.Object, mscorlib, Version=4.0.0.0,Culture=neutral, PublicKeyToken=b77a5c561934e089]]>] , 
  [IsReadOnly<System.Boolean>] , 
  [IsFixedSize <System.Boolean>] , 
  [SyncRoot<System.Object>] , 
  [IsSynchronized <System.Boolean>]
#>

# https://stackoverflow.com/questions/56857362/create-new-system-collections-generic-dictionary-object-fails-in-powershell  
[System.Collections.Generic.Dictionary[[string],[Object]]] $params = new-object "System.Collections.Generic.Dictionary[[string],[Object]]"
$params.Add('userAgent', $userAgent)
$params.Add('platform',  'Windows')
# NOTE: cast is not required with Powershell code
([OpenQA.Selenium.Chromium.ChromiumDriver]$driver).ExecuteCdpCommand($command, $params)
<#
# ignore and rerun 
[1204/092811.846:ERROR:cert_issuer_source_aia.cc(34)] Error parsing cert retrieved from AIA (as DER):
ERROR: Couldn't read tbsCertificate as SEQUENCE
ERROR: Failed parsing Certificate
#>
$url = 'https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending'
$driver.Navigate().GoToUrl($url)
[int]$wait_seconds = 3
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = new-object OpenQA.Selenium.Support.UI.WebDriverWait($driver,[System.TimeSpan]::FromSeconds($wait_seconds))
$xpath = '//*[@id="content-base"]//table//th[contains(text(),"USER-AGENT")]/../td'
# https://stackoverflow.com/questions/49866334/c-sharp-selenium-expectedconditions-is-obsolete
# [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
# https://www.codeproject.com/Articles/787565/Lightweight-Wait-Until-Mechanism
[void]$wait.Until( [Func[[OpenQA.Selenium.IWebDriver],[Bool]]] {
  param(
    [OpenQA.Selenium.IWebDriver] $driver
  )
  # write-host 'Inside Wait'
  [IWebElement[]]$elements = $driver.FindElements([OpenQA.Selenium.By]::XPath($xpath))
  if (($elements -eq $null) -or ($elements.size -eq 0)) {
    return $false
  }
  [IWebElement]$element = $elements[0]
  if ($element.Displayed) {
    return $true
  } else {
    return $false
  }
})

$element = $wait.Until( [Func[[OpenQA.Selenium.IWebDriver],[OpenQA.Selenium.IWebElement]]] {
  param(
    [OpenQA.Selenium.IWebDriver] $driver
  )
  # write-host 'Inside Wait'
  [IWebElement[]]$elements = $driver.FindElements([OpenQA.Selenium.By]::XPath($xpath))
  if (($elements -eq $null) -or ($elements.size -eq 0)) {
    return $null
  }
  [IWebElement]$element = $elements[0]
  if ($element.Displayed) {
    return $element
  } else {
    return $null
  }
})


$element = $driver.FindElement([OpenQA.Selenium.By]::XPath($xpath))
write-host ('{0}' -f $element.Displayed)
write-host ('{0}' -f $element.Text )

function highlight {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [String]$color = 'yellow',
    [int]$delay = 300
  )
  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$local:executor = [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value
  $local:executor.ExecuteScript('arguments[0].setAttribute("style", arguments[1]);',$element_ref.Value, ('color: ${0}; border: 4px solid ${0};' -f $color))

  start-sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);", $element_ref.Value,'')
}

highlight -selenium_ref ([ref]$driver) -element_ref ([ref]$element) -delay 1500 -color 'green'

$driver.close()
$driver.quit()