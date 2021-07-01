# origin: https://stackoverflow.com/questions/68180889/convert-json-data-to-property-format-using-powershell
# https://gist.github.com/1RedOne/ebd7147f377738694446064a7768deef
# (does not work, and somwhow, no surprise)

function convertTo-StringData {
param (
  $object, $propertyOverride
)
  $fields = $object | get-member -MemberType NoteProperty
  foreach($field in $fields){
    if (IsArray($field)){
       OutputArrayMember -object $object -field $field

    }
    else{
      OutputMember -object $object -propertyName $field.name -propertyOverride $propertyOverride
    }
  }
}

function IsArray {
param ($object)
  $object.Definition -match '.*\[\].*'
}
function OutputMember{
  param(
    $object,
    $propertyName,
    $propertyOverride
  )
  if ($propertyOverride){
    "$($propertyOverride).$($propertyName)=$($object.$($propertyName))"
  }
  else{
     "$($propertyName)=$($object.$($propertyName))"
  }

}

function OutputArrayMember{
  param(
    $object,
    $field
  )
  $global:testObject = $object
  $global:testfield = $field
  $base = $field.Name
  $i = 0
  foreach ($item in $object.$($field.Name)){
    ConvertTo-StringData -object $object.$($field.Name)[$i] -propertyOverride "$base[$i]"
    $i++
  }
}


function Drill{
  param(
    $object,
    $parentPath
  )
  if ($null -ne $parentPath){
    $parentPath = $parentPath+$function:parentPath
    $parentPath = $parentPath.TrimStart('.')

  }
  $parentPath
  #select next leaf
  if (hasChildren $object){
    "drilling down into $object"
    $props = GetNoteProperties $object
    $var = getObjectByProperty $object $props
    drill $var -parentPath "$($parentPath).$($props.Name)"
  }
  else{
    ConvertTo-StringData -object $object -propertyOverride $parentPath
    $global:test = $object
  }
}

function hasChildren{
  param(
    $object
  )
  [bool](($object | gm -MemberType NoteProperty).Definition -match 'System.Management.Automation.PSCustomObject')
}

function GetNoteProperties{
  param(
    $object
  )
  get-member -InputObject $object -MemberType NoteProperty
}

function getObjectByProperty{
  param(
    $object,
    $propertyName
  )
  $object.$($propertyName.Name)
}
