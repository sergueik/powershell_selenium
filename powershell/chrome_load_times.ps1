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
  [string]$base_url = 'http://www.carnival.com/',
  [switch]$debug,
  [switch]$pause
)
function ellipsize {
  param
  ([string]$input_string,
    [int]$truncate_length = 70)
  $input_string_length = $input_string.Length
  if ($input_string_length -le $truncate_length) {
    return $input_string
  } else {
    return ($input_string.Substring(0,($truncate_length - 7)) + "..." + $input_string.Substring($input_string_length - 4,3)
    )
  }
}

function create_table {
  param(
    [string]$database = "$(Get-ScriptDirectory)\timings.db",
    # http://www.sqlite.org/datatype3.html
    [string]$create_table_query = @"
   CREATE TABLE IF NOT EXISTS [timings]
      (  ID       INTEGER PRIMARY KEY   AUTOINCREMENT,
         URL      CHAR(2048),
         CAPTION   CHAR(256),
         LOADTIME    DECIMAL 
      );

"@
  )
  [int]$version = 3
  $connection = New-Object System.Data.SQLite.SQLiteConnection ('Data Source={0};Version={1};' -f $database,$version)
  $connection.Open()
  Write-Output $create_table_query
  [System.Data.SQLite.SQLiteCommand]$sql_command = New-Object System.Data.SQLite.SQLiteCommand ($create_table_query,$connection)
  try {
    $sql_command.ExecuteNonQuery()
  } catch [exception]{
  }
  $connection.Close()


}

function insert_database3 {
  param(
    [string]$database = "$(Get-ScriptDirectory)\timings.db",
    [string]$query = @"
INSERT INTO [timings] (CAPTION, URL, LOADTIME )  VALUES(?, ?, ?)
"@,
    [psobject]$data
  )


  [int]$version = 3
  $connection_string = ('Data Source={0};Version={1};' -f $database,$version)
  $connection = New-Object System.Data.SQLite.SQLiteConnection ($connection_string)
  $connection.Open()
  Write-Debug $query
  $command = $connection.CreateCommand()
  $command.CommandText = $query

  $caption = New-Object System.Data.SQLite.SQLiteParameter
  $url = New-Object System.Data.SQLite.SQLiteParameter
  $load_time = New-Object System.Data.SQLite.SQLiteParameter


  [void]$command.Parameters.Add($caption)
  [void]$command.Parameters.Add($url)
  [void]$command.Parameters.Add($load_time)

  $caption.Value = $data.caption
  $url.Value = $data.url
  $load_time.Value = $data.load_time
  $rows_inserted = $command.ExecuteNonQuery()
  $command.Dispose()
}

# TODO: load selenium default configuration, then reload with profile

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies

$sqlite_installlocation_path = read_installed_programs_registry -registry_path '/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/' -package_name 'System.Data.SQLite'
$sqlite_assemblies_path = [System.IO.Path]::Combine($sqlite_installlocation_path,'bin')
$extra_assemblies = @(
  'System.Data.SQLite.dll'
)

pushd $sqlite_assemblies_path
$extra_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

# Probably will work with embedded only 
$selenium = launch_selenium -browser 'chrome'
# close and reload with the profie
cleanup ([ref]$selenium)
$headless = $false

$verificationErrors = New-Object System.Text.StringBuilder

$capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
# override

# Oveview of extensions 
# https://sites.google.com/a/chromium.org/chromedriver/capabilities

# Profile creation
# https://support.google.com/chrome/answer/142059?hl=en
# http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
# using Profile 
# http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195


# origin:
# http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

[OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions

$options.addArguments('start-maximized')
# no-op option - re-enforcing the default setting
$options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\','/')))
# if you like to specify another profile parent directory:
# $options.addArguments('user-data-dir=c:/TEMP'); 

$options.addArguments('--profile-directory=Default')

[OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
$capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability,$options)

$selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver ($options)
$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'
Add-Type @"

using System;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Remote;

namespace WebTester
{

    // http://stackoverflow.com/questions/6229769/execute-javascript-using-selenium-webdriver-in-c-sharp
    // http://stackoverflow.com/questions/14146513/selenium-web-driver-c-sharp-invalidcastexception-for-list-of-webelements-after-j
    // http://stackoverflow.com/questions/8133661/checking-page-load-time-of-several-url-simultaneously
    // http://blogs.msdn.com/b/fiddler/archive/2011/02/10/fiddler-is-better-with-internet-explorer-9.aspx

    public static class Extensions
    {
        static int cnt = 0;

        public static T Execute<T>(this IWebDriver driver, string script)
        {
            return (T)((IJavaScriptExecutor)driver).ExecuteScript(script);
        }

        // no longer is an extension method  
        public static List<Dictionary<String, String>> Performance(IWebDriver driver)
        {
            // NOTE: this code is highly browser-specific: 
            // Chrome has performance.getEntries 
            // FF only has performance.timing 
            // PhantomJS does not have anything
            // System.InvalidOperationException: {"errorMessage":"undefined is not a constructor..
            string performance_script = @"
var ua = window.navigator.userAgent;
if (ua.match(/PhantomJS/)) {
    return [{}];
} else {
    var performance =
        window.performance ||
        window.mozPerformance ||
        window.msPerformance ||
        window.webkitPerformance || {};

    if (ua.match(/Chrome/)) {
        var network = performance.getEntries() || {};
        return network;
    } else {
        var timings = performance.timing || {};
        return [timings];
    }
}
";
            List<Dictionary<String, String>> result = new List<Dictionary<string, string>>();
            IEnumerable<Object> raw_data = driver.Execute<IEnumerable<Object>>(performance_script);

            foreach (var element in (IEnumerable<Object>)raw_data)
            {
                Dictionary<String, String> row = new Dictionary<String, String>();
                Dictionary<String, Object> dic = (Dictionary<String, Object>)element;
                foreach (object key in dic.Keys)
                {
                    Object val = null;
                    if (!dic.TryGetValue(key.ToString(), out val)) { val = ""; }
                    row.Add(key.ToString(), val.ToString());
                }
                result.Add(row);
            }
            return result;
        }
        // no longer is an extension method
        public static void WaitDocumentReadyState(IWebDriver driver, string expected_state, int max_cnt = 10)
        {
            cnt = 0;
            Console.Error.WriteLine("X");
            var wait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
            wait.PollingInterval = TimeSpan.FromSeconds(0.50);
            wait.Until(dummy =>
            {

                string result = driver.Execute<String>("return document.readyState").ToString();
                Console.Error.WriteLine(String.Format("result = {0}", result));
                cnt++;
                // TODO: match
                return ((result.Equals(expected_state) || cnt > max_cnt));
            });
        }
        // NOTE: WaitDocumentReadyState is no longer an extension method
        public static void WaitDocumentReadyState(IWebDriver driver, string[] expected_states, int max_cnt = 10)
        {
            cnt = 0;
            Regex state_regex = new Regex(String.Join("", "(?:", String.Join("|", expected_states), ")"),
                                          RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace | RegexOptions.Compiled);
            var wait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
            wait.PollingInterval = TimeSpan.FromSeconds(0.50);
            wait.Until(dummy =>
            {
                string result = driver.Execute<String>("return document.readyState").ToString();
                Console.Error.WriteLine(String.Format("result = {0}", result));
                Console.WriteLine(String.Format("cnt = {0}", cnt));
                cnt++;
                return ((state_regex.IsMatch(result) || cnt > max_cnt));
            });
        }
    }
}
"@ -ReferencedAssemblies 'System.dll','System.Data.dll','System.Data.Linq.dll',"${shared_assemblies_path}\WebDriver.dll","${shared_assemblies_path}\WebDriver.Support.dll"

# Actual action .
$script_directory = Get-ScriptDirectory

create_table -database "${script_directory}\timings.db"

$selenium.Navigate().GoToUrl($base_url)
$expected_states = @( 'interactive','complete');

[WebTester.Extensions]::WaitDocumentReadyState($selenium,$expected_states)
# [WebTester.Extensions]::WaitDocumentReadyState($selenium,$expected_states[0])
# [WebTester.Extensions]::WaitDocumentReadyState($selenium,"complete")

# NOTE: this code is highly browser-specific: 
# Chrome has performance.getEntries 
# FF only has performance.timing 
# PhantomJS does not have anything
# System.InvalidOperationException: {"errorMessage":"undefined is not a constructor..

$script = @"
var ua = window.navigator.userAgent;
if (ua.match(/PhantomJS/)) {
    return [{}];
} else {
    var performance =
        window.performance ||
        window.mozPerformance ||
        window.msPerformance ||
        window.webkitPerformance || {};

    if (ua.match(/Chrome/)) {
        var network = performance.getEntries() || {};
        return network;
    } else {
        var timings = performance.timing || {};
        return [timings];
    }
}

"@

# executeScript works fine with Chrome or Firefox 31, ie 10, but not IE 11.
# Exception calling "ExecuteScript" with "1" argument(s): "Unable to get browser
# https://code.google.com/p/selenium/issues/detail?id=6511  
# 
# https://code.google.com/p/selenium/source/browse/java/client/src/org/openqa/selenium/remote/HttpCommandExecutor.java?r=3f4622ced689d2670851b74dac0c556bcae2d0fe

$savedata = $true

if ($headless) {
  # for PhantomJS more work is needed
  # https://github.com/detro/ghostdriver/blob/master/binding/java/src/main/java/org/openqa/selenium/phantomjs/PhantomJSDriver.java
  $results = ([OpenQA.Selenium.PhantomJS.PhantomJSDriver]$selenium).ExecutePhantomJS($script,[System.Object[]]@())
  $result | Format-List
  return
} else {

  $results = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script)

  $results | ForEach-Object {
    $result = $_
    $o = New-Object PSObject
    $caption = 'test'
    $o | Add-Member Noteproperty 'url' $result.'name'
    $o | Add-Member Noteproperty 'caption' $caption
    $o | Add-Member Noteproperty 'load_time' $result.duration

    Write-Host ("url:`t{0}" -f (ellipsize $o.url)) -foreground green
    Write-Host ("time:`t{0}" -f $o.'load_time') -foreground green

    if ($savedata) {
      insert_database3 -data $o -database "$script_directory\timings.db"
    }
    $o = $null

  }
}
# How to build a waterfall gantt chart .
# http://blog.trasatti.it/2012/11/measuring-site-performance-with-javascript-on-mobile.html
# http://stackoverflow.com/questions/240333/how-do-you-measure-page-load-speed
# http://checkvincode.ru/p.php?t=Measure+Web+Page+Load+Time

# Cleanup

cleanup ([ref]$selenium)

