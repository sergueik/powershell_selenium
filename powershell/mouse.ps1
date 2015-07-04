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

    public void MouseHelper_mouse_event1(int X, int Y)
    {
        mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, X, Y, 0, 0);
    }


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

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$verificationErrors = New-Object System.Text.StringBuilder

$hub_host = '127.0.0.1'
$hub_port = '4444'

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port



$base_url = "file:///C:/developer/sergueik/powershell_ui_samples/external/architecture.svg"
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()


# https://zoomcharts.com/templates/default/doc/time-chart/images/architecture.svg
# https://zoomcharts.com/en/gallery/all:time-chart-area-gold-prices
# https://www.linkedin.com/groups/Simulate-mouse-clicking-961927.S.5928176227885027333?view=&item=5928176227885027333&type=member&gid=961927&trk=eml-b2_anet_digest-group_discussions-11-grouppost-disc-8&midToken=AQGpqMsZZNuraw&fromEmail=fromEmail&ut=0-qp6wmfrXwCs1
[OpenQA.Selenium.IMouse]$mouse = ([OpenQA.Selenium.IHasInputDevices]$selenium).Mouse

try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 30
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::TagName('image')))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::TagName('image'))
[OpenQA.Selenium.ILocatable]$loc = ([OpenQA.Selenium.ILocatable]$element)

$coord = $loc.Coordinates
$coord.LocationInDom.X = 100
$coord.LocationInDom.Y = 100
$coord | Format-List
$coord | Get-Member
# [System.Drawing.Point]$point = $coord.LocationInDom
# $point | get-member 
$o = New-Object -TypeName MouseHelper

# $mouse.MouseMove($coord)
# $mouse.Click($coord)
# ListDragTarget.Location = new System.Drawing.Point(154, 17)
$o.MouseHelper_SetCursorPos(100,100)
# ($coord.LocationInDom.X, $coord.LocationInDom.Y )
$delay = 10000
$o.MouseHelper_mouse_event(200,200) # ($coord.LocationInDom.X, $coord.LocationInDom.Y)
Start-Sleep -Millisecond $delay
# Cleanup
cleanup ([ref]$selenium)

