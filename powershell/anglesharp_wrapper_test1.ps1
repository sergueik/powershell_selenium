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

# http://anglesharp.github.io/docs/Examples.html
# https://www.codeproject.com/Articles/609053/AngleSharp
# https://stackoverflow.com/questions/45396219/trying-to-parse-and-interact-with-content-from-a-web-page-using-powershell
# https://www.powershellgallery.com/packages/IonFar.SharePoint.PowerShell/0.2.1/Content/IonFar.SharePoint.PowerShell\AngleSharp.xml
# see also: http://hostciti.net/faq/c-sharp/parsing-s-c-anglesharp.html
# async-lean examples

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

# origin: http://anglesharp.github.io/docs/Basics.html#first-steps
add-type -TypeDefinition @'
using System;
using AngleSharp;

public class AngleSharpFirstStepClass {
	public static async void Main(){
		var config = Configuration.Default;
		var context = BrowsingContext.New(config);
		var source = "<h1>Some example source</h1><p>This is a paragraph element";
		var document = await context.OpenAsync(req => req.Content(source));
		Console.WriteLine("Serializing the (original) document:");
		Console.WriteLine(document.DocumentElement.OuterHtml);

		var p = document.CreateElement("p");
		p.TextContent = "This is another paragraph.";

		Console.WriteLine("Inserting another element in the body ...");
		document.Body.AppendChild(p);

		Console.WriteLine("Serializing the document again:");
		Console.WriteLine(document.DocumentElement.OuterHtml);
	}
}
'@  -ReferencedAssemblies "${shared_assemblies_path}\AngleSharp.dll","${shared_assemblies_path}\nunit.framework.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'

[AngleSharpFirstStepClass]::Main()
[String]$data = @'
<html lang=en>
<meta charset=utf-8>
<meta name=viewport content=""initial-scale=1, minimum-scale=1, width=device-width"">
  <head>
    <meta charset="utf-8"/>
    <title>Demo</title>
  </head>
  <body>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js">
</script>
    <script type="text/javascript">
$(document).ready(function() {
    $('.gen_checkbox').change(function() {
        if($(this).is(":checked")) {
            var returnVal = confirm("Checked " + $(this).attr("id"));
           $(this).attr("checked", returnVal);
        } else {
            alert("Cleared " + $(this).attr("id"));

        }
    });
});
</script>
    <div class="contentdiv_listdiv">
      <span class="span1">
        <img style="width: 23px; height: 23px" src="http://qa.uploads.clientuploads.schoolinsites.com/COMMON/FC8672C1-4407-43C6-98B9-43C71A47929C/fb529743-e6b2-41cb-a0ed-5140fbc7ec34.jpg"/>
      </span>
      <span class="span2">shyam Kumar</span>
      <span class="span2"/>
      <span class="span3">
        <input type="checkbox" class="gen_checkbox" title="shyam Kumar" accesskey="User" value="None" id="shyam" name="check"/>
        <label for="7a18efeb-427c-4eec-880d-13cbec2bec17">
          <span class="margtop-17"/>
        </label>
      </span>
    </div>
    <div class="contentdiv_listdiv">
      <span class="span1">
        <img style="width: 23px; height: 23px" src="http://qa.common.productfiles.schoolinsites.com/image.png"/>
      </span>
      <span class="span2">Mary Wilson</span>
      <span class="span2"/>
      <span class="span3">
        <input type="checkbox" class="gen_checkbox" title="Mary Wilson" accesskey="User" value="None" id="mary" name="check"/>
        <label for="a7f76cd7-b08f-4008-b701-3c55de9d3e17">
          <span class="margtop-17"/>
        </label>
      </span>
    </div>
  </body>
</html>
'@


$parser = new-object -typeName 'AngleSharp.Parser.Html.HtmlParser'
# TODO: add inline code with examples in the anglesharp.github.io recommended syntax

$document = $parser.Parse($data)

# IE-style document.All

$elements = $document.All | where-Object {$_.id -eq 'shyam'}

write-output $elements.OuterHtml

<#
[AngleSharp.Configuration]$config = [AngleSharp.Configuration]::Default
$context = new-object AngleSharp.BrowsingContext($config)
# new-object : A constructor was not found. Cannot find an appropriate constructor for type AngleSharp.BrowsingContext.
#>

$selector = 'div span.span3 input'
$cells = $document.QuerySelectorAll($selector)

$titles = $cells | where-Object {$_.id -eq "shyam"} | foreach-object { $_.title }

write-output $titles

# *= does not work
$img_src = $document.QuerySelectorAll('img[src*="http://qa.uploads"]') | foreach-object { $_.Attributes['src'].Value }

write-output ('img src: {0}' -f $img_src)

$labels_for = $document.QuerySelectorAll('label[for]') | foreach-object { $_.Attributes['for'] }

write-output $labels_for | format-list
