using System;
using System.Drawing;
using System.IO;
using System.Threading;
using System.Diagnostics;
// http://msdn.microsoft.com/en-us/library/aa288468%28v=vs.71%29.aspx
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Windows.Forms;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Text;
using System.Text.RegularExpressions;
using System.Reflection;
using System.Xml;
using System.Xml.XPath;
using System.Management;
using System.Net;

#region Bootstrap Application

namespace SystemTrayApp
{

public class App
{

private NotifyIcon appIcon = new NotifyIcon();

private int isStateone = 0;
private Icon IdleIcon;
private Icon BusyIcon;

// Define the menu.
private ContextMenu sysTrayMenu = new ContextMenu();
// TODO: offer options
private MenuItem runNowMenuItem = new MenuItem("Run Now");


private MenuItem exitApp = new MenuItem("Exit");

// private DialogHunter worker = new DialogHunter();
// private ArrayList newDialogs = new ArrayList();

static System.Windows.Forms.Timer myTimer = new System.Windows.Forms.Timer();

static int nScanCounter = 1;
static bool exitFlag = false;

// This is the method to run when the timer is raised.
private void TimerEventProcessor(Object myObject,
				 EventArgs myEventArgs)
{
	myTimer.Stop();
	nScanCounter++;
	Console.Write("{0}\r", nScanCounter.ToString( ));
	isStateone = 1 - isStateone;
	appIcon.Visible = false;
	if (isStateone == 1)
		appIcon.Icon = BusyIcon;
	else
		appIcon.Icon = IdleIcon;
	appIcon.Visible = true;
	// Change the background image to the next image.
	DialogDetector Worker = new DialogDetector();
	Worker.Perform();
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

	// Place the menu items in the menu.
	sysTrayMenu.MenuItems.Add(runNowMenuItem);
	sysTrayMenu.MenuItems.Add(exitApp);
	appIcon.ContextMenu = sysTrayMenu;

	myTimer.Tick += new EventHandler(TimerEventProcessor);

	// Sets the timer interval to 1 hour.
	// TODO -  read config file:
	myTimer.Interval = 3600000;
	myTimer.Start();

	// Show the system tray icon.
	appIcon.Visible = true;

	// Attach event handlers.
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


public static void Main()
{


#if DEBUG
	Console.WriteLine("Debug version." );
#endif

	App app = new App();
	app.Start();
	// No forms are being displayed,
	// next statement to prevent the application from automatically ending.
	Application.Run();
}



}

}
#endregion



#region PInvoke Win32 API

/// <summary>
/// http://pinvoke.net/default.aspx/user32.EnumWindows
/// </summary>


public delegate bool PropEnumProcEx( IntPtr hWnd, IntPtr lpszString /* messy atom */, int hData, int dwData );
public delegate bool CallBackPtr( IntPtr hWnd,  int lParam);
public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr parameter);

public class EnumReport
{
// This Class has everything static
private static ConfigRead x         = null;
private static bool bHasEnemyChild  = false;
public static String CommandLine    = String.Empty;
public static int ProcessID         = 0;
// CreateToolhelp32Snapshot
// GetWindowThreadProcessId
// http://forums.devx.com/showthread.php?t=161953
// http://www.scheibli.com/projects/getpids/index.html
private static String sDialogText   = String.Empty;
public static ToolSpecificEvent evt = null;
static bool DEBUG                   = false;
public static bool Debug {  get { return DEBUG; } set { DEBUG = value; } }
public static string GetText(IntPtr hWnd)
{
	// Allocate correct string length first
	int length       = GetWindowTextLength(hWnd);
	StringBuilder sb = new StringBuilder(length + 1);

	GetWindowText(hWnd, sb, sb.Capacity);
	return sb.ToString();
}
// compare to :  http://www.xtremevbtalk.com/showthread.php?t=296115


[DllImport("user32.dll")]
[return : MarshalAs(UnmanagedType.Bool)]
public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
static extern int GetWindowTextLength(IntPtr hWnd);

[DllImport("user32.dll", SetLastError = true)]
public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out IntPtr lpdwProcessId);

[DllImport("user32.dll")]
public static extern int EnumPropsEx(IntPtr hWnd, PropEnumProcEx lpEnumFunc,  int lParam);

[DllImport("user32.dll")]
public static extern int EnumWindows(CallBackPtr callPtr, int lPar);

[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
static extern IntPtr GetProp(IntPtr hWnd, string lpString);

[return : MarshalAs(UnmanagedType.Bool)]
[DllImport("user32.dll", SetLastError = true)]
private static extern bool GetWindowInfo(IntPtr hwnd, ref WINDOWINFO pwi);
// http://www.wasm.ru/forum/viewtopic.php?pid=312006
//http://msdn.microsoft.com/en-us/library/ms632610%28v=vs.85%29.aspx
[StructLayout(LayoutKind.Sequential)]
struct WINDOWINFO {
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

	public WINDOWINFO(Boolean ?   filler)   :   this()
		// Allows automatic initialization of "cbSize" with
		// "new WINDOWINFO(null/true/false)".
	{
		cbSize = (UInt32)(Marshal.SizeOf(typeof( WINDOWINFO )));
	}

}

[StructLayout(LayoutKind.Sequential)]
public struct RECT {
	private int _Left;
	private int _Top;
	private int _Right;
	private int _Bottom;

	public RECT(RECT Rectangle) : this(Rectangle.Left, Rectangle.Top, Rectangle.Right, Rectangle.Bottom)
	{
	}
	public RECT(int Left, int Top, int Right, int Bottom)
	{
		_Left = Left;
		_Top = Top;
		_Right = Right;
		_Bottom = Bottom;
	}

	public int X {
		get { return _Left; }
		set { _Left = value; }
	}
	public int Y {
		get { return _Top; }
		set { _Top = value; }
	}
	public int Left {
		get { return _Left; }
		set { _Left = value; }
	}
	public int Top {
		get { return _Top; }
		set { _Top = value; }
	}
	public int Right {
		get { return _Right; }
		set { _Right = value; }
	}
	public int Bottom {
		get { return _Bottom; }
		set { _Bottom = value; }
	}
	public int Height {
		get { return _Bottom - _Top; }
		set { _Bottom = value - _Top; }
	}
	public int Width {
		get { return _Right - _Left; }
		set { _Right = value + _Left; }
	}
	public Point Location {
		get { return new Point(Left, Top); }
		set {
			_Left = value.X;
			_Top = value.Y;
		}
	}
	public Size Size {
		get { return new Size(Width, Height); }
		set {
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

public static bool Report( IntPtr hWnd,  int lParam)
{

	IntPtr lngPid  =  System.IntPtr.Zero;

	GetWindowThreadProcessId(hWnd, out lngPid );
	int PID = Convert.ToInt32(/* Marshal.ReadInt32 */ lngPid.ToString() );

	if ( x == null )
		x = new ConfigRead();
	x.LoadConfiguration("Configuration/WindowDetection/Window", "Text");
	string s  = x.DetectorExpression;

	string res =  String.Empty;
	Regex r = new Regex( s,
			     RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase );
	string sToken =  GetText(hWnd);
	MatchCollection m = r.Matches( sToken);
	if ( sToken != null && m.Count != 0 ) {
        Console.WriteLine(String.Format("==>{0}", sToken));

		EnumPropsEx(hWnd, EnumPropsExManaged, 0 );

		bHasEnemyChild = false;
		GetChildWindows(hWnd);

		if (bHasEnemyChild) {

			if (DEBUG) {

				Console.WriteLine("Window process ID is " + PID.ToString() );
				Console.WriteLine("Window handle is "     + hWnd);
				Console.WriteLine("Window title is "      + sToken  );
				Console.WriteLine("Window match "         +  m.Count.ToString());

			}

			// Fire the event.

			evt.FireToolSpecificEvent(PID, CommandLine, sToken, sDialogText );

		}

	}
	return true;
}

// http://msdn.microsoft.com/en-us/library/ms633566%28v=VS.85%29.aspx
// http://msdn.microsoft.com/en-us/library/ms633561%28v=vs.85%29.aspx#listing_properties
// http://source.winehq.org/source/include/winuser.h
public static bool EnumPropsExManaged( IntPtr hWnd, IntPtr lpszString, int hData, int dwData )
{

	String myManagedString = Marshal.PtrToStringAnsi(lpszString );

	if (DEBUG)
		Console.WriteLine("Prop " + myManagedString );
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


		foreach ( System.IntPtr s in sArray) {

			string sChT =  GetText(s);
                        Console.WriteLine(sChT); 
			if (x == null )
				x = new ConfigRead();
			x.LoadConfiguration("Configuration/DialogDetection/Pattern", "DialogText");
			string s2 = x.DetectorExpression;

			string res =  String.Empty;
			Regex r = new Regex( s2,
					     RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase );

			MatchCollection m = r.Matches( sChT);
			if (sChT != null && m.Count != 0 ) {
				if (DEBUG) {
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




#region Configuration Processor

public class ConfigRead {

private static string _ConfigFileName = "config.xml";
public static string ConfigFileName {  get { return _ConfigFileName; } set { _ConfigFileName = value; } }

public static bool Debug {  get { return DEBUG; } set { DEBUG = value; } }
static bool DEBUG = false;
private ArrayList _PatternArrayList;
private string sDetectorExpression;
public string DetectorExpression {  get { return sDetectorExpression; }         }

public void  LoadConfiguration(string Section, string Column)
{

	_PatternArrayList = new ArrayList();

	XmlDocument xmlDoc = new XmlDocument();
	xmlDoc.PreserveWhitespace =  true;
	Assembly CurrentlyExecutingAssembly = Assembly.GetExecutingAssembly();

	FileInfo CurrentlyExecutingAssemblyFileInfo = new FileInfo(CurrentlyExecutingAssembly.Location);
	string ConfigFilePath = CurrentlyExecutingAssemblyFileInfo.DirectoryName;
	try {
		xmlDoc.Load(ConfigFilePath + @"\" + ConfigFileName);
	} catch (Exception e) {
		Console.WriteLine(e.Message);
		//  Environment.Exit(1);
		Console.WriteLine("Loading embedded resource");
		// While Loading - note : embedded resource Logical Name is overriden at the project level.
		xmlDoc.Load(CurrentlyExecutingAssembly.GetManifestResourceStream(ConfigFileName));

	}
	// see http://forums.asp.net/p/1226183/2209639.aspx
	//
	if (DEBUG)
		Console.WriteLine("Loading: Section \"{0}\" Column \"{1}\"", Section, Column);

	XmlNodeList nodes = xmlDoc.SelectNodes(Section);
	foreach (XmlNode node in nodes) {

		XmlNode DialogTextNode = node.SelectSingleNode(Column);
		string sInnerText = DialogTextNode.InnerText;
		if (!String.IsNullOrEmpty(sInnerText)) {
			_PatternArrayList.Add( sInnerText );
			if (DEBUG)
				Console.WriteLine("Found \"{0}\"", sInnerText);
		}
	}
	if (0 == _PatternArrayList.Count) {
		if (Debug)
			Console.WriteLine("Invalid Configuration:\nReview Section \"{0}\" Column \"{1}\"", Section, Column);

		MessageBox.Show(
			String.Format( "Invalid Configuration file:\nReview \"{0}/{1}\"", Section, Column),
			CurrentlyExecutingAssembly.GetName().ToString(),
			MessageBoxButtons.OK,
			System.Windows.Forms.MessageBoxIcon.Exclamation);
		Environment.Exit(1);
	}
	try {
		sDetectorExpression   =  String.Join( "|", (string [] )_PatternArrayList.ToArray( typeof(string)));
	} catch (Exception e) {
		Console.WriteLine("Internal error processing Configuration");
		System.Diagnostics.Debug.Assert(e != null );
		Environment.Exit(1);

	}
	if (DEBUG)
		Console.WriteLine(sDetectorExpression);
}

}


#endregion




#region Configuration XPATH Processor

public class XMLDataExtractor {


private bool DEBUG = false;
public bool Debug {  get { return DEBUG; } set { DEBUG = value; } }
// see http://support.microsoft.com/kb/308333 about XPathNavigator

private XPathNavigator nav;
private XPathDocument docNav;
private XPathNodeIterator NodeIter;
private XPathNodeIterator NodeResult;

public XMLDataExtractor(string sFile)
{
	try {
		// Open the XML.
		docNav = new XPathDocument(sFile);

	} catch (Exception e ) {
		// don't do anything.
		Trace.Assert(e != null); // keep the compiler happy
	}

	if (docNav != null)
		// Create a navigator to query with XPath.
		nav = docNav.CreateNavigator();

}

public String[] ReadAllNodes(String sNodePath, String sFieldPath)
{

	// Select the node and place the results in an iterator.
	NodeIter = nav.Select(sNodePath);

	ArrayList _DATA = new ArrayList(1024);

	// Iterate through the results showing the element value.

	while (NodeIter.MoveNext()) {
		XPathNavigator here = NodeIter.Current;

		if (DEBUG) {
			try {
				Type ResultType = here.GetType();
				Console.WriteLine("Result type: {0}", ResultType);
				foreach (PropertyInfo oProperty in ResultType.GetProperties()) {
					string sProperty = oProperty.Name.ToString();
					Console.WriteLine("{0} = {1}",
							  sProperty,
							  ResultType.GetProperty(sProperty).GetValue(here, new Object[] {})

					                  /* COM  way:
					                     ResultType.InvokeMember(sProperty,
					                                             BindingFlags.Public |
					                                             BindingFlags.Instance |
					                                             BindingFlags.Static |
					                                             BindingFlags.GetProperty,
					                                             null,
					                                             here,
					                                             new Object[] {},
					                                             new CultureInfo("en-US", false))
					                   */
							  );
				}
				;
			} catch (Exception e) {
				// Fallback to system formatting
				Console.WriteLine("Result:\n{0}", here.ToString());
				Trace.Assert(e != null); // keep the compiler happy
			}
		} // DEBUG

		// collect the caller requested data
		NodeResult = null;

		try { NodeResult = here.Select(sFieldPath); }  catch (Exception e) {
			// Fallback to system formatting
			Console.WriteLine(e.ToString());
			throw /* ??? */;
		}

		if (NodeResult != null) {
			while (NodeResult.MoveNext())
				_DATA.Add(NodeResult.Current.Value);

		}


	}
	;
	String []  res =   (String[])_DATA.ToArray(typeof(string));
	if (DEBUG)
		Console.WriteLine(String.Join(";", res));
	return res;

}

public void ReadSingleNode( String sNodePath)
{
	// http://msdn2.microsoft.com/en-us/library/system.xml.xmlnode.selectsinglenode(VS.71).aspx
	// Select the node and place the results in an iterator.
	NodeIter = nav.Select(sNodePath);
	// Iterate through the results showing the element value.
	while (NodeIter.MoveNext())
		Console.WriteLine("Book Title: {0}", NodeIter.Current.Value);
	;
}


}

#endregion




#region NT EventLog Logger

public class NTEventLogLogger  {

private static string ExecutingProcessName = System.Reflection.Assembly.GetExecutingAssembly().ManifestModule.ToString();
private string MySource = ExecutingProcessName;
private int myApplicationEventId = 1480;
private EventLogEntryType myEventLogEntryType =  EventLogEntryType.Error;

static bool DEBUG = false;
public static bool Debug {  get { return DEBUG; } set { DEBUG = value; } }

public NTEventLogLogger ()
{

	// Create the source, if it does not already exist.
	if (!EventLog.SourceExists(MySource)) {
		EventLog.CreateEventSource(MySource, "Application");
		if (DEBUG)
			Console.WriteLine("CreatingEventSource");
	}


	// Create an EventLog instance and assign its source.
	EventLog myLog = new EventLog();
	myLog.Source = MySource;

}

public void WriteToNTEventLog(string myMessage )
{

	EventLog.WriteEntry(MySource, myMessage,
			    myEventLogEntryType, myApplicationEventId);

}


public void handler(object source, ToolSpecificEventargs arg)
{

	this.WriteToNTEventLog(
		String.Format("Suspicious popup posted by Process  {0}\n{1}\nDialog Text:{2}\nWindow Title:{3}\nMore Info: {4}",
			      arg.processID,
			      arg.CommandLine,
			      arg.DialogText,
			      arg.WindowTitle,
			      arg.MoreData));


}
}

#endregion




#region Console Logger



class ConsoleLogger {
public void handler(object source, ToolSpecificEventargs arg)
{
	Console.WriteLine(String.Format("Event received by an X object\n{0}\n{1}\n{2}\n{3}\n", arg.processID, arg.CommandLine, arg.DialogText, arg.WindowTitle));

}
}

#endregion




#region SMS/MailLogger

class FormPoster {

static bool DEBUG = false;
public static bool Debug {  get { return DEBUG; } set { DEBUG = value; } }

WebClient myWebClient;
string uriString = @"http://ftlplanb02/planb/result.pl";

public FormPoster ()
{
	myWebClient = new WebClient();
}

//  [Conditional("Debug")]

private void Action(ToolSpecificEventargs arg)
{



	// Create a new NameValueCollection instance to hold some custom parameters to be posted to the URL.
	NameValueCollection myNameValueCollection = new NameValueCollection();

	string BuildMachine = System.Environment.GetEnvironmentVariable("COMPUTERNAME");
	string UserName = System.Security.Principal.WindowsIdentity.GetCurrent().Name;

	byte[] responseArray = null;


#if DEBUG
	// Maintain VBLMonitor and VBLManager
	Console.WriteLine("I see you." );

//        if (DEBUG ) {
	Console.WriteLine("\nUploading to {0} ...", uriString);
	Console.WriteLine("\nComputer {0}", BuildMachine);
	Console.WriteLine("\nApplication {0}", arg.CommandLine );
	Console.WriteLine("\nWindow Title {0}", arg.WindowTitle);
	Console.WriteLine("\nDialog Text {0}", arg.DialogText);
	Console.WriteLine("\nMore Info: {0}", arg.MoreData);

//         }


	System.Diagnostics.Debug.Assert(uriString !=  null );

#else

	// Add necessary parameter/value pairs to the name/value container.
	myNameValueCollection.Add("Computer", BuildMachine );
	myNameValueCollection.Add("Application", arg.CommandLine ); // command line
	myNameValueCollection.Add("Window Title", arg.WindowTitle);
	myNameValueCollection.Add("Dialog Text", arg.DialogText);
	myNameValueCollection.Add("More Info",  String.Format("{0} {1}",  "Drive", arg.MoreData) );





	try {
		// Upload the NameValueCollection.
		responseArray =  myWebClient.UploadValues(uriString, "POST", myNameValueCollection);
		// Decode and display the response.
		if (DEBUG )
			Console.WriteLine("\nResponse received was:\n{0}", Encoding.ASCII.GetString(responseArray));
	} catch (Exception e) {
		Console.WriteLine(e.ToString());
	}
#endif
	return;

}

public void handler(object source, ToolSpecificEventargs arg)
{
	Action(arg);

}

}

#endregion
#region Internal Event to pass information to Loggers

public class ToolSpecificEventargs : EventArgs {

public int processID;
public string CommandLine;
public string WindowTitle;
public string DialogText;
public string MoreData;

}

public delegate void ToolSpecificEventHandler(object source, ToolSpecificEventargs arg);

public class ToolSpecificEvent {

static int count = 0;    // may be needed for continuous monitoring

public event ToolSpecificEventHandler ActionEvent;


/// <summary>
/// Fires ToolSpecificEvent
/// </summary>

public void FireToolSpecificEvent()
{
	ToolSpecificEventargs arg = new ToolSpecificEventargs();

	if (ActionEvent != null) {
		arg.processID = count++;

		arg.processID   = -1;
		arg.CommandLine =  String.Empty;
		arg.WindowTitle = String.Empty;
		arg.DialogText  = String.Empty;

		ActionEvent(this, arg);
	}
}

/// <summary>
/// Fires ToolSpecificEvent with value data
/// </summary>

public void FireToolSpecificEvent(int value)
{
	ToolSpecificEventargs arg = new ToolSpecificEventargs();

	if (ActionEvent != null) {
		arg.processID = value;
		ActionEvent(this, arg);
	}
}

/// <summary>
/// Fires ToolSpecificEvent with value data
/// </summary>

public void FireToolSpecificEvent(int ProcessID, string CommandLine, string WindowTitle, string DialogText)
{
	// More Info not Passed !
	ToolSpecificEventargs arg = new ToolSpecificEventargs();

	if (ActionEvent   != null) {
		arg.processID   = ProcessID;
		arg.CommandLine =  CommandLine;
		arg.WindowTitle = WindowTitle;
		arg.DialogText  = DialogText;

		DosDriveInventory DosDI = new DosDriveInventory();
		DosDI.Execute();
		arg.MoreData =  DosDI.ReportMappedDosDrives(CommandLine);

		ActionEvent(this, arg);
	}
}

}

#endregion

#region Top Worker class

public class DialogDetector  {

static public bool DialogDetected = false;
static private String CommandLine = String.Empty;
static bool DEBUG = false;
public static bool Debug {  get { return DEBUG; } set { DEBUG = value; } }

public void Perform( )
{

	Process[] myProcesses;
	myProcesses = Process.GetProcesses();

	FormPoster MyFormPoster = new  FormPoster();

	ConsoleLogger MyConsoleLogger = new ConsoleLogger();
	NTEventLogLogger MyNTEventLogLogger = new NTEventLogLogger();
	ToolSpecificEvent myDiscovery = new ToolSpecificEvent();


	// subscribe Loggers to the event list.
	myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyConsoleLogger.handler);
	myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyNTEventLogLogger.handler);
	myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyFormPoster.handler);

	ConfigRead x = new ConfigRead();
	x.LoadConfiguration("Configuration/ProcessDetection/Process", "ProcessName");
	string s  = x.DetectorExpression;
	Regex r = new Regex( s, RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase );

	foreach (Process myProcess in myProcesses) {

		string res =  String.Empty;
		string sProbe = myProcess.ProcessName;
		//  myProcess.StartInfo.FileName - not accessible
		if (Debug) Console.WriteLine( "Process scan: {0}",  s  ); MatchCollection m = r.Matches( sProbe);
		if ( sProbe != null && m.Count != 0 ) {

			try {
				DialogDetected = true;
				ProcessCommandLine z =  new ProcessCommandLine(myProcess.Id.ToString());

				if (Debug) Console.WriteLine( "{0}{1}",  myProcess.Id.ToString(),  z.CommandLine  ); CommandLine =  z.CommandLine;
				// CommandLine = myProcess.ProcessName;
				Console.WriteLine("--> {0} {1} {2} {3}", sProbe, myProcess.ProcessName, myProcess.Id, DateTime.Now -  myProcess.StartTime);
			} catch (Win32Exception e) { System.Diagnostics.Trace.Assert(e !=  null); }
		}
	}

	CallBackPtr callBackPtr = new CallBackPtr(EnumReport.Report);

	if (DialogDetected) {

		EnumReport.evt = myDiscovery;
		EnumReport.CommandLine = CommandLine;
		EnumReport.EnumWindows(callBackPtr, 0);

	}


}

}

#endregion




#region WMI Data processor

public class ProcessCommandLine {

static bool DEBUG = false;
public static bool Debug {  get { return DEBUG; } set { DEBUG = value; } }

private String _CommandLine  = String.Empty;

public String CommandLine { get { return _CommandLine; } }
public ProcessCommandLine (String PID )
{

	ManagementClass mc = new ManagementClass( @"root/cimv2:Win32_Process" );
	ManagementObjectCollection mobjects = mc.GetInstances( );

	if (DEBUG) Console.WriteLine("{0}", PID  ); foreach ( ManagementObject mo in mobjects ) {
		if (DEBUG)
			Console.WriteLine(mo ["ProcessID"].ToString( ));
		if ( PID  ==  mo ["ProcessID"].ToString( ))
			_CommandLine = mo ["CommandLine"].ToString( );

	}
}
}



// Discovery / integration with Plan B Jobs

#endregion

#region PlanB DOS Drive Discovery

public class DosDriveInventory { // originally an MSBuild Task.


private ArrayList _MappedDriveLettersArrayList = new ArrayList(24);
private ArrayList _UnusedDriveLettersArrayList = new ArrayList(24);

private string _MappedDriveLetters = "";

private string _UnusedDriveLetters = "";
static bool DEBUG = false;

public string UnusedDriveLetters {  get { return _UnusedDriveLetters; }         }
public string MappedDriveLetters {  get { return _MappedDriveLetters;  }         }


[DllImport("kernel32.dll")]
public static extern uint QueryDosDevice(string lpDeviceName, StringBuilder lpTargetPath, int ucchMax);

[DllImport("kernel32.dll")]
public static extern long GetDriveType(string driveLetter);

private string FmyProperty;

private Hashtable Unused = new Hashtable();
private Hashtable Used = new Hashtable();

private Encoding ascii  =  Encoding.ASCII;
private String[] x   = new String[24];

public string MyProperty {

	get { return FmyProperty; }
	set { FmyProperty = value; }
}


public static void Main()
{

	DEBUG =  ( System.Environment.GetEnvironmentVariable("DEBUG")  == null) ? false : true;
	DosDriveInventory x = new DosDriveInventory();
	x.Execute();


	string SampleCommand   = @"""C:\Program Files\Wise for Windows Installer\wfwi.exe"" /c N:\foobar""X:\src\layouts\msi\MergeModules\mf\mf_lang\x64\retail\es\MF_LANG.wsm"" /o ""x64\retail\es\MF_LANG.msm"" /s /v /l ""x64\retail\es\MF_LANG_msm.log""";


	Console.WriteLine(x.ReportMappedDosDrives(SampleCommand   ) );

}
public bool Execute()
{


	byte cnt;

	// Internal Drive letter  hash table .
	for (cnt = 0; cnt != x.Length; cnt++ ) {
		String z = String.Format("{0}:\\", ascii.GetString( new byte[] { (byte)( cnt + 67 ) }));
		x[cnt] = z;
		Unused.Add(z, 1);
		Used.Add(z, 1);
	}


	string[] aDrives = Environment.GetLogicalDrives();


	for (cnt = 0; cnt != aDrives.Length; cnt++ ) {

		//


		String sDriveRoot =  aDrives[cnt];
		String aRealDriveRootPath =  GetRealPath( sDriveRoot  );
		int iDriveTypeResult = (int)GetDriveType(sDriveRoot);

		// http://www.entisoft.com/ESTools/WindowsAPI_DRIVEConstantToString.HTML
		/*
		    from WinBase.h:


		   #define DRIVE_UNKNOWN     0
		   #define DRIVE_NO_ROOT_DIR 1
		   #define DRIVE_REMOVABLE   2
		   #define DRIVE_FIXED       3
		   #define DRIVE_REMOTE      4
		   #define DRIVE_CDROM       5
		   #define DRIVE_RAMDISK     6
		 */
		// Only interested in DRIVE_FIXED   drives.

		// Another option is to utilize WMI  like:
		/*
		     ManagementClass manager = new ManagementClass("Win32_LogicalDisk");
		     ManagementObjectCollection drives = manager.GetInstances();
		     foreach( ManagementObject drive in drives )
		     {
		                Console.WriteLine ("{0}  is a {1}", drive["Caption"] ,  drive["Description"] );

		     }

		 */
		// http://www.artima.com/forums/flat.jsp?forum=76&thread=3997

		if (3 == iDriveTypeResult  ) {
			// Do not return   trivial information .
			if (0 != String.Compare(sDriveRoot, aRealDriveRootPath, true )  ) {
				if (DEBUG) {
					Console.WriteLine("GetDriveType({0}) =  {1}",   sDriveRoot, iDriveTypeResult);
					Console.WriteLine("GetRealPath({0}) = {1}", sDriveRoot,  aRealDriveRootPath );
				}
			}
		}

		if (  Unused.Contains( aDrives[cnt]))
			Unused[aDrives[cnt]] =  0;

		if (  Used.Contains( aDrives[cnt])) {
			Used[aDrives[cnt]] =  aRealDriveRootPath;
			_MappedDriveLettersArrayList.Add(aDrives[cnt]);
		}

	}

	for (cnt = 0; cnt !=  x.Length; cnt++ ) {

		if ( Unused[(x[cnt])].ToString() ==  "1" )
			_UnusedDriveLettersArrayList.Add(x[cnt]);

	}

	_MappedDriveLetters = String.Join(";", (string [] )_MappedDriveLettersArrayList.ToArray( typeof(string)));
	_UnusedDriveLetters = String.Join(";", (string [] )_UnusedDriveLettersArrayList.ToArray( typeof(string)));
	return true;
}

// Sample Code for second signature:
// http://www.pinvoke.net/default.aspx/kernel32.QueryDosDevice


private static string GetRealPath(string path)

{

	string realPath;

	StringBuilder pathInformation = new StringBuilder(250);

	// Get the drive letter of the
	string driveLetter = Path.GetPathRoot(path).Replace("\\", "");

	QueryDosDevice(driveLetter, pathInformation, 250);

	if (DEBUG)
		Console.WriteLine(pathInformation.ToString());

	// If drive is substed, the result will be in the format of "\??\C:\RealPath\".
	if (pathInformation.ToString().Contains("\\??\\")) {
		// Strip the \??\ prefix.
		string realRoot = pathInformation.ToString().Remove(0, 4);
		//Combine the paths.
		realPath = Path.Combine(realRoot, path.Replace(Path.GetPathRoot(path), ""));
	}     else{
		if (pathInformation.ToString().Contains("\\Device\\LanmanRedirector\\")) {
			string realRoot = pathInformation.ToString().Remove(0, 26);
			realPath = realRoot;
		}else
			realPath = path;
	}

	return realPath;

}

public int DosDriveCount()
{
	return _UnusedDriveLettersArrayList.Count;
}

public String DosDriveRealPath(string sDosDriveLetterAlias )
{
	return Used [ sDosDriveLetterAlias].ToString();
}




public String   ReportMappedDosDrives( String sCommandLine)
{


	ArrayList _Report = new ArrayList(24);
	String sDosDriveLetters = this.MappedDriveLetters;


	if (DEBUG )
		Console.WriteLine(
			String.Format("Mapped DOS Drive Letters={0}\n", sDosDriveLetters ));

	if (DEBUG ) {
		string[] items = sDosDriveLetters.Split(new char[] { ';' });
		for (int cnt = 0; cnt != items.Length; cnt++ ) {
			String sDrive = items[cnt];
			String sRealPath = this.DosDriveRealPath(sDrive );
			if (String.Compare(sRealPath, sDrive, true)  != 0 )
				_Report.Add(  String.Format("{0} is subst for {1}\n", sDrive, sRealPath ));
		}

	}
	if (DEBUG)
		Console.WriteLine("Number of Free DOS Drive Letters={0}\n", this.DosDriveCount());


	if (DEBUG)
		Console.WriteLine("Parsing Command \"{0}\"\n", sCommandLine);


	string sPatternString = @"(?<driveletter>[" +
				String.Join("", sDosDriveLetters.Split(";".ToCharArray())).Replace(":\\", "") +
				"]:\\\\)";
	if (DEBUG)
		Console.WriteLine("Parsing Pattern\"{0}\"\n", sPatternString );

	string res =  String.Empty;
	Regex r = new Regex( sPatternString,
			     RegexOptions.ExplicitCapture |
			     RegexOptions.IgnoreCase );
	MatchCollection m = r.Matches(  sCommandLine);
	if ( m != null ) {
		for ( int i = 0; i < m.Count; i++ ) {
			string sDrive = m[i].Groups["driveletter"].Value.ToString();
			string sRealPath = this.DosDriveRealPath(sDrive);
			// Only report 'subst' drives.
			if (String.Compare(sRealPath, sDrive, true)  != 0 ) {
				res = String.Format("{0} = \"{1}\"", sDrive,  sRealPath );
				_Report.Add(res);
				if (DEBUG)
					Console.WriteLine(res);
			}
		}

	}

	return String.Join("\n",
			   (string [] )_Report.ToArray( typeof(string)));

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
// http://www.koders.com/csharp/fid555C2348DB4C41916054D8A77ECA4D1C1847A812.aspx
// Environment.GetFolderPath(Environment.SpecialFolder.Programs),
// http://www.koders.com/csharp/fid555C2348DB4C41916054D8A77ECA4D1C1847A812.aspx



// DEBUG build should produce a Console APP  not sending any mail.
// RELEASE Build  should produce Windows App capable of sending the mail


#endregion
// See WIKI on Custom  UI for Wix.
//http://www.wixwiki.com/index.php?title=WixUI_Custom
