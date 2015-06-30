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
  # in the current environment phantomejs is not installed 
  [switch]$destinations,
  [switch]$cruises,
  [string]$browser = 'firefox',
  [string]$filename = 'screenshot',
  [int]$version
)


$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid -shared_assemblies $shared_assemblies

} else {
  $selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies

}

$baseURL = 'http://www.royalcaribbean.com'

$selenium.Navigate().GoToUrl($baseURL + "/")

[string]$logo_class = "siteLogo"
# "img [ src *= 'royal-caribbean-logo' ]"
[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(360))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName($logo_class)))
$element0 = $selenium.FindElement([OpenQA.Selenium.By]::ClassName($logo_class))
$image0 = $element0.FindElement([OpenQA.Selenium.By]::TagName('img'))
Write-Output ('Logo: ' + $image0.GetAttribute('alt'))
[NUnit.Framework.Assert]::IsTrue(($image0.GetAttribute('alt') -match 'Royal Caribbean International'))

[NUnit.Framework.Assert]::IsTrue(($selenium.Title -match 'Welcome'))
Write-Output $selenium.Title

$class0 = 'findACruise'
$css_selector0 = ('body div.{0}' -f $class0)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 50

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector0)
}

$element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

[OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element0).Build().Perform()
Start-Sleep -Millisecond 50
$header0 = $element0.FindElement([OpenQA.Selenium.By]::TagName('h2'))

highlight ([ref]$selenium) ([ref]$header0)


$csspath = 'cufon'
$element = $header0
$attribute = 'alt'

[OpenQA.Selenium.IWebElement[]]$elements = $element.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))

if ($elements -ne $null) {
  Write-Output ('Iterate descendants of {0} directly:' -f $element.TagName)
  $elements | ForEach-Object { $element = $_
    try {
      [NUnit.Framework.Assert]::IsTrue(($element.GetAttribute($attribute) -ne $null))
      Write-Output (' {0} => {1}' -f $element.TagName,$element.GetAttribute($attribute))
      highlight ([ref]$selenium) ([ref]$element)

    } catch [exception]{}
  }
}



$class = 'selectContainer'
$csspath = ('div[class *="{0}"]' -f $class)
$element = $element0
$attribute = 'class'


[OpenQA.Selenium.IWebElement[]]$elements = $element.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))

if ($elements -ne $null) {
  Write-Output ('Iterate descendants of {0} directly:' -f $element.TagName)
  $elements | ForEach-Object { $element = $_
    try {
      [NUnit.Framework.Assert]::IsTrue(($element.GetAttribute($attribute) -ne $null))
      Write-Output (' {0} => {1}' -f $element.TagName,$element.GetAttribute($attribute))
      highlight ([ref]$selenium) ([ref]$element)
      [OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
      $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
      # $element.Size.Height
      # $element.LocationOnScreenOnceScrolledIntoView.Y
      if ($element.LocationOnScreenOnceScrolledIntoView.Y -gt 0) {
        $d = $element.LocationOnScreenOnceScrolledIntoView.Y + 100
        [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript(('scroll(0, {0})' -f $d),$null)
        Start-Sleep -Millisecond 300
        [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript(('scroll(0, -{0})' -f $d),$null)
      }
      Start-Sleep 2
      $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

    } catch [exception]{}
  }
}
Start-Sleep 3
<# 
$env:SCREENSHOT_PATH = (Get-ScriptDirectory)

$screenshot_path = $env:SCREENSHOT_PATH

[OpenQA.Selenium.Screenshot]$screenshot = $selenium.GetScreenshot()

$screenshot.SaveAsFile([System.IO.Path]::Combine( $screenshot_path, ('{0}.{1}' -f $filename,  'png' ) ) , [System.Drawing.Imaging.ImageFormat]::Png)
#>

# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}
