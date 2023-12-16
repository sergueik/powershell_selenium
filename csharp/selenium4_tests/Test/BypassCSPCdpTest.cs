using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using System.Drawing;

using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;
using SeleniumExtras.WaitHelpers;

using Extensions;
using TestUtils;

// https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-setBypassCSP


namespace Test {
	[TestFixture]
	public class BypassCSPCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private const bool headless = false;
		private WebDriverWait wait;
		private IWebElement element;
		private ChromiumDriver chromiumDriver;
		private string command;
		private string page;
		private const int broken_image_width = 16;
		private const int image_width = 100;
		
		// NOTE: the "params" is reserved in .Net 
		private Dictionary<String, Object> arguments = new Dictionary<String, Object>();
		private Object result;
		private const string cssSelector = "img";
		private const string xpath = "//img";
		private const int delay = 3000;
		private Dictionary<String, Object> data = new Dictionary<string, object>();
		
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

			command = "Page.setBypassCSP";
			arguments.Clear();
			arguments["enabled"] = false;
			chromiumDriver.ExecuteCdpCommand(command, arguments);

			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void test1() {
			page = "test1.html";
			Common.GetPageContent(page);			
			element = driver.WaitUntilVisible(By.CssSelector(cssSelector));
			Assert.IsTrue(element.Displayed);
			// NOTE: System.InvalidOperationException : 
			// Assert.Equals should not be used for Assertions
			// Assert.Equals(broken_image_width, element.Size.Width);
			Assert.AreEqual(broken_image_width, element.Size.Width);
			Console.Error.WriteLine("element size: " + element.Size.Width);
			driver.Highlight(element);
		}

		[Test]
		public void test2() {
			page = "test2.html";
			Common.GetPageContent(page);			
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.XPath(xpath)));
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
		}

		[Test]
		public void test3() {
			command = "Page.setBypassCSP";
			arguments.Clear();
			arguments["enabled"] = true;
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			page = "test1.html";
			Common.GetPageContent(page);
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.CssSelector(cssSelector)));
			Assert.IsTrue(element.Displayed);
			// NOTE: System.InvalidOperationException : 
			// Assert.Equals should not be used for Assertions
			// Assert.Equals(image_width, element.Size.Width);
			Assert.AreEqual(image_width, element.Size.Width);
			Console.Error.WriteLine("element size: " + element.Size.Width);
			driver.Highlight(element);
		}

		[Test]
		public void test4() {
			command = "Page.setBypassCSP";
			arguments.Clear();
			arguments["enabled"] = true;
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			page = "test1.html";
			Common.GetPageContent(page);			
			element = driver.WaitUntilVisible(By.CssSelector(cssSelector));
			Assert.IsTrue(element.Displayed);
			// NOTE: System.InvalidOperationException : 
			// Assert.Equals should not be used for Assertions
			// Assert.Equals(broken_image_width, element.Size.Width);
			Assert.AreEqual(image_width, element.Size.Width);
			Console.Error.WriteLine("element size: " + element.Size.Width);
			driver.Highlight(element);
			command = "Page.setBypassCSP";
			arguments.Clear();
			arguments["enabled"] = false;
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			driver.Navigate().Refresh();
			element = driver.WaitUntilVisible(By.CssSelector(cssSelector));
			Assert.IsTrue(element.Displayed);
			// NOTE: System.InvalidOperationException : 
			// Assert.Equals should not be used for Assertions
			// Assert.Equals(broken_image_width, element.Size.Width);
			Assert.AreEqual(broken_image_width, element.Size.Width);
			Console.Error.WriteLine("element size: " + element.Size.Width);
			driver.Highlight(element);
			
		}
	}
}
