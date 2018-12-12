using NUnit.Framework;
using System;

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
			Given.OpenedPageWithBody("<h1 name='hello'>Hello Babe!</h1>");
			Selene.S("css = h1[name='hello']").Should(Have.Attribute("name", "hello"));
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
			Selene.S("text = Hello").ShouldNot(Have.ExactText("Hello"));
			Selene.S("text = world!").ShouldNot(Have.ExactText("Hello"));
			// up casting back to SeleneDriver will be a wrong move: 
			// it will internally switch back to cssSelector
			// SeleneElement element = (new SeleneDriver(Selene.GetWebDriver())).Find(By.XPath("//*[contains(text(),'Hello World')]"));
			IWebElement element = Selene.GetWebDriver().FindElement(By.XPath("//*[contains(text(),'Hello World')]"));
			StringAssert.Contains("Hello World!" , element.Text);
			// Console.Error.WriteLine(element.Text);
			Selene.I.Find(By.XPath("//*[contains(text(),'Hello World')]"));
		}
	}
}