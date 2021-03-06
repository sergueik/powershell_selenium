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
# More often the Text property of the enclosing repeater looks worse than this
param(
  [switch]$debug
)
$raw_input =  @'
Browser
Top 10 Visitors, New Users grouped by Browser

Browser
Visitors
New Users
Firefox
10.0M
1.0M
Chrome
3.0M
120.9K
Vivaldi
10K
0.5K
'@
$input_lines = $raw_input -split "`r?`n"
$column0 = @{
  'Vivaldi' = $null;
  'Firefox' = $null;
  'Chrome' = $null;
}
$column1 = @{}
$column2 = @{}
$column3 = @{}
#
[String[]]$data_keys = $column0.Keys
0..($input_lines.Count -2) | foreach-object {
  $row_index = $_
  $text = $input_lines[$row_index]
  if ($debug){
    write-output ('Processing: {0}' -f $text)
  }
  $matching_element = [String](
    [Array]::Find($data_keys,[System.Predicate[String]]<# follows the code block #>{
    if ($text -match $args[0]) { return $args[0] } else { return $null }
  }))

  if ($debug){
    write-output ('found matching element: {0}' -f $matching_element)
  }  
  if ($matching_element -ne '' -and $matching_element -ne $null) {
   $column1[$matching_element] = $matching_element
   $column2[$matching_element] = $input_lines[$row_index + 1]
   $column3[$matching_element] = $input_lines[$row_index + 2]
  }
}
$data = @()
$column1.keys | foreach-object  {
  $key = $_
  $row = @{}
  $row['Browser'] = $key
  $row['Visitors'] = $column2[$key]
  $row['New Users'] = $column3[$key]
  $data += $row
}
write-output ($data | convertTo-JSON)

