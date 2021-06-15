#Copyright (c) 2021 Serguei Kouzmine
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

param (
  [String]$hub_ip = ''
)
if ($hub_ip -eq '') {
  $datafile = 'grid_console.html'
  $uri = ('file:///{0}' -f ((resolve-path $datafile).path -replace '\\', '/'))
} else {
  $uri = ('http://{0}:4444/grid/console' -f $hub_ip)
}

[Microsoft.PowerShell.Commands.WebResponseObject]$response_obj = (Invoke-WebRequest -Uri $uri)
$html = new-object -ComObject 'HTMLFile'
$html.IHTMLDocument2_write($response_obj.rawContent)

# $html | get-member -membertype method
# TypeName: mshtml.HTMLDocumentClass

[String[]]$texts = @()
<#
$column1 = $html.getElementById('leftColumn')
$element1 = $column1.getElementsByClassName('proxyid')|select-object -first 1
# $element | get-member
# NOTE: getType() may be not available
# $element1.getType().FullName
# System.__ComObject

$text1 = $element1.innertext
# $text1.getType().FullName
# System.String
#>
<#
try {
  $element2 = $column1.querySelectorall('p[class= "proxyid"]')|select-object -first 1
  # $element2.getType().FullName
} catch [Exception] { 
  write-output ( 'Exception : ' + $_.Exception.Message)
  # "a problem causes the program to stop working correctly" dialog. 
  # Cannot be caught
}
#>
# hub version-specific
$ids = @('left-column','right-column')
$ids = @('leftColumn', 'rightColumn') 

$ids| foreach-object {
  $id = $_
  $column = $html.getElementById($id)
  # $elements = $column.querySelectorall('.proxyid')
  $elements = $column.getElementsByClassName('proxyid')
  # in Powershell Version 4.0 [mshtml.HTMLDivElementClass] does not contain a method named 'getElementsByClassName'.
  # in Powershell Version 4.0 [mshtml.HTMLDivElementClass] does not containa method named 'querySelectorall'.
  # not practical to continue coding against 4.0
  $length = $elements.length
  0..($length - 1) | foreach-object {
    $index = $_
    $element = $elements.item($index)
    # $element.getType().FullName
    $text = $element.innertext
    # id : http://SERGUEIK53:5555, OS : WIN8_1
    # $text.getType().FullName 
    $texts += $text
    write-output ('Adding element index: {0} "{1}"' -f $index, $text)
  }
  Remove-Variable column -ErrorAction SilentlyContinue
  Remove-Variable element -ErrorAction SilentlyContinue
  Remove-Variable elements -ErrorAction SilentlyContinue
}
<#
try { 
  [Microsoft.PowerShell.Commands.HtmlWebResponseObject]$obj = (Invoke-WebRequest -Uri $uri)
} catch [Exception] { 
  write-output ( 'Exception : ' + $_.Exception.Message)
  # Cannot convert the value of type 
  # "Microsoft.PowerShell.Commands.WebResponseObject" to type
  # "Microsoft.PowerShell.Commands.HtmlWebResponseObject"
}
#>
# when reading http://localhost:4444/grid/console
# the result is Microsoft.PowerShell.Commands.HtmlWebResponseObject and has ParsedHtml member which is mshtml.HTMLDocumentClass 
# 
<#
$uri = 'http://localhost:4444/grid/console'
[Microsoft.PowerShell.Commands.HtmlWebResponseObject]$obj = (Invoke-WebRequest -Uri $uri)
[mshtml.HTMLDocumentClass] $document = $obj.ParsedHtml
Remove-Variable document -ErrorAction SilentlyContinue

Remove-Variable html -ErrorAction SilentlyContinue
$html = new-object -ComObject 'HTMLFile'
$html.IHTMLDocument2_write($obj.rawContent)
#>
# $texts

$texts| foreach-object { $text = $_; 
  $result = $text | convertfrom-String
  # With Powershell 4.0 the term 'convertfrom-String' is not recognized as the name of a cmdlet, function, script file, or operable program
  $result.P3 -replace ',', '' -replace 'http://', ''
} | sort-object | format-list
