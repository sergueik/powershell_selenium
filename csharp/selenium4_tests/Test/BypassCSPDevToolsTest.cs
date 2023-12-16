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
using SeleniumExtras.WaitHelpers;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using OpenQA.Selenium.DevTools.V109.Page;
using SetBypassCSPCommandSettings = OpenQA.Selenium.DevTools.V109.Page.SetBypassCSPCommandSettings;
using SetBypassCSPCommandResponse = OpenQA.Selenium.DevTools.V109.Page.SetBypassCSPCommandResponse;
using Extensions;
using TestUtils;

// https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-setBypassCSP

namespace Test {
	[TestFixture]
	public class BypassCSPDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		// NOTE: this test will fail when broswer is headless
		private const bool headless = false;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String url = "https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx";
		private string page;
		private string filename = "samplepptx.pptx";
		private WebDriverWait wait;
		private IWebElement element;

		private const string cssSelector = "img";
		private const string xpath = "//img";
		private const int delay = 3000;
		private const int broken_image_width = 16;
		private const int image_width = 100;

		// [OneTimeSetUp]
		[TestFixtureSetUp]
		public void testFixtureSetUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("-headless");
			}
			driver = new ChromeDriver(options);
			Common.Driver = driver;
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);			
			wait = new WebDriverWait(driver, new TimeSpan(0, 0, 30));
			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
		
			devTools = driver as IDevTools;
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
		}
		
		[SetUp]
		public void setUp() {
			var command = new SetBypassCSPCommandSettings {
				Enabled = false
			};
			domains.Page.SetBypassCSP(command);
		}

		[TestFixtureTearDown]
		public void testFixtureTearDown() {
			// Thread.Sleep(delay);
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[TearDown]
		public void tearDown() {
			// Thread.Sleep(delay);
		}

		[Test]
		public void test1() {
			page = "test1.html";
			Common.GetPageContent(page);			
			element = driver.WaitUntilVisible(By.CssSelector(cssSelector));
			Assert.IsTrue(element.Displayed);
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
			var command = new SetBypassCSPCommandSettings {
				Enabled = true
			};
			domains.Page.SetBypassCSP(command);
			page = "test1.html";
			Common.GetPageContent(page);
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.CssSelector(cssSelector)));
			Assert.IsTrue(element.Displayed);
			Assert.AreEqual(image_width, element.Size.Width);
			Console.Error.WriteLine("element size: " + element.Size.Width);
			driver.Highlight(element);
		}

		[Test]
		public void test4() {
			var command = new SetBypassCSPCommandSettings {
				Enabled = true
			};
			domains.Page.SetBypassCSP(command);
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
			command = new SetBypassCSPCommandSettings {
				Enabled = false
			};
			domains.Page.SetBypassCSP(command);
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
