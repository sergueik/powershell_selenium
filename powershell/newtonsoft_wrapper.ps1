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
# $o | get-member
# write-output $o.rawdata$o | get-member
write-output $o.rawdata

write-output $friends[0] | format-list
write-output ('Friend count: {0}' -f $friends.count)
