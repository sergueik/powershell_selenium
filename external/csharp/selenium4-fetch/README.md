### Info

this directory contains a basic skeleton example to practice Selenum WebDriver BIDI and CDP Command examples from
[Selenium 4 Chrome DevTools Documentation](https://www.selenium.dev/documentation/webdriver/bidirectional/chrome_devtools/)
and other sources 
which was compiled against .Net Framework 4.5
The [Selenium .NET API Docs](https://www.selenium.dev/selenium/docs/api/dotnet/)


### Note

When compiled in Sharp Develop (which is discontinued) see the nuget error`
```text
NOTE: Selenium.WebDriver' already has a dependency defined for 'Newtonsoft.Json'.
Exited with code: 1
```
the workaround is to download the package manually:
```powershell
$localfile = (resolve-path '.').path + '\' + 'selenium.webdriver.zip'
$url = 'https://www.nuget.org/api/v2/package/Selenium.WebDriver/4.11.0'
$url = 'https://www.nuget.org/api/v2/package/Selenium.WebDriver/4.8.2'
```

then
```powershell
 [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
 ```
to prevent 

```text
The underlying connection was closed: An unexpected error occurred on a send.
```
error

then
```powershell
$progressPreference  = 'SilentlyContinue'
```
to suppress the time consuming Powershell console download progress indicator
then
```powershell
Invoke-WebRequest -Uri $url -OutFile $localfile
mkdir .\packages\Selenium.WebDriver.4.8.2\lib\net45
```
and unzip the file `lib\net45\WebDriver.dll` from `selenium.webdriver.zip` manually into `packages\Selenium.WebDriver.4.8.2\lib\net45`

### Note

NOTE: With `Selenium WebDriver` __4.11__ the program crashes with excption indicating it attempts to deal with Chrome on its own:

```text

Unhandled Exception: OpenQA.Selenium.NoSuchDriverException: Unable to obtain chrome using Selenium Manager; 
For documentation on this error, please visit: 
https://www.selenium.dev/documentation/webdriver/troubleshooting/errors/driver_location
 ---> System.TypeInitializationException: The type initializer for 'OpenQA.Selenium.SeleniumManager' threw an exception. 
 ---> OpenQA.Selenium.WebDriverException: Unable to locate or obtain Selenium Manager binary at 
...\Program\bin\Debug\selenium-manager/windows/selenium-manager.exe
```
### Usage



### See Also

  * https://github.com/SeleniumHQ/selenium/issues/10564
  * [Run cdp commands on Selenium C#](https://stackoverflow.com/questions/70912939/run-cdp-commands-on-selenium-c-sharp)
  * https://qna.habr.com/q/1266474?e=13639006#clarification_1709400 (in Russian)
  * https://stackoverflow.com/questions/72771825/selenium-4-c-sharp-chrome-devtools
  * [evolution of CreateDevToolsSession in ChromeDriver Selenium](https://stackoverflow.com/questions/70529101/there-are-no-createdevtoolssession-in-chromedriver-selenium)


### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)



