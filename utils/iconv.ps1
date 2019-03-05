# based on https://toster.ru/q/609714
# https://docs.microsoft.com/en-us/dotnet/api/system.text.encoding.codepage?view=netframework-4.0
param(
  [String]$in = 'text_1251.txt',
  [String]$out = 'text_utf8.txt'
)

Add-Type -TypeDefinition @"
using System.IO;
using System.Text;

namespace ansi2utf8{
    public class Convert {

    private string _inputFile;

    public string InputFile {
        get { return _inputFile; }
        set { _inputFile = value; }
    }
    private string _outputFile;
    public string OutputFile {
        get { return _outputFile; }
        set { _outputFile = value; }
    }

    public void convert(){
    // Cannot create an instance of the abstract class or interface 'System.Text.Encoding'
    // Encoding e = new Encoding(1251);
    Encoding _in = Encoding.GetEncoding("windows-1251");
    Encoding _out = Encoding.UTF8;
    // Encoding _out = Encoding.GetEncoding("windows-1251");
    // Encoding _in = Encoding.UTF8;
      var text = File.ReadAllText(_inputFile, _in);
      File.WriteAllText(_outputFile, text, _out);
    }
    }
}
"@ -ReferencedAssemblies 'System.Text.Encoding.dll', 'mscorlib.dll'

$iconv = New-Object ansi2utf8.Convert
$iconv.InputFile = resolve-path $in
$iconv.OutputFile = $out
$iconv.convert()