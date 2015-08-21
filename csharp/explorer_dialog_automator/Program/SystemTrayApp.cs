/*
Copyright (c) 2006, 2014, 2015 Serguei Kouzmine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

using System;
using System.Drawing;
using System.Diagnostics;
using System.Collections;
using System.Windows.Forms;
using System.Threading;

namespace ExplorerFileDialogDetector
{
    public class SystemTrayApp : UserControl
    {

        private string _filename = String.Format("my random filename {0}", new Random().Next(10));
        private NotifyIcon notify_app = new NotifyIcon();
        private bool is_busy = false;
        private Icon idle_icon;
        private Icon busy_icon;
        private ContextMenu sysTrayMenu = new ContextMenu();
        // TODO: offer options?
        private MenuItem configure_options = new MenuItem("Configure");
        private MenuItem run_now = new MenuItem("Run Now");
        private MenuItem exit_app = new MenuItem("Exit");
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
            is_busy = !is_busy;
            notify_app.Visible = false;
            if (is_busy)
                notify_app.Icon = busy_icon;
            else
                notify_app.Icon = idle_icon;
            notify_app.Visible = true;

            // indicate the worker process is running


            EnumReport.Filename = _filename;
            EnumReport.EnumWindows(EnumReport.Report, 0);

            // DialogDetector Worker = new DialogDetector();
            // Worker.Perform();
            Thread.Sleep(1000);
            is_busy = !is_busy;
            notify_app.Visible = false;
            if (is_busy)
                notify_app.Icon = busy_icon;
            else
                notify_app.Icon = idle_icon;
            notify_app.Visible = true;
            // restart Timer.
            myTimer.Start();
        }

        public void Start()
        {
            idle_icon = new Icon(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("ExplorerFileDialogDetector.idle_icon.ico"));
            busy_icon = new Icon(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("ExplorerFileDialogDetector.busy_icon.ico"));

            notify_app.Icon = idle_icon;
            notify_app.Text = "Explorer File Dialog Automator";
            sysTrayMenu.MenuItems.Add(configure_options);
            sysTrayMenu.MenuItems.Add(run_now);
            sysTrayMenu.MenuItems.Add(exit_app);
            notify_app.ContextMenu = sysTrayMenu;

            myTimer.Tick += new EventHandler(TimerEventProcessor);

            // Sets the timer interval to 1 hour.
            // TODO -  read config file:
            myTimer.Interval = 3600000;
            myTimer.Start();

            notify_app.Visible = true;

            run_now.Click += new EventHandler((object sender, System.EventArgs e) => TimerEventProcessor(sender, e));
            exit_app.Click += new EventHandler(exit_app_event_handler);
            configure_options.Click += new EventHandler(DisplayConfigureAppForm);
        }

        private void DisplayConfigureAppForm(object sender, System.EventArgs e)
        {
            ConfigureApp configure_app = new ConfigureApp();
            configure_app.FillList(new ArrayList() { _filename });
            configure_app.Show();
        }

        private void exit_app_event_handler(object sender, System.EventArgs e)
        {
            // No components to dispose:
            // need to Displose individual resources
            Debug.Assert(exitFlag != true);
            notify_app.Dispose();
            idle_icon.Dispose();
            busy_icon.Dispose();

            Application.Exit();
        }

        public static void Main()
        {
            SystemTrayApp app = new SystemTrayApp();
            app.Start();
            Application.Run();
        }

    }
}
