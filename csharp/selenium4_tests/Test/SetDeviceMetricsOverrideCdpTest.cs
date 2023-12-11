using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */
using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;

using Extensions;
using TestUtils;

namespace Test {
	[TestFixture]
	public class SetDeviceMetricsOverrideCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private const bool headless = false;
		private const String url = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private IWebElement element;
		private ChromiumDriver chromiumDriver;
		private string command;
		// NOTE: the "params" is reserved in .Net
		private Dictionary<String, Object> arguments = new Dictionary<String, Object>();
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
		}

		[TearDown]
		public void tearDown() {
			command = "Emulation.clearDeviceMetricsOverride";
			chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void test() {
			var widths = new Dictionary<int, int>();
			widths[480] = 384;
			widths[600] = 480;
			foreach (int device_width in widths.Keys) {

				command = "Emulation.setDeviceMetricsOverride";
				int viewport_width = widths[device_width];

				arguments["deviceScaleFactor"] = 50;
				arguments["width"] = device_width;
				arguments["height"] = 640;
				arguments["mobile"] = true;
				arguments["scale"] = 1;

				Console.Error.WriteLine("Pretend Device Metric Settings Width: " + device_width);
				chromiumDriver.ExecuteCdpCommand(command, arguments);
		
				driver.Navigate().GoToUrl(url);

				driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
				// NOTE: browser needs to be visible for this element to be found
				element = driver.WaitUntilVisible(By.XPath("//*[@id=\"content-base\"]//table//th[contains(text(),\"VIEWPORT-WIDTH\")]/../td"));
				Assert.IsTrue(element.Displayed);
				driver.VerifyElementTextPresent(element, String.Format("{0}", viewport_width));
				Assert.AreEqual(String.Format("{0}", viewport_width), element.Text);
				

				driver.Highlight(element);
				// 480 VIEWPORT-WIDTH 384
				// 600 VIEWPORT-WIDTH 480
				
				command = "Page.getLayoutMetrics";
				var result = (driver as ChromiumDriver).ExecuteCdpCommand(command, new Dictionary<String, Object>());
				Assert.NotNull(result);
				data = result as Dictionary<String, Object>;
				Console.Error.WriteLine("result keys: " + data.PrettyPrint());
				Assert.IsTrue(data.ContainsKey("visualViewport"));
				var visualViewport = data["visualViewport"] as Dictionary<String, Object>;;
				Console.Error.WriteLine("result keys: " + visualViewport.PrettyPrint());
				Thread.Sleep(100);
			}
		}
	}
}

