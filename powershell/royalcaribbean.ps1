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

function highlight {

  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [int]$delay = 300
  )

  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'color: yellow; border: 4px solid yellow;')
  Start-Sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'')


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

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"

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

$baseURL = 'http://www.royalcaribbean.com'

$selenium.Navigate().GoToUrl($baseURL + "/")



[string]$logo_class = "siteLogo"
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
