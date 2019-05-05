Add-Type -IgnoreWarnings -TypeDefinition @'
using System;
using System.Text;
using System.Text.RegularExpressions;
public class Test {
	public bool debug { get; set; }
	public string findMatches(string text, int pos){
		MatchCollection matches = Regex.Matches(text, @"([a-z]+)", RegexOptions.Singleline | RegexOptions.IgnoreCase);
		if (debug) {
			Console.Error.WriteLine(matches.Count);
			Console.Error.WriteLine(matches[pos].Groups.Count);
		}
		return pos > matches.Count ? null : matches[pos].Groups[1].ToString();
	}
}
'@
$o = new-object -TypeName 'Test'
$string =  'a b c d e f'
$pos = 4
write-output ('{0} => "{1}"' -f  $pos,  $o.findMatches($string, $pos))