using System;
using System.Diagnostics;
using System.ComponentModel;
using System.Text.RegularExpressions;

#region Top Worker class

public class DialogDetector
{
    static public bool DialogDetected = false;
    static private String CommandLine = String.Empty;
    static bool DEBUG = false;
    public static bool Debug
    {
        get { return DEBUG; }
        set { DEBUG = value; }
    }

    public void Perform()
    {
        Process[] myProcesses;
        myProcesses = Process.GetProcesses();
        FormPoster MyFormPoster = new FormPoster();
        ConsoleLogger MyConsoleLogger = new ConsoleLogger();
        NTEventLogLogger MyNTEventLogLogger = new NTEventLogLogger();
        ToolSpecificEvent myDiscovery = new ToolSpecificEvent();

        myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyConsoleLogger.handler);
        myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyNTEventLogLogger.handler);
        myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyFormPoster.handler);
        ConfigRead x = new ConfigRead();
        x.LoadConfiguration("Configuration/ProcessDetection/Process", "ProcessName");
        string s = x.DetectorExpression;
        Regex r = new Regex(s, RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);

        foreach (Process myProcess in myProcesses)
        {
            string res = String.Empty;
            string sProbe = myProcess.ProcessName;
            //  myProcess.StartInfo.FileName - not accessible
            if (Debug) Console.WriteLine("Process scan: {0}", s); MatchCollection m = r.Matches(sProbe);
            if (sProbe != null && m.Count != 0)
            {
                try
                {
                    DialogDetected = true;
                    ProcessCommandLine z = new ProcessCommandLine(myProcess.Id.ToString());
                    if (Debug) Console.WriteLine("{0}{1}", myProcess.Id.ToString(), z.CommandLine); CommandLine = z.CommandLine;
                    // CommandLine = myProcess.ProcessName;
                    Console.WriteLine("--> {0} {1} {2} {3}", sProbe, myProcess.ProcessName, myProcess.Id, DateTime.Now - myProcess.StartTime);
                }
                catch (Win32Exception e) { System.Diagnostics.Trace.Assert(e != null); }
            }
        }
        CallBackPtr callBackPtr = new CallBackPtr(EnumReport.Report);
        if (DialogDetected)
        {
            EnumReport.evt = myDiscovery;
            EnumReport.CommandLine = CommandLine;
            EnumReport.EnumWindows(callBackPtr, 0);
        }
    }
}

#endregion
