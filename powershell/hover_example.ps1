# http://www.codeproject.com/Articles/856325/Mouse-Hover-Action-using-selenium-WebDriver

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
  [string]$browser = '',
  [switch]$grid,
  [switch]$pause
)

$verificationErrors = New-Object System.Text.StringBuilder

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

$DebugPreference = 'Continue'
$base_url = 'http://www.myntra.com/'

$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()
# set_timeouts ([ref]$selenium)

[NUnit.Framework.StringAssert]::Contains('www.myntra.com',$selenium.url,{})

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100


$xpath = "//a[@href='/shop/women?src=tn&nav_id=34']"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
$text_url = $element.getAttribute('href')
Write-Output ('Hovering on : "{0}"' -f $text_url  )
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Build().Perform()
Start-Sleep -Millisecond 1000

$xpath = "//a[@href='/shop/men?src=tn&nav_id=5']"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
$text_url = $element.getAttribute('href')
Write-Output ('Hovering on : "{0}"' -f $text_url  )
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Build().Perform()

if ($PSBoundParameters['pause']) {
  Write-Output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}


Start-Sleep -Millisecond 1000
# Click on " bags & backpacks " link
$xpath = "#a[@href='/men-bags-backpacks?src=tn&nav_id=25']"
Write-Output ('Locating via XPATH: "{0}"' -f $xpath)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

# [NUnit.Framework.Assert]::AreEqual('Caribbean',$element.Text)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Click().Build().Perform()


# click on the categories - Bagpacks

$xpath = "//*[text()='Categories']//following::li[1]/label']"
Write-Output ('Locating via XPATH: "{0}"' -f $xpath)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

# [NUnit.Framework.Assert]::AreEqual('Caribbean',$element.Text)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Click().Build().Perform()

# Hover on the 1st bag 
$xpath = "//ul[@class='results small']/li[1]"
Write-Output ('Locating via XPATH: "{0}"' -f $xpath)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

# [NUnit.Framework.Assert]::AreEqual('Caribbean',$element.Text)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Build().Perform()


#Click on the buy icon of the 1st bag
$xpath = "//ul[@class='results small']/li[1]/div[1]//div[2]"
Write-Output ('Locating via XPATH: "{0}"' -f $xpath)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message)
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

# [NUnit.Framework.Assert]::AreEqual('Caribbean',$element.Text)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Click().Build().Perform()

# Wait For Page To Load
# something better !!!
#  driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);
<#  
# Hover over the shopping bag icon present on the top navigatinal bar   
Actions a3 = new Actions(driver);
a3.moveToElement(driver.findElement(By.xpath("#a[@href='/checkout/cart']"))).build().perform();
  
# click on the remove icon
driver.findElement(By.xpath("#a[@data-hint='Remove item']")).click();
#>

# Cleanup
cleanup ([ref]$selenium)



