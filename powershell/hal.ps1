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
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS ORmax
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
  [int]$version,
  [switch]$pause

)

# http://www.codeproject.com/Tips/816113/Console-Monitor
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Drawing.Imaging;
public class WindowHelper
{
    private Bitmap _bmp;
    private Graphics _graphics;
    private int _count = 0;
    private Font _font;

    private string _timeStamp;
    private string _browser;
    private string _srcImagePath;

    private string _dstImagePath;

    public string DstImagePath
    {
        get { return _dstImagePath; }
        set { _dstImagePath = value; }
    }

    public string TimeStamp
    {
        get { return _timeStamp; }
        set { _timeStamp = value; }
    }

    public string SrcImagePath
    {
        get { return _srcImagePath; }
        set { _srcImagePath = value; }
    }

    public string Browser
    {
        get { return _browser; }
        set { _browser = value; }
    }
    public int Count
    {
        get { return _count; }
        set { _count = value; }
    }
    public void Screenshot(bool Stamp = false)
    {
        _bmp = new Bitmap(Screen.PrimaryScreen.Bounds.Width, Screen.PrimaryScreen.Bounds.Height);
        _graphics = Graphics.FromImage(_bmp);
        _graphics.CopyFromScreen(0, 0, 0, 0, _bmp.Size);
        if (Stamp)
        {
            StampScreenshot();
        }
        else
        {
            _bmp.Save(_dstImagePath, ImageFormat.Jpeg);
        }
        Dispose();
    }

    public void StampScreenshot()
    {
        string firstText = _timeStamp;
        string secondText = _browser;

        PointF firstLocation = new PointF(10f, 10f);
        PointF secondLocation = new PointF(10f, 55f);
        if (_bmp == null)
        {
            createFromFile();
        }
        _graphics = Graphics.FromImage(_bmp);
        _font = new Font("Arial", 40);
        _graphics.DrawString(firstText, _font, Brushes.Black, firstLocation);
        _graphics.DrawString(secondText, _font, Brushes.Blue, secondLocation);
        _bmp.Save(_dstImagePath, ImageFormat.Jpeg);
        Dispose();

    }
    public WindowHelper()
    {
    }

    public void Dispose()
    {
        _font.Dispose();
        _bmp.Dispose();
        _graphics.Dispose();

    }

    private void createFromFile()
    {
        try
        {
            _bmp = new Bitmap(_srcImagePath);
        }
        catch (Exception e)
        {
            throw e;
        }
        if (_bmp == null)
        {
            throw new Exception("failed to load image");
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$env:SHARED_ASSEMBLIES_PATH = "c:\java\selenium\csharp\sharedassemblies"

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
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
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = "C:\tools\phantomjs"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}


$base_url = 'http://www.hollandamerica.com'

$selenium.Navigate().GoToUrl($base_url + "/")
[void]$selenium.Manage().Window.Maximize()
[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(360))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("logo")))

[NUnit.Framework.Assert]::IsTrue(($selenium.Title -match 'Holland America Line'))
Write-Output $selenium.Title

function verify_destination {

  param([string]$value4,
    [string]$text4,
    [string]$title4
  )

  $value0 = 'destinations'

  $css_selector0 = ('li#{0} a.pnavmenu_link' -f $value0)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

  [OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element0).Build().Perform()
  Start-Sleep -Millisecond 50
  Write-Debug ('Hovering over ' + $element0.GetAttribute('title'))

  $css_selector3 = ("a[href='{0}']" -f $value4)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector3)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  [OpenQA.Selenium.IWebElement]$element4 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector3))
  [NUnit.Framework.Assert]::IsTrue(($element4.Text -match $text4),$text4)
  Write-Debug ('Clicking on ' + $element4.Text)
  $element4.Click()
  Start-Sleep -Millisecond 100
  Write-Debug $selenium.Title
  [NUnit.Framework.Assert]::IsTrue(($selenium.Title -match $title4),$title4)

  $selenium.Navigate().back()

}
if ($PSBoundParameters["destinations"]) {
  verify_destination `
     -value4 '/cruise-destinations/alaska?WT.ac=pnav_DestMap_Alaska' `
     -text4 'Alaska & Yukon' `
     -title4 'Alaska Cruise Vacations'

  verify_destination `
     -value4 '/cruise-destinations/pacific-northwest-cruises?WT.ac=pnav_DestMap_PNW' `
     -text4 'Pacific Northwest & Pacific Coast' `
     -title4 'Pacific Coast Cruises'

  verify_destination `
     -value4 '/cruise-destinations/canada-new-england-cruises?WT.ac=pnav_DestMap_CNE' `
     -text4 'Canada/New England' `
     -title4 'Canada travel and New England cruises'

  verify_destination `
     -value4 '/cruise-destinations/mexican-cruises?WT.ac=pnav_DestMap_Mexico' `
     -text4 'Mexico' `
     -title4 'Mexico Cruises'
}
if ($PSBoundParameters["cruises"]) {
  $value0 = 'findCruises'

  $css_selector0 = ('li#{0} a.pnavmenu_link' -f $value0)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 50
  $menu0 = 'Plan a Cruise'
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

  [OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element0).Build().Perform()
  [NUnit.Framework.Assert]::IsTrue(($element0.GetAttribute('title') -match $menu0))
  Write-Output ('Hovering over ' + $element0.GetAttribute('title'))
  Start-Sleep -Millisecond 150

  $value0 = 'divContainer_title'
  $css_selector0 = ('div#{0}' -f $value0)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 50
  $menu0 = 'Plan a Cruise'
  $text0 = 'DESIGN your VACATION'
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

  [NUnit.Framework.Assert]::IsTrue(($element0.Text -match $text0))

  try {

    [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element0,'color: #CC6600; border: 4px solid #CC3300;')
    Write-Output ('Optionally Highlighting element: {0}' -f $element0.Text)
    Start-Sleep 3
    [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element0,'')
    Start-Sleep 3
  } catch [exception]{

    Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0]) }

  $choose_random_destination = $false
  if ($choose_random_destination) {

    $value2 = 'selectDestinationsPNAV'
    $css_selector2 = ('select#{0}' -f $value2)


    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
    $wait.PollingInterval = 50

    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
    } catch [exception]{
      Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    }

    $element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
    [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Click().Build().Perform()

    $value1 = 'selectDestinationsPNAV'

    $css_selector3 = ('select#{0} option' -f $value1)

    $results = @()
    $elements1 = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector3))


    $elements1 | ForEach-Object {

      $element3 = $_
      Write-Output ('Found {0}' -f $element3.Text)

      if ($PSBoundParameters['pause']) {
        Write-Output 'pause'
        try {
          [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        } catch [exception]{}
      } else {
        Start-Sleep -Millisecond 100
      }
      # TODO: refactor.find alternative implementation.
      [string]$script = @"
function getPathTo(element) {
    if (element.id!=='')
        return '*[@id="'+element.id+'"]';
    if (element===document.body)
        return element.tagName;

    var ix= 0;
    var siblings= element.parentNode.childNodes;
    for (var i= 0; i<siblings.length; i++) {
        var sibling= siblings[i];
        if (sibling===element)
            return getPathTo(element.parentNode)+'/'+element.tagName+'['+(ix+1)+']';
        if (sibling.nodeType===1 && sibling.tagName===element.tagName)
            ix++;
    }
}
return getPathTo(arguments[0]);
"@
      $result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$element3,'')).ToString()

      Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $element3.Text,$result)
      $results += $result

    }
    [string]$result2 = $null
    if ($results.count -gt 1) {
      $sample_pos = [int]($results.count / 2.0)
      $sample_pos = 3
      $result2 = $results[$sample_pos]
    } else {
      $result2 = $results[$sample_pos]
    }

    Write-Output ('Use XPath = "{0}"' -f $result2)
    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait2 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
    $wait2.PollingInterval = 100
    $xpath2 = ('//{0}' -f $result2)

    try {
      [void]$wait2.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath2)))
    } catch [exception]{
      Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
    }

    [OpenQA.Selenium.IWebElement]$element3 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath2))

    Write-Output ('Choosing ' + $element3.Text)
    [OpenQA.Selenium.Interactions.Actions]$actions3 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions3.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
    Write-Output ('Pressing ENTER {0}' -f $element3.Text)

    [void]$actions3.SendKeys($element3,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))

    # TODO [NUnit.Framework.Assert]::IsTrue(($element3.Text -match $text3 ))


  } else {

    $value2 = 'selectDestinationsPNAV'
    $css_selector2 = ('select#{0}' -f $value2)


    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
    $wait.PollingInterval = 50

    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
    } catch [exception]{
      Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    }

    $element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
    [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Click().Build().Perform()
    #[NUnit.Framework.Assert]::IsTrue(($element0.GetAttribute('title') -match $menu0 ))

    Write-Output ('Clicking on {0}' -f $element2.GetAttribute('title'))
    Start-Sleep -Millisecond 150


    $text3 = 'Pacific Northwest & Pacific Coast'

    $value3 = "L"

    $css_selector3 = ("option[value='{0}']" -f $value3)
    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
    $wait.PollingInterval = 150

    try {
      [OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector3)))
    } catch [exception]{
      Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    }
    $element3 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector3))
    [OpenQA.Selenium.Interactions.Actions]$actions3 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions3.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
    Write-Output ('Pressing ENTER {0}' -f $element3.Text)
    [void]$actions3.SendKeys($element3,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))

  }
  $value2 = 'selectDatesPNAV'
  $css_selector2 = ('select#{0}' -f $value2)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 50
  $menu0 = 'Select a Date'
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  Write-Output ('Clicking on {0}' -f $element2.GetAttribute('title'))
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Click().Build().Perform()

  $choose_random_date = $false
  if ($choose_random_date) {

    # get #n-th element 

    $value2 = 'selectDatesPNAV'
    $css_selector3 = ('select#{0} option' -f $value2)

    $results = @()
    $elements1 = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector3))


    $elements1 | ForEach-Object {

      $element3 = $_

      [string]$script = @"
function getPathTo(element) {
    if (element.id!=='')
        return '*[@id="'+element.id+'"]';
    if (element===document.body)
        return element.tagName;

    var ix= 0;
    var siblings= element.parentNode.childNodes;
    for (var i= 0; i<siblings.length; i++) {
        var sibling= siblings[i];
        if (sibling===element)
            return getPathTo(element.parentNode)+'/'+element.tagName+'['+(ix+1)+']';
        if (sibling.nodeType===1 && sibling.tagName===element.tagName)
            ix++;
    }
}
return getPathTo(arguments[0]);
"@
      $result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$element3,'')).ToString()

      Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $element3.Text,$result)
      $results += $result

    }
    [string]$result2 = $null
    if ($results.count -gt 1) {
      $sample_pos = [int]($results.count / 2.0)
      $result2 = $results[$sample_pos]
    } else {
      $result2 = $results[$sample_pos]
    }

    Write-Output ('Use XPath = "{0}"' -f $result2)
    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait2 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
    $wait2.PollingInterval = 100
    $xpath2 = ('//{0}' -f $result2)

    try {
      [void]$wait2.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath2)))
    } catch [exception]{
      Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
    }

    [OpenQA.Selenium.IWebElement]$element3 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath2))

    Write-Output ('Choosing ' + $element3.Text)
    [OpenQA.Selenium.Interactions.Actions]$actions3 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions3.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
    Write-Output ('Pressing ENTER {0}' -f $element3.Text)

    [void]$actions3.SendKeys($element3,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))

    # TODO [NUnit.Framework.Assert]::IsTrue(($element3.Text -match $text3 ))

  } else {
    # exact month 
    # ------------------
    Start-Sleep -Millisecond 200
    $value3 = "4_2015"

    $css_selector3 = ("option[value='{0}']" -f $value3)
    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
    $wait.PollingInterval = 150

    try {
      [OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector3)))
    } catch [exception]{
      Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    }
    $element3 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector3))
    Write-Output ('Choosing ' + $element3.Text)
    [OpenQA.Selenium.Interactions.Actions]$actions3 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions3.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
    Write-Output ('Pressing ENTER {0}' -f $element3.Text)

    [void]$actions3.SendKeys($element3,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
  }
  Start-Sleep -Millisecond 200
  $value5 = "buttonContinue"

  $css_selector5 = ("a.{0}" -f $value5)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element5 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector5)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element5 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector5))
  Write-Output ('Clicking on ' + $element5.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions5 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions5.MoveToElement([OpenQA.Selenium.IWebElement]$element5).Click().Build().Perform()


  $value5 = 'resultsPaginationTitle'
  $css_selector5 = ("div.{0}" -f $value5)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element5 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector5)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element5 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector5))
  Write-Output ('Reading ' + $element5.Text)

  $css_selector6 = 'div.resultContainer div.cruiseResultTitleContainer'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element6 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector6)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element6 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector6))
  Write-Output ('Navigating to ' + $element6.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions6 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions6.MoveToElement([OpenQA.Selenium.IWebElement]$element6).Build().Perform()


  $css_selector6 = 'a.buttonClose'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element6 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector6)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element6 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector6))
  Write-Output ('Clicking ' + $element6.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions6 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions6.MoveToElement([OpenQA.Selenium.IWebElement]$element6).Click().Build().Perform()


  #--

  $css_selector9 = 'img.imageCruiseResult'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element9 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector9)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element9 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector9))
  Write-Output ('Clicking ' + $element9.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions9 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions9.MoveToElement([OpenQA.Selenium.IWebElement]$element9).Click().Build().Perform()

  Start-Sleep 3
  $css_selector8 = 'div#cboxClose'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element8 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector8)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element8 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector8))
  Write-Output ('Clicking ' + $element8.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions8 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions8.MoveToElement([OpenQA.Selenium.IWebElement]$element8).Click().Build().Perform()


  #--


  $css_selector7 = 'a#buttonSeeFullDetails'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element7 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector7)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element7 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector7))
  Write-Output ('Clicking ' + $element7.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions7 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions7.MoveToElement([OpenQA.Selenium.IWebElement]$element7).Click().Build().Perform()


  $css_selector5 = 'a.buttonContinueDetails'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element7 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector5)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element5 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector5))
  Write-Output ('Clicking ' + $element5.GetAttribute('title'))
  [OpenQA.Selenium.Interactions.Actions]$actions5 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions5.MoveToElement([OpenQA.Selenium.IWebElement]$element5).Click().Build().Perform()




  Start-Sleep 4

  if ($PSBoundParameters['pause']) {
    Write-Output 'pause'
    try {
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 100
  }


  $css_selector2 = 'a[class*=exit_booking_link]'
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$element7 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
  Write-Output ('Clicking ' + $element2.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Click().Build().Perform()
  Start-Sleep 4
  # Do not navigate history here
  #  $selenium.Navigate().back()
  #  $selenium.Navigate().back()
}
# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}


<#
Costa  Cruise 
# http://www.costacruise.com/B2C/USA/Default.htm

CCL - AIDA Home (TxP)[IE] - Success
http://www.aida.de/


Cruise-A-Nality 
http://www.cruiseanality.com/

Conard 
http://www.cunard.com/

Holland America Lite 
http://www.hollandamerica.com/

NCL
http://www.ncl.com/

PO Cruises Intl
http://www.pocruises.com/
Princess Cruise Lines 
http://www.princess.com/
Royal Caribbean
http://www.royalcaribbean.com/

Seabourn
http://www.seabourn.com/

Works Leading Cruise Lines
http://worldleadingcruiselines.com/
#>
