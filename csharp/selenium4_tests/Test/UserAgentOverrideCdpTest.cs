using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

using System;
using System.Text;
using System.Linq;
using System.Management;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;
using SeleniumExtras.WaitHelpers;

using Extensions;
using TestUtils;

// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setUserAgentOverride
namespace Test {
	[TestFixture]
	public class UserAgentOverrideCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private const bool headless = true;
		private const String url = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private WebDriverWait wait;
		private IWebElement element;
		private ChromiumDriver chromiumDriver;
		private string command;
		private string userAgent;
		
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
				// driver = new ChromeDriver(option);
			} else {
				// driver = new ChromeDriver();
			}
			driver = new ChromeDriver(options);
			chromiumDriver = driver as ChromiumDriver;
			wait = new WebDriverWait(driver, new TimeSpan(0, 0, 30));
		}
		[TearDown]
		public void tearDown() {
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		// see also: https://journeyofquality.com/2021/11/27/selenium-chrome-devtools-protocol-cdp/ (for Java)
		// [Ignore]
		[Test]
		public void test() {
			command = "Browser.getVersion";
			result = chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
			Assert.NotNull(result);
			data = result as Dictionary<String, Object>;
			Console.Error.WriteLine("result keys: " + data.PrettyPrint());
			userAgent =  data["userAgent"].ToString();
			Console.Error.WriteLine("Actual Browser User Agent: " + userAgent);
			userAgent = "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25";
			arguments["userAgent"] = userAgent;
			arguments["platform"] = "Windows";
			command =  "Network.setUserAgentOverride";
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			driver.Navigate().GoToUrl(url);			
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);			
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.XPath("//*[@id=\"content-base\"]//table//th[contains(text(),\"USER-AGENT\")]/../td")));
			Assert.IsTrue(element.Displayed);
			Assert.AreEqual(userAgent, element.Text);
			driver.Highlight(element);
			Thread.Sleep(1000);
		}
	}

}
