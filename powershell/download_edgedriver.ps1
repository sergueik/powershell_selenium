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
$scripts = @(
@"
    var selector = '${locator}';
    var elements = document.querySelectorAll(selector);
    var result = elements[0].innerHTML;
    /*
    var fso = new ActiveXObject('Scripting.FileSystemObject');
    var out = fso.GetStandardStream(1); out.Write(result);
    */
    return(result);
"@,
 ("var selector = '{0}';var elements = document.querySelectorAll(selector); var result = elements[0].innerHTML; document.body.setAttribute('PSResult' , result);" -f $locator),
 ("var selector = '{0}';var elements = document.querySelectorAll(selector); var result = elements[0].getAttribute('href'); document.body.setAttribute('PSResult' , result);" -f $locator),
 @"
    var selector = '${locator}';
    var elements = document.querySelectorAll(selector);
    var result = elements[0].innerHTML;
    document.body.setAttribute('PSResult' , result);
"@,
@"
  var selector = '${locator}';
  var elements = document.querySelectorAll(selector);
  var result = elements[0].getAttribute('href');
  document.body.setAttribute('PSResult' , result);
"@
@"
  var selector = '${locator}';
  var elements = document.querySelectorAll(selector);
  var element = elements[0];
  var result = {
    'href': element.getAttribute('href'),
    'text': element.innerHTML
  };
  document.body.setAttribute('PSResult' , JSON.stringify(result) );
"@,
@"
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

)
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

$scripts | foreach-object { $script = $_
  write-debug ('Locating "{0}"' -f $locator)
  write-debug ('Script : "{0}"' -f $script)
  try {
    $window.execScript($script, 'javascript')
    $result = $document.body.getAttribute('PSResult')
    write-output $result
    $result  | convertfrom-json | format-list
    <#
    
href : https://download.microsoft.com/download/C/0/7/C07EBF21-5305-4EC8-83B1-A6
       FCC8F93F45/MicrosoftWebDriver.exe
text : Release 10586

href : https://download.microsoft.com/download/8/D/0/8D0D08CF-790D-4586-B726-C6
       469A9ED49C/MicrosoftWebDriver.exe
text : Release 10240
...
#>
  } catch [Exception] {
      write-output ( 'Exception : ' + $_.Exception.Message)
      # Exception : Could not complete the operation due to error 80020101.
      return
  }
}


# section#downloads ul.driver-downloads li.driver-download > a
# <li class="driver-download"><a class="subtitle" href="https://download.microsoft.com/download/3/2/D/32D3E464-F2EF-490F-841B-05D53C848D15/MicrosoftWebDriver.exe" aria-label="WebDriver for release number 14393">Release 14393</a>
# <p class="driver-download__meta">Version: 3.14393 | Edge version supported: 14.14393 | <a href="https://az813057.vo.msecnd.net/eulas/webdriver-eula.pdf">License terms</a></p>

# Quit and dispose IE COM
$ie.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie) | out-null
Remove-Variable ie
<#
$script_template = @"
var selector = arguments[0];
if (selector == undef)  {
 selector = '{0}' ;
};
var elements = document.querySelectorAll(selector);
"@
# Error formatting a string: Input string was not in a correct format..


$script_template = (($script_template -split "`n" ) -join '' )

#>