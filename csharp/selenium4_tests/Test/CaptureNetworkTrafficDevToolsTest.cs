using System;
using System.Collections.Generic;
using System.Text;

/* Copyright 2025 Serguei Kouzmine */

using OpenQA.Selenium;
using OpenQA.Selenium.Chromium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;

using OpenQA.Selenium.DevTools.V109.Network;
using NUnit.Framework;

using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;

// https://www.selenium.dev/selenium/docs/api/dotnet/webdriver/OpenQA.Selenium.html
namespace Test {
	// based on https://github.com/ebubekirbastama/SeleniumNetworkCaptureNetworkTraffic/tree/main
	public class CaptureNetworkTrafficDevToolsTest {
    
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = true;
		private List<String> captures = new List<String>();
		private IDevToolsSession session = null;
		private DevToolsSessionDomains domains = null;
		private static String baseURL = "https://www.google.com";

		[SetUp]
		// C# doesn't use the throws keyword in method signatures like Java to declare exceptions		
		public void setUp() {
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options)  as ChromiumDriver;
			devTools = driver as IDevTools;

			// GetDevToolsSession  will throw a PlatformNotSupportedException on Windows 7 and bellow
			try {
				session = devTools.GetDevToolsSession();
			} catch (WebDriverException e) {
				if (e.InnerException is PlatformNotSupportedException) {
					Assert.Ignore("Platform not supported — skipping tests.");
					if (session != null)
						session.Dispose();
					return;
				}
			}

			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
			domains.Network.ResponseReceived += ResponseReceivedHandler;

			domains.Network.Enable(new EnableCommandSettings());
		}

		[Test]
		public void test() {
			if (session != null)
				driver.Navigate().GoToUrl(baseURL);
		}

		[TearDown]
		public void tearDown() {
			Assert.Greater(captures.Count, 0);
			Assert.AreEqual("", verificationErrors.ToString());

			try {
				if (domains != null) {
					domains.Network.ResponseReceived -= ResponseReceivedHandler;
					domains.Network.Disable();
				}

				if (driver != null)
					driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */

		}

		public void ResponseReceivedHandler(object sender, ResponseReceivedEventArgs e){
			var line = String.Format("Status: {0} : {1} | File: {2} | Url: {3}", e.Response.Status, e.Response.StatusText, e.Response.MimeType, e.Response.Url);
			captures.Add(line);
			Console.Error.WriteLine(line);
		}

	}
}
