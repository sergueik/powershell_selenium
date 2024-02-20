using NUnit.Framework;

/**
 * Copyright 2024 Serguei Kouzmine
 */

using System;
using System.Text;
using System.Linq;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;

// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V109.Runtime.html
using Runtime = OpenQA.Selenium.DevTools.V109.Runtime;
using RuntimeAdapter = OpenQA.Selenium.DevTools.V109.Runtime.RuntimeAdapter;
using RemoteObject = OpenQA.Selenium.DevTools.V109.Runtime.RemoteObject;
using ExceptionDetails = OpenQA.Selenium.DevTools.V109.Runtime.ExceptionDetails;
using ExceptionThrownEventArgs = OpenQA.Selenium.DevTools.V109.Runtime.ExceptionThrownEventArgs;

using Extensions;

namespace Test {

	// https://www.selenium.dev/documentation/webdriver/bidirectional/chrome_devtools/cdp_api/#console-logs
	[TestFixture]
	public class RuntimeExceptionThrownDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = true;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String baseURL = "https://www.selenium.dev/selenium/web/bidi/logEntryAdded.html";
		private RuntimeAdapter runtimeAdapter;
		private IWebElement element;

		[SetUp]
		public void SetUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);
			// NOTE: not using the WebDriver Service with this version of Selenium

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);

			devTools = driver as IDevTools;

			// Detect Windows 7 or older dynamically and abort the test
			try {
				session = devTools.GetDevToolsSession();
				domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();			
			} catch (WebDriverException  e) {
				Console.Error.WriteLine(e.ToString());
				// OpenQA.Selenium.WebDriverException: Unexpected error creating WebSocket DevTools sessio
				// System.PlatformNotSupportedException:
				// The WebSocket protocol is not supported on this platform.
				Assert.Fail("Aborting the current test as the current platform  is not supported");
			}
		}

		[Test]
		// see also: https://docs.nunit.org/articles/nunit/writing-tests/attributes/platform.html
		[Platform(Include = "Windows8,Windows8.1,Windows10,Windows11,WindowsServer10")]
		public void test() {
			runtimeAdapter = domains.Runtime;
			var enableCommandSettings = new Runtime.EnableCommandSettings();
			// Enables reporting of execution contexts creation by means of executionContextCreated event. When the reporting gets enabled the event will be sent immediately for each existing execution context
			runtimeAdapter.Enable(enableCommandSettings);
			runtimeAdapter.ExceptionThrown += ExceptionThrownProcessor;

			driver.Url = baseURL;
			element = driver.WaitUntilVisible(By.Id("logWithStacktrace"));
			element.Click();
			session.Dispose();
		}

		private void ExceptionThrownProcessor(object sender, ExceptionThrownEventArgs e) {
			ExceptionDetails d = e.ExceptionDetails;
			RemoteObject x = d.Exception;
			System.Console.Error.WriteLine(String.Format(@"ExceptionThrown Line: {0} Column: {1} url: ""{2}"" Text: {3} Exception: {4}", d.LineNumber, d.ColumnNumber, d.Url, d.Text, x.Description));
		}

		[TearDown]
		public void TearDown() {
			try {
				driver.Close();
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}


		private static IWebDriver CreateWebDriver(string browserPath, string driverPath)
		{
			var service = ChromeDriverService.CreateDefaultService(driverPath);
			service.EnableVerboseLogging = false;

			var options = new ChromeOptions { BinaryLocation = browserPath };
			options.AddArgument("incognito");

			return new ChromeDriver(service, options);
		}
	}
}
