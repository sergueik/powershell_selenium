### Info

This directory contains a replica of
[fastJSON - Smallest, Fastest Polymorphic JSON Serializer](https://www.codeproject.com/Articles/159450/fastJSON-Smallest-Fastest-Polymorphic-JSON-Seriali)
picked old Version __1.9.8__ to use with Powershell for a JSON serializartion and deserialization together with/instad of standard `convertTo-JSON` cmdlet.
The latter is supporting the `ashashtable` [switch](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.2) but only in very recent Powrshell versions

### Usage
```powershell
. .\fastjson_test.ps1 [-assemblypath <PATH TO fastjson.dll>]
```
```powershell
json: {
   "a" : [
      {
         "b" : {
            "c" : "C"
         }
      }
   ]
}
$o["a"] = System.Collections.Generic.List`1[System.Object]
dump:
b   {[c, C]}
$o["a"][0] = System.Collections.Generic.Dictionary`2[System.String,System.Object
]
dump:
b   {[c, C]}
$o["a"][0]["b"] = System.Collections.Generic.Dictionary`2[System.String,System.O
bject]
dump:
c   C
$o["a"][0]["b"]["c"] = System.String
C
```
### Note

The build __1.9.8__ of fastJSON was never available on nuget.org.
Powershell can embed the c# code (see `fastjson_embedded_test.ps1`)
or dymamlically load the assembly from nuget package of
the later version [2.1.28](https://www.nuget.org/packages/fastJSON/2.1.28).
The .Net plaform-specific variations of the assembly have not been tested yet.

The only difference fro Powershell perspective is one has to call static methods with build __2.1.28__:
```powershell
$s = "{'a':{'b':'c'}}" -replace "'",  '"'
$o = [fastJSON.JSON]::Parse($s)
```

instead of instance methods with build __1.9.8__
```powershell
$j = [fastJSON.JSON]::Instance

$s = "{'a':{'b':'c'}}" -replace "'",  '"'
$o = $j.Parse($s)
```
### Downloading

if using curl.exe from Windows 10 build and later or from git bash install:
```sh
curl.exe -s -O fastjson.2.1.18.zip -L -k https://www.nuget.org/api/v2/package/fastJSON/2.1.18 -o
```
need to follow symlinks toget the redirect page:
```html
<html><head><title>Object moved</title></head><body>
<h2>Object moved to <a href="https://globalcdn.nuget.org/packages/fastjson.2.1.18.nupkg">here</a>.</h2>
</body></html>
```
(see [stackoverflow explanation of the Invoke-WebRequest defaults](https://stackoverflow.com/questions/41618766/powershell-invoke-webrequest-fails-with-ssl-tls-secure-channel))
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
invoke-webrequest -uri 'https://globalcdn.nuget.org/packages/fastjson.2.1.18.nupkg' -outfile 'fastjson.2.1.18.zip'
$shell = new-object -com shell.application
$zip = $shell.NameSpace((resolve-path -path 'fastjson.2.1.18.zip').path)
$zip.items() | where-object {$_.name -eq 'lib'} |foreach-object {$shell.Namespace((resolve-path -path '.').path).copyhere($_)}
copy-item -path .\lib\net20\fastjson.dll -destination '.'
```
### See Also

  * [fast bson serializer](https://github.com/mgholam/fastBinaryJSON) by same author. NOTE: requires C# 6.x to compile the code, even for target .Net framework 4.x
  * [formatting JSON](https://weblog.west-wind.com/posts/2015/mar/31/prettifying-a-json-string-in-net)
  * [indenting JSON](https://stackoverflow.com/questions/2661063/how-do-i-get-formatted-json-in-net-using-c)

### Author

[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
