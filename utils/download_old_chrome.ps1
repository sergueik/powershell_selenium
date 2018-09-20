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

# Slimjet chrome downloads

# $debugPreference = 'continue'

# NOTE: can not encounter difficult to debug problems when starting nested powershell from powershell and run this

$url = 'https://www.slimjet.com/chrome/google-chrome-old-version.php'
# invoke-webrequest : The request was aborted: Could not create SSL/TLS secure channel.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$cnt = get-random -maximum 100 -minimum 1

$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$html = new-object -ComObject 'HTMLFile'

# caching
$source = Get-Content -Path $tmp_file -raw
$html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getElementsByTagName('TABLE')

# write-debug ('Examine {0} nodes' -f $nodes.length)

$cnt = 0
$data = @{ }
$nodes |  foreach-object {
  $node = $_
  $cnt =  $cnt + 1
  $node_html = ($node | select-object -expandproperty 'outerHTML')
  # if ($debugPReference -eq 'continue'){
  #    write-output ('Processing the node {0} HTML:'  -f $cnt)
  #    write-output $node_html
  # }
  $html2 = new-object -ComObject 'HTMLFile'
  $html2.IHTMLDocument2_write($node_html )
  #  if ($debugPReference -eq 'continue'){
  #   $html2 |get-member -membertype 'method'
  # }
  $rows = $null
  try{
    $rows = $html2.getElementsByTagName('TR')
  } catch [Exception] {
    write-Debug ( 'Exception (ignored) : ' + $_.Exception.Message)
    $rows = $null
  }
  if ($rows -ne $null) {
    (0..$rows.length)  |foreach-object {
      $row_cnt = $_
      $row = $rows[$row_cnt]
      # NOTE: cannot use newline in write-debug messages
      # write-debug ("Row {0}`r{1}`r" -f $row_cnt, $row.innerHTML)
      # write-debug ("Row {0} {1} " -f $row_cnt, $row.innerHTML)
      $node_html = ($row | select-object -expandproperty 'outerHTML')
      $html3 = new-object -ComObject 'HTMLFile'
      $html3.IHTMLDocument2_write($node_html )
      $cols = $html2.getElementsByTagName('TR')
      # need just column 0
      $html3.IHTMLDocument2_write($cols[0].innerHTML )
      $link = $html3.getElementsByTagName('A')[0]
      if ($link -ne $null ) { # -and $link.hasAttribute('href')
        $version = $link.innerText
        # $cols[0] | get-member
        $url = $link.getAttribute('href')
        if ($url -match 'chrome64' -and $url -match 'exe$'){
          $data[$version] = $url
          write-output  ('version = {0}, url = "{1}"' -f  $version, $url )
        }
      }
      try{
        remove-variable html3
      } catch [Exception] {
        write-Debug ( 'Exception (ignored): ' + $_.Exception.Message)
      }
    }
  }
  try{
    remove-variable html2
  } catch [Exception] {
    write-Debug ( 'Exception (ignored): ' + $_.Exception.Message)
  }
}
try{
  remove-variable html
} catch [Exception] {
  write-Debug ( 'Exception (ignored) : ' + $_.Exception.Message)
}
try{
  [System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
} catch [Exception] {
  write-Debug ( 'Exception (ignored) : ' + $_.Exception.Message)
}
