using NUnit.Framework;

/* Copyright 2024 Serguei Kouzmine */

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

// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setBlockedURLs
// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setCacheDisabled
// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-clearBrowserCache

namespace Test {

	[TestFixture]
	public class FilterUrlCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private const bool headless = false;
		private WebDriverWait wait;
		private IWebElement element;
		private ChromiumDriver chromiumDriver;
		private string command;
		
		// NOTE: the "params" is reserved in .Net
		private Dictionary<String, Object> arguments = new Dictionary<String, Object>();
		private const string tagName = "img";
		private const String url = "http://arngren.net";
		
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
			Common.Driver = driver;
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);			
			wait = new WebDriverWait(driver, new TimeSpan(0, 0, 30));
		}

		[TearDown]
		public void tearDown() {
			arguments.Clear();
			command = "Network.clearBrowserCache";
			chromiumDriver.ExecuteCdpCommand(command, arguments);

			arguments.Clear();
			arguments["cacheDisabled"] = false;
			command = "Network.setCacheDisabled";
			chromiumDriver.ExecuteCdpCommand(command, arguments);

			command = "Network.setBlockedURLs";
			arguments.Clear();
			var urls = new List<string>();
			arguments["urls"] = urls;
			chromiumDriver.ExecuteCdpCommand(command, arguments);

			command = "Network.disable";
			arguments.Clear();
			chromiumDriver.ExecuteCdpCommand(command, arguments);

			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void test() {
			command = "Network.enable";
			arguments.Clear();
			long maxTotalBufferSize = 10000000;
			long maxResourceBufferSize = 5000000;
			long maxPostDataSize = 5000000;

			arguments["maxTotalBufferSize"] = maxTotalBufferSize;
			arguments["maxResourceBufferSize"] = maxResourceBufferSize;
			arguments["maxPostDataSize"] = maxPostDataSize;

			chromiumDriver.ExecuteCdpCommand(command, arguments);

			arguments.Clear();
			command = "Network.clearBrowserCache";
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			
			arguments.Clear();
			arguments["cacheDisabled"] = true;
			command = "Network.setCacheDisabled";
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			
			command = "Network.setBlockedURLs";
			arguments.Clear();
			var urls = new List<string>();

			urls.Add("*.css");
			urls.Add("*.png");
			urls.Add("*.jpg");
			urls.Add("*.gif");
			urls.Add("*favicon.ico");

			arguments["urls"] = urls;
			chromiumDriver.ExecuteCdpCommand(command, arguments);

			driver.Navigate().GoToUrl(url);
			wait.Until(ExpectedConditions.ElementIsVisible(By.TagName(tagName)));
			foreach (var image in driver.FindElements(By.TagName(tagName)).Take(10)) { 
				IsImageBroken(image);
				driver.Highlight(image);

			}	
			Thread.Sleep(3000);
		}

		private void IsImageBroken(IWebElement image)
		{
			if (image.GetAttribute("naturalWidth").Equals("0")) {
				Console.Error.WriteLine(String.Format("{0} is broken.", image.GetAttribute("src")));
			}
		}
	}
	

}

