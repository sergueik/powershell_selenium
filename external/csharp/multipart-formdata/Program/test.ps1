param (
  [string]$outputfile = 'a.log'
)
$result = $env:USERPROFILE |split-path -parent |split-path -leaf
write-output ('user home dir: {0}' -f $result)
write-output ('user home dir: {0}' -f $result) | Out-File -FilePath $outputfile -append -encoding ascii

# newer