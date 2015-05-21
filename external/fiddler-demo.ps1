#Copyright (c) 2015 Serguei Kouzmine
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
  [string]$browser = '',
  [int]$version,
  [string]$base_url = 'http://www.google.com/',
  [switch]$debug,
  [switch]$pause
)

function custom_pause {
  param([bool]$fullstop)
  # Do not close Browser / Selenium when run from Powershell ISE
  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }
}


function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'FiddlerCore4.dll', # http://fiddlerbook.com/Fiddler/Core/
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

# refactored http://fiddler.wikidot.com/fiddlercore-demo
# copied  from  http://weblog.west-wind.com/posts/2014/Jul/29/Using-FiddlerCore-to-capture-HTTP-Requests-with-NET
Add-Type @"

using System;
using Fiddler;

namespace WebTester
{
    public class Monitor
    {
        bool IgnoreResources;
        public Monitor()
        {
            #region AttachEventListeners
            //
            // It is important to understand that FiddlerCore calls event handlers on the
            // session-handling thread.  If you need to properly synchronize to the UI-thread
            // (say, because you're adding the sessions to a list view) you must call .Invoke
            // on a delegate on the window handle.
            //

            // Simply echo notifications to the console.  Because CONFIG.QuietMode=true 
            // by default, we must handle notifying the user ourselves.
            FiddlerApplication.OnNotification += delegate(object sender, NotificationEventArgs oNEA) { Console.WriteLine("** NotifyUser: " + oNEA.NotifyString); };
            FiddlerApplication.Log.OnLogString += delegate(object sender, LogEventArgs oLEA) { Console.WriteLine("** LogString: " + oLEA.LogString); };
            IgnoreResources = false;
            FiddlerApplication.BeforeRequest += (s) =>
            {
                Console.WriteLine("Before request for:\t" + s.fullUrl);
                // In order to enable response tampering, buffering mode must
                // be enabled; this allows FiddlerCore to permit modification of
                // the response in the BeforeResponse handler rather than streaming
                // the response to the client as the response comes in.
                s.bBufferResponse = true;
            };

            FiddlerApplication.BeforeResponse += (s) =>
            {
                Console.WriteLine("{0}:HTTP {1} for {2}", s.id, s.responseCode, s.fullUrl);

                // Uncomment the following to decompress/unchunk the HTTP response 
                // s.utilDecodeResponse(); 
            };


            FiddlerApplication.AfterSessionComplete += (s) => Console.WriteLine("Finished session:\t" + s.fullUrl);
            FiddlerApplication.AfterSessionComplete += FiddlerApplication_AfterSessionComplete;
            #endregion AttachEventListeners
        }


        private void FiddlerApplication_AfterSessionComplete(Session sess)
        {
            // Ignore HTTPS connect requests
            if (sess.RequestMethod == "CONNECT")
                return;
            /*
                if (!string.IsNullOrEmpty(CaptureConfiguration.CaptureDomain))
                {
                    if (sess.hostname.ToLower() != CaptureConfiguration.CaptureDomain.Trim().ToLower())
                        return;
                }
            */

            if (IgnoreResources)
            {
                string url = sess.fullUrl.ToLower();
                /*
                        var extensions = CaptureConfiguration.ExtensionFilterExclusions;
                        foreach (var ext in extensions)
                        {
                            if (url.Contains(ext))
                                return;
                        }

                        foreach (var urlFilter in filters)
                        {
                            if (url.Contains(urlFilter))
                                return;
                        }
                */
            }

            if (sess == null || sess.oRequest == null || sess.oRequest.headers == null)
                return;

            string headers = sess.oRequest.headers.ToString();
            var reqBody = sess.GetRequestBodyAsString();

            // to capture the response
            // string respHeaders = session.oResponse.headers.ToString();
            // var respBody = session.GetResponseBodyAsString();

            // replace the HTTP line to inject full URL
            string firstLine = sess.RequestMethod + " " + sess.fullUrl + " " + sess.oRequest.headers.HTTPVersion;
            int at = headers.IndexOf("\r\n");
            if (at < 0)
                return;
            headers = firstLine + "\r\n" + headers.Substring(at + 1);

            string output = headers + "\r\n" +
                            (!string.IsNullOrEmpty(reqBody) ? reqBody + "\r\n" : string.Empty) +
                             "\r\n\r\n";
            Console.WriteLine(output);

        }
        public void Start()
        {
            Console.WriteLine("Starting FiddlerCore...");
            // For the purposes of this demo, we'll forbid connections to HTTPS 
            // sites that use invalid certificates
            CONFIG.IgnoreServerCertErrors = false;
            // Because we've chosen to decrypt HTTPS traffic, makecert.exe must
            // be present in the Application folder.
            FiddlerApplication.Startup(8877, true, true);
            Console.WriteLine("Hit CTRL+C to end session.");
            // Wait Forever for the user to hit CTRL+C.  
            // BUG BUG: Doesn't properly handle shutdown of Windows, etc.
        }

        public void Stop()
        {
            // TODO: raise event
            Console.WriteLine("Shutdown.");
            FiddlerApplication.Shutdown();
            System.Threading.Thread.Sleep(1);
        }
        public static Monitor m;
        // No longer necessary 
        public static void Main(string[] args)
        {
            m = new Monitor();
            #region AttachEventListeners
            // Tell the system console to handle CTRL+C by calling our method that
            // gracefully shuts down the FiddlerCore.
            Console.CancelKeyPress += new ConsoleCancelEventHandler(Console_CancelKeyPress);
            #endregion AttachEventListeners
            m.Start();
            Object forever = new Object();
            lock (forever)
            {
                System.Threading.Monitor.Wait(forever);
            }

        }

        static void Console_CancelKeyPress(object sender, ConsoleCancelEventArgs e)
        {
            Console.WriteLine("Stop.");
            m.Stop();
            System.Threading.Thread.Sleep(1);
        }
    }
}
"@ -ReferencedAssemblies 'System.dll','System.Data.dll',"${shared_assemblies_path}\FiddlerCore4.dll"
# TODO - randomise namespace.
$o = New-Object -TypeName 'WebTester.Monitor'
# http://fiddler.wikidot.com/fiddlercore-api
$o.Start()

<#
TODO: extract $req, $res.

----------------------------------------
POST /CMS/javascript/tealeaf/TealeafTarget.aspx HTTP/1.1
Accept: */*
X-TeaLeaf: ClientEvent
Content-Type: text/xml
X-TeaLeafType: PERFORMANCE; GUI;
X-TeaLeafSubType: INIT; BEFOREUNLOAD
X-TeaLeaf-Page-Url: /bookingengine/cruise-search/caribbean
X-TeaLeaf-Screen-Res: 2
X-TeaLeaf-Browser-Res: 2
X-TeaLeaf-Page-Render: 2370
X-TeaLeaf-Page-Img-Fail: 2
X-TeaLeaf-Page-Cui-Events: 3
X-TeaLeaf-Page-Cui-Bytes: 1241
X-TeaLeaf-Page-Dwell: 13642
Referer: ...
Accept-Language: en-us
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; KTXN B579989732A48120T2783790P5)
Host: www.carnival.com
Content-Length: 1241
Connection: Keep-Alive
Cache-Control: no-cache
Cookie: ...
----------------------------------------
HTTP/1.1 200 OK
Cache-Control: private
Content-Type: text/html; charset=utf-8
Server: Microsoft-IIS/7.0
X-AspNet-Version: 4.0.30319
X-Powered-By: ASP.NET
Content-Length: 238
Date: Tue, 19 May 2015 20:16:33 GMT
Connection: keep-alive
Set-Cookie: ...
Set-Cookie: ...

#>


# TODO : $o.IsStarted()

$headless = $false
if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect('127.0.0.1',4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability('version',$version.ToString());
    }
  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $headless = $true
  Write-Host 'Running on phantomjs'

  $phantomjs_executable_folder = "C:\tools\phantomjs-2.0.0\bin"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
  $options = $null
}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$selenium.Navigate().GoToUrl($base_url)
$o.Stop()

# Cleanup

custom_pause -fullstop $fullstop

cleanup ([ref]$selenium)
