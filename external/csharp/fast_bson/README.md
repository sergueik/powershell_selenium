
### Info

[Kernys.Bson](https://github.com/kernys/Kernys.Bson/tree/master/Kernys.Bson) BSON Encoder &amp; Decoder


### Testing
 * if you have `bsondump` available locally, can verify the temporary files left after running tests, with the following command:

```cmd
set PATH=%PATH;c:\tools\mongo\bin
bsondump.exe c:\temp\text.bson 2>NUL
```
this will output
```json
{"Blah":1}
 ```

### Usage

* encoding
add  the `Program.dll` to the dependencies, then 
```csharp
var obj = new BSONObject ();
obj["hello"] = 123;

obj["where"] = new BSONObject();
obj["where"]["Korea"] = "Asia";
obj["where"]["USA"] = "America";
obj["bytes"] = new byte[128];

byte []buf = SimpleBSON.Dump(obj);
Console.WriteLine (buf);
```

 * decoding 
```csharp
BSONObject obj = SimpleBSON.Load(buf);

Console.WriteLine(obj["hello"]); // => 123
Console.WriteLine(obj["where"]["Korea"]); // => "Asia"
Console.WriteLine(obj["where"]["USA"]); // => "America"
Console.WriteLine(obj["bytes"].binaryValue); // => 128-length bytes
```

### See Also

  * one can either compile  `bsondump` [source](https://docs.mongodb.com/database-tools/bsondump) or have downloaded [MongodB Community Edition Server Installer](https://www.mongodb.com/try/download/community)  - make sure to pick no newer  than 4.0.x if planning to run it on Windows 8.1. Note that `bsondump.go` has a long list of Mongo package dependencies. To have `bsondump.exe` is is sufficient to select __Import/Export Tools__  when installing. Also - bsondump is not distributed with Compass, so clear __include Compass__ checkbox


