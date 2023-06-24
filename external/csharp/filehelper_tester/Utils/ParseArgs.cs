using System;
using System.Text;
using System.Linq;

using System.Text.RegularExpressions;
using System.Collections.Specialized;
using System.Collections.Generic;

namespace Utils {
	public class ParseArgs {
	
		private bool _DEBUG = false;
		public bool DEBUG {
			get { return _DEBUG; }
			set { _DEBUG = value; }
		}
		private StringDictionary _MACROS;
	
		private StringDictionary AllMacros {
			get { return _MACROS; }
		}
	
		private bool DefinedMacro(string name) {
			return _MACROS.ContainsKey(name);
		}
	
		public string GetMacro(string name) {
			return (DefinedMacro(name)) ?
				_MACROS[name] : String.Empty;
		}
	
		public string SetMacro(string name, string value) {
			_MACROS[name] = value;
			return _MACROS[name];
		}
	
		public ParseArgs(string commandLine) {
	
			_MACROS = new StringDictionary();
			String[] tokens = ParseArgs.splitTokens(commandLine);
			for (var cnt = 0; cnt != tokens.Length; cnt++) {
				var token = tokens[cnt];
				ParseSwithExpression(token);
			}
			return;
		}
	
		// origin: https://stackoverflow.com/questions/3366281/tokenizing-a-string-but-ignoring-delimiters-within-quotes
		// (converted from Java)
		// see also:
		// http://www.java2s.com/example/java-utility-method/string-split-by-quote/split-string-str-char-chrsplit-char-chrquote-fbd19.html
		// https://www.baeldung.com/java-split-string-commas
	
		public static String[] splitTokens(String line) {
			line += " "; // To detect last token when not quoted...
			var tokens = new List<String>();
			bool inQuote = false;
			var stringBuilder = new StringBuilder();
		
			for (int i = 0; i < line.Length; i++) {
				// NOTE: extension method		
				char c = line.ElementAt<Char>(i);
				if (c == '"' || c == ' ' && !inQuote) {
					if (c == '"')
						inQuote = !inQuote;
					if (!inQuote && stringBuilder.Length > 0) {
						tokens.Add(stringBuilder.ToString());
						stringBuilder.Remove(0, stringBuilder.Length);
					}
				} else
					stringBuilder.Append(c);
			}
			return tokens.ToArray();
		}
	
		private void ParseSwithExpression(string line) {
			// @"(/|\-{1,2})(?<macro>[a-z0-9_\-]+)([\=\:](?<value>[\:\/a-z0-9_\.\,\\\-\+\@\$\#\=\/?]+))*";
			const string expression = @"(/|\-{1,2})(?<macro>[a-z0-9_\-]+)([\=\:](?<value>[\:\/a-z0-9_\.\,\\\-\+\@\$\#\=\/? ]+))*";
			ParseSwithExpression(line, expression);
		}
	
		private void ParseSwithExpression(string line, string expression) {
	
			var regex = new Regex(expression, RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
			MatchCollection matchCollection = regex.Matches(line);
	
			if (matchCollection != null) {
				for (int i = 0; i < matchCollection.Count; i++) {
					string name = matchCollection[i].Groups["macro"].Value.ToString();
	
					string value = matchCollection[i].Groups["value"].Value;
					if (value == "")
						value = "true";
					SetMacro(name, value);
					if (DEBUG)
						Console.WriteLine("{0} = \"{1}\"", name, GetMacro(name));
				}
			}
			return;
		}
	
	}
}