### Info
Collection of Powershell scripts and modules for work with Selenium C# Client
There is over 70 standalone scripts illustrating varios Selenium-related tasks in a problem-solution fashion.
Common functionality is put into  `page_navigation_common.psm1` and `selenium_common.psm1` modules.

![Developing Selenium Scripts in Powershell ISE](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/55a.png)

### Usage:
To run a Selenium test in Powershell, start with the following script:
```powershell
param(
  [string]$browser = '',
  [string]$base_url = 'https://www.indiegogo.com/explore#',
  [switch]$grid,
  [switch]$pause
)
Import-Module -Name ('{0}/{1}' -f '.', 'selenium_utils.psd1')
$browser = 'chrome'
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
} else {
  $selenium = launch_selenium -browser $browser
}
$selenium.Navigate().GoToUrl($base_url)
# your test here ...
# Cleanup
cleanup ([ref]$selenium)
```
Run the script with the option:
```powershell
. ./test_script.ps1 -browser chrome
```

### Prerequisites
Powershell uses C# Selenium Client API library and needs those and a few of standard asemblies be available
in the directory `$env:SHARED_ASSEMBLIES_PATH`  (default is `C:\developer\sergueik\csharp\sharedassemblies`):
```
log4net.dll
nunit.core.dll
nunit.framework.dll
nunit.mocks.dll
WebDriver.dll
WebDriver.Support.dll
```
The Selenium jars and drivers are supposed to be installed under `c:\java\selenium`:
```
chromedriver.exe
hub.cmd
hub.json
hub.log4j.properties
log4j-1.2.17.jar
node.cmd
node.json
node.log4j.properties
node.xml
selenium-server-standalone-2.47.1.jar
selenium-server-standalone-2.53.1.jar
```
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

Alternatively one may specify the `$hub_host`, `$hub_port` arguments and a `$use_remote_driver` flag to make script connect to `RemoteDriver`
By default hub and node are launched locally on port `4444` when `$use_remote_driver` is set.


#### Note:

Older scripts contain the same functionality inline. There are few scripts that still do, for some reason.

![Selenium Execution Pipeline](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/selenium_execution_pipeline.png)

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)

