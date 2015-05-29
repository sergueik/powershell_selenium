using System;
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
        string tableName = "";
        bool IgnoreResources;
        string dataFolderPath;
        string database;
        string dataSource;
        public Monitor()
        {
            dataFolderPath = Directory.GetCurrentDirectory();
            database = String.Format("{0}\\data.db", dataFolderPath);
            dataSource = "data source=" + database;
            tableName = "product";
            #region AttachEventListeners

            // Simply echo notifications to the console.  Because CONFIG.QuietMode=true 
            // by default, we must handle notifying the user ourselves.
            FiddlerApplication.OnNotification += delegate(object sender, NotificationEventArgs e) { Console.WriteLine("** NotifyUser: " + e.NotifyString); };
            FiddlerApplication.Log.OnLogString += delegate(object sender, Fiddler.LogEventArgs e) { Console.WriteLine("** LogString: " + e.LogString); };
            // TODO: Commit to the database

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

        public bool insert()
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
                        int count = sh.ExecuteScalar<int>(String.Format("select count(*) from {0};", tableName)) + 1;
                        var dic = new Dictionary<string, object>();

                        dic["name"] = "ProductName";
                        dic["datepurchase"] = new DateTime();
                        dic["qty"] = 123;
                        dic["price"] = 345;
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
                    tb.Columns.Add(new SQLiteColumn("name"));
                    tb.Columns.Add(new SQLiteColumn("datepurchase", ColType.DateTime));
                    tb.Columns.Add(new SQLiteColumn("price", ColType.Decimal));

                    tb.Columns.Add(new SQLiteColumn("qty", ColType.Integer));

                    sh.CreateTable(tb);
                    conn.Close();
                }
            }
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
            // TestConnection();
            // createTable();
            // insert();
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
