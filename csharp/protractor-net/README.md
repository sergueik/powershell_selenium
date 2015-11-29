Protractor for .NET
===================
Heavily modified copy of the [protractor-net](https://github.com/sergueik/protractor-net) project created to temporarily simplify project structure and do some experiments.




Testing
-------
Local Angular files placed under `Samples` directory and copied into output directory of the `Test` project.
Note:
```
base_url = new System.Uri(Path.Combine( Directory.GetCurrentDirectory(), testpage)).AbsoluteUri;
ngDriver.Navigate().GoToUrl(base_url);

```
only works with __PhantomJSDriver__ - error varies with the driver:

| __Firefox Driver__          | `System.InvalidOperationException : Access to 'file:///...' from script denied (UnexpectedJavaScriptError)` |
|-----------------------------|-------------------------------------------------------------------------------------------------------------|
| __Chrome Driver__           | `System.Net.WebException Timeout exception`                                                                 |
| __InternetExplorer\ Driver__ | `System.InvalidOperationException : Page reload detected during async script (UnexpectedJavaScriptError)`  |


For browsers-hosted tests, start a web server locally and point web root to the `bin/Debug` directory of the `Test` project:
then update the code to  use `base_url = String.Format("http://localhost/{0}", testpage);`


Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)