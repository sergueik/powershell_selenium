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


# This script extracts the download link the edge driver by parsing the page HTML
# without using Selenium itself
# the current version just prints the data in the format:
# href : https://download.microsoft.com/download/C/0/7/C07EBF21-5305-4EC8-83B1-A6
#        FCC8F93F45/MicrosoftWebDriver.exe
# text : Release 10586
#
# href : https://download.microsoft.com/download/8/D/0/8D0D08CF-790D-4586-B726-C6
#        469A9ED49C/MicrosoftWebDriver.exe
# text : Release 10240

$download_url = 'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/'
$locator = 'section#downloads ul.driver-downloads li.driver-download > a'
# can not directly return the value
# https://stackoverflow.com/questions/26021813/ie-com-automation-how-to-get-the-return-value-of-window-execscript-in-powersh
# $script_template
$script = @"
  var selector = '${locator}';
  var elements = document.querySelectorAll(selector);
  var result = [];
  for (var cnt =0 ;cnt != elements.length ; cnt ++) {
    var element = elements[cnt];
    result.push( {
      'href': element.getAttribute('href'),
      'text': element.innerHTML
    });
  }
  document.body.setAttribute('PSResult' , JSON.stringify(result) );
"@

$ie = new-object -com 'internetexplorer.application'
$ie.visible = $false
$ie.navigate2($download_url)
# wait for the page to load
while ($ie.Busy -or ($ie.ReadyState -ne 4)) {
  start-sleep -milliseconds 100
}
# start-sleep -seconds 1
$debug =  $false
$document_element = $ie.document.documentElement
# write-output $document_element.document
$document = $ie.document

$document = $ie.document
$window = $document.parentWindow

write-debug ('Script : "{0}"' -f $script)
try {
  $window.execScript($script, 'javascript')
  $result = $document.body.getAttribute('PSResult') | convertfrom-json
  # add a release key
  $indexed_downloads = @{}
  $result | foreach-object {
    $data = $_
    add-member -InputObject $data -name release -value ($data.'text' -replace 'Release\s+', '') -membertype noteproperty
    $indexed_downloads[$data.'release'] = $data.'href'
  }
  # https://stackoverflow.com/questions/14741397/what-is-the-view-parameter-of-format-list
  if ($DebugPreference -eq 'Continue') {
    format-list -InputObject $result
  }
  format-list -InputObject $indexed_downloads
} catch [Exception] {
    write-output ('Exception : ' + $_.Exception.Message)
    # NOTE: Exception : Could not complete the operation due to error 80020101.
    # indicates a possible Javascript error, validate in Developer console
    return
}

# quit and dispose IE
$ie.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie) | out-null
Remove-Variable ie