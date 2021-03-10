$data = @(
  'apple',
  'orange',
  'pear',
  'plum'
)


$text = 'pear'
$exact_find = [Boolean](
  [Array]::Find($data,[System.Predicate[String]]{
  return ($args[0] -eq $text)
}))

write-output $exact_find
# NOTE: '-contains' method is is not doing what it name says
# https://docs.microsoft.com/en-us/dotnet/api/system.array.findall?view=netframework-4.0
#
$match_find = [Boolean](
  [Array]::Find($data,[System.Predicate[String]]{
  return ($args[0] -match $text)
}))
write-output ('match_find(boolean): {0}' -f $match_find)

# the default is return the matching values
$text = 'e'
$matching_elements = (
  [Array]::FindAll($data,[System.Predicate[String]]{
  return ($args[0] -match $text)
}))
write-output ('matching_elements(array) of {0}: {1}' -f $text, ($matching_elements -join ','))

$text = 'pear'
# this is not really needed with System.Array.Find but will preactice with plan touse with Wait.Util
$matching_element = [String](
  [Array]::Find($data,[System.Predicate[String]]<# follows the code block #>{
  if ($text -match $args[0]) { return $args[0] } else { return $null }
}))

write-output ('another matching_element: {0}' -f $matching_element)

# NOTE: strong plain.net type
[String[]]$data = @(
  'apple',
  'orange',
  'pear',
  'plum'
)

# both signatures are accepted
write-output 'select example'
[System.Linq.Enumerable]::Select($data,[Func[String,String]] <# follows the code block #> { return $args[0].ToUpper()})

[System.Linq.Enumerable]::Select($data,[System.Func[[String],[String]]] <# follows the code block #> { return $args[0].ToUpper()})

write-output 'where example'
[System.Linq.Enumerable]::Where($data,[Func[String,Bool]] <# follows the code block #> { return $args[0].ToLower() -match $text })
