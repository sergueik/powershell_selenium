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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}
$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd
$verificationErrors = New-Object System.Text.StringBuilder

$hub_host = '127.0.0.1'
$hub_port = '4444'

$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Debug "Running on ${browser}"
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability("version",$version.ToString());
    }

  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Debug 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

# http://www.w3schools.com/xpath/xpath_axes.asp

$base_url = ('file:///{0}\{1}' -f (Get-ScriptDirectory), 'forms_test.html' ) -replace '\\', '/'
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
function get_xpath_of(element) {
    if (element.id !== '')
        return '*[@id="' + element.id + '"]';
    if (element === document.body)
        return element.tagName;
    var ix= 0;
    var siblings= element.parentNode.childNodes;
    for (var i= 0; i<siblings.length; i++) {
        var sibling = siblings[i];
        if (sibling === element)
            return get_xpath_of(element.parentNode) + '/' + element.tagName + '[' + ( ix + 1 ) + ']';
        if (sibling.nodeType === 1 && sibling.tagName === element.tagName)
            ix++;
    }
}
return get_xpath_of(arguments[0]);
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

function get_css_selector_of(el) {
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
return get_css_selector_of(arguments[0]);
"@

$result_css = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($get_css_selector_function,$element,'')).ToString()


Write-Output ('Javascript-generated CSS selector = "{0}"' -f $result_css)
$css_selector = $result_css

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
function get_xpath_of(element) {
    if (element.id !== '')
        return 'id("' + element.id + '")';
    if (element === document.body)
        return element.tagName;

    var ix = 0;
    var siblings = element.parentNode.childNodes;
    for (var i = 0; i < siblings.length; i++) {
        var sibling = siblings[i];
        if (sibling === element)
            return get_xpath_of(element.parentNode) + '/' + element.tagName + '[' + (ix + 1) + ']';
        if (sibling.nodeType === 1 && sibling.tagName === element.tagName)
            ix++;
    }
}
return get_xpath_of(arguments[0]);
"@
$result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($get_xpath_script,$element,'')).ToString()

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

