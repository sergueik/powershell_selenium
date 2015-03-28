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
  [string] $filename = 'screenshot',
  [int]$version
)
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


function find_page_element_by_css_selector {

  param(
    [System.Management.Automation.PSReference]$selenium_driver_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [string]$css_selector,
    [int]$wait_seconds = 10

  )

  if ($css_selector -eq '' -or $css_selector -eq $null) {
    return
  }
  $local:element = $null
  [OpenQA.Selenium.Remote.RemoteWebDriver]$local:selenum_driver = $selenium_driver_ref.Value
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($local:selenum_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector)
  }

  $local:element = $local:selenum_driver.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  $element_ref.Value = $local:element

}


function hover_menus {
  param([string]$value)

  if ($value -eq '' -or $value -eq $null) {
    return
  }
  $local:css_selector = ('a#{0}' -f $value)
  $local:element = $null
  find_page_element_by_css_selector ([ref]$selenium) ([ref]$local:element) $css_selector

  [OpenQA.Selenium.Interactions.Actions]$local:actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $local:actions.MoveToElement([OpenQA.Selenium.IWebElement]$local:element).Build().Perform()
  Start-Sleep -Millisecond 50
  Write-Output ('Hovering over ' + $local:element.GetAttribute('title'))


}


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


$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

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

$selenium.Navigate().GoToUrl($base_url + '/')


[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(360))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("hp-logo")))
$element0 = $selenium.FindElement([OpenQA.Selenium.By]::ClassName("hp-logo"))
Write-Output ('Logo: ' + $element0.GetAttribute('alt'))

[NUnit.Framework.Assert]::IsTrue(($selenium.Title -match 'Holland America Line'))
Write-Output $selenium.Title

('pnav-planACruise','pnav-specialOffers','pnav-destinations','pnav-onboard') | ForEach-Object { hover_menus -Value $_ }
hover_menus

$env:SCREENSHOT_PATH = (Get-ScriptDirectory)

$screenshot_path = $env:SCREENSHOT_PATH

[OpenQA.Selenium.Screenshot]$screenshot = $selenium.GetScreenshot()

$screenshot.SaveAsFile([System.IO.Path]::Combine( $screenshot_path, ('{0}.{1}' -f $filename,  'png' ) ) , [System.Drawing.Imaging.ImageFormat]::Png)

# Cleanup
cleanup ([ref]$selenium)
