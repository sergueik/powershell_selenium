using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

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

// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setUserAgentOverride
namespace Test {
	[TestFixture]
	public class BypassCSPCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private const bool headless = false;
		private const String url = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private WebDriverWait wait;
		private IWebElement element;
		private ChromiumDriver chromiumDriver;
		private string command;
		private string page;
		
		// NOTE: the "params" is reserved in .Net 
		private Dictionary<String, Object> arguments = new Dictionary<String, Object>();
		private Object result;
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

		// see also: https://journeyofquality.com/2021/11/27/selenium-chrome-devtools-protocol-cdp/ (for Java)
		// [Ignore]
		[Test]
		public void test1() {
			page = "test1.html";
			Common.GetPageContent(page);			
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.XPath("//img")));
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			Thread.Sleep(1000);
		}

		[Test]
		public void test2() {
			page = "test2.html";
			Common.GetPageContent(page);			
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.XPath("//img")));
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			Thread.Sleep(1000);
		}

		[Test]
		public void test3() {
			command = "Page.setBypassCSP";
			arguments.Clear();
			arguments["enabled"] = true;
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			page = "test1.html";
			Common.GetPageContent(page);
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.XPath("//img")));
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			Thread.Sleep(1000);
		}
	}

}
