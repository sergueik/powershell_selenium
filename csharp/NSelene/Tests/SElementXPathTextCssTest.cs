using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;


using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;


// using static NSelene.Selene;
// Need 4.6
using NSelene;

namespace NSeleneTests
{
	[TestFixture]
	public class SElementXPathTextCssTest : BaseTest {

		[Test]
		public void SElementAlternativeCssSearch() {
			Given.OpenedPageWithBody("<h1 name=\"hello\">Hello Babe!</h1>");
			Selene.S("css = h1[name=\"hello\"]").Should(Have.Attribute("name", "hello"));
			Selene.S("h1:nth-of-type(1)").Should(Have.Text("Hello"));
			// access directly
			// NOTE: will look like pass
			// SeleneElement element = (new SeleneDriver(Selene.GetWebDriver())).Find(By.CssSelector("h1:nth-of-type(1)"));
			// element.GetCssValue("name");
			IWebElement element = Selene.GetWebDriver().FindElement(By.CssSelector("h1:nth-of-type(1)"));
			StringAssert.IsMatch("hello", element.GetAttribute("name"));
		}


		[Test]
		public void SElementXpathSearch() {
			Given.OpenedPageWithBody("<h1>Hello Babe!</h1>");
			Selene.S("xpath = //h1").ShouldNot(Have.Text("Hello world!"));
			Selene.S("xpath = /h1[1]").ShouldNot(Have.Text("Hello world!"));
			IWebDriver driver = Selene.GetWebDriver();
			IWebElement element = driver.FindElement(By.XPath("//h1[1]"));
			// Console.Error.WriteLine();
			StringAssert.AreEqualIgnoringCase("h1" , element.TagName);
		}

		[Test]
		public void SElementTextSearch() {
			Given.OpenedPageWithBody("<h1>Hello World!</h1>");
			IWebDriver webDriver = Selene.GetWebDriver();
			Selene.S("text = Hello").ShouldNot(Have.ExactText("Hello"));
			Selene.S("text = world!", webDriver).ShouldNot(Have.ExactText("Hello"));
			// up casting back to SeleneDriver will be a wrong move:
			// it will internally switch back to cssSelector
			// SeleneElement element = (new SeleneDriver(Selene.GetWebDriver())).Find(By.XPath("//*[contains(text(),\"Hello World\")]"));
			IWebElement element = webDriver.FindElement(By.XPath("//*[contains(text(), 'Hello World')]"));
			StringAssert.Contains("Hello World!" , element.Text);
			// Console.Error.WriteLine(element.Text);
			// NSelene.Selene no longer has a definiton for \"I\"
			// Selene.I.Find(By.XPath("//*[contains(text(),\"Hello World\")]"));
			element = webDriver.FindElement(By.XPath("//*[contains(text(), \"Hello World\")]"));
			StringAssert.Contains("Hello World!" , element.Text);
		}

		[Test]
        public void SeleneCollectionsShouldWorkWithText() {
            Given.OpenedPageWithBody("<ul>Hello to:<li>Dear Bob</li><li>Dear Frank</li><li>Lovely Kate</li></ul>");
            // Begin with bare bones Selenium WebDriver and assert XPath is valid
			ReadOnlyCollection<IWebElement> webElements = Selene.GetWebDriver().FindElements(By.XPath("//*[contains(text(),\"Dear\")]"));
			Assert.NotNull(webElements);
			Assert.Greater(webElements.Count,0);
			StringAssert.Contains("Dear" , webElements[0].Text);
			// inspect the underlying collection -
			// not commonly done in the test
			String seleneLocator = "text = Dear";
			IWebDriver webDriver = Selene.GetWebDriver();
			SeleneCollection seleWebElements = Selene.SS(seleneLocator, webDriver);
            Assert.NotNull(seleWebElements);
			Assert.Greater(seleWebElements.Count,0);
			StringAssert.Contains("Dear" , seleWebElements[0].Text);

			// exercise NSelene extension methods
            Selene.SS(seleneLocator).Should(Have.CountAtLeast(1));
            Selene.SS(seleneLocator).Should(Have.Texts("Bob", "Frank"));
            Selene.SS(seleneLocator).ShouldNot(Have.Texts("Bob"));
            Selene.SS(seleneLocator).ShouldNot(Have.Texts("Bob", "Kate", "Frank"));
	        Selene.SS(seleneLocator).Should(Have.ExactTexts("Dear Bob", "Dear Frank"));
        }

		[Test]
        public void SeleneCollectionsShouldWorkWithXPath() {
            Given.OpenedPageWithBody("<ul>Hello to:<li>Dear Bob</li><li>Dear Frank</li><li>Lovely Kate</li></ul>");
            String xpath = "//ul/li";
			// Begin with bare bones Selenium WebDriver and assert XPath is valid
			ReadOnlyCollection<IWebElement> webElements = Selene.GetWebDriver().FindElements(By.XPath(xpath));
			Assert.NotNull(webElements);
			Assert.Greater(webElements.Count,0);
			StringAssert.IsMatch("li" , webElements[0].TagName);
			// check the underlying collection - commonly not sent to the test
			SeleneCollection seleWebElements = null;
			String seleneLocator = String.Format("xpath = {0}", xpath);
			seleWebElements = Selene.SS(seleneLocator);
            Assert.NotNull(seleWebElements);
			Assert.Greater(seleWebElements.Count,0);
			StringAssert.IsMatch("li" , seleWebElements[0].TagName);
            // exercise NSelene extension methods
	        Selene.SS(seleneLocator).Should(Have.ExactTexts("Dear Bob", "Dear Frank", "Lovely Kate"));
            Selene.SS(seleneLocator).Should(Have.CountAtLeast(1));
        }

		[Test]
        public void SeleneCollectionsWebDriverCallShouldHandleXPath() {
            Given.OpenedPageWithBody("<ul>Hello to:<li>Dear Bob</li><li>Dear Frank</li><li>Lovely Kate</li></ul>");
            IWebDriver webDriver = Selene.GetWebDriver();
            String xpath = "//ul/li";
			// Begin with bare bones Selenium WebDriver and assert XPath is valid
			ReadOnlyCollection<IWebElement> webElements = webDriver.FindElements(By.XPath(xpath));
			Assert.NotNull(webElements);
			Assert.Greater(webElements.Count,0);
			StringAssert.IsMatch("li" , webElements[0].TagName);
			// check the underlying collection - commonly not sent to the test
			SeleneCollection seleWebElements = null;
			String seleneLocator = String.Format("xpath = {0}", xpath);
			seleWebElements = Selene.SS(seleneLocator, webDriver);
            Assert.NotNull(seleWebElements);
			Assert.Greater(seleWebElements.Count,0);
			StringAssert.IsMatch("li" , seleWebElements[0].TagName);
            // exercise NSelene extension methods
	        Selene.SS(seleneLocator, webDriver).Should(Have.ExactTexts("Dear Bob", "Dear Frank", "Lovely Kate"));
            Selene.SS(seleneLocator, webDriver).Should(Have.CountAtLeast(1));
        }

	}
}
