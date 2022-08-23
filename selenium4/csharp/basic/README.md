### Info	
Tehe program is using Selenium 4.x or 3.x and connects to Chrome websocket on its own 
using [sta/websocket-sharp](https://github.com/sta/websocket-sharp/tree/master/Example)
and connects to  regular socket using [dynamic RestClient](https://github.com/bennidhamma/RestClient)
and uses [fastJSON](https://www.codeproject.com/Articles/159450/fastJSON-Smallest-Fastest-Polymorphic-JSON-Seriali) to compose and process CDP API [messages](https://chromedevtools.github.io/devtools-protocol/tot/).

### Notes

* there is intentionally no `async` code to allow development code
in the now defunct [SharpDevelop](https://github.com/icsharpcode/SharpDevelop) 
IDE which never became able to parse the C# 5.x syntax

* for the same reason (outdated `nuget.exe`) the `Selenium.WebDriver` dependency version `4.x` has tobe downloaded manually:
```powershell
$VERSION =  '4.2.0'
. .\download_nuget_package.ps1 -version $VERSION -package_name Selenium.WebDriver
```
```powershell
 . .\download_nuget_package.ps1 -package_name 'Selenium.Support' -version $VERSION
```

there is also a utility to clean the packages from numerous target platform assemblies, keeping only `net40` and `net45`
```powershell
. .\prune_unneded_nuget_packages.ps1
```
this will unlink these
```text
packages\Selenium.Webdriver.4.2.0\lib\net46\WebDriver.dll
packages\Selenium.Webdriver.4.2.0\lib\net47\WebDriver.dll
packages\Selenium.Webdriver.4.2.0\lib\net48\WebDriver.dll
packages\Selenium.Webdriver.4.2.0\lib\net5.0\WebDriver.dll
packages\Selenium.Webdriver.4.2.0\lib\netstandard2.0\WebDriver.dll
packages\Selenium.Webdriver.4.2.0\lib\netstandard2.1\WebDriver.dll
```

### Usage

It reads the current sesssion Selenium logs looking for
```text
DevTools HTTP Request: http://localhost:57161/json/version
```

technically there is also entry
```text  
  DevTools HTTP Response: {
  "Browser": "Chrome/104.0.5112.102",
  "Protocol-Version": "1.3",
  "User-Agent": "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.102 Safari/537.36",
  "V8-Version": "10.4.132.22",
  "WebKit-Version": "537.36 (@0a2e5078088fc9f9a29247aaa40af9e7ada8b79f)",
  "webSocketDebuggerUrl": "ws://localhost:57161/devtools/browser/6fbfaec5-4de5-4ae2-86ae-89fcc819e704"
  }
```

but it ignores it and reads the json from  `http://localhost:57161/json`:
which looks like:

```json
[ {
   "description": "",
   "devtoolsFrontendUrl": "/devtools/inspector.html?ws=localhost:58045/devtools/page/D699103DDEC2772BB4C00ACD73D2BC3C",
   "id": "D699103DDEC2772BB4C00ACD73D2BC3C",
   "title": "localhost:58045",
   "type": "page",
   "url": "http://localhost:58045/json",
   "webSocketDebuggerUrl": "ws://localhost:58045/devtools/page/D699103DDEC2772BB4C00ACD73D2BC3C"
}, {
   "description": "",
   "devtoolsFrontendUrl": "/devtools/inspector.html?ws=localhost:58045/devtools/page/E8914EBAE6858C7923841CFEA27EE8EC",
   "id": "E8914EBAE6858C7923841CFEA27EE8EC",
   "title": "data:,",
   "type": "page",
   "url": "data:,",
   "webSocketDebuggerUrl": "ws://localhost:58045/devtools/page/E8914EBAE6858C7923841CFEA27EE8EC"
} ]
```
the entries of `page` `type` are used to collect the `webSocketDebuggerUrl`

Then it performs a WebSocket connection to that url 

```c#
var ws = new WebSocket(wsurl)
```
and sends CDP command 
```c#
ws.Send(@"{""id"":534427,""method"":""Browser.getVersion"",""params"":{}}");
```

and gets results, e.g.

```text
result:
```
```json
{
  "id": 534427,
  "result": {
    "protocolVersion": "1.3",
    "product": "Chrome/104.0.5112.102",
    "revision": "@0a2e5078088fc9f9a29247aaa40af9e7ada8b79f",
    "userAgent": "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (K
HTML, like Gecko) Chrome/104.0.5112.102 Safari/537.36",
    "jsVersion": "10.4.132.22"
  }
}
```
 
### See Also

 * https://www.codeproject.com/Articles/618032/Using-WebSocket-in-NET-4-5-Part-2
 * https://www.codeproject.com/Articles/617611/Using-WebSocket-in-NET-4-5-Part-1
 * https://stackoverflow.com/questions/70912939/run-cdp-commands-on-selenium-c-sharp
 * https://lightrun.com/answers/seleniumhq-selenium--bug--a-command-response-was-not-received-networkgetresponsebody-c				
 * https://medium.com/nerd-for-tech/your-first-c-websocket-client-5e7acc30681d	 
 * https://www.lambdatest.com/automation-testing-advisor/selenium/methods/org.openqa.selenium.devtools.Command.getSendsResponse
 * https://github.com/SeleniumHQ/selenium/blob/trunk/dotnet/src/webdriver/DevTools/ICommand.cs
 * https://zetcode.com/csharp/readwebpage/
 * https://stackoverflow.com/questions/36455533/c-sharp-selenium-access-browser-log
 * https://stackoverflow.com/questions/2064641/is-there-a-websocket-client-implemented-for-net#:~:text=Yes%20it%20is.,WebSocket%20client%20lib%20with%20it.
 * https://docs.microsoft.com/en-us/dotnet/api/system.net.websockets.websocket?redirectedfrom=MSDN&view=net-6.0
 * https://docs.microsoft.com/en-us/dotnet/api/system.net.websockets.clientwebsocket?view=net-6.0

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)

Event-based Asynchronous Pattern Overview
https://docs.microsoft.com/en-us/dotnet/standard/asynchronous-programming-patterns/event-based-asynchronous-pattern-overview

Asynchronous Programming Model (APM)
https://docs.microsoft.com/en-us/dotnet/standard/asynchronous-programming-patterns/asynchronous-programming-model-apm?redirectedfrom=MSDN
