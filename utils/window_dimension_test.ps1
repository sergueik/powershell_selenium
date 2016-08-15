#Copyright (c) 2014 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

<#
@('ie', 'chrome' , 'firefox') | foreach-object { ./window_dimension_test.ps1 -browser $_ }

GRID warmup
@('8','8','8','8','8','8','10','11','11','11','11','9','10') | foreach-object {Start-Job -FilePath .\windows_dimension_test.ps1  -argumentlist @('ie' , $_)}
for ($cnt = 0; $cnt -ne 12 ; $cnt ++)  {Start-Job -FilePath .\windows_dimension_test.ps1  -argumentlist @('chrome' )}
for ($cnt = 0; $cnt -ne 12 ; $cnt ++)  {Start-Job -FilePath .\windows_dimension_test.ps1  -argumentlist @('firefox' )}

#>

param(
  # in the current environment phantomejs is not installed 
  [string]$browser = 'firefox',
  [string]$base_url = 'http://www.priceline.com/',
  [int]$version
)

function cleanup
{
  param([object]$selenium_ref)
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
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
    private static int thumbWidth = 96;
    private static int thumbHeight = 96;
    private string _timeStamp;
    private string _browser;
    private string _srcImagePath;

    // NOTE: do not use _imageFormat / ImageFormat for members 
    // due to class name collision
    private string _imgFormat;

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

    public string ImgFormat
    {
        get { return _imgFormat; }
        set { _imgFormat = value; }
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
            _bmp.Save(_dstImagePath, GetImageFormat(ImgFormat));
        }
        Dispose();
    }

    // http://www.java2s.com/Code/CSharp/2D-Graphics/CreateThumbnail.htm
    public byte[] CreateThumbnail(string filename, string dest)
    {
        using (MemoryStream s = new MemoryStream())
        using (Image image = Image.FromFile(filename).GetThumbnailImage(thumbWidth, thumbHeight, null, new IntPtr()))
        {
            image.Save(s, ImageFormat.Jpeg);
            image.Save(dest, GetImageFormat(ImgFormat));
            return s.ToArray();
        }
    }

    public ImageFormat GetImageFormat(string ext)
    {
        switch (ext.ToUpper())
        {
            case "BMP":
                return ImageFormat.Bmp;
            case "PNG":
                return ImageFormat.Png;
            case "GIF":
                return ImageFormat.Gif;
            case "ICO":
                return ImageFormat.Icon;
            case "JPEG":
            case "JPG":
            case "JPE":
                return ImageFormat.Jpeg;
            case "TIF":
            case "TIFF":
                return ImageFormat.Tiff;
            case "WMF":
                return ImageFormat.Wmf;
            default:
                return ImageFormat.Bmp;
        }
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
        _bmp.Save(_dstImagePath, GetImageFormat(ImgFormat));
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
  try
  {
    $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
  } catch [exception]{
    Write-Output $_.Exception.Message
    if ($selenium -ne $null) {

      cleanup ([ref]$selenium)
    }
    return -1
  }
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

$selenium.Navigate().GoToUrl($base_url)

# block until the logo is visible.
$css_selector1 = 'a.logo'
# $css_selector1 = 'a#logo'

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))


$selenium.Manage().Window.Maximize()

Start-Sleep 10

$window_size = $selenium.Manage().Window.Size
$window_position = $selenium.Manage().Window.Position
write-output ('Width:{0}, Height:{1}' -f $window_size.Width,  $window_size.Height )


try {
  [OpenQA.Selenium.Screenshot]$screenshot = $selenium.GetScreenshot()
  $guid = [guid]::NewGuid()
  $image_name = ($guid.ToString())
  [string]$image_path = ('{0}\{1}\{2}.{3}' -f (Get-ScriptDirectory),'temp',$image_name,'.jpg')

  [string]$stamped_image_path = ('{0}\{1}\{2}-stamped.{3}' -f (Get-ScriptDirectory),'temp',$image_name,'.jpg')
  $screenshot.SaveAsFile($image_path,[System.Drawing.Imaging.ImageFormat]::Jpeg)


  $owner = New-Object WindowHelper
  $owner.ImgFormat = "JPG"
  $owner.count = $iteration
  $owner.Browser = ("{0} {1},{2}" -f $browser,$window_size.Width,$window_size.Height)
  $owner.SrcImagePath = $image_path
  $owner.TimeStamp = Get-Date
  # $owner.ThumbImagePath = ('{0}_1.jpg' -f $image_path )
  $owner.DstImagePath = $stamped_image_path 
  [boolean]$stamp = $false

  $owner.StampScreenshot()
  [void]$owner.CreateThumbnail($image_path , ('{0}_1.jpg' -f $image_path ))


} catch [exception]{
  Write-Output $_.Exception.Message
}
# Cleanup

cleanup ([ref]$selenium)
