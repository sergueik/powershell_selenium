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
  [String]$hub_ip = '',
  [String]$hub_port = '4444',
  [switch]$remove_port,
  [switch]$debug_html,
  [switch]$use_form,
  [switch]$debug_ie
)
if ($hub_ip -ne '') {
  $status = test-netconnection -computername $hub_ip -port $hub_port
  if (( -not $status.PingSucceeded )-or (-not $status.TcpTestSucceeded) ) {
    write-output ('http://{0}:4444/grid/console is not responding' -f $hub_ip, $hub_port)
    exit 0
  }
}
if ($hub_ip -eq '') {
  $datafile = 'grid_console.html'
  $uri = ('file:///{0}' -f ((resolve-path $datafile).path -replace '\\', '/'))
} else {
  $uri = ('http://{0}:4444/grid/console' -f $hub_ip, $hub_port)
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
if ($debug_ie) {
  $element = $html.querySelector('#leftColumn,#rightColumn p[class = "proxyid"]')
  write-output 'Found element '
  write-output  $element.InnerText

  # https://www.w3schools.com/cssref/css_selectors.asp
  $column1 = $html.getElementById('leftColumn')
  $length = $column1.querySelectorall('p[class = "proxyid"]').length

  write-output('Found {0} elements' -f $length)
  $content = $html.getElementById('main_content')
  $length = $content.querySelectorall('#leftColumn,#rightColumn p[class = "proxyid"]').length
  write-output('Found {0} elements' -f $length)

}
<#
if ($debug_ie) {
try {
  $column = $html.getElementById('leftColumn')
  $element = $column.querySelectorall('p[class= "proxyid"]')|select-object -first 1
  $element.getType().FullName
} catch [Exception] {
  write-output ( 'Exception : ' + $_.Exception.Message)
  # "a problem causes the program to stop working correctly" dialog.
  # Cannot be caught
}
}
#>
# hub version-specific
$ids = @('left-column','right-column')
$ids = @('leftColumn', 'rightColumn')

$ids| foreach-object {
  $column_id = $_
  $column = $html.getElementById($column_id)
  # $elements = $column.querySelectorall('.proxyid')
  $elements = $column.getElementsByClassName('proxyid')
  # in Powershell Version 4.0 [mshtml.HTMLDivElementClass] does not contain a method named 'getElementsByClassName'.
  # in Powershell Version 4.0 [mshtml.HTMLDivElementClass] does not containa method named 'querySelectorall'.
  # not practical to continue coding against 4.0
  if (($elements -eq $null) -or ($elements.length -eq 0 )) {
    write-output ('all nodes are down on hub http://{0}:4444/grid/console' -f $hub_ip, $hub_port)
    exit 0
  }
  $length = $elements.length
  0..($length - 1) | foreach-object {
    $index = $_
    $element = $elements.item($index)
    # $element.getType().FullName
    $text = $element.innertext
    # id : http://SERGUEIK53:5555, OS : WIN8_1
    # $text.getType().FullName
    $texts += $text
    if ($debug_html) {
      write-output ('Adding element column: {0} index: {1} "{2}"' -f $column_id, $index, $text)
    }
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
add-type -assembly System.Windows.Forms
$form = new-object System.Windows.Forms.Form
$form.Size = new-object System.Drawing.Size(600,300)

$list = new-object System.collections.ArrayList
$hostinfo = $texts| foreach-object { $text = $_;
  $result = $text | convertfrom-String
  # With Powershell 4.0 the term 'convertfrom-String' is not recognized as the name of a cmdlet, function, script file, or operable program
  $node_info = $result.P3 -replace ',', '' -replace 'http://', ''
  if ($remove_port) {
    $node_info = $node_info -replace ':[0-9]+$', ''
    $node_info
  }
  $node_info
} | sort-object

$hostinfo | foreach-object {
# https://www.c-sharpcorner.com/article/binding-an-arraylist-with-datagrid-control/
# NOTE: the following will not work:
# $list.add($_)
# $list.Add(@{"hostname" = $_})
$o = new-object PSObject
$o | add-member Noteproperty 'hostname' $_
$list.add($o)
 } | out-null
if ([bool]$PSBoundParameters['use_form'].IsPresent) {

  $dataGrid = new-object System.Windows.Forms.DataGrid -Property @{
    Size = new-object System.Drawing.Size(584,200)
    Location = new-object System.Drawing.Point(8,8)
    ColumnHeadersVisible = $true
    DataSource = $list
  }
  $style= [System.Windows.Forms.DataGridTextBoxColumn]@{
    MappingName = 'hostname'
    HeaderText = 'hostname'
    Width = 150
  }
  $table_style = new-object System.Windows.Forms.DataGridTableStyle
  $table_style.GridColumnStyles.Add($style)
  $dataGrid.TableStyles.Add($table_style)

  $button = [System.Windows.Forms.Button]@{
    Text = 'OK'
    Name = 'ok_button'
    Location = [System.Drawing.point]::new(8, 222 )
  }
  $form.Controls.AddRange(@($dataGrid, $button))
  $form.ShowDialog() |out-null
} else {
  $list | format-table
}

# see also: https://stackoverflow.com/questions/11468423/powershell-creating-custom-datagridview
