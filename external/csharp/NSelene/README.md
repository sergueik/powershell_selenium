### Info

This directory contains a replica of [NSelene - Selenide "from scratch port" to .NET](https://github.com/yashaka/NSelene), modified to build with C# 5.0 and Nuget 2.6.4. This allowing development in the [SharpDevelop IDE](http://www.icsharpcode.net/OpenSource/SD/Default.aspx) which is far less resource-aggressive then Visual Studio.

The fork for upstreaam pulls and pull requests is located in [standalone fork of the same repository](https://github.com/sergueik/NSelene).
### Added Features

#### Support for XPath and Text Selector
The kind of selector can be defined through prefix in the argument
```c#
S("css = h1[name='hello']")
S("xpath = /h1[1]")
S("text = Hello")
```

or extra argument (work in progress)

In the absence of the prefix the css Selector kind is used,for backward compatilility.

### Limitations
In this version of the project temporarily dropped support for [using "static" feature of c# 6.0](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/using-static)

### See Also

  * [selenide article](http://qa7.ru/blog/2016/08/15/selenide-post/)
  * [selenide article (in Russian)](https://habr.com/company/jugru/blog/416757/)
  * [selenide presentation](https://docs.google.com/presentation/d/1kuzqR8JGnVKIs2r0Bm83LdOfbZkSkoR93f1c8wd26ns/edit?usp=sharing)


# // Разрабатывает NSelene Яков Крамаренко.  

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
