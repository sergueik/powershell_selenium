#Copyright (c) 2015,2021 Serguei Kouzmine
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
  [string]$base_url = 'http://juliemr.github.io/protractor-demo/',
  [switch]$debug,
  [switch]$pause

)

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

function call_flash_object { 
param(
    [System.Management.Automation.PSReference]$selenium_ref,
[string]$function_name= $null ,
[string[]]$arguments = @()
)

  $local:driver_proxy= 'movie_player'
  $local:selenium = $selenium_ref.Value
  $local:arglist  = $arguments  -join ','
# TODO :trim properly
# $arguments | foreach-object
  $local:script = ("return document.{0}.{1}({2});" -f $local:driver_proxy,$function_name,$local:arglist)
  write-host $local:script -foregroundcolor 'green'
  $local:result = ([OpenQA.Selenium.IJavaScriptExecutor]$local:selenium).executeScript($local:script)
  write-host $local:result  -foregroundcolor 'blue'
  return $local:result
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
[string]$model_locator_script = @'
var findByModel = function(model, using, rootSelector) {
    var root = document.querySelector(rootSelector || 'body');
    using = using || '[ng-app]';
    if (angular.getTestability) {
        return angular.getTestability(root).
        findModels(using, model, true);
    }
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = '[' + prefixes[p] + 'model="' + model + '"]';
        var elements = using.querySelectorAll(selector);
        if (elements.length) {
            return elements;
        }
    }
};
var using = arguments[0] || document;
var model = arguments[1];
var rootSelector = arguments[2];
return findByModel(model, using, rootSelector);
'@
[string]$binding_locator_script = @'
var findBindings = function(binding, exactMatch, using, rootSelector) {
    var root = document.querySelector(rootSelector || 'body');
    using = using || document;
    if (angular.getTestability) {
        return angular.getTestability(root).
        findBindings(using, binding, exactMatch);
    }
    var bindings = using.getElementsByClassName('ng-binding');
    var matches = [];
    for (var i = 0; i < bindings.length; ++i) {
        var dataBinding = angular.element(bindings[i]).data('$binding');
        if (dataBinding) {
            var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
            if (exactMatch) {
                var matcher = new RegExp('({|\\s|^|\\|)' +
                    /* See http://stackoverflow.com/q/3561711 */
                    binding.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&') +
                    '(}|\\s|$|\\|)');
                if (matcher.test(bindingName)) {
                    matches.push(bindings[i]);
                }
            } else {
                if (bindingName.indexOf(binding) != -1) {
                    matches.push(bindings[i]);
                }
            }
        }
    }
    return matches; /* Return the whole array for webdriver.findElements. */
};

var using = arguments[0] || document;
var binding = arguments[1];
var rootSelector = arguments[2];

var exactMatch = arguments[3];
if (typeof exactMatch === 'undefined') {
    exactMatch = true;
}

return findBindings(binding, exactMatch, using, rootSelector);
'@
[string]$repeater_locator_script = @'
var repeaterMatch = function(ngRepeat, repeater, exact) {
  if (exact) {
    return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
    split('=')[0].trim() == repeater;
  } else {
    return ngRepeat.indexOf(repeater) != -1;
  }
}

var findAllRepeaterRows = function(using, repeater) {

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        rows.push(repeatElems[i]);
      }
    }
  }
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        var elem = repeatElems[i];
        while (elem.nodeType != 8 ||
          !(elem.nodeValue.indexOf(repeater) != -1)) {
          if (elem.nodeType == 1) {
            rows.push(elem);
          }
          elem = elem.nextSibling;
        }
      }
    }
  }
  return rows;
};
var using = arguments[0] || document;
var repeater = arguments[1];
return findAllRepeaterRows(using, repeater);
'@
[string]$options_locator_script = @'
var findByOptions = function(options, using) {
    using = using || document;
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = '[' + prefixes[p] + 'options="' + options + '"] option';
        var elements = using.querySelectorAll(selector);
        if (elements.length) {
            return elements;
        }
    }
};

var using = arguments[0] || document;
var options = arguments[1];
return findByOptions(options, using);
'@
[string]$button_text_locator_script = @'
var findByButtonText = function(searchText, using) {
    using = using || document;
    var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
    var matches = [];
    for (var i = 0; i < elements.length; ++i) {
        var element = elements[i];
        var elementText;
        if (element.tagName.toLowerCase() == 'button') {
            elementText = element.textContent || element.innerText || '';
        } else {
            elementText = element.value;
        }
        if (elementText.trim() === searchText) {
            matches.push(element);
        }
    }
    return matches;
};
var using = arguments[0] || document;
var searchText = arguments[1];
return findByButtonText(searchText, using);
'@



$selenium.Navigate().GoToUrl($base_url)

$title = $selenium.Title
sleep -millisecond 100
[NUnit.Framework.Assert]::AreEqual('Super Calculator', $title)

$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($model_locator_script,$null,'first',$null))
[NUnit.Framework.Assert]::IsTrue(($elements -ne $null))
$first = $elements[0]
$first.Clear()
$first.sendKeys('40')

$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($model_locator_script,$null,'second',$null))
[NUnit.Framework.Assert]::IsNotNull($elements)
$second = $elements[0]
$second.Clear()
$second.sendKeys('2')


$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($options_locator_script,$null,'value for (key, value) in operators',$null))
[NUnit.Framework.Assert]::IsNotNull($elements)
$operator = $elements[0]
$operator.Click()

$goButton = $selenium.FindElement([OpenQA.Selenium.By]::Id('gobutton'))
[NUnit.Framework.Assert]::AreEqual('Go!', $goButton.Text) # Contains
$elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($button_text_locator_script,$null,'Go!',$null))
[NUnit.Framework.Assert]::IsNotNull($elements)
$goButton = $elements[0]
[NUnit.Framework.Assert]::That(($goButton.Text -match 'Go!')) # Contains
$goButton.Click()

$script_timeout = 120
# only available in latest versions of Selenium assembly
try {
  [void]($selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script_timeout)))
} catch [System.Management.Automation.RuntimeException] { # NOTE: fully specified class
  write-output ('Exception (ignored): {0}' -f $_.Exception.Message)
}

$wait_seconds = 10
$wait_polling_interval = 50

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
$wait.PollingInterval = $wait_polling_interval
$wait.IgnoreExceptionTypes([OpenQA.Selenium.WebDriverTimeoutException],[OpenQA.Selenium.WebDriverException])
# TODO: predicate
# see for Java
# https://www.techbeamers.com/webdriver-fluent-wait-command-examples/
# https://gist.github.com/djangofan/cd96628f9ae2b4927c4d
# https://www.codeproject.com/Articles/787565/Lightweight-Wait-Until-Mechanism

try {
  [void]$wait.Until([Func[[OpenQA.Selenium.IWebDriver],[Bool]]] {
    param(
      [OpenQA.Selenium.IWebDriver] $driver
    )
    # write-host 'Inside Wait'
    $elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($binding_locator_script,$null,'latest',$null))
    if (($elements -eq $null) -or ($elements.size -eq 0)) {
      return $false
    }
    $element = $elements[0]
    if ($element.Text -match '[0-9]+') {
      return $true
    } else {
      return $false
    }
  })

  $elements = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($binding_locator_script,$null,'latest',$null))
  [NUnit.Framework.Assert]::IsNotNull($elements)
  $latest = $elements[0]
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::TextToBePresentInElement($latest, '42'))
  highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$latest) -Delay 150
  [NUnit.Framework.Assert]::AreEqual('42', $latest.Text )

} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  write-output ('Timeout Exception : {0}' -f (($_.Exception.Message) -split "`n")[0])
} catch [Exception]{
  write-output ("Exception : {0} ...`n{1}" -f (($_.Exception.Message) -split "`n")[0],$_.Exception.Type)
}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
