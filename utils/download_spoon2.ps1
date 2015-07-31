param(
  [string]$username = 'kouzmine_serguei@yahoo.com',
  [string]$url = 'http://start-c.spoon.net/layers/setup/3.33.539/spoon-plugin.exe',
  [switch]$use_proxy,
  [string]$password = 'I/z00mscr'
)

$webclient = new-object System.Net.WebClient
$credCache = new-object System.Net.CredentialCache
$creds = new-object System.Net.NetworkCredential($username,$password)
$credCache.Add($url, "Basic", $creds)
$webclient.Credentials = $credCache
# $webpage = $webclient.DownloadString($url)
$status = $webclient.DownloadFile($url, 'a.exe')
$status 
# System.Net.WebClient
# $webpage | get-member
# $webpage.Length