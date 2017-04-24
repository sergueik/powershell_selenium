param(
  [Parameter(Position = 0)]
  [string]$url
)
# ignore self-signed certificates
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
  public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) {
    return true;
  }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
$webRequest = [System.Net.WebRequest]::Create($url)
$get_response_body = $false
$get_response_headers = $true
$webRequest.Method = 'HEAD'
try {
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
} catch [exception]{
  # System.Management.Automation.ErrorRecord -> System.Net.WebException
  $exception = $_[0].Exception
  Write-Output ("Exception : Status: '{0}'  StatusCode: '{1}' Message: '{2}'" -f $exception.Status,$exception.Response.StatusCode,$exception.Message)
}
