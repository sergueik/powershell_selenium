using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;


public class XsltExtension {
public static void Main(string[] args)
{
	if (args.Length == 2)
		Transform(args [0], args [1]);
	else
		PrintUsage();
}

public static void Transform(string sXmlPath, string sXslPath)
{
	try {
		XPathDocument myXPathDoc = new XPathDocument(sXmlPath);
		XslCompiledTransform myXslTrans = new XslCompiledTransform();
		myXslTrans.Load(sXslPath);
		XsltArgumentList xslArgs = new XsltArgumentList();
		Utils classPtr = new Utils();
		xslArgs.AddExtensionObject("urn:util", classPtr);
		XmlTextWriter myWriter = new XmlTextWriter("result.xml", null);
		myXslTrans.Transform(myXPathDoc, xslArgs, myWriter);
		myWriter.Close();
	} catch (Exception e) {

		Console.WriteLine("Exception: {0}", e.ToString());
	}
}

public static void PrintUsage()
{
	Console.WriteLine("Usage: XsltExtension.exe <xml path> <xsl path>");
}
}

public class Utils {

public string labelstep()
{
	return "0";
}

public string formvals(string strPostData)
{
	ArrayList _formvalArrayList = new ArrayList(32);
	string aFormLineRegExp = @"(?<line>[^&]*)(&|&amp)*";
	string s = strPostData.ToString();

	MatchCollection lineMatchCollection =
		Regex.Matches(s, aFormLineRegExp);

	foreach (Match myLineMatch in lineMatchCollection) {
		String sLine = myLineMatch.Groups ["line"].ToString();
		string aFormEntryRegExp = @"(?<name>.*)=(?<value>.*)";
		MatchCollection inputMatchCollection =
			Regex.Matches(sLine, aFormEntryRegExp);
		foreach (Match myMatch in inputMatchCollection) {
			_formvalArrayList.Add(
				String.Format("<input name =\"{0}\" value=\"{1}\"/>", myMatch.Groups ["name"], myMatch.Groups ["value"])

				);
		}
	}
	if (0 == _formvalArrayList.Count)
		return "";
	else
		return String.Join("", (string [])_formvalArrayList.ToArray(typeof(string)));
}
}
/*
   gmcs -r:System.dll -r:System.Xml.dll invoke.cs
 */
