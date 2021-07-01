. .\convertto_stringdata_example.ps1

$json = '{
  "name": "John",
  "age": 30,
  "married": true,
  "cars": [
    {
      "model": "BMW 230",
      "extradata": {
        "list of values": [
          1,
          2,
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

$object = $json | ConvertFrom-Json

$string = convertTo-StringData -object $object
write-output $string
# misses extradata
$new_object = write-output $string | convertFrom-string