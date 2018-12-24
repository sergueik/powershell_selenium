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
			// base.initDriver();
			// Given.RunFromAssemblyLocation = true;  
			// NOTE: the above would create a flash "Your file was not found"
			Given.OpenedPageWithBody(@"
                       <h1 name=""header"">Hello Header!</h1>
                         <ul>Hello to:
                                      <li>Dear Bob</li>
                                      <li>Dear Frank</li>
                                      <li>Lovely Kate</li>
                          </ul>");
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
