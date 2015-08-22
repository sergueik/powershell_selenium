using System;
using System.Runtime.InteropServices;

namespace ExplorerFileDialogDetector
{
    internal static class NativeMethods
    {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        public static IntPtr HWND_BROADCAST = new IntPtr(0xffff);
        public static uint WM_COPYDATA = 0x004A;
        [StructLayout(LayoutKind.Sequential)]
        public struct COPYDATASTRUCT
        {
            public IntPtr dwData;
            public int cbData;
            public IntPtr lpData;
        }
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

        public enum MessageFilterInfo : uint
        {
            None = 0,
            AlreadyAllowed = 1,
            AlreadyDisAllowed = 2,
            AllowedHigher = 3
        }
        public enum ChangeWindowMessageFilterExAction : uint
        {
            Reset = 0,
            Allow = 1,
            DisAllow = 2
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct CHANGEFILTERSTRUCT
        {
            public uint size;
            public MessageFilterInfo info;
        }

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool ChangeWindowMessageFilterEx(IntPtr hWnd, uint msg, ChangeWindowMessageFilterExAction action, ref CHANGEFILTERSTRUCT changeInfo);

    }
}
