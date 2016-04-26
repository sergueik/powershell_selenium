About
=====
Collection of Powershell scripts and modules for work with Selenium C# Client 

![Developing Selenium Scripts in Powershell ISE](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/55a.png)

Prerequisites
------------- 
Common functionality is in the modules `page_navigation_common.psm1` and `selenium_common.psm1`
Powershell uses C# Selenium Client API library and a few of standard asemblies which are stored 
in the location `$env:SHARED_ASSEMBLIES_PATH`  (default is `C:\developer\sergueik\csharp\sharedassemblies`):

		log4net.dll
		nunit.core.dll
		nunit.framework.dll
		nunit.mocks.dll
		pnunit.framework.dll
		WebDriver.dll
		WebDriver.Support.dll

The Selenium JARs are supposed to be installed under `c:\java\selenium`:
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

The standard Java applications are all supposed to be installed under `c:\java`:

		c:\java\apache-maven-3.3.3
		c:\java\groovy-2.4.4
		c:\java\jdk1.7.0_79
		c:\java\jre7
		c:\java\selenium

The phantomjs is supposed to be installed under `C:\tools\phantomjs-2.0.0\bin`. 

The Java applications  and framework versions  need to be updated in `hub.cmd`, `node.cmd` e.g.	
```
set SELENIUM_VERSION=2.47.1
set GROOVY_VERSION=2.4.4
set JAVA_VERSION=1.7.0_79
set MAVEN_VERSION=3.3.3
set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
set GROOVY_HOME=c:\java\groovy-%GROOVY_VERSION%
```
Alternatively the test script can provide 
```
[string]$hub_host
[string]$hub_port
[bool]$use_remote_drive
```
when the test script provides the `grid` switch but does not specify `$hub_host`, the Selenium hub and node are launched locally on port `4444`.

Skeleton script
---------------
To run a Selenium test in Powershell, start with the following script:
```
param(
  [string]$browser = '',
  [string]$base_url = 'https://www.indiegogo.com/explore#',
  [switch]$grid,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
} else {
  $selenium = launch_selenium -browser $browser
}
$selenium.Navigate().GoToUrl($base_url)


# Cleanup
cleanup ([ref]$selenium)

```
Run the script with the option:
```
. ./test_script -browser chrome
```
Scripts
-------
There is over 50 Standalone scripts illustrating varios Selenium-related tasks in a problem-solution fashion. 

Modules
-------

|Module|Description 
| -------|:-------------:|
| selenium_utils.psd1||
| page_navigation_common.psm1||
| selenium_common.psm1||

Usage:
```
  $browser_name = 'chrome'
  $MODULE_NAME = 'selenium_utils.psd1'
  Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
  $selenium = launch_selenium -browser $browser_name
```

Note: 

Older scripts contain the same functionality inline. There are few scripts that still do, for some reason.

History
-------
Sat Mar 28 16:24:58 2015 extracted selenium scripts of [powershell_ui_samples](https://github.com/sergueik/powershell_ui_samples)  repository



![Selenium Execution Pipeline](https://raw.githubusercontent.com/sergueik/powershell_selenium/master/screenshots/selenium_execution_pipeline.png)

Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)

