### Info

this directory contains a tests configured to run on .Net Framework __4.5__ to practice Selenum WebDriver BIDI and CDP Command examples from
[Selenium 4 Chrome DevTools Documentation](https://www.selenium.dev/documentation/webdriver/bidirectional/chrome_devtools/)
and other sources [sergueik/selenium_cdp](https://github.com/sergueik/selenium_cdp)

The [Selenium .NET API Docs](https://www.selenium.dev/selenium/docs/api/dotnet/) - slow to browse, occasionally hangs the browser

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

On Windows 7 all tests operatinv through 
```c#
IWebDriver driver = new ChromeDriver(options);
IDevTools devTools = driver as IDevTools;
IDevToolsSession session = devTools.GetDevToolsSession();
DevToolsSessionDomains domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
```
will be failing with the exception:

```text
SetUp Error : Selenium4.Test.AuthTests.test1
   SetUp : OpenQA.Selenium.WebDriverException : Unexpected error creating WebSocket DevTools session.
  ----> System.PlatformNotSupportedException : The WebSocket protocol is not supported on this platform
```
same applies to Powershell tests, attempting the same:
```powershell
$session = ([OpenQA.Selenium.DevTools.IDevTools]$driver).GetDevToolsSession()
```
```text
Exception calling "GetDevToolsSession" with "0" argument(s): "Unexpected error creating WebSocket DevTools session."
```
Tests operating `ChromiumDriver' class `ExecuteCdpCommand` method
```c#
IWebDriver driver = new ChromeDriver(options);
ChromiumDriver chromiumDriver = driver as ChromiumDriver;
string command = "Browser.getVersion";
Object result = chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
Assert.NotNull(result);
Dictionary<String, Object>	data = result as Dictionary<String, Object>;
Console.Error.WriteLine("result keys: " + data.PrettyPrint());
```
and
```powershell
$options = new-object OpenQA.Selenium.Chrome.ChromeOptions
$options.AddArgument('--headless')
$driver = new-object OpenQA.Selenium.Chrome.ChromeDriver($options)
$driver.executeCdpCommand('Browser.getVersion',@{}) | format-list
```
will work fine.

### See Also

   * https://journeyofquality.com/2021/11/27/selenium-chrome-devtools-protocol-cdp/
   * https://rahulshettyacademy.com/blog/index.php/2021/11/04/selenium-4-feature-chrome-dev-tools-protocol/
   * https://www.lambdatest.com/blog/iwebdriver-browser-commands-in-selenium-c-sharp/
   * https://www.automatetheplanet.com/chrome-devtools-protoco-in-selenium-4-java/
    * [Selenium 4 Fundamentals with C#](https://app.pluralsight.com/courses/38e7c203-dc47-4f15-bfe5-874e1c3fcf4d/table-of-contents) pluralsight training
    * https://app.pluralsight.com/ilx/video-courses/clips/b7499b81-a620-4b37-bf91-9f82ead50843

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)




