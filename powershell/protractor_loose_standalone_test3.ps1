#Copyright (c) 2021 Serguei Kouzmine
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
  [switch]$debug,
  [switch]$pause

)

function loadScript {
  param(
    [string]$scriptName = $null,
    [int]$version,
    [string[]]$shared_scripts_paths = @( 'c:\java\selenium\csharp\sharedassemblies'),
    [switch]$debug
  )
  if ($scriptName -eq $null) {
    throw [System.IO.FileNotFoundException] 'Script name can not be null.'
  }
  [string]$local:scriptDirectory = Get-ScriptDirectory
  [string]$local:scriptdata = $null
  write-debug ('Loading script "{0}"' -f $scriptName)

  $local:scriptPath = ("{0}\{1}" -f $local:scriptDirectory, $scriptName)
  if ( test-path -path $local:scriptPath){
    write-debug ('Found script in "{0}"' -f $local:scriptPath)
    $local:scriptdata = [IO.File]::ReadAllText($local:scriptPath)
  } else {
    foreach ($local:scriptDirectory in $shared_scripts_paths) {
      $local:scriptPath = ("{0}\{1}" -f $local:scriptDirectory, $scriptName)
      if ( test-path -path $local:scriptPath) {
        write-debug ('Found script in "{0}"' -f $local:scriptPath)
        $local:scriptdata = [IO.File]::ReadAllText($local:scriptPat)
      }
    }
  }
  write-debug ('Loaded "{0}"' -f $local:scriptdata)
  if ($local:scriptdata -eq $null -or $local:scriptdata -eq '' ) {
    throw [System.IO.FileNotFoundException] "Script file ${scriptName} was not be found or is empty."
  }
  return $local:scriptdata
}


function localPageURI {
  param(
    [string]$fileName = $null,
    [string]$scriptDirectory = (Get-ScriptDirectory),
    [switch]$debug
  )
  if ($fileName -eq $null) {
    throw [System.IO.FileNotFoundException] 'Script name can not be null.'
  }

  $local:filePath = ("{0}\{1}" -f $scriptDirectory, $fileName)
  if ( test-path -path $local:filePath){
    write-debug ('Found page in "{0}"' -f $local:filePath)
    $local:fileURI = ('file:///{0}' -f ($local:filePath -replace '\\', '/' ) )
  } else {
    throw [System.IO.FileNotFoundException] "Page file ${filePath} was not be found."
  }
  return $local:fileURI
}

function highlight {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [String]$color = 'yellow',
    [int]$delay = 300,
    [switch]$restore
  )
  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [string]$current_value = ''
[OpenQA.Selenium.IJavaScriptExecutor]$local:executor = [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value
  if ($restore) {
    # write-debug 'restore switch is provided'
   $current_value = $local:executor.ExecuteScript("const element = arguments[0]; const current_value =  element.style.border; element.setAttribute('style', arguments[1]); return current_value;", $element_ref.Value, "color: ${color}; border: 4px solid ${color};")
  } else {
    # write-debug 'restore switch was not provided'
    $local:executor.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,"color: ${color}; border: 4px solid ${color};")
  }

  start-sleep -Millisecond $delay
  if ($restore) {
    # write-debug 'restore switch is provided'
    [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].style.border=arguments[1];", $element_ref.Value,$current_value)
  } else {
    # write-debug 'restore switch was not provided'
    [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);", $element_ref.Value,'')
  }
}

# https://seleniumonlinetrainingexpert.wordpress.com/2012/12/03/how-to-automate-youtube-using-selenium-webdriver/

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

# http://poshcode.org/2887
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
# https://msdn.microsoft.com/en-us/library/system.management.automation.invocationinfo.pscommandpath%28v=vs.85%29.aspx
function Get-ScriptDirectory
{
  [string]$scriptDirectory = $null

  if ($host.Version.Major -gt 2) {
    $scriptDirectory = (Get-Variable PSScriptRoot).Value
    Write-Debug ('$PSScriptRoot: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
    Write-Debug ('$MyInvocation.PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    Write-Debug ('$PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
  } else {
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
      $scriptDirectory = $Invocation.PSScriptRoot
    } elseif ($Invocation.MyCommand.Path) {
      $scriptDirectory = Split-Path $Invocation.MyCommand.Path
    } else {
      $scriptDirectory = $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
    }
    return $scriptDirectory
  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


$headless = $false

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
  $selenium = $null
  if ($browser -match 'firefox') {

   #  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

  [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
  [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
  $selected_profile_object.setPreference('general.useragent.override',"Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/34.0")
  $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
  [OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

  # [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
  [NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')



  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
    # override

    # Oveview of extensions
    # https://sites.google.com/a/chromium.org/chromedriver/capabilities

    # Profile creation
    # https://support.google.com/chrome/answer/142059?hl=en
    # http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
    # using Profile
    # http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195


    # origin:
    # http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

    [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions

    $options.addArguments('start-maximized')
    # no-op option - re-enforcing the default setting
    $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))
    # if you like to specify another profile parent directory:
    # $options.addArguments('user-data-dir=c:/TEMP');

    $options.addArguments('--profile-directory=Default')

    [OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
    $capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability,$options)

    $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)

  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
    if ($version -ne $null -and $version -ne 0) {
      $capability.setCapability("version",$version.ToString());
    }

  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  if ($selenium -eq $null) {
    $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
    $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
  }
} else {

  Write-Host 'Running on phantomjs'
  $headless = $true
  $phantomjs_executable_folder = "C:\tools\phantomjs-2.0.0\bin"
  #  $phantomjs_executable_folder = "C:\tools\phantomjs-1.9.7"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.setCapability("ssl-protocol","any")
  $selenium.Capabilities.setCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.setCapability("takesScreenshot",$true)
  $selenium.Capabilities.setCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = $null
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

# Actual action .
$script_directory = Get-ScriptDirectory

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)

$fileURI = localPageURI -fileName 'ng_modal2.htm'
$selenium.Navigate().GoToUrl($fileURI)

start-sleep -millisecond 1000

$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($button_text_locator_script,$null,'Open modal',$null))
[NUnit.Framework.Assert]::IsNotNull($elements)
$elements[0].Click()

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))


$wait.PollingInterval = 150

# NOTE: signature-sensitive
$result = $wait.until([System.Func[[OpenQA.Selenium.IWebDriver],[OpenQA.Selenium.IWebElement]]] <# follows the code block #> {

  [string]$binding_script = loadScript -scriptName 'binding.js'
  $elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($binding_script,$null,'title',$null))
  # probably a bit slow
  # in .net those are properties
  $element =  $elements | where-object { $_.Displayed } | select-object -first 1
  return $element
})

write-output ('Fluent wait result: {0}' -f $result.getAttribute('innerHTML'))
[OpenQA.Selenium.IWebElement[]]$dialog = $result.FindElements([OpenQA.Selenium.By]::XPath('../..'))
highlight ([ref]$selenium) ([ref]$result)
$formdata = @{
	'email' = 'test_user@rambler.ru';
	'password' = 'secret'
}
$formdata.keys |  foreach-object {
  $field = $_
  $data = $formdata[$field]
  $css =('form label[ for="{0}"]' -f $field)
  $element = $dialog.FindElement([OpenQA.Selenium.By]::CssSelector($css))
  highlight ([ref]$selenium) ([ref]$element)
  $css =('form input#{0}' -f $field)
  $element = $dialog.FindElement([OpenQA.Selenium.By]::CssSelector($css))
  highlight ([ref]$selenium) ([ref]$element)
  $element.sendKeys($Data);
}
start-sleep -millisecond 1000
$css = 'button[type="submit"]'
$element = $dialog.FindElement([OpenQA.Selenium.By]::CssSelector($css))
highlight ([ref]$selenium) ([ref]$element)
$element.click()
start-sleep -millisecond 1000
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
