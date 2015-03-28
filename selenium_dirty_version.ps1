param(
  [switch]$browser
)

# http://poshcode.org/1942
function Assert {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,ParameterSetName = 'Script',Mandatory = $true)]
    [scriptblock]$Script,
    [Parameter(Position = 0,ParameterSetName = 'Condition',Mandatory = $true)]
    [bool]$Condition,
    [Parameter(Position = 1,Mandatory = $true)]
    [string]$message)

  $message = "ASSERT FAILED: $message"
  if ($PSCmdlet.ParameterSetName -eq 'Script') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = & $Script
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }
  if ($PSCmdlet.ParameterSetName -eq 'Condition') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = $Condition
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }

  if (!$success) {
    throw $message
  }
}

<#
 # HRESULT: 0x80131515
 # http://stackoverflow.com/questions/18801440/powershell-load-dll-got-error-add-type-could-not-load-file-or-assembly-webdr
 # Streams v1.56 - Enumerate alternate NTFS data streams
 #>

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'ThoughtWorks.Selenium.Core.dll',
  'ThoughtWorks.Selenium.UnitTests.dll',
  'ThoughtWorks.Selenium.IntegrationTests.dll',
  'Moq.dll'
)

$shared_assemblies_folder = 'c:\developer\sergueik\csharp\SharedAssemblies'
pushd $shared_assemblies_folder
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


$phantomjs_executable_folder = 'C:\tools\phantomjs'

if ($PSBoundParameters['browser']) {
  $selemium_driver_folder = 'c:\java\selenium'
  # port check omitted
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\hub.cmd"
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\node.cmd"
  Start-Sleep 10
  # also for grid testing 

  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
  $uri = [System.Uri]('http://127.0.0.1:4444/wd/hub')
  $driver = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $driver = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $driver.Capabilities.SetCapability('ssl-protocol','any');
  $driver.Capabilities.SetCapability('ignore-ssl-errors',$true);
  $driver.Capabilities.SetCapability("takesScreenshot",$false);
  $driver.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")

  # currently unused 
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder);

}

# http://www.andykelk.net/tech/headless-browser-testing-with-phantomjs-selenium-webdriver-c-nunit-and-mono

[void]$driver.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(10))
[string]$base_url = $driver.Url = 'http://www.wikipedia.org';
$driver.Navigate().GoToUrl(('{0}/' -f $base_url))
[OpenQA.Selenium.Remote.RemoteWebElement]$queryBox = $driver.FindElement([OpenQA.Selenium.By]::Id('searchInput'))

# write-output $queryBox.GetType() | format-table -autosize

$queryBox.Clear()
$queryBox.SendKeys('Selenium')
$queryBox.SendKeys([OpenQA.Selenium.Keys]::ArrowDown)
$queryBox.Submit()
$driver.FindElement([OpenQA.Selenium.By]::LinkText('Selenium (software)')).Click()
$title = $driver.Title

assert -Script { ($title.IndexOf('Selenium (software)') -gt -1) } -Message $title
# [OpenQA.Selenium.Screenshot]
# $screenshot = [OpenQA.Selenium.GetScreenshot] $driver 
$screenshot = $driver.GetScreenshot() # [OpenQA.Selenium.OutputType]::FILE
$screenshot.SaveAsFile('C:\developer\sergueik\powershell_ui_samples\a.png',[System.Drawing.Imaging.ImageFormat]::Png)

try {
  $driver.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}
# old
# http://www.incyclesoftware.com/2014/02/executing-selenium-ui-tests-release-management/
# http://stackoverflow.com/questions/11698222/best-way-to-take-screenshot-of-a-web-page
# note:
# https://sepsx.codeplex.com/
