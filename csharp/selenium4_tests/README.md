
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
