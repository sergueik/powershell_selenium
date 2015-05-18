
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
  'FiddlerCore4.dll',
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

Add-Type @"

using System;
using Fiddler;

namespace WebTester
{
    public class Monitor
    {
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

            FiddlerApplication.BeforeRequest += delegate(Session oS)
            {
                Console.WriteLine("Before request for:\t" + oS.fullUrl);
                // In order to enable response tampering, buffering mode must
                // be enabled; this allows FiddlerCore to permit modification of
                // the response in the BeforeResponse handler rather than streaming
                // the response to the client as the response comes in.
                oS.bBufferResponse = true;
            };

            FiddlerApplication.BeforeResponse += delegate(Session oS)
            {
                Console.WriteLine("{0}:HTTP {1} for {2}", oS.id, oS.responseCode, oS.fullUrl);

                // Uncomment the following two statements to decompress/unchunk the
                // HTTP response and subsequently modify any HTTP responses to replace 
                // instances of the word "Microsoft" with "Bayden"
                //oS.utilDecodeResponse(); oS.utilReplaceInResponse("Microsoft", "Bayden");
            };

            FiddlerApplication.AfterSessionComplete += delegate(Session oS) { Console.WriteLine("Finished session:\t" + oS.fullUrl); };

            #endregion AttachEventListeners
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
            Console.WriteLine("Shutting down...");
            FiddlerApplication.Shutdown();
            System.Threading.Thread.Sleep(1);
        }
        public static Monitor m;
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
            Console.WriteLine("Stop...");
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
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
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

