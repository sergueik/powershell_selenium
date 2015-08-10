using System;
using System.Collections.Generic;
using System.Text;

using System.Text.RegularExpressions;
using System.Management;
using System.ComponentModel;
using System.Diagnostics;
/// http://www.c-sharpcorner.com/UploadFile/scottlysle/FindListProcessesCS09102007024714AM/FindListProcessesCS.aspx

 

namespace ApplicationCheck

{

   public class ProcessTreeScanner {

   private static bool _NavigationStatus; 
   public static bool NavigationStatus {  get { return _NavigationStatus; } set { _NavigationStatus = value; }}

   private static bool _DiscoveryStatus; 
   public static bool DiscoveryStatus {  get { return _DiscoveryStatus; } set { _DiscoveryStatus = value; }}

   private static string _Pattern;
    
   public static string Pattern {  get { return _Pattern; } set { _Pattern = value; }}

   public static void Main (string[] args){
   
   NavigationStatus  = true;
   DiscoveryStatus  = false;

   string PID = args[0];
    while  (NavigationStatus) {
    PID = FindProcessById(PID);
    Console.WriteLine (PID);
    if (DiscoveryStatus) {Console.WriteLine ("discovered");
       return;}

    }

   }
 
    public static bool ListProcessByName(string processName) {
        ManagementClass MgmtClass = new ManagementClass("Win32_Process");
        NavigationStatus = false;
    
        foreach (ManagementObject mo in MgmtClass.GetInstances()) {
    
            if (mo["Name"].ToString().ToLower() == processName.ToLower()) {
                NavigationStatus = true ;
            }
        }
        return NavigationStatus ;
    }


/// <summary>
/// 
/// 
/// </summary>
/// <param name="processId"></param>
/// <returns>parentprocessid</returns>

    public static string FindProcessById(string processId) {


        StringBuilder sb = new StringBuilder();
        ManagementClass MgmtClass = new ManagementClass("Win32_Process");
        NavigationStatus = false;
        foreach (ManagementObject mo in MgmtClass.GetInstances()) {
            if (mo["ProcessId"].ToString() == processId) {
                sb.Append(mo["ParentProcessId"].ToString());
                        NavigationStatus = true;
                        // -- need to double
                        string sPATH = @"SKOUZMINE1-argon-tools.cmd"; 
                        string aProcessChoiceRegExp = @"(?<known>10594|3850|525|3740|" + sPATH + ")";
                        string s = mo["CommandLine"].ToString() ;
                        Console.WriteLine (s ) ;

   MatchCollection myMatchCollection =
      Regex.Matches(s, aProcessChoiceRegExp);

    foreach (Match myMatch in myMatchCollection)
    {
      Console.WriteLine("=> " + myMatch.Groups["known"]);

      // use a foreach loop to iterate over the Group objects in
      // myMatch.Group
      foreach (Group myGroup in myMatch.Groups)
      {

        // use a foreach loop to iterate over the Capture objects in
        // myGroup.Captures
        foreach (Capture myCapture in myGroup.Captures)
        {
          Console.WriteLine("myCapture.Value = " + myCapture.Value);
        }

      }

    }
                        if (s.Contains(@"10594")){
                        DiscoveryStatus = true;}
            }
        }

        return sb.ToString();

    }

}

public class PlanBClientList {

    public PlanBClientList (){}

}


}


