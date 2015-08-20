using System;
using System.Drawing;
using System.Diagnostics;
using System.ComponentModel;
using System.Windows.Forms;

namespace SystemTrayApp
{
    public class App
    {
        private string _filename = String.Format("my random filename {0}", new Random().Next(10));
        private NotifyIcon appIcon = new NotifyIcon();
        private int isStateone = 0;
        private Icon IdleIcon;
        private Icon BusyIcon;
        private ContextMenu sysTrayMenu = new ContextMenu();
        // TODO: offer options?
        private MenuItem runNowMenuItem = new MenuItem("Run Now");
        private MenuItem exitApp = new MenuItem("Exit");
        // private DialogHunter worker = new DialogHunter();
        // private ArrayList newDialogs = new ArrayList();
        static System.Windows.Forms.Timer myTimer = new System.Windows.Forms.Timer();
        static int nScanCounter = 1;
        static bool exitFlag = false;

        private void TimerEventProcessor(Object myObject,
                         EventArgs myEventArgs)
        {
            myTimer.Stop();
            nScanCounter++;
            Console.Write("{0}\r", nScanCounter.ToString());
            isStateone = 1 - isStateone;
            appIcon.Visible = false;
            if (isStateone == 1)
                appIcon.Icon = BusyIcon;
            else
                appIcon.Icon = IdleIcon;
            appIcon.Visible = true;

            // indicate the worker process is running


            EnumReport.Filename = _filename;
            EnumReport.EnumWindows(EnumReport.Report, 0);

            // DialogDetector Worker = new DialogDetector();
            // Worker.Perform();
            // Thread.Sleep (1000);
            isStateone = 1 - isStateone;
            appIcon.Visible = false;
            if (isStateone == 1)
                appIcon.Icon = BusyIcon;
            else
                appIcon.Icon = IdleIcon;
            appIcon.Visible = true;
            // restart Timer.
            myTimer.Start();
        }

        public void Start()
        {
            IdleIcon = new Icon(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("enemenurator.IdleIcon.ico"));
            BusyIcon = new Icon(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("enemenurator.BusyIcon.ico"));

            appIcon.Icon = IdleIcon;
            appIcon.Text = "Popup Hunter Tool";
            sysTrayMenu.MenuItems.Add(runNowMenuItem);
            sysTrayMenu.MenuItems.Add(exitApp);
            appIcon.ContextMenu = sysTrayMenu;

            myTimer.Tick += new EventHandler(TimerEventProcessor);

            // Sets the timer interval to 1 hour.
            // TODO -  read config file:
            myTimer.Interval = 3600000;
            myTimer.Start();

            appIcon.Visible = true;

            runNowMenuItem.Click += new EventHandler(runNow);
            exitApp.Click += new EventHandler(ExitApp);
        }

        private void runNow(object sender, System.EventArgs e)
        {
            TimerEventProcessor(sender, e);
        }
        private void ExitApp(object sender, System.EventArgs e)
        {
            // No components to dispose:
            // need to Displose individual resources
            Debug.Assert(exitFlag != true);
            appIcon.Dispose();
            IdleIcon.Dispose();
            BusyIcon.Dispose();

            Application.Exit();
        }
/*
        public static void Main()
        {
#if DEBUG
            Console.WriteLine("Debug version.");
#endif
            App app = new App();
            app.Start();
            Application.Run();
        }
 */
    }
}
