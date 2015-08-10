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

#region DOS Drive Discovery

public class DosDriveInventory
{
    private ArrayList _MappedDriveLettersArrayList = new ArrayList(24);
    private ArrayList _UnusedDriveLettersArrayList = new ArrayList(24);
    private string _MappedDriveLetters = "";
    private string _UnusedDriveLetters = "";
    static bool DEBUG = false;

    public string UnusedDriveLetters
    {
        get { return _UnusedDriveLetters; }
    }
    public string MappedDriveLetters
    {
        get { return _MappedDriveLetters; }
    }

    [DllImport("kernel32.dll")]
    public static extern uint QueryDosDevice(string lpDeviceName, StringBuilder lpTargetPath, int ucchMax);

    [DllImport("kernel32.dll")]
    public static extern long GetDriveType(string driveLetter);

    private string FmyProperty;

    private Hashtable Unused = new Hashtable();
    private Hashtable Used = new Hashtable();

    private Encoding ascii = Encoding.ASCII;
    private String[] x = new String[24];

    public string MyProperty
    {
        get { return FmyProperty; }
        set { FmyProperty = value; }
    }


    public static void Main()
    {
        DEBUG = (System.Environment.GetEnvironmentVariable("DEBUG") == null) ? false : true;
        DosDriveInventory x = new DosDriveInventory();
        x.Execute();
        string SampleCommand = @"""C:\Program Files\Wise for Windows Installer\wfwi.exe"" /c N:\foobar""X:\src\layouts\msi\MergeModules\mf\mf_lang\x64\retail\es\MF_LANG.wsm"" /o ""x64\retail\es\MF_LANG.msm"" /s /v /l ""x64\retail\es\MF_LANG_msm.log""";
        Console.WriteLine(x.ReportMappedDosDrives(SampleCommand));
    }
    public bool Execute()
    {
        byte cnt;
        // Internal Drive letter  hash table .
        for (cnt = 0; cnt != x.Length; cnt++)
        {
            String z = String.Format("{0}:\\", ascii.GetString(new byte[] { (byte)(cnt + 67) }));
            x[cnt] = z;
            Unused.Add(z, 1);
            Used.Add(z, 1);
        }
        string[] aDrives = Environment.GetLogicalDrives();

        for (cnt = 0; cnt != aDrives.Length; cnt++)
        {
            String sDriveRoot = aDrives[cnt];
            String aRealDriveRootPath = GetRealPath(sDriveRoot);
            int iDriveTypeResult = (int)GetDriveType(sDriveRoot);
            /*
               // http://www.entisoft.com/ESTools/WindowsAPI_DRIVEConstantToString.HTML
               // from WinBase.h:
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

            if (3 == iDriveTypeResult)
            {
                // Do not return   trivial information .
                if (0 != String.Compare(sDriveRoot, aRealDriveRootPath, true))
                {
                    if (DEBUG)
                    {
                        Console.WriteLine("GetDriveType({0}) =  {1}", sDriveRoot, iDriveTypeResult);
                        Console.WriteLine("GetRealPath({0}) = {1}", sDriveRoot, aRealDriveRootPath);
                    }
                }
            }

            if (Unused.Contains(aDrives[cnt]))
                Unused[aDrives[cnt]] = 0;

            if (Used.Contains(aDrives[cnt]))
            {
                Used[aDrives[cnt]] = aRealDriveRootPath;
                _MappedDriveLettersArrayList.Add(aDrives[cnt]);
            }
        }

        for (cnt = 0; cnt != x.Length; cnt++)
        {
            if (Unused[(x[cnt])].ToString() == "1")
                _UnusedDriveLettersArrayList.Add(x[cnt]);
        }
        _MappedDriveLetters = String.Join(";", (string[])_MappedDriveLettersArrayList.ToArray(typeof(string)));
        _UnusedDriveLetters = String.Join(";", (string[])_UnusedDriveLettersArrayList.ToArray(typeof(string)));
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
        if (pathInformation.ToString().Contains("\\??\\"))
        {
            // Strip the \??\ prefix.
            string realRoot = pathInformation.ToString().Remove(0, 4);
            //Combine the paths.
            realPath = Path.Combine(realRoot, path.Replace(Path.GetPathRoot(path), ""));
        }
        else
        {
            if (pathInformation.ToString().Contains("\\Device\\LanmanRedirector\\"))
            {
                string realRoot = pathInformation.ToString().Remove(0, 26);
                realPath = realRoot;
            }
            else
                realPath = path;
        }
        return realPath;
    }

    public int DosDriveCount()
    {
        return _UnusedDriveLettersArrayList.Count;
    }

    public String DosDriveRealPath(string sDosDriveLetterAlias)
    {
        return Used[sDosDriveLetterAlias].ToString();
    }

    public String ReportMappedDosDrives(String sCommandLine)
    {
        ArrayList _Report = new ArrayList(24);
        String sDosDriveLetters = this.MappedDriveLetters;
        if (DEBUG)
            Console.WriteLine(
                    String.Format("Mapped DOS Drive Letters={0}\n", sDosDriveLetters));
        if (DEBUG)
        {
            string[] items = sDosDriveLetters.Split(new char[] { ';' });
            for (int cnt = 0; cnt != items.Length; cnt++)
            {
                String sDrive = items[cnt];
                String sRealPath = this.DosDriveRealPath(sDrive);
                if (String.Compare(sRealPath, sDrive, true) != 0)
                    _Report.Add(String.Format("{0} is subst for {1}\n", sDrive, sRealPath));
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
            Console.WriteLine("Parsing Pattern\"{0}\"\n", sPatternString);
        string res = String.Empty;
        Regex r = new Regex(sPatternString,
                            RegexOptions.ExplicitCapture |
                            RegexOptions.IgnoreCase);
        MatchCollection m = r.Matches(sCommandLine);
        if (m != null)
        {
            for (int i = 0; i < m.Count; i++)
            {
                string sDrive = m[i].Groups["driveletter"].Value.ToString();
                string sRealPath = this.DosDriveRealPath(sDrive);
                // Only report 'subst' drives.
                if (String.Compare(sRealPath, sDrive, true) != 0)
                {
                    res = String.Format("{0} = \"{1}\"", sDrive, sRealPath);
                    _Report.Add(res);
                    if (DEBUG)
                        Console.WriteLine(res);
                }
            }
        }
        return String.Join("\n",
                           (string[])_Report.ToArray(typeof(string)));
    }
}
#endregion
