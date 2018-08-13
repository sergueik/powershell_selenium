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
$available_architectures = @(
  'mac32',
  'win32',
  # NOTE: no 'win64'
  'linux32',
  'linux64'
)
$architecture = 'win32'

$release_url = 'https://chromedriver.storage.googleapis.com/'
$latest_release_url = 'https://chromedriver.storage.googleapis.com/LATEST_RELEASE'
$latest_version = (invoke-webrequest -uri $latest_release_url).Content
$base_url = $release_url

$download_url = ('{0}{1}/chromedriver_{2}.zip' -f $base_url, $latest_version,$architecture)

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
  if ($key -match $architecture ) {
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
exit 0

# firefox:

# orogin: https://github.com/lukesampson/scoop/issues/2063
$url = 'https://github.com/mozilla/geckodriver/releases'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 'ParsedHtml' is too slow. appears to be hanging
# (invoke-webrequest -uri $url).$o.ParsedHtml

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
dir $tmp_file

$html = New-Object -ComObject 'HTMLFile'

# backing up
$source = Get-Content -Path $tmp_file -raw
$html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getelementsByClassName('release-title')

$html2   = New-Object -ComObject 'HTMLFile'

# TODO: filtering
$html2.IHTMLDocument2_write($nodes[0].innerhtml )
$html2.getElementsByTagName('A')[0].innerText
# e.g. v0.21.0

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
Remove-Variable html
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
Remove-Variable html2

# geckodriver better way
$url = 'https://api.github.com/repos/mozilla/geckodriver/releases'

$content = (invoke-webrequest -uri $url).Content
$o = $content | convertfrom-json
$o[0] |
select-object -property html_url,url,tag_name,prerelease,zipball_url,published_at |
format-list
<#
html_url     : https://github.com/mozilla/geckodriver/releases/tag/v0.21.0
url          : https://api.github.com/repos/mozilla/geckodriver/releases/11508322
tag_name     : v0.21.0
prerelease   : False
zipball_url  : https://api.github.com/repos/mozilla/geckodriver/zipball/v0.21.0
published_at : 2018-06-15T20:57:11Z

#>

# ie:
# really ?
$url = 'http://www.seleniumhq.org/download'
$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
dir $tmp_file

$html = New-Object -ComObject 'HTMLFile'

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

# IEDriverServer better way
$url = 'https://selenium-release.storage.googleapis.com/'
$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
dir $tmp_file

$o = [xml]$content

$o.'ListBucketResult'.'Contents'[0].'Key'

# 2.39/IEDriverServer_Win32_2.39.0.zip
$download_url = ('{0}{1}' -f $url, $o.'ListBucketResult'.'Contents'[0].'Key')

# note no '/' separator in the format - 'invoke-webrequest' is sensitive
# https://selenium-release.storage.googleapis.com//2.39/IEDriverServer_Win32_2.39.0.zip

# To validate, download it
# (invoke-webrequest -url $download_url ).RawContentLength
# 836478

# edge

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
dir $tmp_file

$html = New-Object -ComObject 'HTMLFile'

# backing up
$source = Get-Content -Path $tmp_file -raw
$html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getelementsByClassName('driver-download')

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
    $cnt = $_
    $element = $elements.item($cnt)

    if ($debugpreference -eq 'continue' ){
      $element
    }
    $element_text = ($element | select-object -expandproperty 'innerText')
    $element_html = ($element | select-object -expandproperty 'outerHTML')
    if ($element_text -match "Release ${currentBuildNumber}") {
      write-output 'Found something'
      write-output 'element inner text: '
      write-output $element_text
      write-output 'element HTML: '
      write-output $element_html
    }
  }
}

$html2.getElementsByTagName('A')[0].href
# e.g. https://download.microsoft.com/download/F/8/A/F8AF50AB-3C3A-4BC4-8773-DC27B32988DD/MicrosoftWebDriver.exe
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
Remove-Variable html
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
Remove-Variable html2
