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
# NOTE: 'contains' method is is not doing what it name says
$match_find = [Boolean](
  [Array]::Find($data,[System.Predicate[String]]{
  return ($args[0] -match $text)
}))
write-output $match_find


$matching_element = [String](
  [Array]::Find($data,[System.Predicate[String]]<# follows the code block #>{
  if ($text -match $args[0]) { return $args[0] } else { return $null }
}))

write-output $matching_element

# NOTE: strong plain.net type
[String[]]$data = @(
  'apple',
  'orange',
  'pear',
  'plum'
)
# both signatures are accepted
[System.Linq.Enumerable]::Select($data,[Func[String,String]] <# follows the code block #> { return $args[0].ToUpper()})

[System.Linq.Enumerable]::Select($data,[System.Func[[String],[String]]] <# follows the code block #> { return $args[0].ToUpper()})

