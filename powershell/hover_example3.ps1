#Copyright (c) 2016 Serguei Kouzmine
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


# http://stackoverflow.com/questions/17293914/how-to-perform-mouseover-function-in-selenium-webdriver-using-java
param(
  [string]$browser = '',
  [switch]$grid,
  [switch]$pause
)

$verificationErrors = New-Object System.Text.StringBuilder
$assemblies = @( 'System.Drawing',
  'System.Collections.Generic',
  'System.Collections',
  'System.ComponentModel',
  'System.Windows.Forms',
  'System.Text',
  'System.Data'
)

$assemblies | ForEach-Object { $assembly = $_; [void][System.Reflection.Assembly]::LoadWithPartialName($assembly) }


$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

Add-Type -TypeDefinition @"

using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class MouseHelper
{
    // http://www.pinvoke.net/default.aspx/user32.mouse_event
    [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, uint cButtons, uint dwExtraInfo);
    // static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);

    [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
    public static extern long SetCursorPos(int X, int Y);

    private const int MOUSEEVENTF_LEFTDOWN = 0x02;
    private const int MOUSEEVENTF_LEFTUP = 0x04;
    private const int MOUSEEVENTF_RIGHTDOWN = 0x08;
    private const int MOUSEEVENTF_RIGHTUP = 0x10;
    private const int MOUSEEVENTF_WHEEL = 0x800;
    private const uint MOUSEEVENTF_MOVE = 0x0001;
    public MouseHelper()
    {
    }
/*
    public void MouseHelper_mouse_event(int X, int Y)
    {
        mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, X, Y, 0, 0);
    }
*/
    public void MouseHelper_mouse_event(int X, int Y)
    {
        mouse_event(MOUSEEVENTF_MOVE , X, Y, 0, 0);
    }

    public void MouseHelper_SetCursorPos(int X, int Y)
    {
        SetCursorPos(X, Y);
    }

}

/* usage
IWebElement element = driver.FindElement(........);
var X = element.Location.X;
var Y = element.Location.Y;
SetCursorPos(X, Y);
mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, 0, 0, 0, 0); 
*/

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'


$DebugPreference = 'Continue'
$base_url = 'http://www.urbandictionary.com/'

$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100


$css_selector = "div#ud-root div#outer div.slogan-panel div.panel div.slogan div.kid"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector)))
  # Java:
  # WebElement clickable = wait.until(ExpectedConditions.elementToBeClickable(By ...)));
  # import org.openqa.selenium.interactions.Mouse;

} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
$element_html = $element.getAttribute('outerHTML')
Write-Output ('Hovering on : "{0}"' -f $element_html)

[System.Drawing.Point]$point = $element.Location
Write-Output 'point:'
$point | Format-Table -AutoSize

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement($element).Build().Perform()
Start-Sleep -Millisecond 10000
<# 
@"
if (arguments[0].className!=''){
  arguments[0].focus();
}
"@
#>

<#
@"

arguments[0].dispatchEvent(
  new MouseEvent('click', {view: window, bubbles:true, cancelable: true}))
"@

#>

[string]$script = @"
var e = document.createEvent('MouseEvents');
e.initMouseEvent( 'mouseover', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
arguments[0].dispatchEvent(e);
"@

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'border: 2px solid red;')
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript($script,$element)
Start-Sleep -Millisecond 3000
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element,'')


[OpenQA.Selenium.IMouse]$mouse = ([OpenQA.Selenium.IHasInputDevices]$selenium).Mouse
$o = New-Object -TypeName MouseHelper

$o.MouseHelper_SetCursorPos($point.X,$point.Y)

# need to use LocationOnScreenOnceScrolledIntoView, or Coordinates
Write-Output ('Location: {{X = {0}; Y = {1}}}' -f $element.Location.X,$element.Location.Y)
Write-Output ('LocationOnScreenOnceScrolledIntoView: {{X = {0}; Y = {1}}}' -f $element.LocationOnScreenOnceScrolledIntoView.X,$element.LocationOnScreenOnceScrolledIntoView.Y)
Write-Output 'Coordinates:'
$path_element.Coordinates | Format-List

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Build().Perform()

$mouse.MouseMove($element.Coordinates)


# Cleanup
cleanup ([ref]$selenium)



