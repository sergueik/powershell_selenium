### Info

This directory contains a replica of [NSelene - Selenide "from scratch port" to .NET](https://github.com/yashaka/NSelene) of Яков Крамаренко, modified to build with C# 5.0 and Nuget 2.6.4. This allowing development in the [SharpDevelop IDE](http://www.icsharpcode.net/OpenSource/SD/Default.aspx) which is far less resource-aggressive then Visual Studio.

The fork for upstreaam pulls and pull requests is located in [standalone fork of the same repository](https://github.com/sergueik/NSelene).
### Added Features

#### Support for XPath and Text Selector
The kind of selector can be defined through prefix in the argument
```c#
S("css = h1[name='hello']")
S("xpath = /h1[1]")
S("text = Hello")
```

or extra argument, or selector kind detection method (work in progress)

In the absence of the prefix the css Selector kind is used, for backward compatilility.


#### Validating CSS Selectors

The project [cssSelector to XPath convertor (java)](https://github.com/sam-rosenthal/java-cssSelector-to-xpath)
is already implemented lexer for cssSelector grammar.

The [`CssSelectorStringSplitter.java`](https://github.com/sam-rosenthal/java-cssSelector-to-xpath/blob/master/src/main/java/org/sam/rosenthal/cssselectortoxpath/utilities/CssSelectorStringSplitter.java)
class defines `ELEMENT_AND_ATTRIBUTE_FOLLOWED_BY_COMBINATOR_AND_REST_OF_LINE` regexp grammar that can be fed into core java regexp Pattern class which will then 
capture head selector + optional attribute token and the rest (tail) of the valid `cssSelector` string:
```java
ELEMENT_AND_ATTRIBUTE_FOLLOWED_BY_COMBINATOR_AND_REST_OF_LINE: ^([^ ~+>\[]*(\[[^\]]+\])*)($|(\s*([ ~+>])\s*([^ ~+>].*)$))
```
The [`CssElementAttributeParser.java`](https://github.com/sam-rosenthal/java-cssSelector-to-xpath/blob/master/src/main/java/org/sam/rosenthal/cssselectortoxpath/utilities/CssElementAttributeParser.java)
class defines `CSS_ATTRIBUTE PATTERN` grammar that can be fed into core java regexp Pattern class which will then 
allow separating element an its attribute for one token. 
```java
CSS_ATTRIBUTE PATTERN: ^((-?[_a-zA-Z]+[_a-zA-Z0-9-]*)|([*]))?((:[a-z][a-z\-]*([(][^)]+[)])?)|(\[\s*(-?[_a-zA-Z]+[_a-zA-Z0-9-]*)\s*((\=)|(\~=)|(\|=)|(\^=)|(\$=)|(\*=))?\s*(((["'])([-_.#a-zA-Z0-9:\/ ]+)(["']))|(([-_.#a-zA-Z0-9:\/]+)))?\s*\]))*$
```
For our purpose it is sufficient to confirm that the expression satisfies both grammars, probably simplify them further too.
Also Morover one can construct similar lexer grammar fragments for a valid DOM locator xpath expression (this is work in progress).

### See Also

   * [cssSelector to XPath convertor (java)](https://github.com/sam-rosenthal/java-cssSelector-to-xpath)

### Limitations
In this version of the project temporarily dropped support for [using "static" feature of c# 6.0](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/using-static)

### See Also

  * [selenide article](http://qa7.ru/blog/2016/08/15/selenide-post/)
  * [selenide article (in Russian)](https://habr.com/company/jugru/blog/416757/)
  * [selenide presentation](https://docs.google.com/presentation/d/1kuzqR8JGnVKIs2r0Bm83LdOfbZkSkoR93f1c8wd26ns/edit?usp=sharing)


### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
