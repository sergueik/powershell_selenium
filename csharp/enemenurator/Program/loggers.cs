using System;
using System.Diagnostics;
using System.Collections.Specialized;
using System.Net;
using System.Text;

#region NT EventLog Logger

public class NTEventLogLogger
{
    private static string ExecutingProcessName = System.Reflection.Assembly.GetExecutingAssembly().ManifestModule.ToString();
    private string MySource = ExecutingProcessName;
    private int myApplicationEventId = 1480;
    private EventLogEntryType myEventLogEntryType = EventLogEntryType.Error;
    static bool DEBUG = false;
    public static bool Debug { get { return DEBUG; } set { DEBUG = value; } }
    public NTEventLogLogger()
    {
        // Create the source, if it does not already exist.
        if (!EventLog.SourceExists(MySource))
        {
            EventLog.CreateEventSource(MySource, "Application");
            if (DEBUG)
                Console.WriteLine("CreatingEventSource");
        }
        // Create an EventLog instance and assign its source.
        EventLog myLog = new EventLog();
        myLog.Source = MySource;
    }

    public void WriteToNTEventLog(string myMessage)
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

class ConsoleLogger
{
    public void handler(object source, ToolSpecificEventargs arg)
    {
        Console.WriteLine(String.Format("Event received by an X object\n{0}\n{1}\n{2}\n{3}\n", arg.processID, arg.CommandLine, arg.DialogText, arg.WindowTitle));
    }
}

#endregion

#region SMS/MailLogger
class FormPoster
{
    static bool DEBUG = false;
    public static bool Debug { get { return DEBUG; } set { DEBUG = value; } }
    WebClient myWebClient;
    string uriString = @"http://ftlplanb02/planb/result.pl";

    public FormPoster()
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

#if DEBUG
        // Maintain VBLMonitor and VBLManager
        Console.WriteLine("I see you.");
        //        if (DEBUG ) {
        Console.WriteLine("\nUploading to {0} ...", uriString);
        Console.WriteLine("\nComputer {0}", BuildMachine);
        Console.WriteLine("\nApplication {0}", arg.CommandLine);
        Console.WriteLine("\nWindow Title {0}", arg.WindowTitle);
        Console.WriteLine("\nDialog Text {0}", arg.DialogText);
        Console.WriteLine("\nMore Info: {0}", arg.MoreData);

        //         }

        System.Diagnostics.Debug.Assert(uriString != null);
#else
    byte[] responseArray = null;
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
