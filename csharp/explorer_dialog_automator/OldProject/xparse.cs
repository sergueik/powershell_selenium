// Microsoft does not have a real SAX parser for .Net.
// However, they do have an XmlReader class
// that you can use to read xml a node at a time.
// Comparing XmlReader to SAX Reader
// http://msdn.microsoft.com/en-us/library/sbw89de7%28vs.71%29.aspx
// push model requires the content handlers to build very complex state machines
// the '.net' port of expat
// http://saxdotnet.sourceforge.net/home.html
// seems to not be pure csharp, possibly fake
// likely a waste of time


using System;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.IO;
using System.Xml;

public class Sample2
{
static Dictionary<string, string> formvals = new Dictionary<string, string>();
static ArrayList urls;
public static void Main()
{
	string fname = @"result.xml";

	xmlparse(fname);                //	OK

	return;

}


// pseudo SAX reader
public static void xmlparse(string fname)
{
	XmlReader reader = new XmlTextReader(fname);
	string line;

	urls    =       new ArrayList();
	int cnt  = 0;
	// http://msdn.microsoft.com/en-us/library/1z92b1d4.aspx
	// http://msdn.microsoft.com/en-us/library/system.xml.xmlreader.readsubtree.aspx
	while (reader.Read()) {
		if (reader.MoveToContent() == XmlNodeType.Element &&
		    reader.Name == "formvals") {

			XmlReader inner = reader.ReadSubtree();
			StringDictionary myCol = new StringDictionary();
			while (inner.Read()) {

				if (inner.MoveToContent() == XmlNodeType.Element &&
				    inner.Name == "input") {

					inner.MoveToFirstAttribute();
// to avoid dependency on the attribute order, key them by the attribute name
// amended with the unique count of the current input element.
					myCol.Add(String.Format("{0}-{1}", inner.Name, cnt.ToString()), inner.Value);
					inner.MoveToNextAttribute();
					myCol.Add(String.Format("{0}-{1}", inner.Name, cnt.ToString()), inner.Value);
					cnt++;
				}

				DictionaryEntry[] myArr = new DictionaryEntry[myCol.Count];
				myCol.CopyTo(myArr, 0);

				for (int i = 0; i < myArr.Length; i++) {


					try{

						string inputNameRegExp = @"name\-(?<input>\d+)";
						MatchCollection myMatchCollection =
							Regex.Matches(myArr[i].Key.ToString(), inputNameRegExp );

						foreach (Match myMatch in myMatchCollection) {

							string pos =  myMatch.Groups["input"].Value.ToString();
							// do not use StringDictionary for final formvals or you have your keyc converted to lower case.
							formvals.Add(myCol[String.Format("name-{0}", pos)], myCol[String.Format("value-{0}", pos)]);

						}
					} catch (Exception e) {
						Console.WriteLine(e.ToString());
					}

				}
				myCol.Clear();
			}
			foreach ( KeyValuePair<string, string> kvp in formvals )
				Console.WriteLine("formvals[ {0} ] = {1}", kvp.Key, kvp.Value);


			inner.Close();


		}
		if (reader.MoveToContent() == XmlNodeType.Element &&   reader.Name == "url") {
			line    =       reader.ReadString();
			urls.Add(line);
			Console.WriteLine(line);
		}
	}

}
}
