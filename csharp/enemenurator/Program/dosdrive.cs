using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections;
using System.Text;
using System.Text.RegularExpressions;

#region DOS Drive Discovery

public class DosDriveInventory
{
    private string _myProperty;
    private Hashtable Unused = new Hashtable();
    private Hashtable Used = new Hashtable();
    private Encoding ascii = Encoding.ASCII;
    // Internal Drive letter hash table .
    private String[] drive_letters = new String[24];

	private ArrayList _mappedDriveLettersArrayList = new ArrayList(24);
    private ArrayList _unusedDriveLettersArrayList = new ArrayList(24);
    private string _mappedDriveLetters = "";
    private string _unusedDriveLetters = "";
    static bool DEBUG = false;

    public string UnusedDriveLetters
    {
        get { return _unusedDriveLetters; }
    }
    public string MappedDriveLetters
    {
        get { return _mappedDriveLetters; }
    }

    [DllImport("kernel32.dll")]
    public static extern uint QueryDosDevice(string lpDeviceName, StringBuilder lpTargetPath, int ucchMax);

    [DllImport("kernel32.dll")]
    public static extern long GetDriveType(string driveLetter);

    public string MyProperty
    {
        get { return _myProperty; }
        set { _myProperty = value; }
    }

    public static void Main()
    {
        DEBUG = (System.Environment.GetEnvironmentVariable("DEBUG") == null) ? false : true;
        DosDriveInventory processor = new DosDriveInventory();
        processor.Execute();
        string SampleCommand = @"""C:\Program Files\Wise for Windows Installer\wfwi.exe"" /c N:\foobar""X:\src\layouts\msi\MergeModules\mf\mf_lang\x64\retail\es\MF_LANG.wsm"" /o ""x64\retail\es\MF_LANG.msm"" /s /v /l ""x64\retail\es\MF_LANG_msm.log""";
        Console.WriteLine(processor.ReportMappedDosDrives(SampleCommand));
    }
    public bool Execute()
    {
        byte cnt;
        
        for (cnt = 0; cnt != drive_letters.Length; cnt++)
        {
            String drive_letter = String.Format("{0}:\\", ascii.GetString(new byte[] { (byte)(cnt + 67) }));
            drive_letters[cnt] = drive_letter;
            Unused.Add(drive_letter, 1);
            Used.Add(drive_letter, 1);
        }
        string[] logical_drives = Environment.GetLogicalDrives();

        for (cnt = 0; cnt != logical_drives.Length; cnt++)
        {
            String sDriveRoot = logical_drives[cnt];
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

            if (Unused.Contains(logical_drives[cnt]))
                Unused[logical_drives[cnt]] = 0;

            if (Used.Contains(logical_drives[cnt]))
            {
                Used[logical_drives[cnt]] = aRealDriveRootPath;
                _mappedDriveLettersArrayList.Add(logical_drives[cnt]);
            }
        }

        for (cnt = 0; cnt != drive_letters.Length; cnt++)
        {
            if (Unused[(drive_letters[cnt])].ToString() == "1")
                _unusedDriveLettersArrayList.Add(drive_letters[cnt]);
        }
        _mappedDriveLetters = String.Join(";", (string[])_mappedDriveLettersArrayList.ToArray(typeof(string)));
        _unusedDriveLetters = String.Join(";", (string[])_unusedDriveLettersArrayList.ToArray(typeof(string)));
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
        return _unusedDriveLettersArrayList.Count;
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
