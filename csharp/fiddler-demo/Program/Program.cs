using System;
using System.Text.RegularExpressions;
using Fiddler;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Data.SQLite;
using System.IO;

namespace WebTester
{
    public class Monitor
    {
        private string tableName = "";
        private bool IgnoreResources;
        private string dataFolderPath;
        private string database;
        private string dataSource;
        public Monitor()
        {
            dataFolderPath = Directory.GetCurrentDirectory();
            database = String.Format("{0}\\data.db", dataFolderPath);
            dataSource = "data source=" + database;
            tableName = "product";

            // Simply echo notifications to the console.  Because CONFIG.QuietMode=true 
            // by default, we must handle notifying the user ourselves.
            FiddlerApplication.OnNotification += delegate(object sender, NotificationEventArgs e) { Console.WriteLine("** NotifyUser: " + e.NotifyString); };
            FiddlerApplication.Log.OnLogString += delegate(object sender, Fiddler.LogEventArgs e) { Console.WriteLine("** LogString: " + e.LogString); };

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
            //https://github.com/jimevans/WebDriverProxyExamples/blob/master/lib/FiddlerCore4.XML
            FiddlerApplication.BeforeResponse += (s) =>
            {
                Console.WriteLine("{0}:HTTP {1} for {2}", s.id, s.responseCode, s.fullUrl);

                // Uncomment the following to decompress/unchunk the HTTP response 
                // s.utilDecodeResponse(); 
            };

            FiddlerApplication.AfterSessionComplete += FiddlerApplication_AfterSessionComplete;

        }

        private void FiddlerApplication_AfterSessionComplete(Session fiddler_session)
        {
            // Ignore HTTPS connect requests
            if (fiddler_session.RequestMethod == "CONNECT")
                return;

            if (fiddler_session == null || fiddler_session.oRequest == null || fiddler_session.oRequest.headers == null)
                return;

            var full_url = fiddler_session.fullUrl;
            Console.WriteLine("URL: " + full_url);

            HTTPRequestHeaders request_headers = fiddler_session.RequestHeaders;
            HTTPResponseHeaders response_headers = fiddler_session.ResponseHeaders;
            int http_response_code = response_headers.HTTPResponseCode;
            Console.WriteLine("HTTP Response: " + http_response_code.ToString());

            string referer = null;
            Dictionary<String, HTTPHeaderItem> request_headers_dictionary =
             request_headers.ToDictionary(p => p.Name);
            if (request_headers_dictionary.ContainsKey("Referer"))
            {
                referer = request_headers_dictionary["Referer"].Value;
            }
            
            //foreach (HTTPHeaderItem header_item in response_headers)
            //{
            //    Console.Error.WriteLine(header_item.Name + " " + header_item.Value);
            //}
            
            //foreach (HTTPHeaderItem header_item in request_headers)
            //{
            //    Console.Error.WriteLine(header_item.Name + " " + header_item.Value);
            //}

            Console.Error.WriteLine("Referer: " + referer);

            // http://fiddler.wikidot.com/timers
            var timers = fiddler_session.Timers;
            TimeSpan duration = timers.ClientDoneResponse - timers.ClientBeginRequest;
            Console.Error.WriteLine(String.Format("Duration: {0:F10}", duration.Milliseconds));
            var dic = new Dictionary<string, object>(){
                	{"url" ,full_url}, {"status", http_response_code},
                	{"duration", duration.Milliseconds },
                	{"referer", referer }
                };
            insert(dic);
        }

        bool TestConnection()
        {
            Console.WriteLine(String.Format("Testing database connection {0}...", database));
            try
            {
                using (SQLiteConnection conn = new SQLiteConnection(dataSource))
                {
                    conn.Open();
                    conn.Close();
                }
                return true;
            }

            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return false;
            }
        }

        public bool insert(Dictionary<string, object> dic)
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
                        int count = sh.ExecuteScalar<int>(String.Format("select count(*) from {0};", this.tableName)) + 1;

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

        public void createTable()
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
                    tb.Columns.Add(new SQLiteColumn("id", true));
                    tb.Columns.Add(new SQLiteColumn("url", ColType.Text));
                    tb.Columns.Add(new SQLiteColumn("referer", ColType.Text));
                    tb.Columns.Add(new SQLiteColumn("status", ColType.Integer));
                    tb.Columns.Add(new SQLiteColumn("duration", ColType.Decimal));
                    sh.CreateTable(tb);
                    conn.Close();
                }
            }
        }

        public void Start()
        {
            Console.WriteLine("Starting FiddlerCore...");
            dataFolderPath = Directory.GetCurrentDirectory();
            database = String.Format("{0}\\fiddler-data.db", dataFolderPath);
            dataSource = "data source=" + database;
            tableName = "product";
            // http://stackoverflow.com/questions/24969198/how-do-i-get-fiddlercore-programmatic-certificate-installation-to-stick
            // http://weblog.west-wind.com/posts/2014/Jul/29/Using-FiddlerCore-to-capture-HTTP-Requests-with-NET
            TestConnection();
            createTable();
            // For the purposes of this demo, we'll forbid connections to HTTPS 
            // sites that use invalid certificates
            CONFIG.IgnoreServerCertErrors = false;
            // Because we've chosen to decrypt HTTPS traffic, makecert.exe must
            // be present in the Application folder.
            FiddlerApplication.Startup(8877, true, true);
            Console.WriteLine("Hit CTRL+C to end session.");
            // Wait  for the user to hit CTRL+C.  
        }
        // TODO : extract cookies
        public void extract_headers(string raw_text)
        {

            string header_name_regexp = @"(?<header_name>[^ ]+):";
            string header_value_regexp = @"(?<header_value>.+)\r\n";

            MatchCollection myMatchCollection =
              Regex.Matches(raw_text, header_name_regexp + header_value_regexp);

            foreach (Match myMatch in myMatchCollection)
            {
                Console.Error.WriteLine(String.Format("Header name = [{0}]", myMatch.Groups["header_name"]));
                Console.Error.WriteLine(String.Format("Data = [{0}]", myMatch.Groups["header_value"]));
            }
        }

        public void Stop()
        {
            Console.WriteLine("Shutdown.");

            FiddlerApplication.AfterSessionComplete -= FiddlerApplication_AfterSessionComplete;
            if (FiddlerApplication.IsStarted())
                FiddlerApplication.Shutdown();
            System.Threading.Thread.Sleep(1);
        }

        public static Monitor m;
        // Not necessary if embedded in Powershell  
        public static void Main(string[] args)
        {
            m = new Monitor();
            #region AttachEventListeners
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
