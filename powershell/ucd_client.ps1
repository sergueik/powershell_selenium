#Copyright (c) 2020 Serguei Kouzmine
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

# automate the UCD Selenium client

param(
  [string]$ucd      = '192.168.0.64',
  [string]$username = 'admin',
  [string]$password = 'admin',
  [string]$browser  = 'firefox', # currently more stable under ferefox
  # 
  [switch]$grid,
  [switch]$kiosk, # chrome behaves differently in kiosk mode
  [switch]$headless,
  [switch]$pause
)
$base_url = ('https://{0}:8443/' -f $ucd)
$debugpreference = 'continue'
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
write-debug ('Full Stop: {0}' -f $fullstop )
$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  write-debug 'Running on grid'
}
if ([bool]$PSBoundParameters['headless'].IsPresent) {
  write-debug 'Running headless'
}
if ([bool]$PSBoundParameters['kiosk'].IsPresent) {
  write-debug 'Running kiosk mode'
}
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  if ([bool]$PSBoundParameters['headless'].IsPresent) {
    $selenium = launch_selenium -browser $browser -grid -headless
  } else {
    $selenium = launch_selenium -browser $browser -grid
  }
} else {
  if ([bool]$PSBoundParameters['headless'].IsPresent) {
    $selenium = launch_selenium -browser $browser -headless
  } elseif ([bool]$PSBoundParameters['kiosk'].IsPresent) {
    $selenium = launch_selenium -browser $browser -kiosk
  } else {
    $selenium = launch_selenium -browser $browser
  }
}

function close_dialog{
  param(
    [string] $css_selector = 'div[role = "dialog"]'
  )
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  [OpenQA.Selenium.IWebElement]$local:element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

  [OpenQA.Selenium.IWebElement]$local:element2 = $element1.FindElement([OpenQA.Selenium.By]::CssSelector('span.closeDialogIcon'))
  $local:element2.click()
  
}

function login_user {
  param(
    [string]$username = 'admin',
    [string]$password = 'admin'
  )
  $id = 'usernameField'
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id($id)))

  $css_selector = 'form[action = "/tasks/LoginTasks/login" ] input[name = "username"]'
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  [OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  $element.sendKeys($username)
  $css_selector = 'form input[name = "password"]'
  $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  setValue -element_ref ([ref]$element) -text $password -selenium_ref ([ref]$selenium)
  $css_selector = 'form span[widgetid = "submitButton"]'
  $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  highlight -element ([ref]$element) -color 'green' -selenium_ref ([ref]$selenium)
  if($debug){
    write-output $element.getAttribute('innerHTML')
  }
  # $element.Click()
  $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()
  <#
  try{
    $css_selector = 'input[type = "submit"]'
    [OpenQA.Selenium.IWebElement]$element2 = $element.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
    $element2.SendKeys([OpenQA.Selenium.Keys]::Enter)
    $element2.Click()
  } catch [Exception] {
    # ignore: "element not interactable"
  }
  #>

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::UrlContains('dashboard'))
}

function user_sign_out {
  param(
    [string]$username = 'admin'
  )
  $css_selector = ( 'div.idxHeaderPrimary a[title = "{0}"]' -f $username )
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  [OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  highlight -element ([ref]$element) -color 'green' -selenium_ref ([ref]$selenium)
  $element.click()
  $css_selector = 'div.dijitPopup.dijitMenuPopup'
  $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  highlight -element ([ref]$element) -color 'green' -selenium_ref ([ref]$selenium)
  $xpath = './/td[contains(@class, "dijitMenuItemLabel")][contains(text(),"Sign Out")]'

  [OpenQA.Selenium.IWebElement]$element2 = $element.FindElements([OpenQA.Selenium.By]::Xpath($xpath))[0]
  highlight -element ([ref]$element2) -color 'green' -selenium_ref ([ref]$selenium)
  $element2.click()
}

function navigate_to_resource_tree() {

  $area = '#main/resources'
  $css_selector = ('a.tab.linkPointer[href = "{0}"] span.tabLabel' -f $area)
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  [OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  highlight -element ([ref]$element) -color 'green' -selenium_ref ([ref]$selenium)
  $element.click()
  
  $css_selector =  '*[id *= "uniqName_"] > div.selectableTable.webextTable.treeTable > table'
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
  [OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  
		if ($debug) {
			write-output ( 'table: ' + $element.getAttribute('innerHTML'))
		}
    <#
		elements = element.findElements(By.cssSelector(
				"tr.noPrint.tableFilterRow input[class *= 'dijitInputInner']"));
		assertThat(elements, notNullValue());
		assertThat(elements.size(), greaterThan(1));
		element = elements.get(0);
		// select group by name
		fastSetText(element, groupName);
		highlight(element);
		element.sendKeys(Keys.ENTER);
		sleep(1000);
		// TODO: improve the selector
		element = wait.until(
				ExpectedConditions.visibilityOf(driver.findElement(By.cssSelector(
						"*[id *= 'uniqName_'] > div.selectableTable.webextTable.treeTable > table"))));
		assertThat(element, notNullValue());
		highlight(element);
		// if (debug) {
		// System.err.println(element.getAttribute("innerHTML"));
		// }
		elements = element.findElements(By.cssSelector(
				"tbody.treeTable-body > tr:nth-of-type(1) > td:nth-of-type(3) div.inlineBlock a[href *= '#resource']"));
		assertThat(elements.size(), is(1));
		element = elements.get(0);
		highlight(element);
		assertThat(element.getText(), is(groupName));
		// if (debug) {
		// System.err.println(element.getAttribute("innerHTML"));
		// }
		element.click();
		element = wait.until(ExpectedConditions.visibilityOf(driver.findElement(
				By.cssSelector("div.masterContainer div.containerLabel"))));
		assertThat(element, notNullValue());
		highlight(element);
		assertThat(element.getText(), is("Subresources"));
    #>
}


# main flow
$selenium.Navigate().GoToUrl($base_url)
# NOTE: slow
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = new-object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(20))
$wait.PollingInterval = 150
[OpenQA.Selenium.Interactions.Actions]$actions = new-object OpenQA.Selenium.Interactions.Actions ($selenium)

login_user -username $username -password $password
user_sign_out -username $username

custom_pause -fullstop $fullstop
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}


