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
  # in the current environment phantomejs is not installed
  [string]$browser = 'firefox',
  [int]$version,
  [switch]$pause

)
function extract_match {

  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)

  )
  Write-Debug ('Extracting from {0}' -f $source)
  $local:results = {}
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  Write-Debug 'extract_match:'
  Write-Debug $local:results
  $result_ref.Value = $local:results.Media
}


function custom_pause {

  param([bool]$fullstop)
  # Do not close Browser / Selenium when run from Powershell ISE

  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
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

function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    # Ignore errors if unable to close the browser
    Write-Output (($_.Exception.Message) -split "`n")[0]

  }
}


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


$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder

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

$base_url = 'http://www.carnival.com'
$base_url = 'http://www3.uatcarnival.com/'

$selenium.Navigate().GoToUrl($base_url + '/')

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

Write-Output ('Started with {0}' -f $selenium.Title)


$selenium.Manage().Window.Maximize()

$destinations = @{
  'Alaska' = 'A';
  'Bahamas' = 'BH';
  'Bermuda' = 'BM';
  'Europe' = 'E';
  'Hawaii' = 'H'
  'Mexico' = 'M'
  'Canada/New England' = 'NN';
  'Transatlantic' = 'ET'
  'Caribbean' = 'C';
}
$ports = @{
  'Miami, FL' = 'MIA';
  'Jacksonville, FL' = 'JAX';
  'Fort Lauderdale, FL' = 'FLL';
  'New York, NY' = 'NYC';
  'Seattle, WA' = 'SEA';
  'Los Angeles, CA' = 'LAX';
  'Barcelona, Spain' = 'BCN';
}




function select_first_option {
  param([string]$choice = $null,
    [string]$label = $null
  )

  $select_name = $choice

  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500

  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)

  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 500

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  # TODO the css_selector needs refactoring

  $select_value_css_selector = ('div[class=option][data-param={0}] div.scrollable-content div.viewport div.overview ul li a' -f $select_name)
  $value_element = $null
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found...'
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null

  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  $value_element = $null

  $actions2 = $null
  Start-Sleep -Milliseconds 500



}
function select_criteria {

  param([string]$choice = $null,
    [string]$label = $null,
    [string]$option = $null,
    [System.Management.Automation.PSReference]$choice_value_ref = ([ref]$null),
    [string]$value = $null # note formatting

  )

  $select_name = $choice

  if ($value) {
    $selecting_value = $value
  } else {
    Write-Output ('"{0}"' -f $option)
    $selecting_value = $choice_value_ref.Value[$option]
    Write-Output $selecting_value
  }
  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  Start-Sleep -Milliseconds 500
  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)
  $select_element.Click()
  Start-Sleep -Milliseconds 500
  $select_element = $null



  $select_value_css_selector = ('div[class=option][data-param={0}] a[data-id={1}]' -f $select_name,$selecting_value)
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))

  $wait.PollingInterval = 150

  $value_element = $null
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found value_element...'
    $value_element
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))

  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $wait = $null
  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  Start-Sleep -Milliseconds 500
  $wait = $null
  $actions2 = $null
  $value_element = $null

}

function search_cruises {
  $css_selector1 = 'div.actions > a.search'
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  [NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'SEARCH'))
  Write-Output ('Clicking on ' + $element1.Text)
  $element1.Click()
  $element1 = $null


}
function count_cruises {
  param(
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)
  )

  $css_selector1 = "li[class*=num-found] strong"

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 500
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  Write-Output ('Found ' + $element1.Text)
  $result_ref.Value = $element1.Text

}


# TODO :finish parameters
$fullstop = (($PSBoundParameters['pause']) -ne $null)
# Do not care 

select_criteria -choice 'dest' -label 'Sail To' -Option 'Canada/New England' -choice_value_ref ([ref]$destinations)
select_criteria -choice 'port' -label 'Sail from' -Option 'New York, NY' -choice_value_ref ([ref]$ports)

search_cruises

Start-Sleep -Milliseconds 10000

$cruises_count_text = $null
count_cruises -result_ref ([ref]$cruises_count_text)
Write-Output $cruises_count_text

$result = 1
extract_match -Source $cruises_count_text -capturing_match_expression '\b(?<media>\d+)\b' -label 'media' -result_ref ([ref]$result)
Write-Output ('Found {0} itinearie(s)' -f $result)
[NUnit.Framework.Assert]::IsTrue(($result -match '\d+'))


#---
<# 
Cannot overwrite variable actions because the variable has been optimized. Try
using the New-Variable or Set-Variable cmdlet (without any aliases) or dot the
command trying to set the variable.
#>
function select_one_seailing {
  param([bool]$pick_random_sailing = $false,
    [int]$total_sailings = 1)

  [OpenQA.Selenium.Interactions.Actions]$local:actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  if ($pick_random_sailing) {
    if ($total_sailings -gt 1) {
      $select_choice = Get-Random -Minimum 1 -Maximum $total_sailings
    } else {
      $select_choice = 1
    }
    Write-Output ("Will try {0}th" -f $select_choice)
  }

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

  $result = $null
  $local:click_element = $null
  $local:learn_more_css_selector = 'div[class*=search-result] a.itin-select'

  Write-Output $local:learn_more_css_selector
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:learn_more_css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  if ($pick_random_sailing) {
    Write-Output 'Will scan many elements until find one'
    $elements1 = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($local:learn_more_css_selector))
    $learn_more_cnt = 0

    $elements1 | ForEach-Object {
      $element3 = $_

      if (($local:click_element -eq $null)) {
        if ($element3.Text -match '\S') {

          if (-not ($element3.Text -match 'LEARN MORE')) {
            $local:click_element = $element3
            Write-Output ('Found: {0} count = {1}' -f $element3.Text,$learn_more_cnt)

            $local:actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
            [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'color: yellow; border: 4px solid yellow;')
            Start-Sleep -Milliseconds 100
            [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'')
          }
        }
      }

    }

    # ---


    $element6 = $null

    $local:book_now_css_selector = 'div[class*=search-result]  li.action-col a[class*=btn-red]'

    $result = ''
    Write-Output $local:book_now_css_selector

    try {
      [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:book_now_css_selector))
    } catch [exception]{
      Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    }
    $elements2 = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($local:book_now_css_selector))
    $learn_more_cnt2 = 0
    $elements2 | ForEach-Object {
      $element4 = $_

      if (($element6 -eq $null)) {
        if ($element4.Text -match '\S') {

          if ($element4.Text -match 'Book Now') {
            $element6 = $element4
            Write-Output ('Found: {0} count = {1}' -f $element4.Text,($learn_more_cnt2 + 1))
            $local:actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element4).Build().Perform()

            [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'color: yellow; border: 4px solid yellow;')
            Start-Sleep -Milliseconds 100
            [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'')


            $result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$element4,'')).ToString()

            Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $element4.Text,$result)

          }

          # Temporarily removed LEARN MORE processing  and iterations 
          # 
        }
      }

    }
  } else {

    $local:book_now_css_selector = '"*[id *="sailings"] a[class*=btn-red]'
    $local:book_now_css_selector = 'div[id *="sailings"]  a[class*=btn-red]'
    Write-Output (' Looking via  quick path  : {0}' -f $local:book_now_css_selector)
    try {
      [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:book_now_css_selector))
    } catch [exception]{
      Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    }
    $elements2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:book_now_css_selector))
    if ($element4.Text -match 'Book Now') {
      $element6 = $element4
      Write-Output ('Found: {0}' -f $element4.Text)

      $local:actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element4).Build().Perform()
      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'color: yellow; border: 4px solid yellow;')
      Start-Sleep -Milliseconds 100
      [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'')

      $result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$element4,'')).ToString()

      Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $element4.Text,$result)
    }
  }
  if ($result -ne $null -and $result -ne '') {

    $xpath = ('//{0}' -f $result)
    Write-Output ('Using XPATH="{0}"' -f $xpath)

    [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
    $wait.PollingInterval = 100
    try {
      [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
    } catch [exception]{
      Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
    }

    [OpenQA.Selenium.IWebElement]$element4 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

    Write-Output ('Found: {0}  | {1}' -f $element4.Text,$cnt)

    $local:actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element4).Build().Perform()
    [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'color: yellow; border: 4px solid yellow;')
    Start-Sleep -Milliseconds 3000
    [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'')
    Start-Sleep -Milliseconds 3000
    $local:actions2 = $null

    $element4.Click()

  } else {
    throw "did not find anything"
  }
}


Write-Output ("Redirected to url: `n`t'{0}'" -f $selenium.url)

function be2_button_process {
  param(
    [string]$data_tag_page_suffix = ':number of travelers',
    [string]$button_text = 'Continue'
  )

  ###--
  $local:click_button = $null


  $local:css_selector1 = ('a[data-tag-page-suffix*="{0}"]' -f $data_tag_page_suffix)

  $local:xpath_selector1 = ''
  Write-Output $local:css_selector1

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  # TODO : cleanup !
  $local:buttons = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($local:css_selector1))
  $local:button_count = 0
  $local:buttons | ForEach-Object {
    $local:button = $_

    if (($local:click_button -eq $null)) {
      if ($local:button.Text -match '\S') {
        $local:click_button = $local:button
        if ($local:button.Text -match $button_text) {

          Write-Output ('Found: {0} count = {1}' -f $local:button.Text,($local:button_count + 1))
          [OpenQA.Selenium.Interactions.Actions]$local:action = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
          $local:action.MoveToElement([OpenQA.Selenium.IWebElement]$local:button).Build().Perform()
          [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$local:button,'color: yellow; border: 4px solid yellow;')
          Start-Sleep -Milliseconds 100
          [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$local:button,'')


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
          $local:xpath_selector1 = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$local:button,'')).ToString()

          Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $local:button.Text,$local:xpath_selector1)



        }


        # Temporarily removed LEARN MORE processing  and iterations 
        # 
      }
    }

  }


  if ($result -ne $null -and $result -ne '') {

  $local:button_xpath = ('//{0}' -f $local:xpath_selector1)
    Write-Output ('Using XPATH="{0}"' -f  $local:button_xpath)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($local:button_xpath)))
  } catch [exception]{
    Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
  }

  [OpenQA.Selenium.IWebElement]$local:button = $selenium.FindElement([OpenQA.Selenium.By]::XPath($local:button_xpath))

  Write-Output ('Found: {0} {1}' -f $local:button.Text,$cnt)
  [OpenQA.Selenium.Interactions.Actions]$local:actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $local:actions.MoveToElement([OpenQA.Selenium.IWebElement]$local:button).Build().Perform()
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$local:button,'color: yellow; border: 4px solid yellow;')
  Start-Sleep -Milliseconds 3000
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$local:button,'')
  Start-Sleep -Milliseconds 3000

  $local:button.Click()
  } else {
    throw "did not find anything"
  }

}

#---

select_one_seailing -pick_random_sailing $true

Start-Sleep -Milliseconds 3000

[NUnit.Framework.StringAssert]::Contains('/BookingEngine/Booking/Book/',$selenium.url,{})
[NUnit.Framework.StringAssert]::Contains('evsel=',$selenium.url,{})

be2_button_process -data_tag_page_suffix ":number of rooms"
be2_button_process -data_tag_page_suffix ':number of travelers'
be2_button_process -data_tag_page_suffix ':check for deals'
Start-Sleep -Seconds 10
be2_button_process -data_tag_page_suffix ':stateroom category selection'
<#
Exception : Unable to locate element: {"method":"css selector","selector":"a[da
ta-tag-page-suffix*=\":stateroom category selection\"]"} ...
#>
be2_button_process -data_tag_page_suffix ':stateroom type selection'
custom_pause -fullstop $fullstop

# At the end of the run - do not close Browser / Selenium when executing from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}


<#

4 Day to Canada/New England from New York, NY
Carnival Splendor - Sailing Date: Aug 20, 2015

number-of-staterooms



div.number-rooms
a.option-select
div class="content-container"
div[@class*="room-sections"]
a[@data-tag-page-suffix=":number of travelers"]



div class="content">
a class="cta-green travelers-cta tealium" data-tag-page-suffix=":check for deals"

div class="booking-engine-app slideup
div class="content">
Which Type Of Room Is Right For


button class="cta-green tealium" data-tag-page-suffix=":stateroom category selection"


a class="option-select cta-green tealium" data-tag-page-suffix=":stateroom type selection"



div class="rates" offer="offer"


button class="cta tealium" data-tag-page-suffix=":choose rate"

a class="cta first-child tealium" data-tag-page-suffix=":choose location"

Back

li class="last-child disabled"
div class="sold-out-label ng-scope" ng-if="isFDisabled"> Sold Out </div>


button class="cta select tealium ng-binding no-price" data-tag-page-suffix=":choose deck" data-tag-_events="event71" data-tag-_link-track-events="event71" data-tag-_link-track-vars="events" ng-click="selectDeck(deck,$event)" ui-sref="next" ng-class="{'no-price':!deck.rateDiffPerPersonPerDay}" ccl-tealium-multicabin="">Select </button>


input class="radio ng-pristine ng-untouched ng-valid ng-isolate-scope" type="radio" data-ccl-map-highlight="" ng-value="room" ng-model="currentSelection.item" ng-checked="room === currentSelection.item" name="roomSelection" value="[object Object]" checked="checked">
R52


'Error getting Prices' 
h2>
We're
<span class="accent"> almost done </span>
</h2>
#>

