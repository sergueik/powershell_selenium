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

$MODULE_NAME = 'selenium_utils.psd1';
import-module -name ('{0}/{1}' -f '.',  $MODULE_NAME)

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port

$base_url = ('file:///{0}\{1}' -f (Get-ScriptDirectory), 'forms_test.html' ) -replace '\\', '/'
write-output $base_url 

$verificationErrors = New-Object System.Text.StringBuilder

# http://www.w3schools.com/xpath/xpath_axes.asp

$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()

# locator # 1

$name = ''
$class = 'contentdiv_listdiv'
$xpath = ('//div[@class="{0}"]//input[@id]' -f $class)

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
  <#
Value cannot be null.
Parameter name: key
#>
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
[OpenQA.Selenium.ILocatable]$loc = ([OpenQA.Selenium.ILocatable]$element)
Write-Output ('{0} id = {1}' -f $element.TagName,$element.GetAttribute('id'))

[OpenQA.Selenium.IMouse]$mouse = ([OpenQA.Selenium.IHasInputDevices]$selenium).Mouse
$coord = $loc.Coordinates
$mouse.MouseMove($coord)

Write-Output ('Checked = {0}' -f $element.GetAttribute('checked'))
$mouse.Click($coord)
Start-Sleep 1

<#
NOTE: can not run the selenium API code while alert iss displayed
Exception calling "GetAttribute" with "1" argument(s): "Modal dialog present: Checked 7a18efeb-427c-4eec-880d-13cbec2bec17
#>
$alert = $selenium.switchTo().alert()
Write-Output ('Clicking on {0}' -f $alert.Text)
$alert.accept()

Start-Sleep 1

# locator # 2

$name = ''
$class = 'contentdiv_listdiv'
# span[text()='{0}']//following-sibling::input[@type='checkbox']
$xpath = ('//div[@class="{0}"]//input[@type="checkbox"]' -f $class)

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
Write-Output ('{0} id = {1}' -f $element.TagName,$element.GetAttribute('id'))
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
Start-Sleep 1
$alert = $selenium.switchTo().alert()
Write-Output ('Clicking on {0}' -f $alert.Text)
$alert.accept()
Start-Sleep 1


# locator # 3

$name = 'shyam Kumar'
$class = 'contentdiv_listdiv'
$xpath = ('//div[@class="{0}"]/span[text()="{1}"]' -f $class,$name)

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
Write-Output ('{0} id = {1}' -f $element.TagName,$element.GetAttribute('id'))
# The name is not clickable

[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: darkblue; border: 4px solid darkblue;')
Start-Sleep 1
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')
Start-Sleep 1



# locator # 4
$name = 'shyam Kumar'
$class = 'contentdiv_listdiv'
$xpath = ('//div[@class="{0}"]/span[text()="{1}"]/following-sibling::*' -f $class,$name)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::XPath($xpath))
$elements | ForEach-Object {
  $element = $_
  Write-Output ('Highlighting element: {0} class={1}' -f $element.TagName,$element.GetAttribute('class'))
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'color: #CC6600; border: 4px solid #CC3300;')
  Start-Sleep 1
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')
  Start-Sleep 1

}


# locator # 5

$name = 'shyam Kumar'
$class = 'contentdiv_listdiv'
$xpath = ('//div[@class="{0}"]/span[text()="{1}"]/following-sibling::*//input[@type="checkbox"]' -f $class,$name)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
[OpenQA.Selenium.ILocatable]$loc = ([OpenQA.Selenium.ILocatable]$element)

[OpenQA.Selenium.IMouse]$mouse = ([OpenQA.Selenium.IHasInputDevices]$selenium).Mouse
$coord = $loc.Coordinates
$mouse.MouseMove($coord)
$mouse.Click($coord)
Start-Sleep 1
$alert = $selenium.switchTo().alert()
Write-Output ('Clicking on {0}' -f $alert.Text)
$alert.accept()
Start-Sleep 1


# locator # 6

$name = 'shyam Kumar'
$class = 'contentdiv_listdiv'
$xpath = ('//div[@class="{0}"]/span[text()="{1}"]/following-sibling::*//input[@type="checkbox"]' -f $class,$name)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
Write-Output ('{0} id = {1}' -f $element.TagName,$element.GetAttribute('id'))
[OpenQA.Selenium.ILocatable]$loc = ([OpenQA.Selenium.ILocatable]$element)

[string]$script = @"
function XpathOf(element) {
    if (element.id !== '')
        return '*[@id="' + element.id + '"]';
    if (element === document.body)
        return element.tagName;
    var ix= 0;
    var siblings= element.parentNode.childNodes;
    for (var i= 0; i<siblings.length; i++) {
        var sibling = siblings[i];
        if (sibling === element)
            return XpathOf(element.parentNode) + '/' + element.tagName + '[' + ( ix + 1 ) + ']';
        if (sibling.nodeType === 1 && sibling.tagName === element.tagName)
            ix++;
    }
}
return XpathOf(arguments[0]);
"@
$result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$element,'')).ToString()

Write-Output ('Javascript-generated XPath = "{0}"' -f $result)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $xpath = ('//{0}' -f $result)

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
Start-Sleep 1
$alert = $selenium.switchTo().alert()
Write-Output ('Clicking on {0}' -f $alert.Text)
$alert.accept()
Start-Sleep 1
# /*                if (regexp.test(el.id)) { */
# locator # 6 css version
[string]$get_css_selector_function = @"

function cssSelectorOf(el) {
    if (!(el instanceof Element))
        return;
    var path = [];
    while (el.nodeType === Node.ELEMENT_NODE) {
        var selector = el.nodeName.toLowerCase();
        if (el.id) {
            if (el.id.indexOf('-') > -1) {
                selector += '[id = "' + el.id + '"]';
            } else {
                selector += '#' + el.id;
            }
            path.unshift(selector);
            break;
        } else {
            var el_sib = el,
                cnt = 1;
            while (el_sib = el_sib.previousElementSibling) {
                if (el_sib.nodeName.toLowerCase() == selector)
                    cnt++;
            }
            if (cnt != 1)
                selector += ':nth-of-type(' + cnt + ')';
        }
        path.unshift(selector);
        el = el.parentNode;
    }
    return path.join(' > ');
} // invoke 
return cssSelectorOf(arguments[0]);
"@

$result_css = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($get_css_selector_function,$element,'')).ToString()


Write-Output ('Javascript-generated CSS selector = "{0}"' -f $result_css)
$result_css = cssSelectorOf ([ref] $element)

$css_selector = $result_css
Write-Output ('Javascript-generated CSS selector = "{0}"' -f $result_css)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
Start-Sleep 1
$alert = $selenium.switchTo().alert()
Write-Output ('Clicking on {0}' -f $alert.Text)
$alert.accept()
Start-Sleep 1



# locator # 7

$name = 'shyam Kumar'
$class = 'contentdiv_listdiv'
$xpath = ('//div[@class="{0}"]/span[text()="{1}"]/following-sibling::*//input[@type="checkbox"]' -f $class,$name)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 25
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n(ignored)" -f (($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
Write-Output ('{0} id = {1}' -f $element.TagName,$element.GetAttribute('id'))
[OpenQA.Selenium.ILocatable]$loc = ([OpenQA.Selenium.ILocatable]$element)

[string]$get_xpath_script = @"
function XpathOf(element) {
    if (element.id !== '')
        return 'id("' + element.id + '")';
    if (element === document.body)
        return element.tagName;

    var ix = 0;
    var siblings = element.parentNode.childNodes;
    for (var i = 0; i < siblings.length; i++) {
        var sibling = siblings[i];
        if (sibling === element)
            return XpathOf(element.parentNode) + '/' + element.tagName + '[' + (ix + 1) + ']';
        if (sibling.nodeType === 1 && sibling.tagName === element.tagName)
            ix++;
    }
}
return XpathOf(arguments[0]);
"@
$result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($get_xpath_script,$element,'')).ToString()

Write-Output ('Javascript-generated XPath = "{0}"' -f $result)
$resul = XpathOf ([ref] $element)

Write-Output ('Javascript-generated XPath = "{0}"' -f $result)
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $xpath = ('{0}' -f $result)

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
Start-Sleep 1
$alert = $selenium.switchTo().alert()
Write-Output ('Clicking on {0}' -f $alert.Text)
$alert.accept()
Start-Sleep 1
# http://stackoverflow.com/questions/11961178/finding-an-element-by-partial-id-with-selenium-in-c-sharp
# Cleanup
cleanup ([ref]$selenium)

