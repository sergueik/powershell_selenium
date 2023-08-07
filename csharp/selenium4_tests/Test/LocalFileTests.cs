using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using System.Threading;

using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;


using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
//
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Page.EnableCommandSettings;
using AddScriptToEvaluateOnNewDocumentCommandSettings = OpenQA.Selenium.DevTools.V109.Page.AddScriptToEvaluateOnNewDocumentCommandSettings;
using SetDeviceMetricsOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Emulation.SetDeviceMetricsOverrideCommandSettings;
using SetUserAgentOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Network.SetUserAgentOverrideCommandSettings;


using FluentAssertions;

using Extensions;
using TestUtils;

namespace Selenium4.Test {

	[TestFixture]
	public class LocalFileTests  {
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private WebDriverWait wait;
		private Actions actions;
		private bool headless = true;
		private const int wait_seconds = 3;
		private const long wait_poll_milliseconds = 300;

		// private String testpage;
		private SimpleHTTPServer pageServer;
		private int port = 0;

		[TestFixtureSetUp]
		public void SetUp() {

			// for testing localserver hosted examples - check that the process can create web servers
			// bool isProcessElevated = ElevationChecker.IsProcessElevated(false);
			// Assert.IsTrue(isProcessElevated, "This test needs to run from an elevated IDE or nunit console");

			// initialize custom HttpListener subclass to host the local files
			// https://docs.microsoft.com/en-us/dotnet/api/system.net.httplistener?redirectedfrom=MSDN&view=netframework-4.7.2
			String filePath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", "");
			
			// Console.Error.WriteLine(String.Format("Using Webroot path: {0}", filePath));
			pageServer = new SimpleHTTPServer(filePath);
			// implicitly does pageServer.Initialize() and  pageServer.Listen();
			Common.Port = pageServer.Port;
			// Console.Error.WriteLine(String.Format("Using Port {0}", port));

			// initialize the Selenium driver
			// driver = new FirefoxDriver();
			// System.InvalidOperationException : Access to 'file:///...' from script denied (UnexpectedJavaScriptError)
			if (headless) { 
				var option = new ChromeOptions();
				option.AddArgument("--headless");
				driver = new ChromeDriver(option);
			} else {
				driver = new ChromeDriver();
			}
			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(60);

	
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
			actions = new Actions(driver);
		}

		[TestFixtureTearDown]
		public void TearDown()
		{
			pageServer.Stop();
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.IsEmpty(verificationErrors.ToString());
		}

		[Test]
		public void test()
		{
		
		}
		
	}
}
