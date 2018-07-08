#Copyright (c) 2014 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


param(
  [string]$export,
  [switch]$override_proxy,
  [switch]$debug
)

# http://poshcode.org/2887
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
# https://msdn.microsoft.com/en-us/library/system.management.automation.invocationinfo.pscommandpath%28v=vs.85%29.aspx
function Get-ScriptDirectory
{
  [string]$scriptDirectory = $null

  if ($host.Version.Major -gt 2) {
    $scriptDirectory = (Get-Variable PSScriptRoot).Value
    Write-Debug ('$PSScriptRoot: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
    Write-Debug ('$MyInvocation.PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    Write-Debug ('$PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
  } else {
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
      $scriptDirectory = $Invocation.PSScriptRoot
    } elseif ($Invocation.MyCommand.Path) {
      $scriptDirectory = Split-Path $Invocation.MyCommand.Path
    } else {
      $scriptDirectory = $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
    }
    return $scriptDirectory
  }
}


$shared_assemblies = @(
  'HtmlAgilityPack.dll',
  'nunit.framework.dll'
)

$env:SHARED_ASSEMBLIES_PATH = "c:\java\selenium\csharp\sharedassemblies"
$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Debug ("Loaded {0} " -f $_) }
popd

# TODO -  read node.json configuration hubHost and hubPort
$url = 'http://127.0.0.1:4444/grid/console#'
# $url = 'http://10.240.140.85:4444/grid/console#'
$sleep_interval = 30
$max_retries = 1
$build_log = 'test.properties'
$expected_http_status = 200

$proxy_url = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
if ($proxy_url -eq $null) {
  $proxy_url = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
}

if ($proxy_url -eq $null -or $PSBoundParameters['override_proxy']) {

  $proxy_url = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script'
}



$proxy = New-Object System.Net.WebProxy
$proxy.Address = $proxy_url
Write-Debug ('Probing {0}' -f $proxy.Address)
$proxy.useDefaultCredentials = $true

$req = [system.Net.WebRequest]::Create($url)
try {
$req.proxy = $proxy}
catch [exception]{
  # Write-Output 'ignoring the exception'
  write-output $_.Exception.Message
<#
Exception setting "proxy": 
The ServicePointManager does not support proxies with the proxy.carnival.com scheme.
#>
 #  exit 1
}
$req.useDefaultCredentials = $true

$req.PreAuthenticate = $true
$req.Headers.Add('UserAgent','Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/535.2')

$req.Credentials = New-Object system.net.networkcredential ($build_user,$build_password)
# $response = $webrequest.GetResponse()
[Io.StreamReader]$sr = $null
[int]$int = 0
for ($i = 0; $i -ne $max_retries; $i++) {


  try {
    $res = $req.GetResponse()
    $sr = [Io.StreamReader]($res.GetResponseStream())
    # may fail!
    # [xml]$xmlout = $sr.ReadToEnd()

  } catch [System.Net.WebException]{

    $res = $_.Exception.Response
  }
  catch [Exception] {

<#
Exception calling "GetResponse" with "0" argument(s): "The ServicePointManager
does not support proxies with the proxy.carnival.com scheme." 
#>
  write-output $_.Exception

 }

  $int = [int]$res.StatusCode
  $time_stamp = (Get-Date -Format 'yyyy/MM/dd hh:mm')
  $status = $res.StatusCode
  Write-Output "$time_stamp`t$url`t$int`t$status"
  if (($int -ne $expected_http_status) -or ($sr -eq $null)) {
    Start-Sleep -Seconds $sleep_interval
  }
}
$time_stamp = $null
if ($int -ne $expected_http_status) {
  Write-Output 'Unexpected http status detected. Error reported.'
  exit 1
}

[string]$source = $sr.ReadToEnd()
# TODO detect failure to  handle proxy :
# <title>Access to this site is blocked</title>

try {
  # will fail to load. 
  [xml]$xmlout = $source

}
catch [exception]{
  Write-Output 'ignoring the exception'
  # write-output $_.Exception.Message
  <# Cannot convert value "<html><... </a></div></body></html>" to type "System.Xml.XmlDocument". 
Error: "The 'p' start tag on line 1 position 749 does not match the end tag of 'div'. Line 4, position 833." 
#>
}

[void][System.Net.WebUtility]::HtmlDecode($source)
if ($PSBoundParameters['debug']) {
   write-output $source
}

[HtmlAgilityPack.HtmlDocument]$resultat = New-Object HtmlAgilityPack.HtmlDocument
$resultat.LoadHtml($source)

# http://www.codeproject.com/Tips/804660/How-to-Parse-Html-using-csharp
# http://htmlagilitypack.codeplex.com/downloads/get/437941
[HtmlAgilityPack.HtmlNodeCollection]$nodes = $resultat.DocumentNode.SelectNodes("//p[@class='proxyid']")
foreach ($node in $nodes)
{
  Write-Output $node.InnerText
  <#
  try {
    [HtmlAgilityPack.HtmlNodeNavigator]$navigator = $node.CreateNavigator()
    [void]$navigator.MoveToNext()
    [void]$navigator.MoveToNext()
    $navigator.SelectNodes("//div[@type='browsers']//img")
    TODO - switch back to node collection
    Write-Output 'in navigator'
    $navigator = $null
  } catch [exception]{
    # write-output $_.Exception.Message
    # NOOP 
  }
#>
  $browsers_div = $node.NextSibling.NextSibling
  [HtmlAgilityPack.HtmlNodeCollection]$browsers = $browsers_div.SelectNodes("div[@type='browsers']//img")
  $node_browsers = @()
  foreach ($image in $browsers)
  {
    # Parse JSON-like format 
    $browser = $image.Attributes['title'].Value
    $browser_info = @{}
    if ($browser -match '{(.+)}') {
      $data = $matches[1]
      # $data -split ', ' | foreach-object { $entry =  $_ ; $entry  -split '=' | foreach-object { write-output $_  } } 
      $data -split ', ' | ForEach-Object { $entry = $_;
        if ($entry -match '^(.+)\s*=(.*)$') {
          $k = $matches[1]
          $v = $matches[2]
          # Write-Output ( $k + ' = ' + ('"{0}"' -f $v))
          $browser_info[$k] = $v
        } }


      # write-output $data
    }
    # Write-Output $image.Attributes["title"].Value
    # Write-Output $image.Attributes['class'].Value
    $browser_info['class'] = $image.Attributes['class'].Value
    $node_browsers += $browser_info
  }
  $node_browsers | Format-Table -AutoSize
}

if ($PSBoundParameters['export']) {

  [HtmlAgilityPack.HtmlWeb]$web = New-Object HtmlAgilityPack.HtmlWeb
  [System.Xml.XmlTextWriter]$writer = New-Object XML.XmlTextWriter ('{0}\{1}' -f (Get-ScriptDirectory),'test12.xml'),([Text.Encoding]::Unicode)
  [void]$web.LoadHtmlAsXml($url,$writer)

  $writer.Close()
}
return
