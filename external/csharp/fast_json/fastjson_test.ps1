param (
  [String]$assembly_path = '.\Program\bin\Debug'
)
<#
if ($env:PROCESSOR_ARCHITECTURE -ne 'x86') { 
  # if the dll is compiled in SharpDevelp for x86 
  # the attempt to load in 64 bit Powershell will result in "BadImageFormatException"'
  write-output 'this test needs to be run on c:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
  exit 1;
}
#>
$asssembly = 'fastJSON.dll'
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
