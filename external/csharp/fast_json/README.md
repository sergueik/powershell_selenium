### Info

This directory contains a replica of [fastJSON - Smallest, Fastest Polymorphic JSON Serializer](https://www.codeproject.com/Articles/159450/fastJSON-Smallest-Fastest-Polymorphic-JSON-Seriali)
picked old Version  1.9.8 to use with Powershell for a JSON de-serialization together with standard `convertTo-JSON` cmdlet 

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

The build __1.9.8__ of fastJSON was never available on nuget.org. Powershell can use the later version [2.1.28](https://www.nuget.org/packages/fastJSON/2.1.28). The .Net plaform-specific variations of the assembly have not been tested yet.

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

```sh
curl  -l -k https://www.nuget.org/api/v2/package/fastJSON/2.1.18
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
invoke-webrequest -uri 'https://globalcdn.nuget.org/packages/fastjson.2.1.18.nupkg'  -outfile 'fastjson.2.1.18.zip'
$shell = new-object -com shell.application
$zip = $shell.NameSpace((resolve-path -path 'fastjson.2.1.18.zip').path)
$zip.items() | where-object {$_.name -eq 'lib'} |foreach-object {$shell.Namespace((resolve-path -path '.').path).copyhere($_)}
copy-item -path .\lib\net20\fastjson.dll -destination '.'
```
### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
