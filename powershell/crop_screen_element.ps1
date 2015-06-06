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
  [string]$browser = 'chrome',
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

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\node.cmd"
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
      $capability.SetCapability('version',$version.ToString());
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
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent


[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(3000))


$window_position = $selenium.Manage().Window.Position
$window_size = $selenium.Manage().Window.Size

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
$promo_element = $carousel_items[1]

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$promo_element).Build().Perform()
start-sleep -millisecond 2000
$result1_hash = @{
  'LocationOnScreenOnceScrolledIntoView.X' = $promo_element.LocationOnScreenOnceScrolledIntoView.X;
  'LocationOnScreenOnceScrolledIntoView.Y' = $promo_element.LocationOnScreenOnceScrolledIntoView.Y;
  'Location.X' = $promo_element.Location.X;
  'Location.Y' = $promo_element.Location.Y;
  'Size.Width' = $promo_element.Size.Width;
  'Size.Height' = $promo_element.Size.Height;
}

$result1_hash | Format-List

$document_size_report_script = @"
return [
document.documentElement.clientWidth , 
document.documentElement.clientHeight
];

"@
[object]$result2 = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($document_size_report_script)
$result2 | Format-List
$result2_hash = @{
  'document.clientWidth' = $result2[0];
  'document.clientHeight' = $result2[1];
}
$result2_hash | Format-List
$element_size_report_script = @"
var target_element = arguments[0];
//var clientHeight = target_element.clientHeight;
//var offsetHeight = target_element.offsetHeight;
return [
target_element.clientHeight,
target_element.offsetHeight,
target_element.clientWidth,
target_element.offsetWidth
] 
"@
[object]$result3 = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($element_size_report_script,$promo_element,$null)
$result3_hash = @{
  'element.clientHeight' = $result3[0];
  'element.offsetHeight' = $result3[1];
  'element.clientWidth' = $result3[2];
  'element.offsetwidth' = $result3[3];

}

$result3_hash | Format-List
# DETECT if the client page is using jquery
# by csquery check of the body
#  <script type="text/javascript" src="/common/CCLUS/Core2/js/libs/jquery-1.8.3.min.js"></script>
# or through simply runing typeof $

$detect_jquery_in_use_script = @"
return (typeof $) ;
"@
[string]$result0 = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($detect_jquery_in_use_script)
Write-Output ('$ is {0}' -f $result0)

$result4_hash = @{
  'x' = $result1_hash['LocationOnScreenOnceScrolledIntoView.X'];
  'y' = $result1_hash['LocationOnScreenOnceScrolledIntoView.Y']; 
  'width' = $result3_hash['element.clientWidth'];
  'height' = $result3_hash['element.clientHeight'];
}
$result4_hash | Format-List

# $result4_hash = @{
#'X'=294;'Y'=186;'Width'=220;'Height'=254;
# }


$assemblies = @( 'System.Drawing',
  'System.Collections.Generic',
  'System.Collections',
  'System.ComponentModel',
  'System.Windows.Forms',
  'System.Text',
  'System.Data'
)

$assemblies| ForEach-Object { $assembly = $_; [void][System.Reflection.Assembly]::LoadWithPartialName($assembly) }

[OpenQA.Selenium.Screenshot]$screenshot = $selenium.GetScreenshot()
$filename = 'full'
$screenshot_path = get-scriptdirectory
$image_path = ('{0}.{1}' -f $filename,'png')
$screenshot.SaveAsFile([System.IO.Path]::Combine($screenshot_path,$image_path),[System.Drawing.Imaging.ImageFormat]::Png)


#--------

[System.Drawing.Image]$image = [System.Drawing.Image]::FromFile([System.IO.Path]::Combine($screenshot_path,$image_path))
[System.Drawing.Graphics]$g = [System.Drawing.Graphics]::FromImage($image)
[System.Drawing.Bitmap]$bitmap1 = ([System.Drawing.Bitmap]$image)
$color = [System.Drawing.Color]::Red
[System.Drawing.Pen]$pen = New-Object System.Drawing.Pen ($color)
[System.Drawing.Rectangle]$rect = New-Object System.Drawing.Rectangle ($result4_hash['x'],$result4_hash['y'],$result4_hash['width'],$result4_hash['height'])
$g.DrawRectangle(
  $pen,
  $rect
)
[void]$g.Save()
$filename = 'modified'
$image_path = ('{0}.{1}' -f $filename,'png')
$bitmap1.Save([System.IO.Path]::Combine($screenshot_path,$image_path),[System.Drawing.Imaging.ImageFormat]::Png)

#--------

[System.Drawing.RectangleF]$rect = New-Object System.Drawing.RectangleF ($result4_hash['x'],$result4_hash['y'],$result4_hash['width'],$result4_hash['height'])
[System.Drawing.Image]$image = [System.Drawing.Image]::FromFile([System.IO.Path]::Combine($screenshot_path,$image_path))
[System.Drawing.Bitmap]$bitmap1 = ([System.Drawing.Bitmap]$image)
[System.Drawing.Bitmap]$bitmap2 = $bitmap1.Clone($rect,$bitmap1.PixelFormat)
$filename = 'cropped'
$image_path = ('{0}.{1}' -f $filename,'png')
$bitmap2.Save([System.IO.Path]::Combine($screenshot_path,$image_path),[System.Drawing.Imaging.ImageFormat]::Png)

Start-Sleep -Milliseconds 1000
# Cleanup
cleanup ([ref]$selenium)


