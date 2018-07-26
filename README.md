### Info
Collection of Powershell scripts and modules for work with Selenium C# Client
illustrating varios Selenium-related tasks in a problem-solution fashion.
Common functionality is put into  `page_navigation_common.psm1` and `selenium_common.psm1` modules.

![Developing Selenium Scripts in Powershell ISE](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/55a.png)

### Basic Usage:
To run a Selenium test in Powershell, start with the following script:
```powershell

param(
  [string]$browser = '',
  [string]$base_url = 'https://www.indiegogo.com/explore#',
  [switch]$grid,
  [switch]$pause
)
  import-module -Name ('{0}/{1}' -f '.', 'selenium_utils.psd1')

  # create WebDriver object
  if ([bool]$PSBoundParameters['grid'].IsPresent) {
    $selenium = launch_selenium -browser $browser -grid
  } else {
    $selenium = launch_selenium -browser $browser
  }
  set_timeouts ([ref]$selenium)
  $selenium.Navigate().GoToUrl($base_url)
  # create Actions object
  [OpenQA.Selenium.Interactions.Actions]$actions = new-object OpenQA.Selenium.Interactions.Actions($selenium)

  # create WebDriverWait object
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = new-object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  # iterate over ingiegogo campains ...

  $project_card_tagname = 'discoverable-card'
  $project_card_title_selector = 'div[class*="discoverableCard-title"]'

  [object[]]$project_card_elements = $selenium.FindElements([OpenQA.Selenium.By]::TagName($project_card_tagname))

  Write-Output ('{0} project card found' -f $project_card_elements.count)
  $project_card_elements | ForEach-Object {
    $project_card_element = $_
    [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_card_element).Build().Perform()
    Write-Output $project_card_element.Text
    Write-Output '----'
    highlight ([ref]$selenium) ([ref]$project_card_element)
    [object]$project_card_title = $project_card_element.FindElement([OpenQA.Selenium.By]::CssSelector($project_card_title_selector))
    flash ([ref]$selenium) ([ref]$project_card_title)
    # continue test
  }

  # Cleanup
  cleanup ([ref]$selenium)
```
Run the script with the option:
```powershell
. ./test_script.ps1 -browser chrome
```

### Prerequisites
Powershell relies on C# Selenium Client API library for interaction with the browser, Nunit for assertions and log4net for logging.
Thus needs those asemblies need to be available in the directory `$env:SHARED_ASSEMBLIES_PATH`
(default used in this project is `c:\java\selenium\csharp\sharedassemblies`):
```
log4net.dll
nunit.core.dll
nunit.framework.dll
nunit.mocks.dll
WebDriver.dll
WebDriver.Support.dll
```

Download past versions download links on nuget:
  * [Selenium.WebDriver v. 2.53.1](https://www.nuget.org/packages/Selenium.WebDriver/2.53.1)
  * [Selenium.Support v. 2.53.1](https://www.nuget.org/packages/Selenium.Support/2.53.1)

e.g. with
```powershell
$ProgressPreference = 'silentlyContinue' ;
pushd $env:TEMP
$download_api_href = 'https://www.nuget.org/api/v2/package/Selenium.Support/2.53.1' ;
$output_file = 'Selenium.Support.nupkg' ;
Invoke-WebRequest -uri $download_api_href -OutFile $output_file ;
Add-Type -assembly 'system.io.compression.filesystem'

[IO.Compression.ZipFile]::ExtractToDirectory("${env:TEMP}\${output_file}", $env:TEMP)
copy-item -path .\lib\net35\WebDriver.Support.dll -destination $shared_assemblies_path
```
NOTE: you will have to close the powershell window that has been running Powershell Selenium scripts to avoid __The process cannot access the file because it is being used by another process__ error.

There is no strict enforcement to use Selenium 2.x - the Selenium 3.x libraries work as well. In particular, headless mode can be enabled by passing the `-headless` flag to the `launch_selenium` helper method.OB

The Selenium jars and drivers are loaded from `$env:SELENIUM_DRIVERS_PATH` or from `$env:SELENIUM_PATH` (whichever is found set first) or from `c:\java\selenium` by default:
```
chromedriver.exe
geckodriver.exe
IEDriverServer.exe
hub.cmd
hub.json
hub.log4j.properties
log4j-1.2.17.jar
node.cmd
node.json
node.log4j.properties
node.xml
selenium-server-standalone-2.53.1.jar
```
The recent versions of the drivers are found in

  * [chromedriver](https://chromedriver.storage.gooeapis.com/)
  * [edgedriver](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/)
  * [geckodriver](https://api.github.com/repos/mozilla/geckodriver/releases)
  * [iedriver](https://selenium-release.storage.googleapis.com/)

The Java runtime is supposed to be installed under `c:\java`:
```
c:\java\jdk1.7.0_79
c:\java\jre7
c:\java\selenium
```

The .net Selenium assemblies can be loaded from alternative location / withspeciic build versos via the following code:

```powershell
$shared_assemblies = @{
  'WebDriver.dll'         = '3.13.0';
  'WebDriver.Support.dll' = '3.13.0';
  'nunit.core.dll'        = $null;
  'nunit.framework.dll'   = '2.6.3';
}

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.', $MODULE_NAME)

$custom_shared_assemblies_path = 'c:\users\sergueik\Downloads'

load_shared_assemblies_with_versions -path $custom_shared_assemblies_path -shared_assemblies $shared_assemblies


```
this has to be done before initializing the browser
```poweshell
  $selenium = launch_selenium -browser $browser
```

The phantomjs is supposed to be installed under `C:\tools\phantomjs-2.0.0\bin`.

The mockup of Selenium grid is launched on the local host TCP port `4444` via `hub.cmd`, `node.cmd`:	
```cmd
set SELENIUM_VERSION=2.53.1
set JAVA_VERSION=1.7.0_79
set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
PATH=%JAVA_HOME%\bin;%PATH%;c:\Program Files\Mozilla Firefox
java -XX:MaxPermSize=1028M -Xmn128M -jar selenium-server-standalone-%SELENIUM_VERSION%.jar -port %HTTP_PORT% -role hub
```

Alternatively one may specify the `$hub_host`, `$hub_port` arguments and a `$use_remote_driver` switch
to make script connect to Selenium through `Remote Driver` class with `http://${hub_host}:${hub_port}/wd/hub`
By default hub and node are launched locally on port `4444` when `$use_remote_driver` is set.

### Note:

Using raw .Net method calls from Powershell looks rather verbosely:
```powershell
(New-Object OpenQA.Selenium.Interactions.Actions ($selenium)).MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector)))
[NUnit.Framework.StringAssert]::AreEqualIgnoringCase($expected_text, $element.Text)

```
and naturally this leads to a big number of helper methods written in this project.

The common functionality for locating elements, changing the element visual appearance on the page
is mostly refactored into the modules `selenium_common.psm1` and `page_navigation_common.psm1`
Older scripts contained the same functionality inline, few scripts still do, for some reason.
The Powershell named function arguments "calling convention" is used in the project e.g:

```powershell

[string]$css_selector = 'input#mainSearch'
[object]$element = find_element -css_selector $css_selector
highlight ([ref]$selenium) ([ref]$element)
```
or
```powershell
highlight -element ([ref]$element) -color 'green' -selenium_ref ([ref]$selenium)

```

![Selenium Execution Pipeline](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/selenium_execution_pipeline.png)

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
