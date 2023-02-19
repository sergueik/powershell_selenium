param(
  [switch]$html_documentebug
)

$shared_assemblies = @(
  'HtmlAgilityPack.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path


$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd
# https://www.nuget.org/packages/HtmlAgilityPack/
# 1.4.9.0
# origin (no longer exist): https://htmlagilitypack.codeplex.com/
# fork (also archived): https://github.com/tomap/HtmlAgilityPack
# nuget (latest is 1.11.46): https://www.nuget.org/packages/HtmlAgilityPack/#supportedframeworks-body-tab
[HtmlAgilityPack.HtmlDocument]$html_document = new-Object HtmlAgilityPack.HtmlDocument
$url = 'https://store.epicgames.com/ru/free-games'
$html_web = new-Object HtmlAgilityPack.HtmlWeb

# Exception calling "Load" with "1" argument(s): "The request was aborted: Could not create SSL/TLS secure channel."
# https://stackoverflow.com/questions/51668380/web-query-with-htmlagilitypack-throws-system-net-webexception-the-request-was-a
# https://learn.microsoft.com/en-us/answers/questions/173758/the-request-was-aborted-could-not-create-ssl-tls-s
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'

# see also:
# https://docs.workflowgen.com/wfgmy/v802/html/2cc12c34-ceac-0c1f-ac31-c357e539e2e5.htm#!
$html_document = $html_web.Load($url)

$temp_filename = ('{0}\{1}' -f $env:TEMP, ('temp_{0}.html' -f (Get-Random -Maximum 5000)))
# 
$html_document.Save($temp_filename)
# write-output $temp_filename

$rawdata = get-content -path $temp_filename
$html_document.LoadHtml($rawdata)

if ($html_document.ParseErrors -ne $null -and $html_document.ParseErrors.Count -gt 0) {
  Write-Output 'Handle any parse errors as required'
}
$xpath = '/html/body/div[1]/div/div[4]/main/div[3]/div/div/div/div/div[1]/span/div/div/div/div/div/h1'
$nodes = $html_document.DocumentNode.SelectNodes($xpath)
# write-output $nodes.Count
if ($nodes.Count -ne 0) {
  $nodes | ForEach-Object {
    Write-Output ($_.InnerText)
  }
}