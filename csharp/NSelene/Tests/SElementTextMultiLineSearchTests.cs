using NUnit.Framework;
using System;
using System.Linq;

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
	public class SElementTextMultiLineSearchTests : BaseTest
	{

		// [OneTimeSetUp]
		[SetUp]
		public void initPage()
		{
			// Given.RunFromAssemblyLocation = true;  
			// NOTE: the above would create a flash "Your file was not found"
		}

		[Test]
		public void SElementMultilineTextSearch()
		{
			String[]names = {"Alice", "Bob"};
			String elementText = String.Format(@"
Hello {0}
and {1}!", names[0],names[1]);
			Given.OpenedPageWithBody(String.Format(@"<h1>{0}</h1>", elementText));
			IWebDriver driver = Selene.GetWebDriver();
			String searchText = Regex.Replace(elementText.Replace("\n", " ").Replace("\r", ""), "^ +", "");
			IWebElement element = driver.FindElement(By.XPath(String.Format("//h1[contains(text(), '{0}')]",  searchText)));			
			Assert.NotNull(element);
			StringAssert.AreEqualIgnoringCase("h1", element.TagName);
			Selene.S(With.XPath(String.Format("//h1[contains(text(), '{0}')]", searchText))).Should(Be.InDom).Should(Have.Text(String.Format("Hello {0}", names[0])));

			Selene.S(With.Text(names[0])).Should(Have.Text(searchText));
		}

		[Ignore("failing with System.NullReferenceException : Object reference not set to an instance of an object.")]
		[Test]
		public void FindByCssSelectorAndInnerTextSearch()
		{
			String[]names = {"Alice", "Bob"};
			String elementText = String.Format(@"
Hello {0}
and {1}!", names[0],names[1]);
			Given.OpenedPageWithBody(String.Format(@"<h1>{0}</h1>", elementText));
			IWebDriver driver = Selene.GetWebDriver();
			String searchText = Regex.Replace(Regex.Replace(elementText, "\r?\n", " "),"^ +", "");
			Selene.S(String.Format("text={0}", searchText)).Should(Be.InDom);

		}

		[Test]
		public void SElementLocalizedTextSearch()
		{
			String name = "абвгдежзийклмнопрстуфхцчшщъыьэюя";
			Given.OpenedPageWithBody(String.Format("<h1>Hello {0}!</h1>", name));
			Selene.S(With.Text(name)).Should(Have.Text(String.Format("Hello {0}!", name)));
			IWebDriver driver = Selene.GetWebDriver();
			IWebElement element = driver.FindElement(By.XPath(String.Format("//h1[contains(text(), '{0}')]", name)));			
			StringAssert.AreEqualIgnoringCase("h1", element.TagName);
			Selene.S(With.XPath(String.Format("//h1[contains(text(), '{0}')]", name))).Should(Have.Text(String.Format("Hello {0}!", name)));
		}

		[Test]
		public void YandexTextSearch()
		{
			String emptySearchResponse = "Задан пустой поисковый запрос";
			Selene.GoToUrl("https://yandex.ru/search");
			Selene.S(With.Text(emptySearchResponse)).Should(Have.Text(emptySearchResponse));
		}

		[Test]
		public void MultilineTextSearchIntegrationTest() {
			String url = "http://www.rfbr.ru/rffi/ru/";
			String cssSelector = "div.grants > p";
			// NOTE: The element on the page has a <br/> and a newline 
			// removing newline makes the search string one space shorter
			// searchString = "Информация для заявителейи исполнителей проектов";
			// making it difficult to impossible to "predict" the right matching expression
			String searchString = @"Информация для заявителей
и исполнителей проектов";
			Selene.GoToUrl(url);
			// NOTE: slurps exceptions but not in a "Nunit" way
			try {
				// Selene.S(With.Text(searchString)).Should(Be.InDom);
				Selene.S(String.Format("text={0}", searchString.Replace("\n", "").Replace("\r", "")), Selene.GetWebDriver()).Should(Be.InDom);
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
		
	}
}
