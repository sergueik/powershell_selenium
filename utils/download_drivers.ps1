#Copyright (c) 2018 Serguei Kouzmine
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

# This script extracts download link for latest version of Seleium driver from release page XML, JSON or HTML as applicable

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-6

# chrome:
$available_plaforms = @(
  'mac32',
  'win32',
  # NOTE: no 'win64'
  'linux32',
  'linux64'
)
$plaform = 'win32'

$release_url = 'https://chromedriver.storage.googleapis.com/'
$latest_release_url = 'https://chromedriver.storage.googleapis.com/LATEST_RELEASE'
$latest_version = (invoke-webrequest -uri $latest_release_url).Content
$base_url = $release_url

$download_url = ('{0}{1}/chromedriver_{2}.zip' -f $base_url, $latest_version, $plaform)

write-output ('Latest version: {0}' -f $latest_version)
write-output ('Download url: {0}' -f $download_url)
<#
e.g.
  Latest version: 2.41
  Download url: https://chromedriver.storage.googleapis.com/2.41/chromedriver_win32.zip
#>
# Alternative chrome

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $release_url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}
$o = [xml]$content

# TODO: filtering by platform and CPU architecture
$contents = $o.'ListBucketResult'.'Contents'
$releases = @{}
$contents |
foreach-object {
$contents_element = $_
  if ($debugPReference -eq 'continue'){
    $contents_element | select-object -property *
  }
  $key = $contents_element.Key
  if ($key -match 'debug' ) {
    return
  }
  if ($key -match $plaform ) {
    $download_url = ('{0}{1}'-f $base_url, $key )
    if ($key -match '\b(?<version>[0-9]+\.[0-9]+)\b' ){
      $version = $matches['version']
      # TODO: support build
      $version_key = 0 + ($version -replace '.(\d)', '000$1')
      # write-output $version
      # write-output $download_url
      $release_info = @{}
      $release_info['version'] = $version
      $release_info['download_url'] = $download_url
      $releases[$version_key] = $release_info
    }
  }
}
$latest_release = $releases.GetEnumerator() | sort -Property name -descending | select-object -first 1
$latest_release.Value | format-list

# firefox:
$available_plaforms = @(
  'arm7hf',
  'linux32',
  'linux64',
  'macos',
  'win32',
  'win64',
  'osx'
)

$platform = 'win32'

$release_url = 'https://github.com/mozilla/geckodriver/releases'
# origin: https://github.com/lukesampson/scoop/issues/2063
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 'ParsedHtml' is too slow. appears to be hanging
# (invoke-webrequest -uri $url).$o.ParsedHtml

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $release_url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$html = New-Object -ComObject 'HTMLFile'

# backing up
$source = Get-Content -Path $tmp_file -raw
$html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getElementsByClassName('release-title')

$html2   = New-Object -ComObject 'HTMLFile'

$html2.IHTMLDocument2_write($nodes[0].innerhtml )
$html2.getElementsByTagName('A')[0].innerText
# e.g. v0.21.0
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
remove-variable html2


# TODO: filtering
0..($nodes.length) |
foreach-object {
$cnt = $_
$node = $nodes.item($cnt)
$html2   = New-Object -ComObject 'HTMLFile'
$html2.IHTMLDocument2_write($node.innerhtml )
$element =  $html2.getElementsByTagName('A')[0]
# $element | get-member
$text = $element.innerText
write-output $text
try{
  if ($debugPReference -eq 'continue'){
    $attributes = $element.attributes
    $attributes | where-object { $_.name -match 'href'} | select-object -first 1 | format-list
    <#
    # e.g.

    nodeName        : href
    nodeValue       : about:/mozilla/geckodriver/releases/tag/v0.16.0
    specified       : True
    name            : href
    value           : about:/mozilla/geckodriver/releases/tag/v0.16.0
    expando         : False
    nodeType        : 2
    parentNode      :
    childNodes      :
    firstChild      :
    lastChild       :
    previousSibling :
    nextSibling     :
    attributes      :
    ownerDocument   : mshtml.HTMLDocumentClass
    ie8_nodeValue   : /mozilla/geckodriver/releases/tag/v0.16.0
    ie8_value       : /mozilla/geckodriver/releases/tag/v0.16.0
    ie8_specified   : True
    ownerElement    : System.__ComObject
    ie9_nodeValue   : /mozilla/geckodriver/releases/tag/v0.16.0
    ie9_nodeName    : href
    ie9_name        : href
    ie9_value       : /mozilla/geckodriver/releases/tag/v0.16.0
    ie9_firstChild  : System.__ComObject
    ie9_lastChild   : System.__ComObject
    ie9_childNodes  : System.__ComObject
    ie9_specified   : True
    constructor     : System.__ComObject
    prefix          :
    localName       : href
    namespaceURI    :
    textContent     : /mozilla/geckodriver/releases/tag/v0.16.0

    #>
  }
    $href = $element.getAttribute('href',0)
    write-output ($href -replace '^about:','')
    $attributes = $element.attributes
    $attributes | where-object { $_.name -match 'href'} | select-object -first 1 | select-object -property textContent | format-list
    # write-output ($href.textContent)
  } catch [Exception] {
    # ignore
    write-Debug ( 'Exception : ' + $_.Exception.Message)
  }
  [System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
  remove-variable html2

}
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
remove-variable html

# geckodriver better way
$url = 'https://api.github.com/repos/mozilla/geckodriver/releases'
$releases = new-object -typename 'System.Collections.HashTable'

$content = (invoke-webrequest -uri $url).Content
$array_obj_json = $content | convertfrom-json
if ($debugPReference -eq 'continue'){
  $obj_json[11] | select-object -property *
}
$array_obj_json | foreach-object {
  $obj_json = $_
  $assets = $obj_json.assets
  $assets | foreach-object {
    $key = $_.browser_download_url
    if ($key -match $plaform ) {
      if ($key -match '/\b(?<version>v[0-9]+\.[0-9]+\.[0-9]+)\b/' ){
        $version = $matches['version']
        $release_key = 0 + ($version -replace '^v','' -replace '.(\d)', '000$1')
        $download_url = $key
        <#
        write-output $download_url
        write-output $version_key
        write-output $version
        #>
        $release_info = new-object -typename 'System.Collections.HashTable'
        $release_info['version'] = $version
        $release_info['download_url'] = $download_url
        $releases.add($release_key, $release_info)
      }
    }
  }
}
$latest_release_key = $releases.keys |sort-object -descending | select-object -first 1
$latest_release = $releases[$latest_release_key]
$latest_release | format-list

# ie:
# really ?
$url = 'http://www.seleniumhq.org/download'
$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$html = new-object -ComObject 'HTMLFile'

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement
# TODO: finish


# IEDriverServer better way

# NOTE: releases of several products:
# selenium-standalone, selenium-server, selenium-java, selenium-dotnet and IEDriverServer
# are all described in https://selenium-release.storage.googleapis.com/

$url = 'https://selenium-release.storage.googleapis.com/'
$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$o = [xml]$content
# see also https://www.petri.com/search-xml-files-powershell-using-select-xml
$contents = $o.'ListBucketResult'.'Contents'
$releases = @{}
$contents |
foreach-object {
  $contents_element = $_
  if ($debugPReference -eq 'continue'){
    $contents_element | select-object -property *
  }
  $key = $contents_element.Key
  if ($key -match 'debug' ) {
    return
  }
  if ($key -match $plaform ) {
    $download_url = ('{0}{1}'-f $base_url, $key )
    if ($key -match '\b(?<version>[0-9]+\.[0-9]+)\b' ){
      $version = $matches['version']
      $version_key = 0 + ($version -replace '.(\d)', '000$1')
      # write-output $version
      # write-output $download_url
      $release_info = @{}
      $release_info['version'] = $version
      $release_info['download_url'] = $download_url
      $releases[$version_key] = $release_info
    }
  }
}
$latest_release = $releases.GetEnumerator() | sort -Property name -descending | select-object -first 1
$latest_release.Value | format-list


# similar to chromedriver

$o.'ListBucketResult'.'Contents'[0].'Key'

# 2.39/IEDriverServer_Win32_2.39.0.zip
$download_url = ('{0}{1}' -f $url, $o.'ListBucketResult'.'Contents'[0].'Key')

# note no '/' separator in the format - 'invoke-webrequest' is sensitive
# https://selenium-release.storage.googleapis.com//2.39/IEDriverServer_Win32_2.39.0.zip

# To validate, download it
# (invoke-webrequest -url $download_url ).RawContentLength
# 836478

# edge
# TODO: select relevant version to prevent the error:
# This version of MicrosoftWebDriver.exe is not compatible with the installed version of Windows 10.


pushd 'HKLM:/'
cd 'SOFTWARE/Microsoft/Windows NT/CurrentVersion'
$currentBuildNumber = (Get-ItemProperty -Path ('HKLM:/SOFTWARE/Microsoft/Windows NT/CurrentVersion' -f $hive,$path) -Name 'CurrentBuildNumber' -ErrorAction 'SilentlyContinue').CurrentBuildNumber
if ($currentBuildNumber -eq $null ) {
  $currentBuildNumber = '17134'
}
popd

# mocking on Windows 7
$currentBuildNumber = '17134'

write-output ('CurrentBuildNumber: {0}' -f $currentBuildNumber)

$url = 'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver'

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$html = New-Object -ComObject 'HTMLFile'

# backing up
$source = Get-Content -Path $tmp_file -raw
$html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getElementsByClassName('driver-download')

$html2   = New-Object -ComObject 'HTMLFile'
<#
NOTE:
  $nodes[0].innerhtml
  <P aria-label="WebDriver for Windows Insiders and future Windows releases" class=subtitle>Insiders and future releases</P>
  <P class=driver-download__meta>Microsoft WebDriver is now a Windows Feature on Demand.</P>
  <P class=driver-download__meta>To install run the following in an elevated command prompt:</P>
  <P class=driver-download__meta>DISM.exe /Online /Add-Capability /CapabilityName:Microsoft.WebDriver~~~~0.0.1.0</P>
#>
write-output ('Examine {0} nodes' -f $nodes.length)

$nodes |  foreach-object {
  $node = $_
  $node_html = ($node | select-object -expandproperty 'outerHTML')
  if ($debugPReference -eq 'continue'){
    write-output 'Processing the node HTML:'
    write-output $node_html
  }
  $html2.IHTMLDocument2_write($node_html )

  <#
    # element data sample
    <a class="subtitle"
       href="https://download.microsoft.com/download/F/8/A/F8AF50AB-3C3A-4BC4-8773-DC27B32988DD/MicrosoftWebDriver.exe"
       aria-label="WebDriver for release number 17134">Release 17134</a>
    <p class="driver-download__meta">Version: 6.17134 | Edge version supported: 17.17134 |
  #>

  $elements = $html2.getElementsByTagName('A')

  write-output $elements.length
  0..($elements.length) | foreach-object {
    # TODO: all elements show the release 17134 (12 times istead of 1 time)
    $cnt = $_
    $element = $elements.item($cnt)

    if ($debugpreference -eq 'continue' ){
      $element
    }
    $element_text = ($element | select-object -expandproperty 'innerText')
    if ($debugPReference -eq 'continue'){
      $element_html = ($element | select-object -expandproperty 'outerHTML')
      write-output ('element HTML: {0}' -f $element_html )
    }
    if ($element_text -match 'Release *\d+') {
      write-output ('Item # {0}' -f  $cnt)
      write-output ('Release: {0}' -f  ($element_text -replace '^Release *', ''))
      write-output ('Download: {0}' -f $element.getAttribute('href') )
    }
  }
}

$html2.getElementsByTagName('A')[0].href
# e.g. https://download.microsoft.com/download/F/8/A/F8AF50AB-3C3A-4BC4-8773-DC27B32988DD/MicrosoftWebDriver.exe
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
remove-variable html
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
remove-variable html2
