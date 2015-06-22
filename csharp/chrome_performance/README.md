Chrome Page Element Performance Collector
=========================================
Collect details of the web navigation from the browser. Stores results in the SQLite database allowing measuring  Page performance at the individual Page element level.

Writing Tests
=============

Include `Program.cs` into your project and merge `nuget.config` with yours. There are two extension methods : `WaitDocumentReadyState` and `Performance` 

Note
====

This code is not browser-agnostic, and is fully functional for Chrome only :  Chrome has `performance.getEntries`, while barebones Firefox only has `performance.timing` - with no further details. For better results with Firefox, one needs to install [Firebug](https://getfirebug.com/releases/) and [netExport](https://getfirebug.com/releases/netexport/) add-ons into the profile the test is run. It is unknown if PhantomJS supports the same - currenty a stub is used .


The following Javascript is run to collect performance results while the page is being loaded:

    (
    window.performance ||
    window.mozPerformance ||
    window.msPerformance ||
    window.webkitPerformance 
    ).getEntries() 
    
The scrupt is invoked when browser reports certain `document.readyState`.


The following headers are selected to go to the database:

 * id
 * url
 * duration 


The [browsermob-proxy](https://github.com/lightbody/browsermob-proxy) offers similar functionality for Java - see e.g. [http://amormoeba.blogspot.com/2014/02/how-to-use-browser-mob-proxy.html][http://amormoeba.blogspot.com/2014/02/how-to-use-browser-mob-proxy.html]


Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
