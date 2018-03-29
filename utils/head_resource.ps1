param(
  [Parameter(Position = 0)]
  [string]$url,
  [switch]$body
)

$get_response_body = [bool]$PSBoundParameters['body'].IsPresent
$get_response_headers = -not $get_response_body

# ignore self-signed certificates
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# https://msdn.microsoft.com/en-us/library/system.net.httpwebrequest(v=vs.95).aspx
$webRequest = [System.Net.WebRequest]::Create($url)
if ($get_response_headers -eq $true ) {
  $webRequest.Method = 'HEAD'; }
else { 
  $webRequest.Method = 'GET';
}
try {
	# https://msdn.microsoft.com/en-us/library/system.net.webresponse(v=vs.95).aspx
  [System.Net.WebResponse]$response = $webRequest.GetResponse()
  if ($get_response_headers -eq $true) {
    if ($response.StatusCode.value__ -eq 200) {
      Write-Output $response.Headers['Content-Length']
    } else {
      Write-Output ('Invalid response status : {0}',$response.StatusCode.value__)
    }
  }
  if ($get_response_body -eq $true) {
    [System.IO.StreamReader]$sr = New-Object System.IO.StreamReader ($response.GetResponseStream())
    [string]$Result = $sr.ReadToEnd()
    Write-Output ("Reponse:`n{0}" -f $Result)
  }
  try { 
    $response.Close();
  } catch [exception]{
    Write-Output ("Exception (ignored ): '{0}'" -f $_[0].Exception.Message)
    # ignore
  }

} catch [exception]{
  Write-Output ("Exception : '{0}'" -f $_[0].Exception.Message)
}
$webRequest = $null
