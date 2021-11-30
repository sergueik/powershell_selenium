using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
// 'System.Collections.Hashtable' does not contain a definition for 'Cast' and 
// no extension method 'Cast' accepting a first argument of type 'System.Collections.Hashtable' 
// could be found
using System.Text.RegularExpressions;

namespace Utils {
	public class UpdateDataHelper {
		private static string result = null;
		private static Regex regex;
		private static MatchCollection matches;
		private Dictionary<string,string> data = new Dictionary<string,string>();
		private string matchPattern = "(?<key>[^: ]+) *: *(?<value>.*)";
		private string text;
		public string Text { 
			get {
				text = null;
				foreach (string str in data.Keys)
					text += String.Format("{0}: {1}\r\n", str, data[str]);
				return text;
			}
			set { 
				text = value;
				// https://stackoverflow.com/questions/1508203/best-way-to-split-string-into-lines
				var lines = text.Split(new[]  { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
				foreach (string line in lines) {
					regex = new Regex(matchPattern, RegexOptions.IgnoreCase | RegexOptions.Compiled);
					matches = regex.Matches(line);
					foreach (Match match in matches) {
						if (match.Length != 0) {
							string resultKey = null;
							foreach (Capture capture in match.Groups["key"].Captures) {
								if (resultKey == null) {
									resultKey = capture.ToString();
								}
							}
							string resultValue = null;
							foreach (Capture capture in match.Groups["value"].Captures) {
								if (result == null) {
									resultValue = capture.ToString();
								}
							}
							data[resultKey] = resultValue;
						}
					}
				}
			} 
		}
	
		// https://stackoverflow.com/questions/6455822/convert-hashtable-to-dictionary-in-c-sharp/6455933
		private static Dictionary<K,V> HashtableToDictionary<K,V>(Hashtable table){
			return table.Cast<DictionaryEntry>().ToDictionary(kvp => (K)kvp.Key, kvp => (V)kvp.Value);
		}
    
		public void UpdateData(Hashtable newdata) {
			UpdateData(HashtableToDictionary<string,string>(newdata));
		}
		public void UpdateData(Dictionary<string,string> newdata) {
			foreach (string str in newdata.Keys)
				data[str] = newdata[str];
		}
	}
}
