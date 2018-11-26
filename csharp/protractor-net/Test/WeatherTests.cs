using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
// using OpenQA.Selenium.PhantomJS;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using System.Collections.ObjectModel;
using System.Collections;
using System.Threading;
using System.Linq;
using Protractor.Extensions;
//using System.Drawing;
//using System.Windows.Forms;


namespace Protractor.Test
{
	[TestFixture]
	public class WeatherTests
	{
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private String base_url = "https://weather.com/";
		private WebDriverWait wait;
		private const int wait_seconds = 3;
		private const long wait_poll_milliseconds = 300;

		[TestFixtureSetUp]
		public void SetUp()
		{
			driver = new FirefoxDriver();
			// NOTE: SetScriptTimeout is obsolete
            driver.Manage().Timeouts().AsynchronousJavaScript =  TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			// driver.Manage().Window.Size = new System.Drawing.Size(700, 400);
			ngDriver = new NgWebDriver(driver);
			ngDriver.Navigate().GoToUrl(base_url);
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
		}

		[TestFixtureTearDown]
		public void TearDown()
		{
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}


		[Test]
		public void ShouldSearchCitySuggestions()
		{

			String city = "Jacksonville, FL";
			wait.Until(ExpectedConditions.ElementIsVisible(NgBy.Model("term")));
			IWebElement search = driver.FindElement(By.XPath("//input[@name='search']"));
			Assert.IsNotNull(search);
			ngDriver.Highlight(search);

			// NOTE: Chrome is occasionally dropping first letter .
			// search.SendKeys(city[0].ToString());
			// TODO: http://stackoverflow.com/questions/1450774/splitting-a-string-into-chunks-of-a-certain-size
			foreach (char cityChar in city.ToCharArray()) {
				Console.Error.WriteLine("Sending: {0}", cityChar);
				search.SendKeys(cityChar.ToString());
				Thread.Sleep(50);
			}
			search.Click();
			ReadOnlyCollection<NgWebElement> ng_elements = ngDriver.FindElements(NgBy.Repeater("item in results | limitTo:10"));
			foreach (NgWebElement ng_element in ng_elements) {
				try {
					Assert.IsNotNull(ng_element.FindElement(NgBy.Binding("getPresName($index)")));
					Console.Error.WriteLine("Suggested: {0}", ng_element.Text);
				} catch (StaleElementReferenceException e) { 
					Console.Error.WriteLine("Ignored exception: {0}", e.Message);
				}
			}
			NgWebElement ng_firstMatchingElement = ng_elements.First(x => x.Text.ToLower() == city.ToLower());
			Assert.IsNotNull(ng_firstMatchingElement);
			ngDriver.Highlight(ng_firstMatchingElement);
			Console.Error.WriteLine("Clicking: {0}", ng_firstMatchingElement.Text);

			ng_firstMatchingElement.Click();
			Thread.Sleep(1000);

			// TODO: Assert the change of the URL
		}
	}
}