using System;
using System.Text;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Edge;

namespace ShadowDriver.Test {
	[TestFixture]
	public class BasicTests {
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private NgWebDriver ngDriver;
		private bool headless = false;
		private String base_url = "https://www.virustotal.com";
		
		[SetUp]
		public void SetUp() {
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			
			// Using NuGet Package 'WebDriver.ChromeDriver.win32'
			if (headless) { 
				var option = new ChromeOptions();
				option.AddArgument("--headless");
				driver = new ChromeDriver(option);
			} else {
				driver = new ChromeDriver();
			}

			// Using Internet Explorer
			//var options = new InternetExplorerOptions() { IntroduceInstabilityByIgnoringProtectedModeSettings = true };
			//driver = new InternetExplorerDriver(options);

			// Using Microsoft Edge
			//driver = new EdgeDriver();

			// Required for TestForAngular and WaitForAngular scripts
            driver.Manage().Timeouts().AsynchronousJavaScript =  TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			ngDriver = new NgWebDriver(driver);
			ngDriver.Navigate().GoToUrl(base_url);
		}

		[TearDown]
		public void TearDown() {
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void ShouldFindShadowElements() {
			string urlLocator = "*[data-route='url']";
			IWebElement element = ngDriver.FindElement(By.CssSelector(urlLocator));
			var elements = ngDriver.FindElements(NgBy.ShadowDOMPath(urlLocator, "#wrapperLink"));
			Assert.Greater(elements.Count, 0);
		}

	}
}
