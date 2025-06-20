using System;
using System.Collections.Generic;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.Chromium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;

using OpenQA.Selenium.DevTools.V109.Network;
using System.Text;
using NUnit.Framework;

using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;


namespace Test
{
	public class CaptureNetworkTrafficDevToolsTest
	{
    
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = true;
		private IDevToolsSession session;
		private List<String> captures = new List<String>();

		private DevToolsSessionDomains domains;
		private static String baseURL = "https://www.google.com";

		[SetUp]
		// C# doesn't use the throws keyword in method signatures like Java to declare exceptions		
		public void setUp()
		{
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			try {
				driver = new ChromeDriver(options)  as ChromiumDriver;
			
				devTools = driver as IDevTools;
				
				try {
					session = devTools.GetDevToolsSession();
				} catch (WebDriverException e) {
					if (e.InnerException is PlatformNotSupportedException) {
						// Assert.Ignore(...) marks the test as ignored/skipped in NUnit's output/report
						Assert.Ignore("Platform not supported — skipping test.");
						return;
					}
				}

				session = devTools.GetDevToolsSession();
				domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();

				domains.Network.ResponseReceived += ResponseReceivedHandler;

				domains.Network.Enable(new EnableCommandSettings());
			} catch (PlatformNotSupportedException e) { 
				return;
			}
		}
		[Test]
		public void test()
		{
			if (session != null)
				driver.Navigate().GoToUrl(baseURL);
		}

		[TearDown]
		public void tearDown()
		{
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.Greater(captures.Count, 0);
			Assert.AreEqual("", verificationErrors.ToString());

		}
    
		public void ResponseReceivedHandler(object sender, ResponseReceivedEventArgs e)
		{
			var line = String.Format("Status: {0} : {1} | File: {2} | Url: {3}", e.Response.Status, e.Response.StatusText, e.Response.MimeType, e.Response.Url);
			captures.Add(line);
			Console.Error.WriteLine(line);
		}

	}
}

