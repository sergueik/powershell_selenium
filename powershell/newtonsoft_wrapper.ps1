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

# used to answer: https://toster.ru/q/658363
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
   public Test test {
      get;
      set;
    }

    public Tester(String rawdata) {
      this.rawdata = rawdata;
    }

    public void  load() {

      if (rawdata != null) {
        // Console.Error.WriteLine(rawdata);
        Console.Error.WriteLine("Creating dummy Test instance");
        Test data = null;
        Console.Error.WriteLine("Now trying to load it");
        try {
          data = JsonConvert.DeserializeObject<Test>(rawdata);
          Console.Error.WriteLine("Load it");
        } catch (NullReferenceException e) {
          Console.Error.WriteLine(e.ToString());
        }
        Assert.IsNotNull(data);

        Friendslist friendslist = data.friendslist;

        Assert.IsNotNull(friendslist);
        IList<Friend> friends = friendslist.friends;
        Assert.IsNotNull(friends);
        Console.WriteLine("Friend count: " + data.friendslist.friends.Count);
        this.test = data;
      }
    }
  }

  public class Test
  {
    public Friendslist friendslist {
      get;
      set;
    }

  }

  public class Friendslist
  {
    public IList<Friend> friends {
      get;
      set;
    }
  }

  public class Friend
  {
    public string steamid {
      get;
      set;
    }
    public string relationship {
      get;
      set;
    }
    public string friend_since {
      get;
      set;
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
$o.load()

$o | get-member
write-output $o.rawdata
$friends = $o.test.friendslist.friends
write-output $o.rawdata

write-output $friends[0] | format-list
write-output ('Friend count: {0}' -f $friends.count)

write-output 'Indenting JSON'
# static methods
$p = @{'s' = 1; 'r' = @(1,2,3); 'q' = @{'t' = 0; }}
#

$n = [Newtonsoft.Json.JsonConvert]::SerializeObject($p, [Newtonsoft.Json.Formatting]::Indented)

write-output $n
$r = @'
{"a" : 1
,
    "b" : {
"c" :[
2,3,4]
}
}
'@
write-output 'unindented JSON:'
write-output $r

write-output 'indented JSON:'
$y = [Newtonsoft.Json.JsonConvert]::DeserializeObject($r)
$n = [Newtonsoft.Json.JsonConvert]::SerializeObject($y, [Newtonsoft.Json.Formatting]::Indented)

write-output $n

write-output 'indented JSON with inline helper class:'
# configuring indentation -
# https://stackoverflow.com/questions/2661063/how-do-i-get-formatted-json-in-net-using-c
# https://www.newtonsoft.com/json/help/html/M_Newtonsoft_Json_JsonConvert_SerializeObject_3.htm
# https://www.newtonsoft.com/json/help/html/t_newtonsoft_json_formatting.htm
# https://www.newtonsoft.com/json/help/html/P_Newtonsoft_Json_JsonTextWriter_Indentation.htm
# https://www.newtonsoft.com/json/help/html/P_Newtonsoft_Json_JsonTextWriter_IndentChar.htm
# https://www.newtonsoft.com/json/help/html/writejsonwithjsontextwriter.htm
# https://www.newtonsoft.com/json/help/html/M_Newtonsoft_Json_JsonConvert_SerializeObject_3.htm
add-type -TypeDefinition  @'

using System;
using System.IO;
using Newtonsoft.Json;

public class JsonUtil {
    public int Indentation { get; set; }

    public string JsonPrettify(string json) {
        using (var stringReader = new StringReader(json))
        using (var stringWriter = new StringWriter()) {
            var jsonReader = new JsonTextReader(stringReader);
            var jsonWriter = new JsonTextWriter(stringWriter) { Formatting = Formatting.Indented };
            if (this.Indentation !=0 )
              jsonWriter.Indentation = this.Indentation;
	
            jsonWriter.WriteToken(jsonReader);
            return stringWriter.ToString();
        }
    }
}
'@  -ReferencedAssemblies "${shared_assemblies_path}\Newtonsoft.Json.dll","${shared_assemblies_path}\nunit.framework.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'

$o = new-object -typeName 'JsonUtil'
$o.Indentation = 2

$o.JsonPrettify($r)
write-output 'indented JSON with Powershell helper class using "Newtonsoft.Json" loaded assembly namespace'
# converted to plain Powershell
[Newtonsoft.Json.Formatting] $f = [Newtonsoft.Json.Formatting]::Indented
[System.IO.TextWriter]$t = new-object System.IO.StringWriter

# https://www.newtonsoft.com/json/help/html/t_newtonsoft_json_jsontextwriter.htm
[Newtonsoft.Json.JsonTextWriter] $w =  new-object Newtonsoft.Json.JsonTextWriter($t)
$w.Formatting = $f
$w.Indentation = 3

[System.IO.TextReader]$i = new-object System.IO.StringReader($r)
[Newtonsoft.Json.JsonTextReader] $e =  new-object Newtonsoft.Json.JsonTextReader($i)

$w.WriteToken($e)
write-output $t.ToString()
$t.close()
