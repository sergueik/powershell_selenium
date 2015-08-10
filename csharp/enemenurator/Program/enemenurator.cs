using System;
using System.Drawing;
// http://msdn.microsoft.com/en-us/library/aa288468%28v=vs.71%29.aspx
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Windows.Forms;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Text;
using System.Text.RegularExpressions;

#region PInvoke Win32 API

/// <summary>
/// http://pinvoke.net/default.aspx/user32.EnumWindows
/// </summary>


public delegate bool PropEnumProcEx(IntPtr hWnd, IntPtr lpszString /* messy atom */, int hData, int dwData);
public delegate bool CallBackPtr(IntPtr hWnd, int lParam);
public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr parameter);

public class EnumReport
{
    // This Class has everything static
    private static ConfigRead x = null;
    private static bool bHasEnemyChild = false;
    public static String CommandLine = String.Empty;
    public static int ProcessID = 0;
    // CreateToolhelp32Snapshot
    // GetWindowThreadProcessId
    // http://forums.devx.com/showthread.php?t=161953
    // http://www.scheibli.com/projects/getpids/index.html
    private static String sDialogText = String.Empty;
    public static ToolSpecificEvent evt = null;
    static bool DEBUG = false;
    public static bool Debug
    {
        get { return DEBUG; }
        set { DEBUG = value; }
    }
    public static string GetText(IntPtr hWnd)
    {
        // Allocate correct string length first
        int length = GetWindowTextLength(hWnd);
        StringBuilder sb = new StringBuilder(length + 1);

        GetWindowText(hWnd, sb, sb.Capacity);
        return sb.ToString();
    }
    // compare to :  http://www.xtremevbtalk.com/showthread.php?t=296115


    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out IntPtr lpdwProcessId);

    [DllImport("user32.dll")]
    public static extern int EnumPropsEx(IntPtr hWnd, PropEnumProcEx lpEnumFunc, int lParam);

    [DllImport("user32.dll")]
    public static extern int EnumWindows(CallBackPtr callPtr, int lPar);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    static extern IntPtr GetProp(IntPtr hWnd, string lpString);

    [return: MarshalAs(UnmanagedType.Bool)]
    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool GetWindowInfo(IntPtr hwnd, ref WINDOWINFO pwi);
    // http://www.wasm.ru/forum/viewtopic.php?pid=312006
    //http://msdn.microsoft.com/en-us/library/ms632610%28v=vs.85%29.aspx
    [StructLayout(LayoutKind.Sequential)]
    struct WINDOWINFO
    {
        public uint cbSize;
        public RECT rcWindow;
        public RECT rcClient;
        public uint dwStyle;
        // http://msdn.microsoft.com/en-us/library/ms632600%28v=vs.85%29.aspx
        // WS_DLGFRAME
        // WS_POPUP
        public uint dwExStyle;
        // http://msdn.microsoft.com/en-us/library/ff700543%28v=vs.85%29.aspx
        public uint dwWindowStatus;
        public uint cxWindowBorders;
        public uint cyWindowBorders;
        public ushort atomWindowType;
        public ushort wCreatorVersion;

        public WINDOWINFO(Boolean? filler)
            : this()
        // Allows automatic initialization of "cbSize" with
        // "new WINDOWINFO(null/true/false)".
        {
            cbSize = (UInt32)(Marshal.SizeOf(typeof(WINDOWINFO)));
        }

    }

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT
    {
        private int _Left;
        private int _Top;
        private int _Right;
        private int _Bottom;

        public RECT(RECT Rectangle)
            : this(Rectangle.Left, Rectangle.Top, Rectangle.Right, Rectangle.Bottom)
        {
        }
        public RECT(int Left, int Top, int Right, int Bottom)
        {
            _Left = Left;
            _Top = Top;
            _Right = Right;
            _Bottom = Bottom;
        }

        public int X
        {
            get { return _Left; }
            set { _Left = value; }
        }
        public int Y
        {
            get { return _Top; }
            set { _Top = value; }
        }
        public int Left
        {
            get { return _Left; }
            set { _Left = value; }
        }
        public int Top
        {
            get { return _Top; }
            set { _Top = value; }
        }
        public int Right
        {
            get { return _Right; }
            set { _Right = value; }
        }
        public int Bottom
        {
            get { return _Bottom; }
            set { _Bottom = value; }
        }
        public int Height
        {
            get { return _Bottom - _Top; }
            set { _Bottom = value - _Top; }
        }
        public int Width
        {
            get { return _Right - _Left; }
            set { _Right = value + _Left; }
        }
        public Point Location
        {
            get { return new Point(Left, Top); }
            set
            {
                _Left = value.X;
                _Top = value.Y;
            }
        }
        public Size Size
        {
            get { return new Size(Width, Height); }
            set
            {
                _Right = value.Width + _Left;
                _Bottom = value.Height + _Top;
            }
        }

        public static implicit operator Rectangle(RECT Rectangle)
        {
            return new Rectangle(Rectangle.Left, Rectangle.Top, Rectangle.Width, Rectangle.Height);
        }
        public static implicit operator RECT(Rectangle Rectangle)
        {
            return new RECT(Rectangle.Left, Rectangle.Top, Rectangle.Right, Rectangle.Bottom);
        }
        public static bool operator ==(RECT Rectangle1, RECT Rectangle2)
        {
            return Rectangle1.Equals(Rectangle2);
        }
        public static bool operator !=(RECT Rectangle1, RECT Rectangle2)
        {
            return !Rectangle1.Equals(Rectangle2);
        }

        public override string ToString()
        {
            return "{Left: " + _Left + "; " + "Top: " + _Top + "; Right: " + _Right + "; Bottom: " + _Bottom + "}";
        }

        public override int GetHashCode()
        {
            return ToString().GetHashCode();
        }

        public bool Equals(RECT Rectangle)
        {
            return Rectangle.Left == _Left && Rectangle.Top == _Top && Rectangle.Right == _Right && Rectangle.Bottom == _Bottom;
        }

        public override bool Equals(object Object)
        {
            if (Object is RECT)
                return Equals((RECT)Object);
            else if (Object is Rectangle)
                return Equals(new RECT((Rectangle)Object));

            return false;
        }
    }



    /// <summary>
    /// Checks  Window Caption and optionally inspects Dialog text
    /// </summary>

    public static bool Report(IntPtr hWnd, int lParam)
    {

        IntPtr lngPid = System.IntPtr.Zero;

        GetWindowThreadProcessId(hWnd, out lngPid);
        int PID = Convert.ToInt32(/* Marshal.ReadInt32 */ lngPid.ToString());

        if (x == null)
            x = new ConfigRead();
        x.LoadConfiguration("Configuration/WindowDetection/Window", "Text");
        string s = x.DetectorExpression;

        string res = String.Empty;
        Regex r = new Regex(s,
                            RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
        string sToken = GetText(hWnd);
        MatchCollection m = r.Matches(sToken);
        if (sToken != null && m.Count != 0)
        {
            Console.WriteLine(String.Format("==>{0}", sToken));

            EnumPropsEx(hWnd, EnumPropsExManaged, 0);

            bHasEnemyChild = false;
            GetChildWindows(hWnd);

            if (bHasEnemyChild)
            {

                if (DEBUG)
                {

                    Console.WriteLine("Window process ID is " + PID.ToString());
                    Console.WriteLine("Window handle is " + hWnd);
                    Console.WriteLine("Window title is " + sToken);
                    Console.WriteLine("Window match " + m.Count.ToString());

                }

                // Fire the event.

                evt.FireToolSpecificEvent(PID, CommandLine, sToken, sDialogText);

            }

        }
        return true;
    }

    // http://msdn.microsoft.com/en-us/library/ms633566%28v=VS.85%29.aspx
    // http://msdn.microsoft.com/en-us/library/ms633561%28v=vs.85%29.aspx#listing_properties
    // http://source.winehq.org/source/include/winuser.h
    public static bool EnumPropsExManaged(IntPtr hWnd, IntPtr lpszString, int hData, int dwData)
    {

        String myManagedString = Marshal.PtrToStringAnsi(lpszString);

        if (DEBUG)
            Console.WriteLine("Prop " + myManagedString);
        return true;
    }
    // http://stackoverflow.com/questions/1145347/what-is-the-best-way-to-make-a-single-instance-application-in-net
    public static List<IntPtr> GetChildWindows(IntPtr parent)
    {
        List<IntPtr> result = new List<IntPtr>();
        GCHandle listHandle = GCHandle.Alloc(result);
        try
        {
            EnumWindowsProc childProc = new EnumWindowsProc(EnumWindow);
            EnumChildWindows(parent, childProc, GCHandle.ToIntPtr(listHandle));

            System.IntPtr[] sArray = new System.IntPtr[result.Count];
            result.CopyTo(sArray, 0);
            foreach (System.IntPtr s in sArray)
            {
                string sChT = GetText(s);
                Console.WriteLine(sChT);
                if (x == null)
                    x = new ConfigRead();
                x.LoadConfiguration("Configuration/DialogDetection/Pattern", "DialogText");
                string s2 = x.DetectorExpression;

                string res = String.Empty;
                Regex r = new Regex(s2,
                                    RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);

                MatchCollection m = r.Matches(sChT);
                if (sChT != null && m.Count != 0)
                {
                    if (DEBUG)
                    {
                        Console.WriteLine(s.ToString());
                        Console.WriteLine(sChT);
                    }
                    bHasEnemyChild = true;

                    sDialogText = sChT;
                }
            }
        }

        finally
        {
            if (listHandle.IsAllocated)
                listHandle.Free();
        }
        return result;
    }

    /// <summary>
    /// Collect Window Handle information of Child Windows.
    /// </summary>

    private static bool EnumWindow(IntPtr handle, IntPtr pointer)
    {
        GCHandle gch = GCHandle.FromIntPtr(pointer);

        List<IntPtr> list = gch.Target as List<IntPtr>;
        if (list == null)
            throw new InvalidCastException("GCHandle Target could not be cast as List<IntPtr>");
        list.Add(handle);
        //  You can modify this to check to see if you want to cancel the operation, then return a null here
        return true;
    }

}


#endregion
#region Internal Event to pass information to Loggers

public class ToolSpecificEventargs : EventArgs
{
    public int processID;
    public string CommandLine;
    public string WindowTitle;
    public string DialogText;
    public string MoreData;
}

public delegate void ToolSpecificEventHandler(object source, ToolSpecificEventargs arg);

public class ToolSpecificEvent
{
    static int count = 0;        // may be needed for continuous monitoring
    public event ToolSpecificEventHandler ActionEvent;

    public void FireToolSpecificEvent()
    {
        ToolSpecificEventargs arg = new ToolSpecificEventargs();
        if (ActionEvent != null)
        {
            arg.processID = count++;

            arg.processID = -1;
            arg.CommandLine = String.Empty;
            arg.WindowTitle = String.Empty;
            arg.DialogText = String.Empty;
            ActionEvent(this, arg);
        }
    }

    public void FireToolSpecificEvent(int value)
    {
        ToolSpecificEventargs arg = new ToolSpecificEventargs();
        if (ActionEvent != null)
        {
            arg.processID = value;
            ActionEvent(this, arg);
        }
    }

    public void FireToolSpecificEvent(int ProcessID, string CommandLine, string WindowTitle, string DialogText)
    {
        // More Info not Passed !
        ToolSpecificEventargs arg = new ToolSpecificEventargs();
        if (ActionEvent != null)
        {
            arg.processID = ProcessID;
            arg.CommandLine = CommandLine;
            arg.WindowTitle = WindowTitle;
            arg.DialogText = DialogText;

            DosDriveInventory DosDI = new DosDriveInventory();
            DosDI.Execute();
            arg.MoreData = DosDI.ReportMappedDosDrives(CommandLine);
            ActionEvent(this, arg);
        }
    }

}

#endregion
#region PlanB Job Discovery

// subst drive classes
// WMI process tree span classes
// Process features   review
//
#endregion
#region Misc

// smtpmail
// http://www.greenend.org.uk/rjk/2000/05/21/smtp-replies.html
// Popup Killer by someone else
// http://69.10.233.10/KB/cs/popupkiller.aspx

// http://msdn.microsoft.com/en-us/library/aa380671(VS.85).aspx
// http://msdn.microsoft.com/en-us/library/aa383490.aspx
// Terminal Services Programming Guidelines

// http://technet2.microsoft.com/windowsserver/en/library/2cb5c8c9-cadc-44a9-bf39-856127f4c8271033.mspx?mfr=true

// wmic.exe path win32_product where (caption like "%wise popup hunter%") call uninstall

#if DISPLAY_HINTS
#warning Don't forget to select main class during compiler:
#warning csc.exe /target:winexe /main:SystemTrayApp.App <file>
#endif

//  Terminal Service C#
// http://www.pinvoke.net/default.aspx/kernel32/GetWindowsDirectory.html
// http://www.codeproject.com/KB/system/TSAddinInCS.aspx
// http://forums.microsoft.com/TechNet/ShowPost.aspx?PostID=3020241&SiteID=17
// http://www.pinvoke.net/default.aspx/wtsapi32.WTSEnumerateSessions
// enumerqate across sessions.
// http://www.codeproject.com/KB/winsdk/LiviuBirjegaCode3.aspx

// http://msdn.microsoft.com/en-us/library/bb762203(VS.85).aspx
// http://vbnet.mvps.org/index.html?code/shell/desktoplink.htm
// vb.net
// http://msdn.microsoft.com/en-us/library/bb762494(VS.85).aspx
// CSIDL_LOCAL_APPDATA
// CSIDL_SYSTEM
// http://www.koders.com/csharp/fid555C2348DB4C419160i54D8A77ECA4D1C1847A812.aspx
// Environment.GetFolderPath(Environment.SpecialFolder.Programs),
// http://www.koders.com/csharp/fid555C2348DB4C41916054D8A77ECA4D1C1847A812.aspx



// DEBUG build should produce a Console APP  not sending any mail.
// RELEASE Build  should produce Windows App capable of sending the mail


#endregion
// See WIKI on Custom  UI for Wix.
//http://www.wixwiki.com/index.php?title=WixUI_Custom
