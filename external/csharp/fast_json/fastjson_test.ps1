$shared_assemblies = @('fastJSON.dll')
pushd .\fastJSON\bin\Debug
add-type -path $shared_assemblies[0]
popd
$j = [fastJSON.JSON]::Instance

write-output 'test #1'

$s = "{'a':{'b':'c'}}" -replace "'",  '"'
$o = $j.Parse($s)
write-output ('json: {0}' -f $j.Beautify($s))
write-output ('$o["a"] = {0}' -f ($o["a"]).getType())
write-output $o["a"]["b"]

write-output 'test #2'

$s = @'
{
  "a": [
    "b",
    "c"
  ]
}
'@

$o = $j.Parse($s)
write-output ('json: {0}' -f $j.Beautify($s))
write-output ('$o["a"] = {0}' -f $o["a"])
write-output $o["a"][0]


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
$o = $j.Parse($s)
write-output ('json: {0}' -f $j.Beautify($s))

write-output ('$o["a"] = {0}' -f ($o["a"]).getType())
write-output 'dump:'
write-output $o["a"]
write-output ('$o["a"][0] = {0}' -f ($o["a"][0]).getType())
write-output 'dump:'

write-output $o["a"][0]	
write-output ('$o["a"][0]["b"] = {0}' -f ($o["a"][0]["b"]).getType())
write-output $o["a"][0]["b"]

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
$o = $j.Parse($s)
write-output ('json: {0}' -f $j.Beautify($s))
write-output ('$o["a"] = {0}' -f ($o["a"]).getType())
write-output 'dump:'
write-output $o["a"]
write-output ('$o["a"][0] = {0}' -f ($o["a"][0]).getType())
write-output 'dump:'
write-output $o["a"][0]	
write-output ('$o["a"][0]["b"] = {0}' -f ($o["a"][0]["b"]).getType())
write-output 'dump:'
write-output $o["a"][0]["b"]
write-output ('$o["a"][0]["b"][0] = {0}' -f ($o["a"][0]["b"][0]).getType())

write-output $o["a"][0]["b"][0]


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
$o = $j.Parse($s)
write-output ('json: {0}' -f $j.Beautify($s))

write-output ('$o["a"] = {0}' -f ($o["a"]).getType())
write-output 'dump:'
write-output $o["a"]
write-output ('$o["a"][0] = {0}' -f ($o["a"][0]).getType())
write-output 'dump:'
write-output $o["a"][0]	
write-output ('$o["a"][0]["b"] = {0}' -f ($o["a"][0]["b"]).getType())
write-output 'dump:'
write-output $o["a"][0]["b"]
write-output ('$o["a"][0]["b"]["c"] = {0}' -f ($o["a"][0]["b"]["c"]).getType())

write-output $o["a"][0]["b"]["c"]

