using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Collections;

namespace PopupHandler
{

    class Program
    {
        private const int WM_SETTEXT = 0x000C;
        public const int WM_SYSCOMMAND = 0x0112;
        public const int SC_CLOSE = 0xF060;
        public const int BM_CLICK = 0x00F5;
        public const int EM_SETPASSWORDCHAR = 0X00CC;

        [DllImport("user32.dll")]
        private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("User32.dll")]
        private static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindows);
        [DllImport("User32.dll")]
        private static extern Int32 SendMessage(IntPtr hWnd, int Msg, IntPtr wParam, StringBuilder lParam);
        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);

        private void HandlePopUp(string browser, string executionmode, string uid, string pwd)
        {

            if (browser.Equals("ie", StringComparison.InvariantCultureIgnoreCase))
            {

                if (executionmode.Equals("cancel", StringComparison.InvariantCultureIgnoreCase))
                {
                    // retrieve Windows Security main window handle
                    IntPtr hWnd = FindWindow("#32770", "Windows Security");
                    int iterateForSecurityPopup = 0;
                    for (iterateForSecurityPopup = 0; iterateForSecurityPopup < 20; iterateForSecurityPopup++)
                    {
                        hWnd = FindWindow("#32770", "Windows Security");
                        if (!hWnd.Equals(IntPtr.Zero))
                        {
                            SendMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
                            Environment.Exit(0);
                        }
                        System.Threading.Thread.Sleep(1000);
                    }
                    if (hWnd.Equals(IntPtr.Zero))
                    {
                        Console.WriteLine("Dialog with title Security Popup not found");
                    }
                    return;
                }

                if (executionmode.Equals("ok", StringComparison.InvariantCultureIgnoreCase))
                {
                    string[] data = { uid, pwd };
                    // retrieve Windows Security main window handle
                    IntPtr hWnd = FindWindow("#32770", "Windows Security");
                    int iterateForSecurityPopup = 0;
                    IntPtr duihWnd;

                    for (iterateForSecurityPopup = 0; iterateForSecurityPopup < 25; iterateForSecurityPopup++)
                    {
                        hWnd = FindWindow("#32770", "Windows Security");
                        if (!hWnd.Equals(IntPtr.Zero))
                        {
                            // Get DirectUIHandle
                            duihWnd = FindWindowEx(hWnd, IntPtr.Zero, "DirectUIHWND", "");
                            if (!duihWnd.Equals(IntPtr.Zero))
                            {
                                ArrayList childs = GetAllChildrenWindowHandles(duihWnd, 15);
                                int i = 0;
                                int j = 0;
                                while (i <= childs.Count)
                                {
                                    IntPtr edithWnd = FindWindowEx((IntPtr)childs[i], IntPtr.Zero, "Edit", "");
                                    if (!edithWnd.Equals(IntPtr.Zero))
                                    {
                                        // send WM_SETTEXT message to control
                                        SendMessage(edithWnd, WM_SETTEXT, IntPtr.Zero, new StringBuilder(data[j]));
                                        j++;
                                        if (j == 2) { break; }
                                    }
                                    i++;
                                }

                                i = 0;
                                while (i <= childs.Count)
                                {
                                    //Click on ok
                                    IntPtr btnOkhWnd = FindWindowEx((IntPtr)childs[i], IntPtr.Zero, "Button", "OK");

                                    if (!btnOkhWnd.Equals(IntPtr.Zero))
                                    {
                                        SendMessage(btnOkhWnd, BM_CLICK, 0, 0);
                                        break;
                                    }
                                    i++;
                                }
                            }
                        }

                        System.Threading.Thread.Sleep(750);
                    }

                    if (hWnd.Equals(IntPtr.Zero))
                    {
                        Console.WriteLine("Dialog Handle not present");
                    }
                    return;
                }
            }
        }

        static ArrayList GetAllChildrenWindowHandles(IntPtr hParent, int maxCount)
        {
            ArrayList result = new ArrayList();
            int ct = 0;
            IntPtr prevChild = IntPtr.Zero;
            IntPtr currChild = IntPtr.Zero;
            while (true && ct < maxCount)
            {
                currChild = FindWindowEx(hParent, prevChild, null, null);
                if (currChild == IntPtr.Zero)
                {
                    int errorCode = Marshal.GetLastWin32Error();
                    break;
                }
                result.Add(currChild);
                prevChild = currChild;
                ++ct;
            }
            return result;
        }

        static void Main(string[] args)
        {

            string browser = args[0];
            string mode = args[1];
            string uid = "";
            string pwd = "";

            uid = args[2];
            pwd = args[3];

            new Program().HandlePopUp(browser, mode, uid, pwd);


        }
    }
}