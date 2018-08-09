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
$url = 'https://chromedriver.storage.googleapis.com/LATEST_RELEASE'
$version = (invoke-webrequest -uri $url).Content
# e.g. 2.41

# alternative chrome

$url = 'https://chromedriver.storage.googleapis.com/'
$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
dir $tmp_file

$o = [xml]$content
# TODO: filtering
$o.'ListBucketResult'.'Contents'[0].'Key'
$download_url = ('{0}{1}' -f $url, $o.'ListBucketResult'.'Contents'[0].'Key')
write-output $download_url

# https://chromedriver.storage.googleapis.com/2.0/chromedriver_linux32.zip

# firefox:
#  invoke-webrequest : The request was aborted: Could not create SSL/TLS securechannel.
# https://github.com/lukesampson/scoop/issues/2063
$url = 'https://github.com/mozilla/geckodriver/releases'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# this is too slow. appears to even be hanging
# (invoke-webrequest -uri $url).$o.ParsedHtml

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
dir $tmp_file

$html = New-Object -ComObject 'HTMLFile'

# backing up
# $source = Get-Content -Path $tmp_file -raw
# $html.IHTMLDocument2_write($source)

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
url          : https://api.github.com/repos/mozilla/geckodriver/releases/115083
               22
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
# note no '//' separator
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
# debugging on Windows 7
# mock
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
# $source = Get-Content -Path $tmp_file -raw
# $html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getelementsByClassName('driver-download')

$html2   = New-Object -ComObject 'HTMLFile'

# TODO: filter away $nodes[0] because it does not have structure as the rest
<#
  $nodes[0].innerhtml
  <P aria-label="WebDriver for Windows Insiders and future Windows releases" class=subtitle>Insiders and future releases</P>
  <P class=driver-download__meta>Microsoft WebDriver is now a Windows Feature on Demand.</P>
  <P class=driver-download__meta>To install run the following in an elevated command prompt:</P>
  <P class=driver-download__meta>DISM.exe /Online /Add-Capability /CapabilityName:Microsoft.WebDriver~~~~0.0.1.0</P>
#>
write-output $nodes.length
# 0..($nodes.length -1)|

$nodes |  foreach-object { 
  $node = $_
  $node_html = ($node | select-object -expandproperty 'outerHTML')
  write-output 'Processing:'
  write-output $node_html

  $html2.IHTMLDocument2_write($node_html )

  # $html2.IHTMLDocument2_write($nodes[1].innerHTML )
  <#

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
  <#
    # This does not work
    $element_text = $element.innerText
    $element_html = $element.outerHTML
    write-output ('element inner text: ' -f  $element_text)
    write-output ('element HTML: ' -f  $element_html)
  #>
  <#
   # this works but can be misleading

    $element | select-object -property 'outerHTML'
    $element | select-object -property 'innerText'
  #>
  if ($debugpreference -eq 'continue' ){
    $element
  }
  <#
    # This also does not work
    $element_html = ($element | select-object -property 'outerHTML')
    $element_text = ($element | select-object -property 'innerText')
    write-output ('element inner text: ' -f  $element_text)
    write-output ('element HTML: ' -f  $element_html)
  #>
    $element_text = ($element | select-object -expandproperty 'innerText')
    $element_html = ($element | select-object -expandproperty 'outerHTML')
  <#
    # This also does not work
    write-output ('element inner text: ' -f  $element_text)
    write-output ('element HTML: ' -f  $element_html)
  #>
    write-output 'element inner text: '
    write-output $element_text
    write-output 'element HTML: '
    write-output $element_html
    if ($element_text -match "Release ") {
      write-output 'Found something'
    }
    if ($element_text -match "Release ${currentBuildNumber}") {
      write-output ('Found {0}' -f $currentBuildNumber)
    }
  }
}

$html2.getElementsByTagName('A')[0].href
# e.g. https://download.microsoft.com/download/F/8/A/F8AF50AB-3C3A-4BC4-8773-DC27B32988DD/MicrosoftWebDriver.exe
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
Remove-Variable html
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
Remove-Variable html2

