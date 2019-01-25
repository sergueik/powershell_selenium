using System;
using System.Linq;
using NUnit.Framework;
using System.IO;

namespace HapCss.UnitTests {
	[TestFixture]
	// original class integrted from upstream (almost)
	public class Original {
		static HtmlAgilityPack.HtmlDocument doc = null;
		
		[TestFixtureSetUp]
		public void SetUp() {
			doc = new HtmlAgilityPack.HtmlDocument();
			String name = "test1.html";
			var asm = typeof(Original).Assembly;
			string resourceName = Path.GetFileNameWithoutExtension(asm.GetLoadedModules()[0].Name) + "." + name;
			Stream stream = asm.GetManifestResourceStream(resourceName);

			doc.LoadHtml(Resource.GetString(name, stream));
		}

		// special test, implemetnation detail
		// NOTE: using id here is not the best example,
		// see e.g. https://www.w3.org/TR/WCAG20-TECHS/H93.html
		// about uniqueness of the id of the Web page DOM
		[Test]
		public void IdSelectorMustReturnOnlyFirstElement() {
			String elementId = "myDiv";
			String cssSelector = String.Format("#{0}", elementId);
			var elements = doc.QuerySelectorAll(cssSelector);
			Assert.IsTrue(elements.Count == 1);
			Assert.IsTrue(elements[0].Id == elementId);
			// identify the DOM node that was found, there are multiple
			Assert.IsTrue(elements[0].Attributes["first"].Value == "1");
		}

		[TestCase("div[id=myDiv]", "myDiv")]
		[TestCase("*[id*=myDiv]", "myDiv")]
		[TestCase("div[id^=myDiv]", "myDiv")]
		[TestCase("body div[id=myDiv]", "myDiv")]
		[TestCase("body > div[id=myDiv]", "myDiv")]
		public void GetElementsByAttribute(String cssSelector, String elementId) {
			var elements = doc.QuerySelectorAll(cssSelector);
			Assert.IsTrue(elements.Distinct().Count() == 2);
			Assert.IsTrue(elements.Count == 2);
			for (int i = 0; i < elements.Count; i++)
				Assert.IsTrue(elements[i].Id == elementId);
		}

		// works
		// [TestCase("div[id='myDiv']", "myDiv")]
		// NOTE: driver still has to be made whitespace tolerant
		// https://developer.mozilla.org/en-US/docs/Web/CSS/Attribute_selectors
		// System.InvalidOperationException : Token inválido: =
		// [TestCase("div[id = 'myDiv']", "myDiv")]
		 [TestCase("div[id = myDiv]", "myDiv")]
		// [ExpectedException( typeof( System.InvalidOperationException ) )]
		// System.NotSupportedException : Uso inválido de seletor por atributo
		public void GetElementsByConditionCss(String cssSelector, String elementId) {
			var elements = doc.QuerySelectorAll(cssSelector);
			Assert.IsTrue(elements.Distinct().Count() == 2);
			Assert.IsTrue(elements.Count == 2);
			for (int i = 0; i < elements.Count; i++)
				Assert.IsTrue(elements[i].Id == elementId);
		}


		// https://developer.mozilla.org/en-US/docs/Web/CSS/:nth-of-type
		// System.NotSupportedException : Pseudo classe não suportada: nth-of-type
		[ExpectedException(typeof(System.NotSupportedException))]
		[Test]
		public void GetElementsByPseudoClass1Css() {
			String cssSelector = "div:nth-of-type(1)";
			String elementId = "myDiv";
			var elements = doc.QuerySelectorAll(cssSelector);
			Assert.IsTrue(elements.Distinct().Count() == 1);
			Assert.IsTrue(elements.Count == 1);
			Assert.IsTrue(elements[0].Id == elementId);
		}

		// https://developer.mozilla.org/en-US/docs/Web/CSS/:nth-child
		[Test]
		[Ignore("Ignore failing test - the locator is not working")]
		public void GetElementsByPseudoClass2Css() {
			String cssSelector = "body:nth-child(1)";
			String elementId = "myDiv";
			var elements = doc.QuerySelectorAll(cssSelector);
			Assert.IsTrue(elements.Distinct().Count() == 1);
			Assert.IsTrue(elements.Count == 1);
			Assert.IsTrue(elements[0].Id == elementId);
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
	}
}
