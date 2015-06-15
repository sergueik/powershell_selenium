SplunkClient
===============

Console app that cloned from the [example](http://dev.splunk.com/view/csharp-sdk/SP-CAAAEXR) demostrates logging to Splunk.  It can be tested against [Splunk Light](http://docs.splunk.com/Documentation/SplunkLight).

Note
====

Building example
----------------

The Splunk Client SDK 2.x appears to be available through Nuget only compiled to [Windows Phone 8.1 assembly](http://dev.splunk.com/view/csharp-sdk-pcl/SP-CAAAEYN#packman) for .Net 4.5.1.

The alternative is to compile Splunk Client SDK  from source for Net 4.5 and use the locally build assembly to run examples. This may eventually allow one to have Spunk Client in plain Powershell examples.


To avoid forking the full Splunk Client repo, one have to get the original zip and apply a patch to various csproj files. The patch:

   * Downgrades from MS Build 2013 to MS Build 2010
   * Downgrades from .Net 4.5.1 to .Net 4.5
   * Uncomments the implementaion of to avoid [An assembly (probably "<my project>") must be rewritten using the code contracts binary rewriter...](http://stackoverflow.com/questions/24729398/code-contracts-support-in-visual-studio-express-2013) runtime error.


