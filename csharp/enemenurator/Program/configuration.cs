using System;
using System.IO;
using System.Diagnostics;
using System.Windows.Forms;
using System.Collections;
using System.Reflection;
using System.Xml;
using System.Xml.XPath;

#region Configuration Processor

public class ConfigRead
{
    private static string _ConfigFileName = "config.xml";
    public static string ConfigFileName { get { return _ConfigFileName; } set { _ConfigFileName = value; } }
    public static bool Debug { get { return DEBUG; } set { DEBUG = value; } }
    static bool DEBUG = false;
    private ArrayList _PatternArrayList;
    private string sDetectorExpression;
    public string DetectorExpression { get { return sDetectorExpression; } }

    public void LoadConfiguration(string Section, string Column)
    {

        _PatternArrayList = new ArrayList();
        XmlDocument xmlDoc = new XmlDocument();
        xmlDoc.PreserveWhitespace = true;
        Assembly CurrentlyExecutingAssembly = Assembly.GetExecutingAssembly();
        FileInfo CurrentlyExecutingAssemblyFileInfo = new FileInfo(CurrentlyExecutingAssembly.Location);
        string ConfigFilePath = CurrentlyExecutingAssemblyFileInfo.DirectoryName;
        try
        {
            xmlDoc.Load(ConfigFilePath + @"\" + ConfigFileName);
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
            //  Environment.Exit(1);
            Console.WriteLine("Loading embedded resource");
            // While Loading - note : embedded resource Logical Name is overriden at the project level.
            xmlDoc.Load(CurrentlyExecutingAssembly.GetManifestResourceStream(ConfigFileName));
        }
        // see http://forums.asp.net/p/1226183/2209639.aspx
        if (DEBUG)
            Console.WriteLine("Loading: Section \"{0}\" Column \"{1}\"", Section, Column);

        XmlNodeList nodes = xmlDoc.SelectNodes(Section);
        foreach (XmlNode node in nodes)
        {
            XmlNode DialogTextNode = node.SelectSingleNode(Column);
            string sInnerText = DialogTextNode.InnerText;
            if (!String.IsNullOrEmpty(sInnerText))
            {
                _PatternArrayList.Add(sInnerText);
                if (DEBUG)
                    Console.WriteLine("Found \"{0}\"", sInnerText);
            }
        }
        if (0 == _PatternArrayList.Count)
        {
            if (Debug)
                Console.WriteLine("Invalid Configuration:\nReview Section \"{0}\" Column \"{1}\"", Section, Column);
            MessageBox.Show(
                String.Format("Invalid Configuration file:\nReview \"{0}/{1}\"", Section, Column),
                CurrentlyExecutingAssembly.GetName().ToString(),
                MessageBoxButtons.OK,
                System.Windows.Forms.MessageBoxIcon.Exclamation);
            Environment.Exit(1);
        }
        try
        {
            sDetectorExpression = String.Join("|", (string[])_PatternArrayList.ToArray(typeof(string)));
        }
        catch (Exception e)
        {
            Console.WriteLine("Internal error processing Configuration");
            System.Diagnostics.Debug.Assert(e != null);
            Environment.Exit(1);
        }
        if (DEBUG)
            Console.WriteLine(sDetectorExpression);
    }
}
#endregion




#region Configuration XPATH Processor

public class XMLDataExtractor
{
    private bool DEBUG = false;
    public bool Debug { get { return DEBUG; } set { DEBUG = value; } }
    // http://support.microsoft.com/kb/308333

    private XPathNavigator nav;
    private XPathDocument docNav;
    private XPathNodeIterator NodeIter;
    private XPathNodeIterator NodeResult;

    public XMLDataExtractor(string sFile)
    {
        try
        {
            docNav = new XPathDocument(sFile);
        }
        catch (Exception e)
        {
            // don't do anything.
            Trace.Assert(e != null); // keep the compiler happy
        }

        if (docNav != null)
            nav = docNav.CreateNavigator();
    }

    public String[] ReadAllNodes(String sNodePath, String sFieldPath)
    {
        NodeIter = nav.Select(sNodePath);
        ArrayList _DATA = new ArrayList(1024);

        // Iterate through the results showing the element value.

        while (NodeIter.MoveNext())
        {
            XPathNavigator here = NodeIter.Current;

            if (DEBUG)
            {
                try
                {
                    Type ResultType = here.GetType();
                    Console.WriteLine("Result type: {0}", ResultType);
                    foreach (PropertyInfo oProperty in ResultType.GetProperties())
                    {
                        string sProperty = oProperty.Name.ToString();
                        Console.WriteLine("{0} = {1}",
                                  sProperty,
                                  ResultType.GetProperty(sProperty).GetValue(here, new Object[] { })

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
                }
                catch (Exception e)
                {
                    // Fallback to system formatting
                    Console.WriteLine("Result:\n{0}", here.ToString());
                    Trace.Assert(e != null); // keep the compiler happy
                }
            } // DEBUG

            // collect the caller requested data
            NodeResult = null;

            try { NodeResult = here.Select(sFieldPath); }
            catch (Exception e)
            {
                // Fallback to system formatting
                Console.WriteLine(e.ToString());
                throw /* ??? */;
            }

            if (NodeResult != null)
            {
                while (NodeResult.MoveNext())
                    _DATA.Add(NodeResult.Current.Value);
            }
        }
        ;
        String[] res = (String[])_DATA.ToArray(typeof(string));
        if (DEBUG)
            Console.WriteLine(String.Join(";", res));
        return res;
    }

    public void ReadSingleNode(String sNodePath)
    {
        // http://msdn2.microsoft.com/en-us/library/system.xml.xmlnode.selectsinglenode(VS.71).aspx
        // Select the node and place the results in an iterator.
        NodeIter = nav.Select(sNodePath);
        // Iterate through the results showing the element value.
        while (NodeIter.MoveNext())
            Console.WriteLine("Book Title: {0}", NodeIter.Current.Value);
    }
}
#endregion



