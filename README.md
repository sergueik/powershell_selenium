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

  # test begins ...

  $css_selector = 'a#logo'
  Write-Debug ('Trying CSS Selector "{0}"' -f $css_selector)
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  } catch [exception]{
    Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
  }

  [OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

  $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()

  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element2,'background-color:  blue;')

  Start-Sleep -Milliseconds 100
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element2,'')

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
(default is `C:\selenium\csharp\sharedassemblies`):
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

There is no strict enforcement to use Selenium 2.x - the Selenium 3.x libraries work as well.

The Selenium jars and drivers are loaded from `c:\java\selenium` by default:
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
The phantomjs is supposed to be installed under `C:\tools\phantomjs-2.0.0\bin`.

The Selenium is launched via `hub.cmd`, `node.cmd`:	
```cmd
set SELENIUM_VERSION=2.53.1
set JAVA_VERSION=1.7.0_79
set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
PATH=%JAVA_HOME%\bin;%PATH%;c:\Program Files\Mozilla Firefox
java -XX:MaxPermSize=1028M -Xmn128M -jar selenium-server-standalone-%SELENIUM_VERSION%.jar -port %HTTP_PORT% -role hub
```

Alternatively one may specify the `$hub_host`, `$hub_port` arguments and a `$use_remote_driver` switch 
to make script connect to `RemoteDriver`
By default hub and node are launched locally on port `4444` when `$use_remote_driver` is set.

#### Note:

The common functionality is mostly refactored into the modules `selenium_common.psm1` and `page_navigation_common.psm1` 
Older scripts contained the same functionality inline, few scripts still do, for some reason.

![Selenium Execution Pipeline](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/selenium_execution_pipeline.png)

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)