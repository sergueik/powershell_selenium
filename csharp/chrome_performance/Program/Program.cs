using System;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Activities.UnitTesting;
using System.Data.SQLite;
using System.IO;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;

namespace WebTester
{

    public static class Extensions
    {
        static int cnt = 0;
        // http://stackoverflow.com/questions/6229769/execute-javascript-using-selenium-webdriver-in-c-sharp
        public static T Execute<T>(this IWebDriver driver, string script)
        {
            return (T)((IJavaScriptExecutor)driver).ExecuteScript(script);
        }

        public static List<Dictionary<String, String>> Performance(this IWebDriver driver)
        {
            // NOTE:  performance.timing will not return anything with Chrome
            // timing is returned by FF and PhantomJS

            string performance_script = @"
var ua = window.navigator.userAgent;

if (ua.match(/PhantomJS/)) {
    return 'Cannot measure on ' + ua;
} else {
    var performance =
        window.performance ||
        window.mozPerformance ||
        window.msPerformance ||
        window.webkitPerformance || {};

    // var timings = performance.timing || {};
    // return timings;
    var network = performance.getEntries() || {};
    return network;
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
                Console.WriteLine(String.Format("cnt = {0}", cnt));
                cnt++;
                // TODO: match
                return ((result.Equals(expected_state) || cnt > max_cnt));
            });
        }
    }

    [TestClass]
    public class Monitor
    {
        private static IWebDriver driver;
        private static string step_url = "http://www.carnival.com/";
        private static string expected_state = "interactive";
        private static int max_cnt = 10;

        public static void Main(string[] args)
        {
            driver = new ChromeDriver();
            driver.Navigate().GoToUrl(step_url);
            driver.WaitDocumentReadyState(expected_state);
            List<Dictionary<String, String>> result = driver.Performance();
            foreach (var row in result)
            {
                foreach (string key in row.Keys)
                {
                    Console.Error.WriteLine(key + " " + row[key]);
                }
                Console.Error.WriteLine("");
            }
            if (driver != null)
                driver.Close();
        }

        [TestInitialize()]
        public void Initialize()
        {
            driver = new ChromeDriver();
        }

        [TestCleanup()]
        public void Cleanup()
        {
            if (driver != null)
                driver.Close();
        }

        [ClassCleanup()]
        public static void MyClassCleanup() { }

        [TestMethod]
        public void TestPerformance()
        {
            driver.Navigate().GoToUrl(step_url);
            driver.WaitDocumentReadyState(expected_state);
            List<Dictionary<String, String>> result = driver.Performance();
            foreach (var row in result)
            {
                foreach (string key in row.Keys)
                {
                    Console.Error.WriteLine(key + " " + row[key]);
                }
            }
        }
    }
}
