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
  [string]$browser = 'chrome',
  [switch]$mobile,# currently unused
  [string]$base_url = 'http://www.hollandamerica.com/main/Main.action',
  [switch]$savedata,
  [switch]$pause

)

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

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$MODULE_NAME = 'selenium_utils.psd1'
import-module -name ('{0}/{1}' -f '.',  $MODULE_NAME)

$selenium = launch_selenium -browser $browser

$verificationErrors = New-Object System.Text.StringBuilder
$phantomjs_executable_folder = 'C:\tools\phantomjs'


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


