# origin: https://stackoverflow.com/questions/40495248/create-hashtable-from-json
function parse_json_helper{
  param (
    [string]$json,
    [string]$file = $null,
    [int]$threshold = 15
  )
  $data = @{}
  if ($file -ne $null -and $file -ne '' -and (test-item -path $file)) {
    write-debug ('Reading file "{0}"' -f $file)
    $data = [IO.File]::ReadAllText($file)
  } else {
    $data = $json
  }
  $parser = new-object -typeName 'Web.Script.Serialization.JavaScriptSerializer'
  $parser.MaxJsonLength = $data.length
  $data = $parser.DeserializeObject($data)
  write-output -NoEnumerate $data
  $data.keys|
    foreach-object {
      $key = $_;
      $row = $data[$key]
      if ( $row['CPU'] -gt $threshold ){
        write-output $row | format-table
      }
    }
  # $data
}

function collection_processing_function {
  param (
    [String]$json,
    [int]$threshold
  )
  $data = convertFrom-json -InputObject $json <# -Hashtable parameter was introduced in PowerShell 6.2 #>

  # the $data here is unpleasant MS-own pscustomobject type
  $data = @{}
  (convertFrom-json -InputObject $json  <# -Depth parameter is unavailable prior PowerShell 6.2 #> ).psobject.properties |
    foreach-object {
      $data[$_.Name] = $_.Value
    }

  $data.keys|
    foreach-object {
      $key = $_;
      $row = @{}
      ($data[$key]).psobject.properties |
        foreach-object {
          $row[$_.Name] = $_.Value
        }
      if ( $row['CPU'] -gt $threshold ){
        write-output $row | format-table
      }
    }
}
$name = 'vivaldi'; $data = @{ } ; get-process -Name $name | foreach-object {
  # using pid as a key. The convertTo-json only supports  string keys
  # convertTo-json : The type 'System.Collections.Hashtable' is not supported for serialization or deserialization of a dictionary. Keys must be strings.
  $it = $_;
  $data[('{0}' -f $it.'Id')] = @{
    'pid' = $it.'Id';
    'CPU' = $it.'CPU';
    'Name' = $name
  }
};
$process_list = convertTo-json -inputobject $data| out-string;
collection_processing_function $process_list 13
parse_json_helper -json $process_list


