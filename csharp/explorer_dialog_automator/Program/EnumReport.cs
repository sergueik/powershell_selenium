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
using System.IO;
using System.Threading;
// TODO: restore process tracking
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;

namespace ExplorerFileDialogDetector
{
	public delegate bool CallBackPtr(IntPtr hWnd, int lParam);
	public delegate bool PropEnumProcEx(IntPtr hWnd, IntPtr lpszString, int hData, int dwData);
	public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr parameter);

	public class EnumReport
	{

		private static string _filename;

		public static string Filename {
			get { return _filename; }
			set { _filename = value; }
		}
		private static int _data;
		public static int Data {
			get { return _data; }
			set { _data = value; }
		}

		private static bool bHasButton = false;
		public static String CommandLine = String.Empty;
		public static int ProcessID = 0;
		private static String sDialogText = String.Empty;

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

		[DllImport("user32.dll")]
		public static extern Int32 SendMessage(IntPtr hwnd, UInt32 Msg, IntPtr wParam, [MarshalAs(UnmanagedType.LPStr)] string lParam);

		[return: MarshalAs(UnmanagedType.SysUInt)]
		[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
		static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

		[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

		[DllImport("user32.dll", SetLastError = true)]
		public static extern IntPtr FindWindowEx(IntPtr parentHandle, IntPtr childAfter, string className, string windowTitle);

		[return: MarshalAs(UnmanagedType.Bool)]
		[DllImport("user32.dll", SetLastError = true)]
		static extern bool PostMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

		public static string GetText(IntPtr hWnd)
		{
			int length = GetWindowTextLength(hWnd);
			StringBuilder sb = new StringBuilder(length + 1);
			GetWindowText(hWnd, sb, sb.Capacity);
			return sb.ToString();
		}
		private static string GetWindowClassName(IntPtr hWnd)
		{
			StringBuilder ClassName = new StringBuilder(256);
			int nRet = GetClassName(hWnd, ClassName, ClassName.Capacity);
			return (nRet != 0) ? ClassName.ToString() : null;
		}

		public static void SetText(IntPtr hWnd, String text)
		{
			UInt32 WM_SETTEXT = 0x000C;
			StringBuilder sb = new StringBuilder(text);
			int result = SendMessage(hWnd, WM_SETTEXT, (IntPtr)sb.Length, (String)sb.ToString());
		}

		private static string windowText = "Save As|Opening|Restore Session|Enter name of file to save to";
        
		public string WindowText {
			get {
				return windowText;
			}
			set {
				if ((value != null) && (value != String.Empty)) {
					windowText = value;
				}
			}
		}
        
		public static bool Report(IntPtr hWnd, int lParam)
		{
			IntPtr lngPid = System.IntPtr.Zero;
			GetWindowThreadProcessId(hWnd, out lngPid);
			int PID = Convert.ToInt32(/* Marshal.ReadInt32 */ lngPid.ToString());
			string res = String.Empty;
			string sToken = GetText(hWnd);
			
			MatchCollection m = new Regex(windowText,
				                    RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase).Matches(sToken);
			if (sToken == "" || (sToken != null && m.Count != 0)) {
				EnumPropsEx(hWnd, EnumPropsExManaged, 0);
				bHasButton = false;
				GetChildWindows(hWnd);

				if (bHasButton) {
					Console.WriteLine("Window process ID is " + PID.ToString());
					Console.WriteLine("Window handle is " + hWnd);
					Console.WriteLine("Window title is " + sToken);
					Console.WriteLine("Window match " + m.Count.ToString());
					// urrently unused
					// UInt32 WM_CLOSE = 0x10;
					// SendMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
				}

			}
			return true;
		}

		// http://msdn.microsoft.com/en-us/library/windows/desktop/ms633561%28v=vs.85%29.aspx#retrieving_property
		public static bool EnumPropsExManaged(IntPtr hWnd, IntPtr lpszString, int hData, int dwData)
		{
			String myManagedString = Marshal.PtrToStringAnsi(lpszString);
			string propName = Marshal.PtrToStringAnsi(lpszString);
			return true;
		}

		public static List<IntPtr> GetChildWindows(IntPtr parent)
		{
			List<IntPtr> result = new List<IntPtr>();
			GCHandle listHandle = GCHandle.Alloc(result);
			try {
				EnumWindowsProc childProc = new EnumWindowsProc(EnumWindow);
				EnumChildWindows(parent, childProc, GCHandle.ToIntPtr(listHandle));

				System.IntPtr[] sArray = new System.IntPtr[result.Count];
				result.CopyTo(sArray, 0);

				foreach (System.IntPtr s in sArray) {
					string sChT = GetText(s);
					string s2 = "&Save";
					string res = String.Empty;
					Regex r = new Regex(s2,
						          RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);

					MatchCollection m = r.Matches(sChT);
					if (sChT != null && m.Count != 0) {
						Console.WriteLine("Matches button [{0}] text : \"{1}\"", s, sChT);
						bHasButton = true;

						sDialogText = sChT;
					}
				}
			} finally {
				if (listHandle.IsAllocated)
					listHandle.Free();
			}
			return result;
		}

		private static string saveButtonText = "&Save";
		// "Restore Session";
		
	 
		public static string SaveButtonText {
			get { return saveButtonText; }
			set { saveButtonText = value; }
		}

		private static bool EnumWindow(IntPtr handle, IntPtr pointer)
		{
			GCHandle gch = GCHandle.FromIntPtr(pointer);
			String window_class_name = GetWindowClassName(handle);
			// Set textbox text - filename to save
			if (string.Compare(window_class_name, "Edit", true, CultureInfo.InvariantCulture) == 0) {
				// http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
				const UInt32 WM_CHAR = 0x0102;
				const UInt32 WM_KEYDOWN = 0x0100;
				// not used
				// const UInt32 WM_KEYUP = 0x0101;
				const UInt32 VK_RETURN = 0x0D;
				SendMessage(handle, WM_CHAR, new IntPtr(WM_KEYDOWN), IntPtr.Zero);
				SetText(handle, Path.Combine(Environment.GetEnvironmentVariable("TEMP"), _filename));
				Thread.Sleep(1000);
				SendMessage(handle, WM_CHAR, new IntPtr(VK_RETURN), IntPtr.Zero);
			}

			

			// Click "Save"
			if (string.Compare(window_class_name, "Button", true, CultureInfo.InvariantCulture) == 0) {
				string button_text = GetText(handle);
				if (string.Compare(button_text, saveButtonText, true, CultureInfo.InvariantCulture) == 0) {
					SetText(handle, "About to click");
					const UInt32 BM_CLICK = 0x00F5;
					Thread.Sleep(1000);
					SendMessage(handle, BM_CLICK, IntPtr.Zero, IntPtr.Zero);
				}
			}
			List<IntPtr> list = gch.Target as List<IntPtr>;
			if (list == null)
				throw new InvalidCastException("cast exception");
			list.Add(handle);
			return true;
		}
	}
}