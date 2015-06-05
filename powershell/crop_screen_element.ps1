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

# sample call
# . .\shorex_carousel_box_image.ps1 -browser chrome -savedata -destination 'Manzanillo'

param(
  [string]$browser,
  [switch]$mobile,# currently unused
  [string]$base_url = 'http://www.hollandamerica.com/main/Main.action',
  [switch]$savedata,
  [switch]$pause

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

function extract_match {
  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)

  )

  if ($DebugPreference -eq 'Continue') {
    Write-Debug ('Extracting from {0}' -f $source)
  }

  $local:results = {}
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  $result_ref.Value = $local:results.Media
}


function set_timeouts {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [int]$explicit = 120,
    [int]$page_load = 600,
    [int]$script = 3000
  )

  [void]($selenium_ref.Value.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
  [void]($selenium_ref.Value.Manage().timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
  [void]($selenium_ref.Value.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))

}


function redirect_workaround {

  param(
    [string]$web_host = '',
    [string]$app_url = '',
    [string]$app_virtual_path = ''


  )

  if ($web_host -eq $null -or $web_host -eq '') {
    throw 'Web host cannot be null'

  }

  if (($app_virtual_path -ne '') -and ($app_virtual_path -ne '')) {
    $app_url = "http://${web_host}/${app_virtual_path}"
  }


  if ($app_url -eq $null -or $app_url -eq '') {
    throw 'Url cannot be null'
  }

  # workaround for 
  # The underlying connection was closed: Could not establish
  # trust relationship for the SSL/TLS secure channel.
  # error 
  # explained in 
  # http://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
  Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

  $result = $null

  try {
    $result = (Invoke-WebRequest -MaximumRedirection 0 -Uri $app_url -ErrorAction 'SilentlyContinue')
    if ($result.StatusCode -eq '302' -or $result.StatusCode -eq '301') {
      $location = $result.headers.Location
      if ($location -match '^http') {
        # TODO capture the host
        $location = $location -replace 'secure.carnival.com',$web_host
      } else {
        $location = $location -replace '^/',''
        $location = ('http://{0}/{1}' -f $web_host,$location)
      }
      Write-Host ('Following {0} ' -f $location)

      $result = (Invoke-WebRequest -Uri $location -ErrorAction 'Stop')
    }
  } catch [exception]{}


  return $result.Content.length

}


function compute_media_dimensions {

  # TODO: md5 hash 
  param(
    $base_url = 'http://www.carnival.com',
    $web_host = 'www.carnival.com',
    $img_src
  )

  $img_url = ('{0}/{1}' -f $base_url,$img_src)
  $media_size = 0
  <#
    $warmup_response_time = [System.Math]::Round((Measure-Command {
          try {
            $media_size = redirect_workaround -web_host $web_host -app_url $app_url
            # (New-Object net.webclient).DownloadString($_)
          } catch [exception]{
            Write-Output ("Exception `n{0}" -f (($_.Exception.Message) -split "`n")[0])
          }
        }
      ).totalmilliseconds)
    # Write-Output ("Opening page: {0} took {1} ms" -f $app_url,$warmup_response_time)
#>
  $media_size = redirect_workaround -web_host $web_host -app_url $img_url
  return $media_size

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
  'System.Data.SQLite.dll',

  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {
  # Unblock-File -Path $_; 
  Add-Type -Path $_
}
popd
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$verificationErrors = New-Object System.Text.StringBuilder
$phantomjs_executable_folder = 'C:\tools\phantomjs'
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch [exception]{
    Write-Output ('Exception: {0}' -f (($_.Exception.Message) -split "`n")[0])
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }


  if ($PSBoundParameters["mobile"].IsPresent) {
    # note $profile is not set
    [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
    [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
    $selected_profile_object.setPreference('general.useragent.override','Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16')

    [OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

    # [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
    [NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')


    $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
  } else {
    $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
    $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
  }
  $DebugPreference = 'Continue'

} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  if ($PSBoundParameters["mobile"].IsPresent) {
    $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  }
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}
[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(3000))


$window_position = $selenium.Manage().Window.Position
$window_size = $selenium.Manage().Window.Size
Write-Debug $destination

$selenium.Navigate().GoToUrl($base_url)

$css_selector = "div[class *='promo-tile-list'][class *='promo-tile'][class *='ng-isolate-scope'][class *='visible']"
Write-Output ('Locating via CSS SELECTOR: "{0}"' -f $css_selector)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
}

[OpenQA.Selenium.IWebElement[]]$carousel_items = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector))
$promo_element = $carousel_items[0]

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$promo_element).Build().Perform()

@{
  'LocationOnScreenOnceScrolledIntoView.X' = $promo_element.LocationOnScreenOnceScrolledIntoView.X;
  'LocationOnScreenOnceScrolledIntoView.Y ' = $promo_element.LocationOnScreenOnceScrolledIntoView.Y;
  'Location.X' = $promo_element.Location.X;
  'Location.Y' = $promo_element.Location.Y;
  'Size.Width' = $promo_element.Size.Width;
  'Size.Height' = $promo_element.Size.Height;
} | Format-List

$document_size_report_script = @"
return [
document.documentElement.clientWidth , 
document.documentElement.clientHeight
];

"@
[object]$result2 = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($document_size_report_script)
$result2 | Format-List
$result2_formatted = @{
  'document.clientWidth' = $result2[0];
  'document.clientHeight' = $result2[1];
}
$result2_formatted | Format-List
$element_size_report_script = @"
var target_element = arguments[0];
return [
target_element.clientHeight,
target_element.offsetHeight,
target_element.clientWidth,
target_element.offsetWidth
] 
"@
[object]$result3 = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($element_size_report_script,$promo_element,$null)
$result3_formatted = @{
  'element.clientHeight' = $result3[0];
  'element.offsetHeight' = $result3[1];
  'element.clientWidth' = $result3[2];
  'element.offsetwidth' = $result3[3];

}

$result3_formatted | Format-List
# DETECT if the client page is using jquery
# by csquery check of the body
#  <script type="text/javascript" src="/common/CCLUS/Core2/js/libs/jquery-1.8.3.min.js"></script>
# or through simply runing typeof $

$detect_jquery_in_use_script = @"
return (typeof $) ;
"@
[string]$result0 = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($detect_jquery_in_use_script)
Write-Output ('$ is {0}' -f $result0)
<#
$coords = @{
$res['Location.X'], 
$res['Location.X'] + ($res['element.clientHeight'] - $res['document.clientWidth']), 
$res['elementSize_clientWidth'], 
$res['elementSize_clientHeight']
}

#>

Start-Sleep -Milliseconds 1000
# Cleanup
cleanup ([ref]$selenium)


<#

http://stackoverflow.com/questions/13832322/how-to-capture-the-screenshot-of-only-a-specific-element-using-selenium-webdrive
https://github.com/guitarrapc/PowerShellUtil/blob/master/Get-Screenshot/Get-ScreenShot.ps1
driver.Manage().Window.Maximize();
             RemoteWebElement remElement = (RemoteWebElement)driver.FindElement(By.Id("submit-button")); 
             Point location = remElement.LocationOnScreenOnceScrolledIntoView;  

             int viewportWidth = Convert.ToInt32(((IJavaScriptExecutor)driver).ExecuteScript("return document.documentElement.clientWidth"));
             int viewportHeight = Convert.ToInt32(((IJavaScriptExecutor)driver).ExecuteScript("return document.documentElement.clientHeight"));

             driver.SwitchTo();

             int elementLocation_X = location.X;
             int elementLocation_Y = location.Y;

             IWebElement img = driver.FindElement(By.Id("submit-button"));

             int elementSize_Width = img.Size.Width;
             int elementSize_Height = img.Size.Height;

             Size s = new Size();
             s.Width = driver.Manage().Window.Size.Width;
             s.Height = driver.Manage().Window.Size.Height;


IWebElement img = driver.FindElement(By.Id("IMG1"));
int width = img.Size.Width;
int height = img.Size.Height;
Point point = img.Location;
int x = point.Location.X;;
int y = point.Location.Y;
RectangleF part = new RectangleF(x, y, width, height);
Bitmap bmpobj = new Bitmap(filePath);
Bitmap bn = bmpobj.Clone(part, bmpobj.PixelFormat);
// http://stackoverflow.com/questions/6992993/selenium-c-sharp-webdriver-wait-until-element-is-present
public static class WebDriverExtensions
{
    public static IWebElement FindElement(this IWebDriver driver, By by, int timeoutInSeconds)
    {
        if (timeoutInSeconds > 0)
        {
            var wait = new WebDriverWait(driver, TimeSpan.FromSeconds(timeoutInSeconds));
            return wait.Until(drv => drv.FindElement(by));
        }
        return driver.FindElement(by);
    }
}

            // https://github.com/guitarrapc/PowerShellUtil/blob/master/Get-Screenshot/Get-ScreenShot.ps1 
            $fileName = $FileNamePattern -f (Get-Date).ToString('yyyyMMdd_HHmmss_ffff')
            $path = Join-Path $OutPath $fileName


            $b = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
            $g = [System.Drawing.Graphics]::FromImage($b)
            $g.CopyFromScreen((New-Object System.Drawing.Point(0,0)), (New-Object System.Drawing.Point(0,0)), $b.Size)
            $g.Dispose()
            $b.Save($path)


             Bitmap bitmap = new Bitmap(s.Width, s.Height);
             Graphics graphics = Graphics.FromImage(bitmap as Image);
             graphics.CopyFromScreen(0, 0, 0, 0, s);

             bitmap.Save(filePath, System.Drawing.Imaging.ImageFormat.Png);

             RectangleF part = new RectangleF(elementLocation_X, elementLocation_Y + (s.Height - viewportHeight), elementSize_Width, elementSize_Height);

             Bitmap bmpobj = (Bitmap)Image.FromFile(filePath);
             Bitmap bn = bmpobj.Clone(part, bmpobj.PixelFormat);
             bn.Save(finalPictureFilePath, System.Drawing.Imaging.ImageFormat.Png); 

#>

<#
 
$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()

Start-Sleep -Millisecond 3000
$selenium.FindElement([OpenQA.Selenium.By]::CssSelector("#hlogo > a")).Displayed
Start-Sleep -Millisecond 3000
$selenium.FindElement([OpenQA.Selenium.By]::CssSelector("#hlogo > a > b > c")).Displayed
#>
# Cleanup
cleanup ([ref]$selenium)




