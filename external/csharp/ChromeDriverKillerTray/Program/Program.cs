using System;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using ChromeDriverKillerTray.Properties;


namespace ChromeDriverKillerTray
{
    public class ChromeDriverKillerTray : Form
    {
        [STAThread]
        public static void Main()
        {
            Application.Run(new ChromeDriverKillerTray());
        }
 
        private readonly NotifyIcon  _trayIcon;
        private bool _chromedriverRunning = false;

        protected override void OnLoad(EventArgs e)
        {
            Visible       = false;
            ShowInTaskbar = false;
 
            base.OnLoad(e);
        }
 
        private static void OnExit(object sender, EventArgs e)
        {
            Application.Exit();
        }
 
        protected override void Dispose(bool isDisposing)
        {
            if (isDisposing)
            {
                _trayIcon.Dispose();
            }
 
            base.Dispose(isDisposing);
        }

        public ChromeDriverKillerTray()
        {
            var trayMenu = new ContextMenu();
            trayMenu.MenuItems.Add("Exit", OnExit);
 
            _trayIcon = new NotifyIcon
            {
                Text = Resources.ChromeDriverKillerTray_AppName,
                Icon = new Icon(Resources.skull_blue_black, 16, 16),
                ContextMenu = trayMenu,
                Visible = true
            };
            _trayIcon.DoubleClick += _trayIcon_DoubleClick;
            var task = new Task(() =>
            {
                while (true)
                {
                    Task.Delay(2000).Wait();
                    CheckForChromeDriver();
                }
            }, TaskCreationOptions.LongRunning);
            task.Start();
        }

        private void _trayIcon_DoubleClick(object sender, EventArgs e)
        {
            KillChromeDriver();
            CheckForChromeDriver();
        }

        private static void KillChromeDriver()
        {
            foreach (var process in Process.GetProcessesByName("chromedriver"))
            {
                Debug.WriteLine("Killing a ChromeDriver");
                process.Kill();
            }
        }

        private void CheckForChromeDriver()
        {
            var prcs = Process.GetProcesses();
            var chromeDriverProcs = prcs.Where(prc => prc.ProcessName.Contains("chromedriver"));
            
            _chromedriverRunning = chromeDriverProcs.Any();
            UpdateIcon();
        }

        private void UpdateIcon()
        {
            if (_chromedriverRunning)
            {
                _trayIcon.Text = Resources.ChromeDriverKillerTray_ChromeDriver_Detected_AppName;
                _trayIcon.Icon = new Icon(Resources.skull_orange, 16, 16);
            }
            else
            {
                _trayIcon.Text = Resources.ChromeDriverKillerTray_AppName;
                _trayIcon.Icon = new Icon(Resources.skull_blue_black, 16, 16);
            }
        }
    }
}