#Copyright (c) 2015, 2018 Serguei Kouzmine
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
  [string]$browser = '',
  # only 'grid' version is currently working. 
  [switch]$grid,
  # [switch]$headless,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  write-debug 'Running on grid'
  $hub_host = '127.0.0.1'
  $hub_port = '4444'
  $uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))
  $use_remote_driver = $true
} else {
  $use_remote_driver = $false
}

# https://blogs.technet.microsoft.com/heyscriptingguy/2013/07/09/simplify-your-script-by-creating-powershell-type-accelerators/
# https://blogs.technet.microsoft.com/heyscriptingguy/2013/07/08/use-powershell-to-find-powershell-type-accelerators/
# NOTE: with  Powershell 3.x  use the original recipe
# [accelerators] | get-member -Static -MemberType method -Name add | fl -Force
# Powershell 5.0 : Unable to find type [accelerators].
# https://social.technet.microsoft.com/wiki/contents/articles/31895.adding-type-accelerators-in-the-powershell-5-0-april-2015-preview.aspx

$obj_accel = [PowerShell].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$obj_accel::Add("AList", [System.Collections.ArrayList])
$obj_accel.GetFields([System.Reflection.BindingFlags]"static, nonpublic") | out-null

$obj_accel.GetField("userTypeAccelerators", [System.Reflection.BindingFlags]"Static,NonPublic").GetValue($obj_accel)

$builtinField = $obj_accel.GetField("builtinTypeAccelerators", [System.Reflection.BindingFlags]"Static,NonPublic")
$builtinField.SetValue($builtinField, $obj_accel::Get)

# add accelerators
$obj_accel::Add('RemoteWebDriver', [OpenQA.Selenium.Remote.RemoteWebDriver])
$obj_accel::Add('ChromeDriver', [OpenQA.Selenium.Chrome.ChromeDriver])
$obj_accel::Add('WebDriverWait', [OpenQA.Selenium.Support.UI.WebDriverWait])
$obj_accel::Add('ExpectedConditions', [OpenQA.Selenium.Support.UI.ExpectedConditions])
$obj_accel::Add('ExpectedConditions', [OpenQA.Selenium.Support.UI.ExpectedConditions])
$obj_accel::Add('By', [OpenQA.Selenium.By])
$obj_accel::Add('Actions', [OpenQA.Selenium.Interactions.Actions])
$obj_accel::Add('SelectElement', [OpenQA.Selenium.Support.UI.SelectElement])
# $obj_accel::Add('IWebElement', [OpenQA.Selenium.IWebElement])
# cannot make accelerators to interfaces:
# [8780:8704:1021/154106.756:ERROR:mf_helpers.cc(14)] Error in dxva_video_decode_accelerator_win.cc on line 510

if ($browser -match 'firefox') {
  if ($use_remote_driver) {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
  } else {
  }
} elseif ($browser -match 'chrome') {
      $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
      if ($use_remote_driver) {
        $selenium = New-Object RemoteWebDriver($uri,$capability)
      } else {
        $driver_environment_variable = 'webdriver.chrome.driver'
        if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)){
          [Environment]::SetEnvironmentVariable( $driver_environment_variable, "${selenium_drivers_path}\chromedriver.exe")
        }

        # override

        # Oveview of extensions
        # https://sites.google.com/a/chromium.org/chromedriver/capabilities

        $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
        [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
        $selenium = New-Object ChromeDriver ($options)
      }
}

# if ([bool]$PSBoundParameters['headless'].IsPresent) {
#   write-debug 'Running headless'
# }

$base_url = 'https://datatables.net/examples/api/form.html'
$selenium.Navigate().GoToUrl($base_url)
$wait = New-Object WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
try {
  [void]$wait.Until([ExpectedConditions]::ElementExists([By]::ClassName("logo")))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}


$table_id = 'example';
$table_element = $selenium.FindElement([By]::Id($table_id))  

# two-step input

$text_input_css_selector = 'input[id="row-5-age"]'

$cell_text = 'Software Developer'

# Find a specific leftmost column input field
$text_input_element = $table_element.FindElement([By]::CssSelector($text_input_css_selector))
write-output $text_input_element.getAttribute('outerHTML')


$actions = new-object Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$text_input_element).Build().Perform()

highlight ([ref]$selenium) ([ref]$text_input_element)

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
