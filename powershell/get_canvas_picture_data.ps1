#Copyright (c) 2015 Serguei Kouzmine
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
  [string]$browser = '',

  [string]$base_url = 'http://learn.genetics.utah.edu/content/cells/scale/',
  [switch]$debug,
  [switch]$pause
)

# basic canvas access
# https://jdhnet.wordpress.com/2014/04/01/reading-out-the-canvas-element-in-the-robot-framework-via-javascript/


$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies


if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

$selenium.Navigate().GoToUrl($base_url)


$script = @"

function GetRegionPixelData(document_element, canvas_id, start_x, start_y, width, height) {
    var context;
    if (document_element) {
        var canvas = document_element.getElementsByTagName("canvas");
        context = canvas[canvas_id].getContext("2d");

    } else {
        var canvas = document.getElementsByTagName("canvas");
        context = canvas[canvas_id].getContext("2d");
    }
    //get pixel data in an array
    var picture = context.getImageData(start_x, start_y, width, height);

// http://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_canvas_getimagedata2
/* invert colors example does not work

for (var i=0;i<picture.data.length;i+=4)
  {
  picture.data[i]=255-picture.data[i];
  picture.data[i+1]=255-picture.data[i+1];
  picture.data[i+2]=255-picture.data[i+2];
  picture.data[i+3]=255;
  }
context.putImageData(picture,start_x, start_y);
*/
    return picture.data;
};

return GetRegionPixelData(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5]);
"@
 
[string]$xpath = "//iframe[@src='scale.html']"
[object]$canvas_frame_element = $null
find_page_element_by_xpath ([ref]$selenium) ([ref]$canvas_frame_element) $xpath
$canvas_frame = $selenium.SwitchTo().Frame($canvas_frame_element)

[OpenQA.Selenium.IWebElement]$canvas_body = $canvas_frame.FindElement([OpenQA.Selenium.By]::TagName("html"))
$canvas_body
highlight ([ref]$canvas_frame) ([ref]$canvas_body)
$results = ([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script,$canvas_body,0,100.0,100.0,100.0,100.0)
$results

# Cleanup
cleanup ([ref]$selenium)
