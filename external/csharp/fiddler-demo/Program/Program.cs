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