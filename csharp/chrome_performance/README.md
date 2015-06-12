Chrome Page Element Performance Collector
=========================================

Collect details of the web navigation. 

by 
running the Javascript to  collect

    (
    window.performance ||
    window.mozPerformance ||
    window.msPerformance ||
    window.webkitPerformance 
    ).getEntries() 
    
    
while the page is being loaded.

Stores selected headers 

 * id
 * url
 * duration 

in the SQLite database allowing measuring  Page performance at the individual Page element level.


Writing Tests
=============

Include `Program.cs` into your project and merge `nuget.config` with yours. There are two extension methods : `WaitDocumentReadyState` and `Performance` 

Note
====

This code is highly browser-specific:  Chrome has `performance.getEntries`, while Firefox only has `performance.timing` 
and  PhantomJS does not seem to have anything

Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
