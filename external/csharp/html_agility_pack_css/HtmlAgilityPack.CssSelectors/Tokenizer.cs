using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HapCss {
	public class Tokenizer {
		public static IEnumerable<Token> GetTokens(string cssFilter) {
			var reader = new System.IO.StringReader(cssFilter);
			while (true) {
				int v = reader.Read();

				if (v < 0)
					yield break;

				char c = (char)v;

				// TODO: ~
				if (c == '>') {
					yield return new Token(">");
					continue;
				}
                // too early 
				if (c == ' ' || c == '\t')
					continue;

				string word = c + ReadWord(reader);
				yield return new Token(word);
			}
		}
		private static string ReadConditionToken(System.IO.StringReader reader) {
			StringBuilder sb = new StringBuilder();
			while (true) {
				int v = reader.Read();

				if (v < 0)
					break;

				char c = (char)v;

				if (c == '[' ){
					// TODO: throw an excepion nested conditionas do  not appear to be supported by spec
					break;
				}
				
				if (c == ']') {
						break;
				}

				sb.Append(c);
			}
		return sb.ToString();
		}

		private static string ReadWord(System.IO.StringReader reader) {
			StringBuilder sb = new StringBuilder();
			while (true) {
				int v = reader.Read();

				if (v < 0)
					break;

				char c = (char)v;

				if (c == '[' ){
					// can we put back ? 
					sb.Append('[');
					sb.Append(ReadConditionToken(reader));
					sb.Append(']');
					// yield 
						return  sb.ToString();
					// too difficult to reset the position i guess.
				}
				
				if (c == ' ' || c == '\t')
					break;

				sb.Append(c);
			}
			return sb.ToString();

		}
	}
}
