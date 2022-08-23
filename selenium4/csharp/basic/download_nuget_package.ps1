param (
  [string]$package_name = 'Selenium.WebDriver',
  [string]$baseurl = 'https://www.nuget.org/api/v2/package',
  [string]$version = '4.2.0',
  [switch]$debug
)

$debug_flag = [bool]$PSBoundParameters['debug'].IsPresent -bor $debug.ToBool()
# will redirect
# Powershell does not accept without options passed
if ($debug_flag) {
  write-output ("(New-Object Net.WebClient).DownloadFile('{0}/{1}/{2}' , '{3}\{1}.{4}')" -f $baseurl,  $package_name, $version, $env:Temp, 'zip' )
  # (New-Object Net.WebClient).DownloadFile('https://www.nuget.org/api/v2/package/Selenium.WebDriver/4.2.0' , 'C:\Users\Serguei\AppData\Local\Temp\Selenium.WebDriver.zip')
  # Exception calling "DownloadFile" with "2" argument(s): "The underlying connection was closed: An unexpected error occurred on a send."
}
$local_file = ('{3}\{1}.{4}' -f $baseurl,  $package_name, $version, $env:Temp, 'zip' )
$url = ('{0}/{1}/{2}' -f $baseurl,  $package_name, $version )
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://globalcdn.nuget.org/packages/selenium.webdriver.4.2.0.nupkg'
(New-Object Net.WebClient).DownloadFile($url, $local_file)

<# NOTE:

curl -s -k -I https://www.nuget.org/api/v2/package/Selenium.WebDriver/4.2.0
HTTP/1.1 404 Not Found
Cache-Control: private
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
Access-Control-Expose-Headers: Request-Context
Set-Cookie: ARRAffinity=34509b3ce0b740928781763ffdad2cf678ad0c3563cc45c4c67d9e8a7186fef3;Path=/;HttpOnly;Secure;Domain=nuget-prod-v2gallery-appservice.trafficmanager.net
Set-Cookie: ARRAffinitySameSite=34509b3ce0b740928781763ffdad2cf678ad0c3563cc45c4c67d9e8a7186fef3;Path=/;HttpOnly;SameSite=None;Secure;Domain=nuget-prod-v2gallery-appservice.trafficmanager.net

Request-Context: appId=cid-v1:338f6804-b1a9-4fe3-bba7-c93064e7ae7b
Content-Security-Policy: frame-ancestors 'none'
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000; includeSubDomains
Date: Mon, 22 Aug 2022 23:49:12 GMT


browser network tab shows :
302
Location https://globalcdn.nuget.org/packages/selenium.webdriver.4.2.0.nupkg
probably need to add headers

User-Agent Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36
#>
# https://stackoverflow.com/questions/27768303/how-to-unzip-a-file-in-powershell
<#
# legacy -  does not work, there is possibly an incorrect call to target  shell namespace object
	$shell = New-Object -ComObject shell.application
$zip = $shell.NameSpace($local_file)
mkdir("package\xxx")
foreach ($item in $zip.items()) {
  $shell.Namespace("package\xxx").CopyHere($item)
}
#>
<#
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
#>
$ProgressPreference = 'SilentlyContinue'

$package_dir = ("packages\{0}.{1}" -f $package_name, $version)
mkdir $package_dir -erroraction silentlycontinue
Expand-Archive -path $local_file -DestinationPath $package_dir -force