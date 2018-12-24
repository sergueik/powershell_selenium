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
	public class SElementSearchUsingWithTests : BaseTest
	{

		// [OneTimeSetUp]
		[SetUp]
		public void initPage()
		{
			// base.initDriver();
			// Given.RunFromAssemblyLocation = true;  
			// NOTE: the above would create a flash "Your file was not found"
			Given.OpenedPageWithBody(@"
                       <h1 name=""greeting"">Hello there!</h1>
                         <ul>Hello to:
                                      <li>Dear Bob</li>
                                      <li>Dear Frank</li>
                                      <li>Lovely Kate</li>
                          </ul>");
		}

		[Test]
		public void SElementSearchWithCss()
		{
			// search using wrapped driver methods
			String cssSelector = @"h1[name = ""greeting""]";
			IWebDriver driver = Selene.GetWebDriver();
			IWebElement element = driver.FindElement(By.CssSelector(cssSelector));
			StringAssert.IsMatch("greeting", element.GetAttribute("name"));

			// search using NSelene methods	
			Selene.S(With.Css(cssSelector), driver).Should(Be.InDom);
			Selene.S(With.Css(cssSelector)).Should(Have.Attribute("name", element.GetAttribute("name")));

			// compare old style and new style search results
			StringAssert.IsMatch(Selene.S(cssSelector).GetAttribute("outerHTML"), Selene.S(With.Css(cssSelector)).GetAttribute("outerHTML"));
		}
		
		[Test]
		public void SElementSearchWithXpath()
		{
			// find using wrapped driver methods
			IWebDriver driver = Selene.GetWebDriver();
			String xpath = "//h1[1]";
			IWebElement element = driver.FindElement(By.XPath(xpath));
			Selene.S(With.XPath(xpath)).Should(Be.InDom);
			StringAssert.AreEqualIgnoringCase(Selene.S(With.XPath(xpath)).TagName, element.TagName);
            
		}

		[Test]
		[Ignore("The argument control is missing - ignore the test")]
		[ExpectedException(typeof(Exception))]
		public void BadXpathArgumentSearch()
		{
			Selene.S(With.XPath("div span")).ShouldNot(Be.InDom);
		}

		[Test]
		public void SElementSearchWithText()
		{
			String searchText = "Dear";
			String xpathSearchText = String.Format(@"//*[contains(text(), ""{0}"")]", searchText);
			IWebDriver webDriver = Selene.GetWebDriver();
			IWebElement element = webDriver.FindElement(By.XPath(xpathSearchText));
			StringAssert.Contains(searchText, element.Text);
			Selene.S(NSelene.With.Text(searchText)).Should(Be.InDom);
			Selene.S(NSelene.With.Text(searchText),webDriver).Should(Be.InDom);
		}

		[Test]
		public void SElementSearchWithTextResultConditons()
		{
			String searchText = "Hello there!";
			String xpathSearchText = String.Format(@"//*[contains(text(), ""{0}"")]", searchText);
			IWebDriver webDriver = Selene.GetWebDriver();
			IWebElement element = webDriver.FindElement(By.XPath(xpathSearchText));
			StringAssert.Contains(searchText, element.Text);

			// verify can use part of the search text in the condition
			Selene.S(NSelene.With.Text(searchText)).Should(Have.Text("Hello"));
			// verify can use the raw text in assertions - more about it in a dedicated class(es) SElementTextMultiLineSearchTests
			Selene.S(NSelene.With.Text("there!"), webDriver).Should(Have.ExactText(searchText));			
			Selene.S(NSelene.With.ExactText(element.Text), webDriver).Should(Have.ExactText(element.Text));
		}
	}
}
