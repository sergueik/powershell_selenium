using System;
using System.Linq;
using NUnit.Framework;

namespace HapCss.UnitTests {
	[TestFixture]
	public class Html1
	{
		static HtmlAgilityPack.HtmlDocument doc = null;
		
		[TestFixtureSetUp]
		public void SetUp() {
			doc = LoadHtml();
		}

		[Test]
		public void IdSelectorMustReturnOnlyFirstElement() {
			var elements = doc.QuerySelectorAll("#myDiv");

			Assert.IsTrue(elements.Count == 1);
			Assert.IsTrue(elements[0].Id == "myDiv");
			Assert.IsTrue(elements[0].Attributes["first"].Value == "1");
		}

		[Test]
		public void GetElementsByAttribute() {
			var elements = doc.QuerySelectorAll("*[id=myDiv]");

			Assert.IsTrue(elements.Distinct().Count() == 2 && elements.Count == 2);
			for (int i = 0; i < elements.Count; i++)
				Assert.IsTrue(elements[i].Id == "myDiv");
		}

		[Test]
		public void GetElementsByClassName1() {
			var elements1 = doc.QuerySelectorAll(".cls-a");
			var elements2 = doc.QuerySelectorAll(".clsb");

			Assert.IsTrue(elements1.Count == 1);
			for (int i = 0; i < elements1.Count; i++)
				Assert.IsTrue(elements1[i] == elements2[i]);
		}

		[Test]
		public void GetElementsByClassName_MultiClasses() {
			var elements = doc.QuerySelectorAll(".cls-a, .cls-b");

			Assert.IsTrue(elements.Count == 2);
			Assert.IsTrue(elements[0].Id == "spanA");
			Assert.IsTrue(elements[1].Id == "spanB");
		}

		[Test]
		public void GetElementsByClassName_WithUnderscore() {
			var elements = doc.QuerySelectorAll(".underscore_class");

			Assert.IsTrue(elements.Count == 1);
			Assert.IsTrue(elements[0].Id == "spanB");
		}

		private static HtmlAgilityPack.HtmlDocument LoadHtml()
		{
			var doc = new HtmlAgilityPack.HtmlDocument();
			doc.LoadHtml(Resource.GetString("Test1.html"));

			return doc;
		}

	}
}
