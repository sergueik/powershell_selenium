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
  [string]$browser
  # TODO: version
)

$MODULE_NAME = 'selenium_utils.psd1'
import-module -name ('{0}/{1}' -f '.',  $MODULE_NAME)

$selenium = launch_selenium -browser $browser

# http://www.w3schools.com/xpath/xpath_axes.asp

$base_url = "file:///C:/developer/sergueik/powershell_ui_samples/external/example2.html"
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

# locator # 1

$name = ''
$class = 'money-out'
$xpath1 = ("//div[contains(@class,'{0}')]" -f $class)

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath1)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath1))


[NUnit.Framework.Assert]::IsTrue(($element1 -ne $null))
[NUnit.Framework.Assert]::IsTrue(($element1.Displayed))

# [OpenQA.Selenium.ILocatable]$loc = ([OpenQA.Selenium.ILocatable]$element)
#
# Write-Output ('{0} id = {1}' -f $element.TagName,$element.GetAttribute('id'))

$classname1 = 'transactionTable'

<#
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  [OpenQA.Selenium.IWebElement]$element2 = $element1.FindElement([OpenQA.Selenium.By]::ClassName($classname1))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
#>
[OpenQA.Selenium.IWebElement]$element2 = $element1.FindElement([OpenQA.Selenium.By]::ClassName($classname1))

$element2
[NUnit.Framework.Assert]::IsTrue(($element2 -ne $null))
[NUnit.Framework.Assert]::IsTrue(($element2.Displayed))

$classname2 = 'transactionItem'

[OpenQA.Selenium.IWebElement[]]$elements3 = $element2.FindElements([OpenQA.Selenium.By]::ClassName($classname2))
$elements3

if ($elements3 -ne $null) {
  Write-Output 'Iterate directly...'
  $elements3 | ForEach-Object { $element3 = $_

    [NUnit.Framework.Assert]::IsTrue(($element3 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element3.Displayed))

    $xpath = 'div/div/div/div/div'

    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element4 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element4 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element4.Displayed))

    $element4.GetAttribute('class')
    $element4.Text

    $xpath = ("div/div/div/div/div[@class]" -f 'transactionAmount')
    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element5 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element5 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element5.Displayed))
    $element5.GetAttribute('class')
    $element5.Text

    $xpath = ("div/div/div/div/div[contains(@class,'{0}')]" -f 'transactionAmount')
    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element6 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element6 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element6.Displayed))
    $element6.GetAttribute('class')
    $element6.Text

    $xpath = ("div/div/div/div/div[@class = '{0}']" -f 'transactionAmount')
    Write-Output ('Trying XPath "{0}"' -f $xpath)
    [OpenQA.Selenium.IWebElement[]]$element7 = $element3.FindElement([OpenQA.Selenium.By]::XPath($xpath))
    [NUnit.Framework.Assert]::IsTrue(($element7 -ne $null))
    [NUnit.Framework.Assert]::IsTrue(($element7.Displayed))
    $element7.GetAttribute('class')
    $element7.Text

  }
  $cnt++
}


# Cleanup
cleanup ([ref]$selenium)


