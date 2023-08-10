### Info

this directory contains a tests configured to run on .Net Framework __4.5__ to practice Selenum WebDriver BIDI and CDP Command examples from
[Selenium 4 Chrome DevTools Documentation](https://www.selenium.dev/documentation/webdriver/bidirectional/chrome_devtools/)
and other sources [sergueik/selenium_cdp](https://github.com/sergueik/selenium_cdp)

The [Selenium .NET API Docs](https://www.selenium.dev/selenium/docs/api/dotnet/) - slow to browse, occsionally hangs the browser

### Note
	
### Note

When compiled in Sharp Develop (which is discontinued) see the nuget error`
```text
NOTE: Selenium.WebDriver' already has a dependency defined for 'Newtonsoft.Json'.
Exited with code: 1
```
the workaround is to download the package manually:
```powershell
$localfile = (resolve-path '.').path + '\' + 'selenium.webdriver.zip'
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
cmd %%- /c  dir /b/s .\packages\Selenium.WebDriver.4.8.2\lib\
```
and unzip the file `lib\net45\WebDriver.dll` from `selenium.webdriver.zip` manually into `packages\Selenium.WebDriver.4.8.2\lib\net45`

repeat with

```powershell
$localfile = (resolve-path '.').path + '\' + 'selenium.suppport.zip'
$url = 'https://www.nuget.org/api/v2/package/Selenium.Support/4.11.0'
mkdir .\packages\Selenium.Support.4.8.2\lib\net45
cmd %%- /c  dir /b/s .\packages\Selenium.Support.4.8.2\lib\
```

### NOTE

On Windows 7 all tests will be failing with the exception:

```text
SetUp Error : Selenium4.Test.AuthTests.test1
   SetUp : OpenQA.Selenium.WebDriverException : Unexpected error creating WebSocket DevTools session.
  ----> System.PlatformNotSupportedException : The WebSocket protocol is not supported on this platform
```

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)



