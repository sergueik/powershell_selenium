param (
  [String]$assembly_path = '.\Program\bin\Debug'
)
$asssembly = 'fastJSON.dll'
$shared_assemblies = @($asssembly)
pushd $assembly_path
add-type -path $shared_assemblies[0]
popd
$asssembly_version = ((get-item -path $asssembly | select-object -expandproperty VersionInfo).ProductVersion ) -replace '\..*$', ''
write-output ('Running with assembly version {0}' -f $asssembly_version)
# no need to create instance with build 2.1.x
# $j = [fastJSON.JSON]::Instance

write-output 'test #1'

$s = "{'a':{'b':'c'}}" -replace "'",  '"'
$o = [fastJSON.JSON]::Parse($s)
write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
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

$o = [fastJSON.JSON]::Parse($s)
write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
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
$o = [fastJSON.JSON]::Parse($s)
write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))

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
$o = [fastJSON.JSON]::Parse($s)
write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))
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
$o = [fastJSON.JSON]::Parse($s)
write-output ('json: {0}' -f [fastJSON.JSON]::Beautify($s))

write-output ('$o["a"] = {0}' -f ($o["a"]).getType())
write-output 'dump:'
write-output $o['a']
write-output ('$o["a"][0] = {0}' -f ($o["a"][0]).getType())
write-output 'dump:'
write-output $o['a'][0]	
write-output ('$o["a"][0]["b"] = {0}' -f ($o["a"][0]["b"]).getType())
write-output 'dump:'
write-output $o['a'][0]['b']
write-output ('$o["a"][0]["b"]["c"] = {0}' -f ($o["a"][0]["b"]["c"]).getType())

write-output $o['a'][0]['b']['c']

