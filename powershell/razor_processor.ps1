# https://knutkj.wordpress.com/2012/04/29/how-to-render-a-razor-template-with-powershell/
# https://github.com/dzharii/swd-recorder
# This is a vanilla script to bootstrap code requird to invoke RazorEngine.
# it has some minor modifications compared to
# https://github.com/knutkj/misc/blob/master/PowerShell/Razor/Render-RazorTemplate.ps1
# it depends on System.Web.Razor.dll which is already in the GAC, but not loaded by defauls, or can be restored by nuget :


$assembly_name = 'System.Web.Razor'

# Load assembly from the GAC 
[void][Reflection.Assembly]::LoadWithPartialName($assembly_name)

# check if the System.Web.Razor is already loaded
$assembly_in_the_GAC =
[appdomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -match "^${assembly_name}" }


if ($assembly_in_the_GAC -eq $null) {
  [string[]]$shared_assemblies = @( 'System.Web.Razor.dll')

  [string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

  # SHARED_ASSEMBLIES_PATH environment overrides parameter, for Team City
  if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  }


  pushd $shared_assemblies_path


  popd

  # example of using nuget packages
  $nuget_base_dir = $PWD
  $razorSearchPath = Join-Path -Path $nuget_base_dir -ChildPath "packages\AspNetRazor.Core.*\lib\net40\${assembly_name}.dll"

  $assembly_nuget_package_path = Get-ChildItem -Path $razorSearchPath | Select-Object -First 1 -ExpandProperty FullName

  if ($assembly_nuget_package_path -ne $null) {
    Add-Type -Path $razorPath
  } else {
    throw "The System.Web.Razor assembly must be loaded."
  }
}



$template1 = "<ul>@foreach(var i in Model){<li>@i</li>}</ul>"
$template2 = "<ul>@Model.PageObject.Name</ul>"

$template3 = @"


@functions{

    string RubyHow(string how)
    {
        switch (how)
        {
            case "Id":              return "id";
            case "Name":            return "name";
            case "ClassName":       return "class";
            case "CssSelector":     return "css";
            case "LinkText":        return "text";
            case "PartialLinkText": return "text";
            case "XPath":           return "xpath";
            default:                return String.Format("!!! LOCATOR PARSE ERROR : '{0}' !!!", how);
        }
    }

    string RubyTagToAccessor(string tag, string type)
    {
        string result = string.Empty;

        tag = tag.ToLower();
        type = type.ToLower();

        Dictionary<string, string[]> AccessorsAndTags = new Dictionary<string, string[]>();
        AccessorsAndTags.Add("text_area",       new string[] { "textarea"   });
        AccessorsAndTags.Add("select_list",     new string[] { "select"     });
        AccessorsAndTags.Add("link",            new string[] { "a"          });
        AccessorsAndTags.Add("list_item",       new string[] { "li"         });
        AccessorsAndTags.Add("unordered_list",  new string[] { "ul"         });
        AccessorsAndTags.Add("ordered_list",    new string[] { "ol"         });
        AccessorsAndTags.Add("paragraph",       new string[] { "p"          });
        AccessorsAndTags.Add("cell",            new string[] { "td", "th"   });
        AccessorsAndTags.Add("image",           new string[] { "img"        });

        Dictionary<string, string[]> AccessorsAndTypes = new Dictionary<string, string[]>();
        AccessorsAndTypes.Add("area",         new string[] { "area"      });
        AccessorsAndTypes.Add("audio",        new string[] { "audio"     });
        AccessorsAndTypes.Add("button",       new string[] { "submit", "image", "button", "reset",});
        AccessorsAndTypes.Add("canvas",       new string[] { "canvas"    });
        AccessorsAndTypes.Add("checkbox",     new string[] { "checkbox"  });
        AccessorsAndTypes.Add("file_field",   new string[] { "file"      });
        AccessorsAndTypes.Add("hidden_field", new string[] { "hidden"    });
        AccessorsAndTypes.Add("radio_button", new string[] { "radio"     });
        AccessorsAndTypes.Add("text_field",   new string[] { "text", "password"});
        AccessorsAndTypes.Add("video",        new string[] { "video"     });

        if (!String.IsNullOrEmpty(type))
        {
            foreach (KeyValuePair<string, string[]> entry in AccessorsAndTypes)
            {
                if (Array.Exists(entry.Value, delegate(string item) { return item == type; }))
                {
                    result = entry.Key;
                    break;
                }
            }
        }

        if (String.IsNullOrEmpty(result))
        {
            foreach (KeyValuePair<string, string[]> entry in AccessorsAndTags)
            {
                if (Array.Exists(entry.Value, delegate(string item) { return item == tag; }))
                {
                    result = entry.Key;
                    break;
                }
            }
        }

        if (String.IsNullOrEmpty(result))
        {
            result = tag;
        }
        
        return result;
    }

    string QuoteLocator(string locator)
    {
        locator = locator.Replace("'", "\\'");
        return locator;
    }    


    string RubyWebElement(string name, string tag, string type, string how, string locator)
    {
        System.Text.StringBuilder result = new System.Text.StringBuilder();
        
        result.AppendFormat("{0}(", RubyTagToAccessor(tag, type));
        result.AppendFormat(":{0}, ", name);
        result.AppendFormat("{0}: '{1}')", RubyHow(how), QuoteLocator(locator));

        return result.ToString();
    }
}



@{

<text>@@Model.PageObject.Name = '@Model.PageObject.Name'</text>
<text>@@Model.PageObject.HtmlTag='@Model.PageObject.HtmlTag'</text> 
<text>@@Model.PageObject.Type='@Model.PageObject.Type'</text> 
<text>@@Model.PageObject.How='@Model.PageObject.How'</text>
<text>@@Model.PageObject.Locator='@Model.PageObject.Locator'</text>
<text>(@Model.PageObject.Name, @Model.PageObject.HtmlTag, @Model.PageObject.Type, @Model.How, @Model.PageObject.Locator)</text>
      
<text>@RubyWebElement(@Model.PageObject.Name, @Model.PageObject.HtmlTag, @Model.PageObject.Type, @Model.PageObject.How, @Model.PageObject.Locator);</text>
    
}


end
"@

[object]$Model1 = (0..3)

$Model2 = New-Object PSObject

$element = New-Object PSObject
$element | Add-Member Noteproperty 'Name' 'element_name'
$element | Add-Member Noteproperty 'Type' 'ordered_list'
$element | Add-Member Noteproperty 'How' 'CssSelector'
$element | Add-Member Noteproperty 'HtmlTag' 'element_html_tag'
$element | Add-Member Noteproperty 'Locator' 'CssSelector'

$Model2 | Add-Member Noteproperty 'PageObject' $element

$ModelType = "dynamic"
$TemplateClassName = ("t{0}" -f ([System.IO.Path]::GetRandomFileName() -replace "\.",""))
$TemplateBaseClassName = ("t{0}" -f ([System.IO.Path]::GetRandomFileName() -replace "\.",""))
$TemplateNamespace = "Kkj.Templates"

$templateBaseCode = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Microsoft.CSharp.RuntimeBinder;

namespace {2} {{

    public abstract class {1}
    {{
        protected {0} Model;
        private StringBuilder _sb = new StringBuilder();
        public abstract void Execute();
        public virtual void Write(object value)
        {{
            WriteLiteral(value);
        }}
        public virtual void WriteLiteral(object value)
        {{
            _sb.Append(value);
        }}
        public string Render ({0} model)
        {{
            Model = model;
            Execute();
            var res = _sb.ToString();
            _sb.Clear();
            return res;
        }}
    }}
}}
"@ -f $ModelType,$TemplateBaseClassName,$TemplateNamespace

#
# A Razor template.
#

$razor_code_language = New-Object -TypeName 'System.Web.Razor.CSharpRazorCodeLanguage'
$razor_engine_host = New-Object -TypeName 'System.Web.Razor.RazorEngineHost' -ArgumentList $razor_code_language -Property @{
  DefaultBaseClass = ("{0}.{1}" -f $TemplateNamespace,$TemplateBaseClassName);
  DefaultClassName = $TemplateClassName;
  DefaultNamespace = $TemplateNamespace;
}
$razor_template_engine = New-Object -TypeName System.Web.Razor.RazorTemplateEngine -ArgumentList $razor_engine_host

$stringReader = New-Object -TypeName 'System.IO.StringReader' -ArgumentList $Template3
$code = $razor_template_engine.GenerateCode($stringReader)

#
# Template compilation.
#
$stringWriter = New-Object -TypeName System.IO.StringWriter
$compiler = New-Object -TypeName Microsoft.CSharp.CSharpCodeProvider
$compilerResult = $compiler.GenerateCodeFromCompileUnit(
  $code.GeneratedCode,$stringWriter,$null
)
$templateCode =
$templateBaseCode + "`n" + $stringWriter.ToString()
Add-Type `
   -TypeDefinition $templateCode `
   -ReferencedAssemblies System.Core,Microsoft.CSharp

#
# Template execution.
#
$templateInstance = New-Object -TypeName ("{0}.{1}" -f $TemplateNamespace,$TemplateClassName)

$x = $templateInstance
Write-Output $x.ToString()
Write-Output ($templateInstance | Get-Member)
$Model2.PageObject | Get-Member
$templateInstance.Render($Model2)
