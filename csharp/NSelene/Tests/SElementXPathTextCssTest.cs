using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text.RegularExpressions;

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
			// Given.RunFromAssemblyLocation = true;  
			// the above would create a flash "Your file was not found"
			Given.OpenedPageWithBody("<h1 name=\"hello\">Hello Babe!</h1>");
			Selene.S(With.Css("h1[name=\"hello\"]")).Should(Have.Attribute("name", "hello"));
			Selene.S(With.Css("h1:nth-of-type(1)")).Should(Have.Text("Hello"));
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
			Selene.S(With.XPath("//h1")).ShouldNot(Have.Text("Hello world!"));
			Selene.S(With.XPath("/h1[1]")).ShouldNot(Have.Text("Hello world!"));
			IWebDriver driver = Selene.GetWebDriver();
			IWebElement element = driver.FindElement(By.XPath("//h1[1]"));
			StringAssert.AreEqualIgnoringCase("h1" , element.TagName);
		}

		[Test]
		public void SElementLocalizedTextSearch() {
			String name = "абвгдежзийклмнопрстуфхцчшщъыьэюя";
			Given.OpenedPageWithBody(String.Format("<h1>Hello {0}!</h1>", name));
			Selene.S(With.Text(name)).Should(Have.Text(String.Format("Hello {0}!", name)));
			IWebDriver driver = Selene.GetWebDriver();
			IWebElement element = driver.FindElement(By.XPath(String.Format("//h1[contains(text(), '{0}')]", name)));			
			StringAssert.AreEqualIgnoringCase("h1" , element.TagName);
			Selene.S(With.XPath(String.Format("//h1[contains(text(), '{0}')]", name))).Should(Have.Text(String.Format("Hello {0}!", name)));
		}


		[Test]
		public void YandexTextSearch() {
			String emptySearchResponse = "Задан пустой поисковый запрос";
			Selene.GoToUrl("https://yandex.ru/search");
			Selene.S(With.Text(emptySearchResponse)).Should(Have.Text(emptySearchResponse));
		}

		[Test]
		public void MultilineTextSearch()
		{
			String url = "http://www.rfbr.ru/rffi/ru/";
			String cssSelector = "div.grants > p";
			// note one space short
			String searchString = "Информация для заявителей и исполнителей проектов";
			// note one space short
			searchString = "Информация для заявителейи исполнителей проектов";
			// The text of the element has a <br/> and a newline 
			// making it difficult to impossible to write the matching expression
			Selene.GoToUrl(url);
			// NOTE: the exception is confirmed but not in a "junit" way
			try{
				// Selene.S(With.Text(searchString)).Should(Be.InDom);
				Selene.S(String.Format("text={0}", searchString.Replace("\n","").Replace("\r","")), Selene.GetWebDriver()).Should(Be.InDom);
				// Selene.S(With.Text(searchString)).Should(Have.Text(searchString));
			} catch (TimeoutException e) {
				Console.Error.WriteLine("Exception (ignored) " + e.ToString());
			} catch (NoSuchElementException e) {
				Console.Error.WriteLine("Exception (ignored) " + e.ToString());
			}   

			// Break down the element text into single line chunks, successfully find each
			string elementText = (Selene.GetWebDriver()).FindElement(By.CssSelector(cssSelector)).Text;
			elementText = Selene.S(With.Css(cssSelector)).Text;

			foreach (String line in elementText.Split('\n')) {
				searchString = line.Replace("\r", "");
				Console.Error.WriteLine("Searching by inner Text fragment:" + searchString);
				Selene.S(With.Text(searchString)).Should(Be.InDom);
				Selene.S(With.Text(searchString)).Should(Have.Text(searchString));            
			}
		}
		
		[Test]
		public void ElementTextSearch() {
			Given.OpenedPageWithBody("<h1>Hello World!</h1>");
			IWebDriver webDriver = Selene.GetWebDriver();
			Selene.S(NSelene.With.Text("Hello")).ShouldNot(Have.ExactText("Hello"));
			Selene.S(NSelene.With.Text("world!"), webDriver).ShouldNot(Have.ExactText("Hello"));
			// up casting back to SeleneDriver will be a wrong move:
			// it will internally switch back to cssSelector
			// SeleneElement element = (new SeleneDriver(Selene.GetWebDriver())).Find(By.XPath("//*[contains(text(),\"Hello World\")]"));
			IWebElement element = webDriver.FindElement(By.XPath("//*[contains(text(), 'Hello World')]"));
			StringAssert.Contains("Hello World!" , element.Text);
			Selene.S(NSelene.With.ExactText(element.Text), webDriver).Should(Have.ExactText(element.Text));
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
			By seleneLocator = NSelene.With.Text("Dear");
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
			By seleneLocator = With.XPath(xpath);
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
			By seleneLocator = With.XPath( xpath);
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
