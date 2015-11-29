Protractor for .NET
===================
Heavily modified copy of the [protractor-net](https://github.com/sergueik/protractor-net) project created to temporarily simplify project structure and do some experiments.




Testing
-------

Note: `base_url` of the schema `"file://"` only works with __PhantomJSDriver__. The error varies with the driver:

| __Firefox Driver__          | `System.InvalidOperationException : Access to 'file:///...' from script denied (UnexpectedJavaScriptError)` |
|-----------------------------|-------------------------------------------------------------------------------------------------------------|
| __Chrome Driver__           | `System.Net.WebException Timeout exception`                                                                 |
| __InternetExplorer Driver__ | `System.InvalidOperationException : Page reload detected during async script (UnexpectedJavaScriptError)`   |


For browsers-hosted tests, start a web server locally and point wwwroot to the `bin/Debug` directory of the `Test` project:
then update the code to `base_url = "http://localhost/&lt;page&gt;.html";`


[See also:](https://social.msdn.microsoft.com/Forums/silverlight/en-US/71937b5e-51f1-4d69-8e97-65ca2745b672/access-denied-exception-with-htmlpagewindownavigate-and-ie78)


Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)