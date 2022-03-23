
using System;
using System.Linq;
using System.Text;

using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
// A using namespace directive can only be applied to namespaces; 'OpenQA.Selenium.Chrome.ChromeOptions' is a type not a namespace (CS0138)
// using OpenQA.Selenium.Chrome.ChromeOptions;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

// https://stackoverflow.com/questions/44619071/how-to-wait-in-selenium-webdriver-until-the-text-of-5-characters-length-is-enter
// see also: https://www.lambdatest.com/blog/explicit-fluent-wait-in-selenium-c/

namespace Protractor.Test {
	[TestFixture]
	public class CapchaWaitTest {
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private WebDriverWait wait;
		private Actions actions;
		private const int wait_seconds = 10;
		private const long wait_poll_milliseconds = 500;
		private const string base_url = "https://www.wikipedia.org";
		private const String selector = "#searchInput";


		[TestFixtureSetUp]
		public void SetUp() {

			// https://developercommunity.visualstudio.com/t/selenium-ui-test-can-no-longer-find-chrome-binary/1170486
			
			// "major impediment"
			ChromeOptions options = new  ChromeOptions();
			options.BinaryLocation = @"C:\Program Files\Google\Chrome\Application\chrome.exe";
				driver = new ChromeDriver(options);
			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(60);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(60));
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
			actions = new Actions(driver);
		}
		
		[Test]		
		public void ShouldEnterSomeText(){
			driver.Navigate().GoToUrl(base_url);
			wait.Until(ExpectedConditions.ElementExists(By.CssSelector(
				selector)));

			wait.Until(x => {
				var size = 
					x.FindElement(By.CssSelector(selector)).GetAttribute("value").Length;
				if (size >= 5) {
					return true;
				} else {
					Console.Error.Write("waiting for specific text length");
					return false;
				}
			});


			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
		}
	}

}