param (
  [String]$assembly_path = '.\Program\bin\Debug'
)
<#
if ($env:PROCESSOR_ARCHITECTURE -ne 'x86') { 
  # if the dll is compiled in SharpDevelop for x86 (e.g. for debugging)
  # attempt to load in 64 bit Powershell will fail with "BadImageFormatException"
  write-output 'this test needs to be run on c:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
  exit 1;
}
#>
$asssembly = 'fastJSON.dll'
if (-not (test-path -path ( $assembly_path + '\' + $asssembly ) ) ) { 
   write-host ('Missing dependency {0}' -f ( $assembly_path + '\' + $asssembly ) )
   return
}
$shared_assemblies = @($asssembly)
pushd $assembly_path

add-type -path $shared_assemblies[0]
$asssembly_version = ((get-item -path $asssembly | select-object -expandproperty VersionInfo).ProductVersion ) -replace '\..*$', ''
write-output ('Running with assembly version {0}' -f $asssembly_version)
popd

# no need to create instance with build 2.1.x
# $j = [fastJSON.JSON]::Instance

$j = [fastJSON.JSON]::Instance

write-output 'test #1'

$s = "{'a':{'b':'c'}}" -replace "'",  '"'
# $o = [fastJSON.JSON]::Parse($s)
$o = $j.Parse($s)
# write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
write-output ('json: {0}' -f $j.Beautify($s))
write-output ('$o["a"] = {0}' -f ($o['a']).getType())
write-output $o['a']['b']

write-output 'test #2'

$s = @'
{
  "a": [
    "b",
    "c"
  ]
}
'@

# $o = [fastJSON.JSON]::Parse($s)
$o = $j.Parse($s)
# write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
write-output ('json: {0}' -f $j.Beautify($s))
write-output ('$o["a"] = {0}' -f $o['a'])
write-output $o['a'][0]


write-output 'test #3'

$s = @'
{
  "a": [
    {
      "b": "B"
    },
    {
      "c": "C"
    }
  ]
}
'@
# $o = [fastJSON.JSON]::Parse($s)
$o = $j.Parse($s)
# write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
write-output ('json: {0}' -f $j.Beautify($s))

write-output ('$o["a"] = {0}' -f ($o["a"]).getType())
write-output 'dump:'
write-output $o['a']
write-output ('$o["a"][0] = {0}' -f ($o["a"][0]).getType())
write-output 'dump:'

write-output $o['a'][0]	
write-output ('$o["a"][0]["b"] = {0}' -f ($o["a"][0]["b"]).getType())
write-output $o['a'][0]['b']

write-output 'test #4'

$s = @'
{
    "a" : [
        {
            "b" : [
                "B"
            ]
        },
        {
            "c" : "C"
        }
    ]
}
'@
# $o = [fastJSON.JSON]::Parse($s)
$o = $j.Parse($s)
# write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
write-output ('json: {0}' -f $j.Beautify($s))

write-output ('$o["a"] = {0}' -f ($o["a"]).getType())
write-output 'dump:'
write-output $o['a']
write-output ('$o["a"][0] = {0}' -f ($o["a"][0]).getType())
write-output 'dump:'
write-output $o['a'][0]	
write-output ('$o["a"][0]["b"] = {0}' -f ($o["a"][0]["b"]).getType())
write-output 'dump:'
write-output $o['a'][0]['b']
write-output ('$o["a"][0]["b"][0] = {0}' -f ($o["a"][0]["b"][0]).getType())

write-output $o['a'][0]['b'][0]


write-output 'test #5'

$s = @'
{
    "a" : [
        {
            "b" : {
                "c" : "C"
            }
        }
    ]
}
'@
# $o = [fastJSON.JSON]::Parse($s)
write-output 'Deserialize...'
$o = $j.Parse($s)
# write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
write-output ('json: {0}' -f $j.Beautify($s))

write-output ('$o["a"] = {0}' -f ($o['a']).getType())
write-output 'dump:'
write-output $o['a']
write-output ('$o["a"][0] = {0}' -f ($o['a'][0]).getType())
write-output 'dump:'
write-output $o['a'][0]	
write-output ('$o["a"][0]["b"] = {0}' -f ($o['a'][0]['b']).getType())
write-output 'dump:'
write-output $o['a'][0]['b']
write-output ('$o["a"][0]["b"]["c"] = {0}' -f ($o['a'][0]['b']['c']).getType())

write-output $o['a'][0]['b']['c']
write-output $j.ToJSON($o)

write-output 'test #6'
$s = '{
  "name": "John",
  "age": 30,
  "married": true,
  "cars": [
    {
      "model": "BMW 230",
      "extradata": {
        "list of values": [
          1,
          42,
          3
        ]
      },
      "mpg": 27.5
    },
    {
      "model": "Ford Edge",
      "mpg": 24.1
    }
  ]
}
'

$o = $j.Parse($s)
write-output ('Type: {0}' -f $o.getType())
# write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
write-output ('json: {0}' -f $j.Beautify($s))
$o = $j.Parse($s)
#
write-output $o['cars'][0]['extradata']['list of values'][1]
write-output 'Serialize...'
write-output $j.ToJSON($o)

$data = @{ 
  "foo" = "bar";
  "number" = 42;
  "valid"  = $true;
  "array" = @(1,2,3);
}

write-output ('Type: {0}' -f $data.getType())
$raw_json = $j.ToJSON($data)
write-output $raw_json
<#
[
{"k":"valid","v":true},{"k":"number","v":42},{"k":"foo","v":"bar"},{"k":"arrray","v":[1,2,3]}
]

#>
write-output 'Transforming data'
[System.Collections.Generic.Dictionary[String,Object]]$input_data = New-Object System.Collections.Generic.Dictionary'[String,Object]'

$data.keys| foreach-object {
  $key = $_
  # NOTE: [System.Collections.Hashtable] does not contain a method named 'get'.
  # $input_data.Add($key, $data.get($key))
  if ($input_data.ContainsKey($key)) {
    $input_data.Remove($key)
  }
  $input_data.Add($key, $data[$key])
}

write-output ('Type: {0}' -f $input_data.getType())


$raw_json = $j.ToJSON($input_data)
write-output $raw_json
