Protractor for .NET
===================
This is a fork of [protractor-net](https://github.com/bbaia/protractor-net) project with slightly more complete and up-to-date Javascript code (PR pending).

Example
-------

![Screen Recording](https://github.com/sergueik/powershell_selenium/blob/master/csharp/protractor-net/Screenshots/3.gif?)

```
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


Note
----
Local Angular files may be placed under `Samples` directory and copied into output directory of the `Test`
```
base_url = new System.Uri(Path.Combine( Directory.GetCurrentDirectory(), testpage)).AbsoluteUri;
ngDriver.Navigate().GoToUrl(base_url);

```
However, local files work only  with __PhantomJSDriver__ - error varies with the browser:

| __Firefox Driver__          | `System.InvalidOperationException` : Access to 'file:///...' from script |
| __Chrome Driver__           | `System.Net.WebException` Timeout exception                              |
| __InternetExplorer Driver__ | `System.InvalidOperationException` : Page reload detected                |


For desktop browser-hosted tests, start a web server locally and point web root to the `bin/Debug` directory of the `Test` project:
then update the code to  use `base_url = String.Format("http://localhost/{0}", testpage);`


Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)

Screen Recording converted to gif via [convert-to-gif](http://image.online-convert.com/convert-to-gif)



