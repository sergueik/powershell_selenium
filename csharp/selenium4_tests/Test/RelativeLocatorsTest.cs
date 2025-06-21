using NUnit.Framework;

/**
 * Copyright 2025 Serguei Kouzmine
 */

using System;
using System.Text;
using System.Linq;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;

// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V119.Console.ConsoleMessage.html


using Extensions;
// https://www.browserstack.com/guide/relative-locators-in-selenium
// Selenium 4 introduced relative locators, also known as "friendly locators," allowing you to locate elements based on their position relative to other elements. 

namespace Test {
	
	[TestFixture]
	public class RelativeLocatorsDevToolsTest	{
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private bool headless = true;
		private const String baseURL = "https://www.browserstack.com/";
		private IWebElement element1;
		private IWebElement element2;
		private IWebElement element3;
		private int delay =100;

		[SetUp]
		public void SetUp() {
			Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			if (headless) 
				options.AddArgument("--headless");
			else 
				options.AddArgument("--start-maximized");
	
			driver = new ChromeDriver(options);
			// NOTE: not using the WebDriver Service with this version of Selenium

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);		}

		[Test]
		public void test1() {

			driver.Url = baseURL;
			element1 = driver.WaitUntilVisible(By.Id("signupModalProductButton"));
			Assert.That(element1.Text, Is.StringContaining("Get started free"));
			Console.WriteLine("Element1: {0}", element1.Text);
			element2 = driver.FindElement(RelativeBy.WithLocator(By.TagName("button")).RightOf(element1));
			Assert.That(element2.Text, Is.EqualTo("Talk to us"));
			Console.WriteLine("Element2: {0}", element2.Text);
			element2.Click();
			Thread.Sleep(delay);
		}

		// NOTE:  succeeds in headless, fails in visible
		[Test]
		public void test2() {

			driver.Url = baseURL;
			element1 = driver.WaitUntilVisible(By.CssSelector("#product-tab-content0 a[aria-label='Live']"));
			if(headless)
				Assert.That(element1.Text.Replace(Environment.NewLine, " "), Is.StringContaining("Live Manual cross browser testing"));
			Console.WriteLine("Element1: {0}", element1.Text);
			element2 = driver.FindElement(RelativeBy.WithLocator(By.TagName("button")).RightOf(element1));
			if(headless)
				Assert.That(element2.Text, Is.EqualTo("App Testing"));
			Console.WriteLine("Element2: {0}", element2.Text);
			element3 = driver.FindElement(RelativeBy.WithLocator(By.TagName("button")).LeftOf(element2));
			Console.WriteLine("Element3: {0}", element3.Text);
			if(headless)
				Assert.That(element3.Text, Is.EqualTo("Web Testing"));
			element2.Click();
			Thread.Sleep(delay);
		}

		[TearDown]
		public void TearDown()
		{
			try {
				driver.Close();
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}


		private static IWebDriver CreateWebDriver(string browserPath, string driverPath)
		{
			var service = ChromeDriverService.CreateDefaultService(driverPath);
			service.EnableVerboseLogging = false;

			var options = new ChromeOptions { BinaryLocation = browserPath };
			options.AddArgument("incognito");

			return new ChromeDriver(service, options);
		}
	}
}
