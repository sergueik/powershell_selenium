param (
  [string]$outputfile = 'a.log'
)
# TODO: detect Windows version and Powershell version and quit executing the unstable cmdlet
$result =  get-computerinfo
# plain text formatting 
write-output ('computer info: {1}{0}' -f ($result|select-object -property *), ([char]13+[char]10)) | Out-File -FilePath $outputfile -append -encoding ascii
