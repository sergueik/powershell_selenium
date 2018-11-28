## Protractor for .NET
### Info

This directory contains a fork of [protractor-net](https://github.com/bbaia/protractor-net) project with slightly more complete and up-to-date Javascript code (PR pending) and significant number of tests exploring various typical scenaios.

### Example
![Screen Recording](https://github.com/sergueik/powershell_selenium/blob/master/csharp/protractor-net/Screenshots/3.gif?)

```  csharp
IWebDriver driver = new FirefoxDriver();
NgWebDriver ngDriver = new NgWebDriver(driver);
String base_url = "http://juliemr.github.io/protractor-demo/";

ngDriver.Navigate().GoToUrl(base_url);

StringAssert.AreEqualIgnoringCase(ngDriver.Title, "Super Calculator");
var ng_first_operand = ngDriver.FindElement(NgBy.Model("first"));
ng_first_operand.SendKeys("8");

NgWebElement ng_second_operand = ngDriver.FindElement(NgBy.Input("second"));
ng_second_operand.SendKeys("5");

IWebElement math_operator_element = ngDriver.FindElement(NgBy.SelectedOption("operator"));
Assert.AreEqual(math_operator_element.Text, "+");

ReadOnlyCollection<NgWebElement> ng_math_operators = ngDriver.FindElements(NgBy.Options("value for (key, value) in operators"));
NgWebElement ng_substract_math_operator = ng_math_operators.First(op => op.Text.Equals("-", StringComparison.Ordinal));
Assert.IsNotNull(ng_substract_math_operator);
ng_substract_math_operator.Click();

NgWebElement result_element = ngDriver.FindElement(NgBy.Binding("latest"));
Assert.AreEqual("3", result_element.Text);
highlight(result_element.WrappedElement);
```

### Note
Local Angular files may be placed under `Samples` directory and copied into output directory of the `Test`
``` csharp
base_url = new System.Uri(Path.Combine( Directory.GetCurrentDirectory(), testpage)).AbsoluteUri;
ngDriver.Navigate().GoToUrl(base_url);
```
However, local files work only  with __PhantomJSDriver__ - error varies with the browser:

| __Firefox Driver__          | `System.InvalidOperationException` : Access to 'file:///...' from script |
| __Chrome Driver__           | `System.Net.WebException` Timeout exception                              |
| __InternetExplorer Driver__ | `System.InvalidOperationException` : Page reload detected                |


For desktop browser-hosted tests, start a web server locally and point web root to the `bin/Debug` directory of the `Test` project:
then update the code to  use `base_url = String.Format("http://localhost/{0}", testpage);`


### PhantomJS vs. Chrome or Firefox in Headless mode

The significant subset of Protractor.net test suite has been designed around static files accessed via `file:///` 
with basically one Angular feature per page. 
This seemed reasonable: no server behavior was examined by any of the 
Protractor / Angular tests, all action took place in the browser.

This shortcut never worked with real browsers, regardless they are visible or headless.

Starting with version __3.14__  Selenium asseblies for .net sease to have PhantomJS support, therefore the *localfile tests* 
are currently failing.

After a very noticeable delay every local file test fails with an exception
```cmd
OpenQA.Selenium.WebDriverException : The HTTP request to the remote WebDriver server 
for URL http://localhost:65087/session/721da078cad526a4acfa0a762a7b45d9/execute_async timed out after 60 seconds.
  ----> System.Net.WebException : The request was aborted: The operation has timed out.
```
It was originally onsidered somewhat too much overhead to host the web server in .net application just to host those static pages, compared to Java where it is more than somewhat easier, yet was avoided while it could be. 
One possible workaround is to host a [tiny http-only one shot web server](https://gist.github.com/aksakalli/9191056) 
in each test setup.
The minimal approach is frequently taken in Powershell for HTML parsing testing needs, 
e.g. [simple web server in PowerShell ](https://4sysops.com/archives/building-a-web-server-with-powershell/)
 or [creating PowerShell Web Server](https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/creating-powershell-web-server).


### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
Screen Recording converted to gif via [convert-to-gif](http://image.online-convert.com/convert-to-gif)
