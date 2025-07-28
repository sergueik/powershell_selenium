using NUnit.Framework;

/* Copyright 2025 Serguei Kouzmine */

using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;
using SeleniumExtras.WaitHelpers;

using Extensions;
using TestUtils;
// https://github.com/sukgu/shadow-automation-selenium
// https://stackoverflow.com/questions/51346883/selenium-webdriver-with-shadow-dom

namespace Test
{
	[TestFixture]
	public class ShadowRootTest
	{
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private ISearchContext shadowRootElement;
		private const bool headless = true;
		private const String url = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private const string page = "inner_html_example.html";

		[SetUp]
		public void setUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);
			chromiumDriver = driver as ChromiumDriver;
			Common.Driver= driver;
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);			
			wait = new WebDriverWait(driver, new TimeSpan(0, 0, 30));
		}

		[TearDown]
		public void tearDown() {
			// Thread.Sleep(delay);

			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void test1() {
			Common.GetPageContent(page);			
			element = driver.WaitUntilVisible(By.CssSelector(cssSelector));
shadowRootElement = GetShadowRootElement(element);
		}

		[Test]
		public void test2() {
			element = driver.WaitUntilVisible(By.CssSelector(cssSelector));
shadowRootElement = GetShadowRootElement(element);
		}

		// get shadow root hosted in element using 
		// new GetShadowRoot method introduced in 4.x
		public static ISearchContext GetShadowRootElement(IWebElement element) {
			ISearchContext shadowRootElement = element.GetShadowRootUsingJavascript();
			return shadowRootElement;
		}

		// get shadow root hosted in element using plain javascript invocation
		public static ISearchContext GetShadowRootElementUsingJavaScript(IWebDriver driver, IWebElement element) {
			IJavaScriptExecutor js = (IJavaScriptExecutor)driver;
			ISearchContext shadowRootElement = (ISearchContext)js.ExecuteScript("return arguments[0].shadowRoot", element);

			return shadowRootElement;
		}
	}
}
