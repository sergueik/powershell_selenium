using System;
using System.Management;

#region WMI Data processor

public class ProcessCommandLine
{
    static bool DEBUG = false;
    public static bool Debug { get { return DEBUG; } set { DEBUG = value; } }
    private String _CommandLine = String.Empty;
    public String CommandLine { get { return _CommandLine; } }
    public ProcessCommandLine(String PID) {
        ManagementClass mc = new ManagementClass(@"root/cimv2:Win32_Process");
        ManagementObjectCollection mobjects = mc.GetInstances();
        if (DEBUG) Console.WriteLine("{0}", PID); 
        foreach (ManagementObject mo in mobjects) {
            if (DEBUG)
                Console.WriteLine(mo["ProcessID"].ToString());
            if (PID == mo["ProcessID"].ToString())
                _CommandLine = mo["CommandLine"].ToString();
        }
    }
}
#endregion


