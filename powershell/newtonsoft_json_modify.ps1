#Copyright (c) 2022 Serguei Kouzmine
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

# based on: https://qna.habr.com/q/1228494
# see also https://toster.ru/q/658363
param(
  [switch]$debug
)

function load_shared_assemblies {

  param(
    [string]$shared_assemblies_path = 'C:\java\selenium\csharp\sharedassemblies',
    [string[]]$shared_assemblies = @(
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
      write-debug ('Loading assembly "{0}" ' -f $shared_assembly_filename)
      Unblock-File -Path $shared_assembly_filename;
      Add-Type -Path $shared_assembly_filename
  }
  popd
}

$shared_assemblies_path = 'C:\java\selenium\csharp\sharedassemblies'
load_shared_assemblies -shared_assemblies_path $shared_assemblies_path

add-type -TypeDefinition @'

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NUnit.Framework;

namespace WebTester {
  public class Tester {
    public String rawdata {
      get;
      set;
    }
    public Tester(String rawdata) {
      this.rawdata = rawdata;
    }

    public JObject addElement(string elementName = "friendslist" , string  newElementName = "CustomCommands") {

      // NOTE: cannot mix stringly typed and LINQ serialization type
      // JObject? obj = (JObject?) test[elementName];
      // 'Newtonsoft.Json.Linq.JObject' must be a non-nullable value type in order to use it as parameter 'T' in the generic type or method 'System.Nullable<T>'

      // JObject obj = (JObject) test[elementName];
      // Cannot apply indexing with [] to an expression of type 'WebTester.Test'

      // JObject obj = (JObject) test.friendslist;
      // Cannot convert type 'WebTester.Friendslist' to 'Newtonsoft.Json.Linq.JObject'

      var data = JObject.Parse(rawdata);
      JObject obj = (JObject)data[elementName];
      obj.Add(new JProperty(newElementName, new JObject()));
      data[elementName] = obj;
      return data;
    }

    public JObject addElement(string newElementData, string elementName = "friendslist" , string  newElementName = "CustomCommands" ) {
      //optional parameters must appear after all required parameters
      var data = JObject.Parse(rawdata);
      JObject obj = (JObject)data[elementName ];
      var element = JObject.Parse(newElementData);
      obj.Add(new JProperty(newElementName, element));
      data[elementName] = obj;
      return data;
    }
  }
}
'@  -ReferencedAssemblies "${shared_assemblies_path}\Newtonsoft.Json.dll","${shared_assemblies_path}\nunit.framework.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'
$data = @'
{
  "friendslist": {
    "friends": [{
      "steamid": "76561198031578776",
      "relationship": "friend",
      "friend_since": 1519194870
    }, {
      "steamid": "76561198040628535",
      "relationship": "friend",
      "friend_since": 1460743289
    }]
  }
}
'@

$o = new-object -typeName 'WebTester.Tester'($data);

$o.rawdata = $data;
$o2 = $o.addElement()
write-output $o2.ToString()
# NOTE: the next looks broken, badly
<#
# write-output (convertTo-Json -InputObject $o2)
[
    [
        [
            "{\r\n  \"steamid\": \"76561198031578776\",\r\n  \"relationship\": \"friend\",\r\n  \"friend_since\": 1519194870\r\n} {\r\n  \"steamid\": \"76561198040628535\",\r\n  \"relationship\": \"friend\",\r\n  \"friend_since\": 1460743289\r\n}"
        ],
        [
            ""
        ]
    ]
]

#>
$o.rawdata = $data;
try {
  $o3 = $o.addElement("{""name"":""value"", ""a"": [""b"",""c""]}")
} catch [Exception] { 
  # Exception calling "addElement" with "1" argument(s): "Object reference not set to an instance of an object."
  write-output $_.Exception.Message
}
# should put all interacting classes in one virtual type definition otherwise cannnot compile (below is an example):
# The type or namespace name 'Tester' does not exist in the namespace 'WebTester' (are you missing an assembly reference?)
#
<#

add-type -TypeDefinition @'
using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NUnit.Framework;
namespace WebTester {
  public class Tester2 {
    public String rawdata {
      get;
      set;
    }
    public String elementdata {
      get;
      set;
    }
    public Tester2(String rawdata,String elementdata ) {
      this.rawdata = rawdata;
      this.elementdata  = elementdata;
    }
    public JObject addElement2(){
    var o = new WebTester.Tester(rawdata);
    return o.addElement(elementdata);
    }
  }
}
'@  -ReferencedAssemblies "${shared_assemblies_path}\Newtonsoft.Json.dll","${shared_assemblies_path}\nunit.framework.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'

#>
<#
add-type -TypeDefinition @'
using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NUnit.Framework;

namespace WebTester {
  public class Tester1 {
    public String rawdata {
      get;
      set;
    }
    public Tester1(String rawdata) {
      this.rawdata = rawdata;
    }

    public JObject addElement(string elementName = "friendslist" , string  newElementName = "CustomCommands") {

      // NOTE: cannot mix stringly typed and LINQ serialization type
      // JObject? obj = (JObject?) test[elementName];
      // 'Newtonsoft.Json.Linq.JObject' must be a non-nullable value type in order to use it as parameter 'T' in the generic type or method 'System.Nullable<T>'

      // JObject obj = (JObject) test[elementName];
      // Cannot apply indexing with [] to an expression of type 'WebTester.Test'

      // JObject obj = (JObject) test.friendslist;
      // Cannot convert type 'WebTester.Friendslist' to 'Newtonsoft.Json.Linq.JObject'

      var data = JObject.Parse(rawdata);
      JObject obj = (JObject)data[elementName];
      obj.Add(new JProperty(newElementName, new JObject()));
      data[elementName] = obj;
      return data;
    }

    public JObject addElement(string newElementData, string elementName = "friendslist" , string  newElementName = "CustomCommands" ) {
      //optional parameters must appear after all required parameters
      var data = JObject.Parse(rawdata);
      JObject obj = (JObject)data[elementName ];
      var element = JObject.Parse(newElementData);
      obj.Add(new JProperty(newElementName, element));
      data[elementName] = obj;
      return data;
    }
  }
    public class Tester2 {
    public String rawdata {
      get;
      set;
    }
    public String elementdata {
      get;
      set;
    }
    public Tester2(String rawdata,String elementdata ) {
      this.rawdata = rawdata;
      this.elementdata  = elementdata;
    }
    public JObject addElement2(){
    // The call is ambiguous between the following methods or properties:
    var o = new WebTester.Tester1(rawdata);
    return o.addElement(elementdata);
    }
  }

}
'@  -ReferencedAssemblies "${shared_assemblies_path}\Newtonsoft.Json.dll","${shared_assemblies_path}\nunit.framework.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'
#>


$elementName = "friendslist" 
$newElementName = "CustomCommands" 
$o3 = $o.addElement("{""name"":""value"", ""a"": [""b"",""c""]}", $elementName, $newElementName)

write-output $o3.ToString()
<#

$o3 | convertto-json
[
    [
        [
            "{\r\n  \"steamid\": \"76561198031578776\",\r\n  \"relationship\": \"friend\",\r\n  \"friend_since\": 1519194870\r\n} {\r\n  \"steamid\": \"76561198040628535\",\r\n  \"relationship\": \"friend\",\r\n  \"friend_since\": 1460743289\r\n}"
        ],
        [
            "\"name\": \"value\" \"a\": [\r\n  \"b\",\r\n  \"c\"\r\n]"
        ]
    ]
]
#>
