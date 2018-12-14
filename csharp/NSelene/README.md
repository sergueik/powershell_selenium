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
For our purpose it is sufficient to confirm that the expression satisfies both grammars, probably simplify them further too:
The following [example](https://github.com/sergueik/selenium_tests/blob/master/src/test/java/com/github/sergueik/selenium/CssValidatorTest.java) is in Java, but  comverison is simple, as it only uses
```java
	@Test(enabled = true)
	public void cssSelectorComprehensiveTokenTest() {
    String cssSelectorString = "body > h1[name='hello'] h2:nth-of-type(1)";
		// String tokenTest = cssValidator.getTokenTest();
    // modified: the original implementation appears broken
		String  tokenTest = "^([^ ~+>\\[]*(?:\\[[^\\]]+\\])*)(?:\\s*[ ~+>]\\s*([^ ~+>\\[].*))*$";
		System.err.println(tokenTest);
		Pattern pattern = Pattern.compile(tokenTest);
		Matcher match = pattern.matcher(cssSelectorString);

		boolean found_token = true;
		boolean found_tail = true;
		List<String> tokenBuffer = new ArrayList<>();
		List<String> tailBuffer = new ArrayList<>();
		int cnt = 0;
		while (match.find() && found_token && found_tail && cnt < 100) {

			if (match.group(1) == null || match.group(1) == "") {
				found_token = false;
			}
			if (match.group(2) == null || match.group(2) == "") {
				found_tail = false;
			}
			if (found_token) {
				tokenBuffer.add(match.group(1));
				System.err
						.println(String.format("Token = \"%s\"", tokenBuffer.get(cnt)));
			}
			if (found_tail) {
				tailBuffer.add(match.group(2));
				System.err.println("Tail = " + tailBuffer.get(cnt));
				match = pattern.matcher(match.group(2));
			}
			cnt++;
		}
    // String attributeTest = cssValidator.getAttributeTest();
   // unmodified. optimization is likely possible
   String attributeTest = "^((-?[_a-zA-Z]+[_a-zA-Z0-9-]*)|([*]))?((:[a-z][a-z\\-]*([(][^)]+[)])?)|(\\[\\s*(-?[_a-zA-Z]+[_a-zA-Z0-9-]*)\\s*((\\=)|(\\~=)|(\\|=)|(\\^=)|(\\$=)|(\\*=))?\\s*(((["'])([-_.#a-zA-Z0-9:\\/ ]+)(["']))|(([-_.#a-zA-Z0-9:\\/]+)))?\\s*\\]))*$";
		for (String cssSelectorTokenString : tokenBuffer) {
			assertTrue(
					cssSelectorTokenString.matches(attributeTest));
		}
}
```

### Limitations
In this version of the project temporarily dropped support for [using "static" feature of c# 6.0](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/using-static)

### See Also

    * [selenide article](http://qa7.ru/blog/2016/08/15/selenide-post/)
    * [selenide article (in Russian)](https://habr.com/company/jugru/blog/416757/)
    * [selenide presentation](https://docs.google.com/presentation/d/1kuzqR8JGnVKIs2r0Bm83LdOfbZkSkoR93f1c8wd26ns/edit?usp=sharing)
    * [cssSelector to XPath convertor](https://github.com/sam-rosenthal/java-cssSelector-to-xpath), java, grammar based - can be used for quick assertion of a valid cssSelectors
    * [XPath parser, C#](https://github.com/quamotion/XPathParser) , does not seem to be grammar based, but can be simly add to package.config and used for quick assertion of a valid XPaths

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
