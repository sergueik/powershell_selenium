# origin : https://github.com/testingbot/Selenium-Screenshots
Add-Type -TypeDefinition @"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Timers;
using System.Management;
using System.IO;

namespace ScreenShotter
{
    class Program
    {
        public struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        };

        private static int width;
        private static int height;

        private static int originalWidth;
        private static int originalHeight;

        private static Process observedProcess;
        [DllImport("user32.dll")]
        private static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);

        [DllImport("user32.dll")]
        private static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern bool EnumThreadWindows(int threadId, EnumThreadProc pfnEnum, IntPtr lParam);

        private delegate bool EnumThreadProc(IntPtr hwnd, IntPtr lParam);

        private static IntPtr hwndProgram;
        private static int processID = 0;
        private static String filename = "";
        static void Main(string[] args)
        {
            try
            {
                processID = Convert.ToInt32(args[0]);
                filename = args[1];
            }
            catch (Exception ex)
            {
               // invalid args
                Console.WriteLine("Invalid arguments: needs processID and filename");
                Environment.Exit(0);
            }

            try
            {
                Process p = Process.GetProcessById(processID);

                if (p == null)
                {
                    // could not fetch process info
                    Environment.Exit(0);
                }

                observedProcess = p;
                getWindowHandle();
            }
            catch (Exception e)
            {
                Console.WriteLine("Could not fetch process info");
                Environment.Exit(0);
            }

            Console.WriteLine("Screenshot saved");
            Environment.Exit(0);
        }

        private static void getWindowHandle()
        {
            // loop all windows for this process
            foreach (ProcessThread t in observedProcess.Threads)
            {
                EnumThreadWindows(t.Id, MyEnumThreadWindowsProc, IntPtr.Zero);
            }

            if (hwndProgram.ToInt32() == 0)
            {
                // could not find a window in the process that matches our requirements (Needs to be a valid browser window)
                Environment.Exit(0);
            }

            // we're ready to take a picture
            takeShot();
        }

        private static void takeShot()
        {
            RECT srcRect;
            if (GetWindowRect(hwndProgram, out srcRect))
            {
                originalWidth = srcRect.Right - srcRect.Left;
                originalHeight = srcRect.Bottom - srcRect.Top;

                width = 400;
                height = (originalHeight / (originalWidth / width));

                if ((height % 2) != 0)
                {
                    height++;
                }


                Bitmap b = new Bitmap(originalWidth, originalHeight);

                using (Graphics g = Graphics.FromImage(b))
                {
                    IntPtr hdc = g.GetHdc();
                    bool result = PrintWindow((IntPtr)observedProcess.MainWindowHandle, hdc, 0);
                    g.ReleaseHdc();
                    g.Flush();
                }

               // Bitmap resized = ResizeImage(b, width, height);

                b.Save(@"C:\test\recorder\" + filename + ".jpg");
            }
        }

        private static bool MyEnumThreadWindowsProc(IntPtr hWnd, IntPtr lParam)
        {
            if (hwndProgram.ToInt32() != 0)
            {
                return true;
            }
            StringBuilder buffer = new StringBuilder(256);
            if (GetWindowText(hWnd, buffer, buffer.Capacity) > 0)
            {
                if ((buffer.ToString().IndexOf("Firefox") > -1) || (buffer.ToString().IndexOf("Internet Explorer") > -1) || (observedProcess.ProcessName == "Safari" && (buffer.ToString() != "Safari") && (buffer.ToString() != "MSCTFIME UI") && (buffer.ToString() != "Default IME") && (buffer.ToString() != "CoreAnimationTesterWindow") && (buffer.ToString().IndexOf("Selenium Remote Control") == -1) && (buffer.ToString().IndexOf("Untitled") == -1)))
                {
                    if ((buffer.ToString().IndexOf("Selenium Remote Control") == -1) && !buffer.ToString().Equals("Windows Internet Explorer") && !buffer.ToString().Equals("Mozilla Firefox") && (buffer.ToString().IndexOf("AppData") == -1))
                    {
                        hwndProgram = hWnd;
                    }
                }
            }
            return true;
        }

        public static System.Drawing.Bitmap ResizeImage(Bitmap image, int width, int height)
        {
            //a holder for the result
            Bitmap result = new Bitmap(width, height);

            //use a graphics object to draw the resized image into the bitmap
            using (Graphics gg = Graphics.FromImage(result))
            {
                //draw the image into the target bitmap
                gg.DrawImage(image, 0, 0, width, height);
                gg.Dispose();
            }

            //return the resulting bitmap
            return result;
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$o = new-object -TypeName 'ScreenShotter'
