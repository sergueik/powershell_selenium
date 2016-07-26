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
  [switch]$browser
)

function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.framework.dll'
)

$max_count = 5
$env:SHARED_ASSEMBLIES_PATH = 'c:\developer\sergueik\csharp\SharedAssemblies'

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://www.wikipedia.org/'
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  [void]($selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder))
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(10))
try {
  [OpenQA.Selenium.IWebElement]$web_element = $null
  $web_element = $selenium.FindElement([OpenQA.Selenium.By]::Id('searchLanguage'))
} catch [exception]{
}
[NUnit.Framework.Assert]::IsTrue(($web_element -ne $null))
try {
  [OpenQA.Selenium.IWebElement]$web_element = $null
  $web_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector('select#searchLanguage'))
} catch [exception]{
}
[NUnit.Framework.Assert]::IsTrue(($web_element -ne $null))
try {
  [OpenQA.Selenium.IWebElement]$web_element = $null
  $web_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector('select[id=searchLanguage]'))
} catch [exception]{
}
[NUnit.Framework.Assert]::IsTrue(($web_element -ne $null))
try {
  [OpenQA.Selenium.IWebElement]$web_element = $null
  $web_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector('select[id$=Language]'))
  [System.Collections.ObjectModel.ReadOnlyCollection[OpenQA.Selenium.IWebElement]]$web_element_list = $web_element.findElements([OpenQA.Selenium.By]::TagName('option'))
} catch [exception]{
}
[NUnit.Framework.Assert]::IsTrue(($web_element -ne $null))

$web_element_enumerator = $web_element_list.GetEnumerator()

$cnt = 0
while ($web_element_enumerator.MoveNext()) {
  if ($cnt++ -gt $max_count) {
    continue
  }

  $current = $web_element_enumerator.Current
  [string]$xPath = ('/html/body//select[@id="searchLanguage"]/option[@value="{0}"]' -f $current.GetAttribute('value'))
  $result = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xPath))
  [NUnit.Framework.Assert]::AreEqual($result.Text,$current.Text)
  Write-Output $current.Text
}
$cnt = 0
$web_element_list | ForEach-Object {
  if ($cnt++ -gt $max_count) {
    return
  }

  Write-Output $_.Text
  $value = $_.GetAttribute('value')
  $css_selector = ('option[value="{0}"]' -f $value)
  Write-Output $css_selector
  try {
    [void]$web_element.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

}

[OpenQA.Selenium.IWebElement]$web_element = $selenium.FindElement([OpenQA.Selenium.By]::Name('language'))
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($web_element)

$availableOptions = $select_element.Options
$index = 0

foreach ($item in $availableOptions)
{
  if ($index -gt $max_count) {
    continue
  }

  $select_element.SelectByValue($item.GetAttribute('value'))
  $result = $select_element.SelectedOption
  [NUnit.Framework.Assert]::AreEqual($result.Text,$item.Text)
  Write-Output $result.Text
  $select_element.SelectByText($item.Text)
  $select_element.SelectByIndex($index)
  Start-Sleep -Milliseconds 10
  $index++
}

# Cleanup
cleanup ([ref]$selenium)
