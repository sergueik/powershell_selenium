using System;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using Microsoft.Activities.UnitTesting;
using System.Data.SQLite;
using SQLite.Utils;
using System.IO;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.PhantomJS;

namespace WebTester
{
    public static class Extensions
    {
        static int cnt = 0;

        public static T Execute<T>(this IWebDriver driver, string script)
        {
            return (T)((IJavaScriptExecutor)driver).ExecuteScript(script);
        }

        public static List<Dictionary<String, String>> Performance(this IWebDriver driver)
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

        public static void WaitDocumentReadyState(this IWebDriver driver, string expected_state, int max_cnt = 10)
        {
            cnt = 0;
            var wait = new OpenQA.Selenium.Support.UI.WebDriverWait(driver, TimeSpan.FromSeconds(30.00));
            wait.PollingInterval = TimeSpan.FromSeconds(0.50);
            wait.Until(dummy =>
            {
                string result = driver.Execute<String>("return document.readyState").ToString();
                Console.Error.WriteLine(String.Format("result = {0}", result));
                Console.Error.WriteLine(String.Format("cnt = {0}", cnt));
                cnt++;
                // TODO: match
                return ((result.Equals(expected_state) || cnt > max_cnt));
            });
        }

        public static void WaitDocumentReadyState(this IWebDriver driver, string[] expected_states, int max_cnt = 10)
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
                cnt++;
                return ((state_regex.IsMatch(result) || cnt > max_cnt));
            });
        }
    }

    [TestClass]
    [DeploymentItem(@"x86\SQLite.Interop.dll", "x86")] 
    public class Monitor
    {
        private static string hub_url = "http://localhost:4444/wd/hub";
        private static IWebDriver selenium_driver;
        private static string step_url = "http://www.carnival.com/";
        private static string[] expected_states = { "interactive", "complete" };
        private static int max_cnt = 10;
        private static string tableName = "";
        private static string dataFolderPath;
        private static string database;
        private static string dataSource;


        [TestInitialize]
        public void Initialize()
        {
            dataFolderPath = Directory.GetCurrentDirectory();
            database = String.Format("{0}\\data.db", dataFolderPath);
            dataSource = "data source=" + database;
            tableName = "product";
            createTable();
            selenium_driver = new RemoteWebDriver(new Uri(hub_url), DesiredCapabilities.Chrome());
            selenium_driver.Manage().Timeouts().ImplicitlyWait(new TimeSpan(0, 0, 30));
        }

        [TestCleanup]
        public void Cleanup()
        {
            if (selenium_driver != null)
                selenium_driver.Close();
        }

        [TestMethod]
        // [ExpectedException(typeof(NoSuchElementException))]
        public void Sample()
        {
            selenium_driver.Navigate().GoToUrl(step_url);
            selenium_driver.WaitDocumentReadyState(expected_states[0]);
            List<Dictionary<String, String>> result = selenium_driver.Performance();
            var dic = new Dictionary<string, object>();

            foreach (var row in result)
            {
                dic["caption"] = "dummy";
                foreach (string key in row.Keys)
                {


                    if (Regex.IsMatch(key, "(name|duration)"))
                    {

                        Console.Error.WriteLine(key + " " + row[key]);

                        if (key.IndexOf("duration") > -1)
                        {
                            dic[key] = (Double)Double.Parse(row[key]);
                        }
                        else
                        {
                            dic[key] = (String)row[key];
                        }
                    }
                }
                insert(dic);

                foreach (string key in dic.Keys.ToArray())
                {
                    dic[key] = null;
                }
                Console.Error.WriteLine("");
            }
        }
        public static void Main(string[] args)
        {

            dataFolderPath = Directory.GetCurrentDirectory();
            database = String.Format("{0}\\data.db", dataFolderPath);
            dataSource = "data source=" + database;
            tableName = "product";

            Console.WriteLine("Starting..");
            // TestConnection();
            createTable();
            // selenium_driver = new ChromeDriver();
            // ActiveState Remote::Selenium:Driver 
            // selenium_driver = new RemoteWebDriver(new Uri(hub_url), DesiredCapabilities.Firefox());
            selenium_driver = new RemoteWebDriver(new Uri(hub_url), DesiredCapabilities.Chrome());
            // string phantomjs_executable_folder = @"C:\tools\phantomjs-2.0.0\bin";
            // selenium_driver = new PhantomJSDriver(phantomjs_executable_folder);
            selenium_driver.Manage().Timeouts().ImplicitlyWait(new TimeSpan(0, 0, 30));

            selenium_driver.Navigate().GoToUrl(step_url);
            selenium_driver.WaitDocumentReadyState(expected_states);
            List<Dictionary<String, String>> result = selenium_driver.Performance();
            var dic = new Dictionary<string, object>();

            foreach (var row in result)
            {
                dic["caption"] = "dummy";
                foreach (string key in row.Keys)
                {


                    if (Regex.IsMatch(key, "(name|duration)"))
                    {

                        Console.Error.WriteLine(key + " " + row[key]);

                        if (key.IndexOf("duration") > -1)
                        {
                            dic[key] = (Double)Double.Parse(row[key]);
                        }
                        else
                        {
                            dic[key] = (String)row[key];
                        }
                    }
                }
                insert(dic);

                foreach (string key in dic.Keys.ToArray())
                {
                    dic[key] = null;
                }
                Console.Error.WriteLine("");
            }
            if (selenium_driver != null)
                selenium_driver.Close();
        }

        public static bool insert(Dictionary<string, object> dic)
        {
            try
            {
                using (SQLiteConnection conn = new SQLiteConnection(dataSource))
                {
                    using (SQLiteCommand cmd = new SQLiteCommand())
                    {
                        cmd.Connection = conn;
                        conn.Open();
                        SQLiteHelper sh = new SQLiteHelper(cmd);
                        sh.Insert(tableName, dic);
                        conn.Close();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return false;
            }
        }

        public static void createTable()
        {
            using (SQLiteConnection conn = new SQLiteConnection(dataSource))
            {
                using (SQLiteCommand cmd = new SQLiteCommand())
                {
                    cmd.Connection = conn;
                    conn.Open();
                    SQLiteHelper sh = new SQLiteHelper(cmd);
                    sh.DropTable(tableName);

                    SQLiteTable tb = new SQLiteTable(tableName);
                    tb.Columns.Add(new SQLiteColumn("id", true)); // auto increment 
                    tb.Columns.Add(new SQLiteColumn("caption"));
                    tb.Columns.Add(new SQLiteColumn("name"));
                    tb.Columns.Add(new SQLiteColumn("duration", ColType.Decimal));
                    sh.CreateTable(tb);
                    conn.Close();
                }
            }
        }
    }
}
