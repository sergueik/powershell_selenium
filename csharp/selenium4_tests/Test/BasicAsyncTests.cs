﻿using NUnit.Framework;

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
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Page.EnableCommandSettings;
using AddScriptToEvaluateOnNewDocumentCommandSettings = OpenQA.Selenium.DevTools.V109.Page.AddScriptToEvaluateOnNewDocumentCommandSettings;
using SetDeviceMetricsOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Emulation.SetDeviceMetricsOverrideCommandSettings;
using SetUserAgentOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Network.SetUserAgentOverrideCommandSettings;

using Extensions;

namespace Test {
	[TestFixture]
	public class BasicAsyncTests
	{
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = false;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private static String baseURL = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private IWebElement element;
		
		[SetUp]
		public void SetUp() {
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
			// NOTE: not using the WebDriver Service
			// var service = ChromeDriverService.CreateDefaultService();
			// service.DriverServicePath = driverLocation;
			// IWebDriver driver = new ChromeDriver(service);	

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));

		
			devTools = driver as IDevTools;
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
			domains.Page.Enable(new EnableCommandSettings());
		}

		[TearDown]
		public void TearDown() {
			try {
				driver.Quit();
			} catch (Exception e) {
				Console.Error.WriteLine("Exception :" + e.ToString
				                        ());
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		// NOTE: Selenium dev recommends async / await
		// but the async test appears to simply hanging somewhere in setup on Windows 8.1
		// see also: https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V112.Network.SetUserAgentOverrideCommandSettings.html
		[Ignore]
		[Test]
		public async void test1() {
			Console.Error.WriteLine("Actual Browser User Agent: " + domains.Browser.GetVersion().Result.UserAgent);
			
			var settings = new SetUserAgentOverrideCommandSettings();
			const string userAgent = "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25";
			settings.UserAgent = userAgent;
			Console.Error.WriteLine("PretendUser Agent: " + userAgent);
			await domains.Network.SetUserAgentOverride(settings);
		
			driver.Navigate().GoToUrl(baseURL);

			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			element = driver.FindElement(By.XPath("//*[@id=\"content-base\"]//table//th[contains(text(),\"USER-AGENT\")]/../td"));
			Assert.IsTrue(element.Displayed);
			Assert.AreEqual(userAgent, element.Text);
			driver.Highlight(element);
			Thread.Sleep(1000);
		}
		
		
		// NOTE: Selenium dev recommends async / await
		// but the async test appears to simply hanging somewhere in setup on Windows 8.1
		// [Ignore]		
		[Test]
		public async void test2() {
			var widths = new Dictionary<int, int>();
			widths[480] = 384;
			widths[600] = 480;
			foreach (int device_width in widths.Keys) {
			
				int viewport_width = widths[device_width];
				var settings = new SetDeviceMetricsOverrideCommandSettings();
				settings.Width = device_width;
				settings.Height = 640;
				settings.Mobile = true;
				settings.DeviceScaleFactor = 50;

				await domains.Emulation.SetDeviceMetricsOverride(settings);
		
				// Console.Error.WriteLine("Actual Deice Metric Settings Witdh: " + settings.Width);
				Console.Error.WriteLine("Pretend Device Metric Settings Witdh: " + device_width);
				driver.Navigate().GoToUrl(baseURL);

				driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
				// NOTE: browser needs to be visible for this element to be found
				element = driver.FindElement(By.XPath("//*[@id=\"content-base\"]//table//th[contains(text(),\"VIEWPORT-WIDTH\")]/../td"));
				Assert.IsTrue(element.Displayed);
				Assert.AreEqual(String.Format("{0}", viewport_width), element.Text);
				driver.Highlight(element);
				// 480 VIEWPORT-WIDTH 384
				// 600 VIEWPORT-WIDTH 480
				Thread.Sleep(100);
			}
		}
	}
}
