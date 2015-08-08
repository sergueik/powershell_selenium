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
  [switch]$grid,
  [switch]$pause
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$base_url = 'https://datatables.net/examples/api/form.html'
$selenium.Navigate().GoToUrl($base_url)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150


try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("logo")))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}


$table_id = 'example';
$text_input_css_selector = 'input[id="row-5-age"]'



$cell_text = 'Software Developer'

$table_element = find_element_new -Id $table_id

# Find a specific input
[OpenQA.Selenium.IWebElement]$text_input_element = $table_element.FindElement([OpenQA.Selenium.By]::CssSelector($text_input_css_selector))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$text_input_element).Build().Perform()

highlight ([ref]$selenium) ([ref]$text_input_element)

# https://msdn.microsoft.com/en-us/library/system.windows.forms.sendkeys.send%28v=vs.110%29.aspx
# need to invoke through $action to avoid runtime error.
# ^a has no effect on the input
# [void]$actions.SendKeys($text_input_element,[System.Windows.Forms.SendKeys]::SendWait("^a"))
# [void]$actions.SendKeys($text_input_element,[System.Windows.Forms.SendKeys]::SendWait("{BACKSPACE}{BACKSPACE}{BACKSPACE}")) 
# start-sleep -millisecond 100
# TODO : keyboard
# [void]$selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait("{BACKSPACE}"))


# https://selenium.googlecode.com/svn/trunk/docs/api/java/org/openqa/selenium/Keys.html
$text_input_element.SendKeys(([OpenQA.Selenium.Keys]::Backspace + [OpenQA.Selenium.Keys]::Backspace + [OpenQA.Selenium.Keys]::Backspace + [OpenQA.Selenium.Keys]::Backspace + [OpenQA.Selenium.Keys]::Backspace + [OpenQA.Selenium.Keys]::Backspace))
Start-Sleep -Millisecond 100
$text_input_element.SendKeys(("20" + [OpenQA.Selenium.Keys]::Tab + $cell_text + [OpenQA.Selenium.Keys]::Enter))

Start-Sleep -Millisecond 100
$select_css_selector = 'select[id="row-5-office"]'


[OpenQA.Selenium.IWebElement]$select_element = $table_element.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$select_element).Build().Perform()

[OpenQA.Selenium.IWebElement[]]$option_collection = $select_element.FindElements([OpenQA.Selenium.By]::XPath('option'))
[object]$move_to_top = ''
$option_collection | ForEach-Object {
  Write-Output $_.Text
}
0..$option_collection.Count | ForEach-Object {
  $move_to_top += [OpenQA.Selenium.Keys]::Up
}
[object]$move_to_target = ''
$target_input = 'New York'
# TODO: 'New York'
$found = $false
$option_collection | ForEach-Object {
  if ($_.Text -match $target_input ) {
    $found = $true
    return
  }
  Write-Output $_.Text
  if (-not $found ) {
    $move_to_target += [OpenQA.Selenium.Keys]::Down
   }
}

$select_element.SendKeys($move_to_top)

# $select_element.SendKeys(( [OpenQA.Selenium.Keys]::Up + [OpenQA.Selenium.Keys]::Up + [OpenQA.Selenium.Keys]::Up + [OpenQA.Selenium.Keys]::Up +[OpenQA.Selenium.Keys]::Up+[OpenQA.Selenium.Keys]::Up  ))
Start-Sleep -Millisecond 100

# $select_element.SendKeys([OpenQA.Selenium.Keys]::Down)
$select_element.SendKeys($move_to_target)


Start-Sleep -Millisecond 100

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
