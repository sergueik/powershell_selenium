#Copyright (c) 2019 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

param(
  [switch]$debug
)

# https://stackoverflow.com/questions/45396219/trying-to-parse-and-interact-with-content-from-a-web-page-using-powershell
# http://anglesharp.github.io/docs/Examples.html
# see also: https://www.codeproject.com/Articles/609053/AngleSharp
# LYNC style http://hostciti.net/faq/c-sharp/parsing-s-c-anglesharp.html

[string]$shared_assemblies_path = 'C:\java\selenium\csharp\sharedassemblies'

function load_shared_assemblies {

  param(
    [string]$shared_assemblies_path = 'C:\java\selenium\csharp\sharedassemblies',
    [string[]]$shared_assemblies = @(
      'AngleSharp.dll', # using .Net 4.5 assembly downloaded from https://www.nuget.org/packages/AngleSharp/0.9.10
      'Newtonsoft.Json.dll',
      'nunit.core.dll',
      'nunit.core.interfaces.dll',
      'nunit.framework.dll'
      )
  )

  write-debug ('Loading "{0}" from ' -f ($shared_assemblies -join ',' ), $shared_assemblies_path)
  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    $shared_assembly_filename = $_
    if ( assembly_is_loaded -assembly_path ("${shared_assemblies_path}\\{0}" -f $shared_assembly_filename)) {
      write-debug ('Skipping from  assembly "{0}"' -f $shared_assembly_filename)
     } else {
      write-debug ('Loading assembly "{0}" ' -f $shared_assembly_filename)
      Unblock-File -Path $shared_assembly_filename;
      Add-Type -Path $shared_assembly_filename
    }
  }
  popd
}

load_shared_assemblies

# origin: http://anglesharp.github.io/docs/Examples.html#connecting-javascript-evaluation
# https://www.nuget.org/packages/AngleSharp.Scripting.JavaScript/
add-type -TypeDefinition @'

using System;
using AngleSharp;

public class AngleSimpleScriptingSample {

	public static async void Main(){
    // need to study the project https://github.com/AngleSharp/AngleSharp history: 
    // for release 0.9.10 the example no longer works:
    // 'AngleSharp.IConfiguration' does not contain a definition for 'WithJavaScript' and no extension method 'WithJavaScript' accepting a first argument of type 'AngleSharp.IConfiguration' could be found (are you missing a using directive
       var config = Configuration.Default.WithJs();
    // the AngleSharp.JS requireds .Net 4.6
    // with the Configuration.Default the Javascript will not be executed
    
    // var config = Configuration.Default;
		var context = BrowsingContext.New(config);
    var source = @"<!doctype html>
        <html>
        <head><title>Sample</title></head>
        <body>
        <script>
        document.title = 'Simple manipulation...';
        document.write('<span class=greeting>Hello World!</span>');
        </script>
        </body>";

    var document = await context.OpenAsync(req => req.Content(source));

    // observe modified HTML to be output
    Console.WriteLine(document.DocumentElement.OuterHtml);
	}
}
'@  -ReferencedAssemblies "${shared_assemblies_path}\AngleSharp.dll","${shared_assemblies_path}\nunit.framework.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'

[AngleSimpleScriptingSample]::Main()
