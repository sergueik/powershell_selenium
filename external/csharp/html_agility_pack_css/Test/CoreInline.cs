using System;
using System.Linq;
using NUnit.Framework;
using HtmlAgilityPack;


// exercises https://html-agility-pack.net/selectors
namespace HapCss.UnitTests
{
	[TestFixture]
	public class CoreInline
	{
		static HtmlAgilityPack.HtmlDocument doc = null;
		
		[TestFixtureSetUp]
		public void SetUp()
		{
			doc = new HtmlAgilityPack.HtmlDocument();
			doc.LoadHtml(Resource.GetString(@"<?xml version=""1.0""?>
<!DOCTYPE html>
<html xmlns=""http://www.w3.org/1999/xhtml"" lang=""en"">
  <head>
    <meta charset=""utf-8""/>
    <title/>
  </head>
  <body>
    <div id=""myDiv"" first=""1"">
      <span id=""spanA"" class=""cls-a clsb"">SPAN1</span>
    </div>
    <div id=""myDiv"">
      <p>P1</p>
    </div>
    <div>
      <span>s</span>
      <span id=""spanB"" class=""cls-b c2 underscore_class"">
        <p class=""cls"">P2</p>
      </span>
      <span class=""cls c3"">
        <p class=""cls"">P3</p>
      </span>
    </div>
  </body>
</html>
"));
		}
		
		[Test]
		public void CoreSelectSingleNodeStronglyTypedAssertTest()
		{
			var body = doc.DocumentNode.SelectSingleNode("//body");
			Assert.NotNull(body);
			Assert.IsInstanceOf(typeof(HtmlAgilityPack.HtmlNode), body, "Expecyt strongly typer response");
			Assert.NotNull(body.OuterHtml);
		}
		
		[TestCase("//div/span/p", "class")]
		public void CoreSelectXpathTest(String xpath, string attributeNAme)
		{
			var data = doc.DocumentNode.SelectSingleNode(xpath).Attributes[attributeNAme].Value;
			Assert.NotNull(data);
			// Assert.IsInstanceOf(typeof( HtmlAgilityPack.HtmlNode), body, "Expecyt strongly typer response");
			// Assert.NotNull(body.OuterHtml);
		}
	
		[TestCase("div[id=myDiv]", "myDiv")]
		[TestCase("*[id*=myDiv]", "myDiv")]
		[TestCase("div[id^=myDiv]", "myDiv")]
		[TestCase("body div[id=myDiv]", "myDiv")]
		[TestCase("body > div[id=myDiv]", "myDiv")]
		public void GetElementsByAttribute(String cssSelector, String elementId)
		{
			var elements = doc.QuerySelectorAll(cssSelector);
			Assert.IsTrue(elements.Distinct().Count() == 2);
			Assert.IsTrue(elements.Count == 2);
			for (int i = 0; i < elements.Count; i++)
				Assert.IsTrue(elements[i].Id == elementId);
		}
	}
}
