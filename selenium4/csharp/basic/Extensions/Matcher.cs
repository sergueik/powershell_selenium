using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
/**
 * Copyright 2022 Serguei Kouzmine
 */

namespace Extensions {
	public static class Matcher {

		private static string result = null;
		private static Regex regex;
		private static MatchCollection matches;
	
		public static string FindMatch(this string text, string matchPattern, string matchTag)
		{
			result = null;
			regex = new Regex(matchPattern, RegexOptions.IgnoreCase | RegexOptions.Compiled);
			matches = regex.Matches(text);
			foreach (Match match in matches) {
				if (match.Length != 0) {
					foreach (Capture capture in match.Groups[matchTag].Captures) {
						if (result == null) {
							result = capture.ToString();
						}
					}
				}
			}
			return result;
		}
	
		public static string FindMatch(this string text, string matchPattern)
		{
			string generated_tag = matchPattern.FindMatch("(?:<(?<result>[^>]+)>)", "result");
			result = null;
			regex = new Regex(matchPattern, RegexOptions.IgnoreCase | RegexOptions.Compiled
				                  /* RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace | RegexOptions.Compiled */
			);
			matches = regex.Matches(text);
			foreach (Match match in matches) {
				if (match.Length != 0) {
					foreach (Capture capture in match.Groups[generated_tag].Captures) {
						if (result == null) {
							result = capture.ToString();
						}
					}
				}
			}
			return result;
		}
	}
}
