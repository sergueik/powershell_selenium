### Info

This directory contains a replica of [HAP CSS Selector](https://github.com/hcesar/HtmlAgilityPack.CssSelector) HtmlAgilityPak .net library extension project that supports a subset of CssSelector DSL API for DOM manipulation -  the genuine [Html Agility Pack (HAP)](https://github.com/zzzprojects/html-agility-pack) is featuring XPath only. 

The project has been converted to downlevel version __4.5__  of .Net to prevent waterfall of .Net platform upgrade dependencies and switched to Nunit annotations from MSTest to enable development in lightweight [SharpDevelop](http://www.icsharpcode.net/) IDE instead of heavyweight [Visual Studio](https://visualstudio.microsoft.com/) families.
It appears that without switching to the .Net core product line one can not use the [nuget download](https://www.nuget.org/packages/HtmlAgilityPack.CssSelector.Core/) of assembly - no such problem with core [HAP nuget package](https://www.nuget.org/packages/HtmlAgilityPack/).

### Summary
Core Html Agility Pack is HTML parser a with DOM read/write capabilities and own DSL. The HapCss client adds partial support for `CssSelector` API for dealing with HTML.

### See Also:

 * [HAP massive presence](https://html-agility-pack.net/?z=codeplex) 
 * [hap documentation](https://html-agility-pack.net/documentation)
 * [cssSelector on hap top](https://github.com/hcesar/HtmlAgilityPack.CssSelector)
 * Java implementations 
   + [jsoup](https://github.com/jhy/jsoup)
   + [tidy](https://github.com/htacg/tidy-html5)
   + [jtidy](https://github.com/spullara/jtidy)
 * post about HTML parser library [choices](https://tomassetti.me/parsing-html/)
 * [wikipedia](https://en.wikipedia.org/wiki/Comparison_of_HTML_parsers)
### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
