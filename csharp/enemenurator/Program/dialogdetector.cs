using System;
using System.Diagnostics;
using System.ComponentModel;
using System.Text.RegularExpressions;

#region Top Worker class

public class DialogDetector
{
    private ConsoleLogger MyConsoleLogger;
    private NTEventLogLogger MyNTEventLogLogger;
    private ToolSpecificEvent myDiscovery;
    private FormPoster MyFormPoster;
    private ConfigRead configuration_from_xml;
    private ProcessCommandLine process_command_line;

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
        MyFormPoster = new FormPoster();
        MyConsoleLogger = new ConsoleLogger();
        MyNTEventLogLogger = new NTEventLogLogger();
        myDiscovery = new ToolSpecificEvent();

        myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyConsoleLogger.handler);
        myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyNTEventLogLogger.handler);
        myDiscovery.ActionEvent += new ToolSpecificEventHandler(MyFormPoster.handler);
        configuration_from_xml = new ConfigRead();
        configuration_from_xml.LoadConfiguration("Configuration/ProcessDetection/Process", "ProcessName");
        string process_detector_expression = configuration_from_xml.DetectorExpression;
        Regex process_detector_regex = new Regex(process_detector_expression, RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);

        foreach (Process myProcess in myProcesses)
        {
            string res = String.Empty;
            string sProbe = myProcess.ProcessName;
            //  myProcess.StartInfo.FileName - not accessible
            if (Debug) Console.WriteLine("Process scan: {0}", process_detector_expression); MatchCollection m = process_detector_regex.Matches(sProbe);
            if (sProbe != null && m.Count != 0)
            {
                try
                {
                    DialogDetected = true;
                    process_command_line = new ProcessCommandLine(myProcess.Id.ToString());
                    if (Debug) Console.WriteLine("{0}{1}", myProcess.Id.ToString(), process_command_line.CommandLine); 
                    CommandLine = process_command_line.CommandLine;
                    // CommandLine = myProcess.ProcessName;
                    Console.WriteLine("--> {0} {1} {2} {3}", sProbe, myProcess.ProcessName, myProcess.Id, DateTime.Now - myProcess.StartTime);
                }
                catch (Win32Exception e) { 
                     System.Diagnostics.Trace.Assert(e != null); 
                }
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
