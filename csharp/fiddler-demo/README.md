Fiddler Core Page Performance Collector
=======================================
Collect details of the web navigation. 

by 
Establishing the proxy for the duration of the execution of the test with the help of [FiddlerCore API](http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0CCoQFjAAahUKEwjAjsXr44XGAhUCz4AKHa-LAKA&url=http%3A%2F%2Fwww.telerik.com%2Ffiddler%2Ffiddlercore&ei=IYV4VYD6OYKegwSvl4KACg&usg=AFQjCNFytjHPn-EXeXR3Vr-LT-syJw-huw&bvm=bv.95277229,d.eXY) .

Stores selected headers 

 * id
 * url
 * referer
 * duration 
 * status   

in the SQLite database allowing measuring  Page performance at the individual Page element level.

Writing Tests
=============
Include `Program.cs` into your project and merge `nuget.config` with yours.  


Note
====
A replica of [SQLite Helper (C#) project sources](http://sh.codeplex.com) is included as the `SQLite.Utils` namespace.

Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
