#Copyright (c) 2015 Serguei Kouzmine
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
  [string]$hub_port = '4444',
  [string]$sample = 'piechart',# barchart has less impressive behavior
  [switch]$use_native_methods # NOTE: native_methods do not work

)

function get_svg_xpath_of {
  param(
    <# there is no need to explicitly pass the reference to selenium 
    [System.Management.Automation.PSReference]$selenium_ref,
    #>
    [System.Management.Automation.PSReference]$element_ref = ([ref]$element_ref)
  )
  [OpenQA.Selenium.ILocatable]$local:element = ([OpenQA.Selenium.ILocatable]$element_ref.Value)
  [string]$local:result = $null

  [string]$local:script = @"
 function get_svg_xpath_of(element) {
     var elementTagName = element.tagName.toLowerCase();
     if (element.id != '') {
         return 'id("' + element.id + '")';
         // alternative : 
         // return '*[@id="' + element.id + '"]';
     } else if (element.name && document.getElementsByName(element.name).length === 1) {
         return '//' + elementTagName + '[@name="' + element.name + '"]';
     }
     if (element === document.body) {
         return '/html/' + elementTagName;
     }
     var sibling_count = 0;
     var siblings = element.parentNode.childNodes;
     siblings_length = siblings.length;
     for (cnt = 0; cnt < siblings_length; cnt++) {
         var sibling_element = siblings[cnt];
         if (sibling_element.nodeType !== 1) { // not ELEMENT_NODE
             continue;
         }
         if (sibling_element === element) {
             return get_svg_xpath_of(element.parentNode) + '/*[name()="' + elementTagName + '"][' + (sibling_count + 1) + ']';
         }
         if (sibling_element.nodeType === 1 && sibling_element.tagName === elementTagName) {
             sibling_count++;
         }
     }
     return;
 };
 return get_svg_xpath_of(arguments[0]);
"@

  $local:result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($local:script,$local:element,'')).ToString()
  Write-Debug ('Javascript-generated XPath = "{0}"' -f $local:result)

  return $local:result
}


if ('barchart','piechart' -notcontains $sample)
{
  throw "$($sample) is not a valid sample! Please use 'barchart','piechart'"
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

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port

# http://mikaelkoskinen.net/post/kendoui-dataviz-tips-and-tricks
$base_url = 'http://demos.telerik.com/kendo-ui/bar-charts/column'

$base_url = ('file:///{0}/{1}' -f (Get-ScriptDirectory),('../assets/{0}.html' -f $sample)) -replace '\\','/'

Write-Output $base_url

$verificationErrors = New-Object System.Text.StringBuilder
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
Start-Sleep 3


$css_selector = 'div#chart svg'
$element = find_element -css $css_selector
# fails in hext line ?
$element
# highlight ([ref]$selenium) ([ref]$element )
$xpath_of_element = xpathOfElement ([ref]$element)
# next : path
Write-Output ('Javascript-generated XPath = "{0}"' -f $xpath_of_element)
$path_css_selector = 'path[fill = "#fff"]'

# $path_css_selector = 'path[d="M0 0 L 50 0 50 15 0 15Z"]'
#


[bool]$use_native_methods = [bool]$PSBoundParameters['use_native_methods'].IsPresent

[OpenQA.Selenium.IMouse]$mouse = ([OpenQA.Selenium.IHasInputDevices]$selenium).Mouse
$o = New-Object -TypeName MouseHelper
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$paths = $element.FindElements([OpenQA.Selenium.By]::CssSelector($path_css_selector))
$delay = 500

$paths | ForEach-Object {
  $path_element = $_
  # Write-Output $path_element.GetAttribute('d')
  # CSS Selector can be used to locate the elements
  $css_selector_of_path_element = cssSelectorOfElement ([ref]$path_element)
  Write-Output ('CSS "{0}"' -f $css_selector_of_path_element)
  $assert_element = find_element -css $css_selector_of_path_element
  # -wait_seconds 2

  <#
  # XPath is known to fail
  # https://www.linkedin.com/grp/post/961927-6022651674206748672
  # one has to switch to equivalent, but more verbose XPath
  # e.g. //*[@id="chartdiv"]/div/div[1]/*[name()="svg"]/*[name()="g"][7]/*[name()="g"]/*[name()="g"][1]/*[name()="path"][starts-with(@d, "M371.75,174.28l")]
  # http://stackoverflow.com/questions/26722421/how-do-i-test-a-click-on-svg-objects-using-selenium-webdriver
 #>
  $svg_xpath_of_element = get_svg_xpath_of ([ref]$path_element)
  Write-Output ('XPath "{0}"' -f $svg_xpath_of_element)

  try {
    # TODO - variable names
    $assert_element = find_element -xpath $svg_xpath_of_element
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  <#  #>

  if ($use_native_methods) {

    [System.Drawing.Point]$point = $path_element.Location
    Write-Output 'point:'
    $point | Format-Table -AutoSize

    $o.MouseHelper_SetCursorPos($point.X,$point.Y)

  } else {

    # need to use LocationOnScreenOnceScrolledIntoView, or Coordinates
    Write-Output ('Location: {{X = {0}; Y = {1}}}' -f $path_element.Location.X,$path_element.Location.Y)
    Write-Output ('LocationOnScreenOnceScrolledIntoView: {{X = {0}; Y = {1}}}' -f $path_element.LocationOnScreenOnceScrolledIntoView.X,$path_element.LocationOnScreenOnceScrolledIntoView.Y)
    Write-Output 'Coordinates:'
    $path_element.Coordinates | Format-List

    $actions.MoveToElement([OpenQA.Selenium.IWebElement]$assert_element).Build().Perform()

    $mouse.MouseMove($assert_element.Coordinates)

  }

  # [OpenQA.Selenium.Interactions.Actions]$builder = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

  # http://stackoverflow.com/questions/14592213/selenium-webdriver-clicking-on-elements-within-an-svg-using-xpath


  # this breaks kendo chart - first clicker element disappears, the rest of the loop throws "stale element reference: element is not attached to the page document" errors 
  # $actions.click($path_element).Perform()

  # the next two seem to have no effect:
  # [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("if (arguments[0].className!=''){arguments[0].focus();}",$path_element)
  # [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].dispatchEvent(new MouseEvent('click', {view: window, bubbles:true, cancelable: true}))",$path_element)


  Start-Sleep -Millisecond $delay


}

# Cleanup
cleanup ([ref]$selenium)
