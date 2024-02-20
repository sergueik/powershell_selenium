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

//  https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V121.Runtime.html
using Runtime = OpenQA.Selenium.DevTools.V109.Runtime;
using RuntimeAdapter = OpenQA.Selenium.DevTools.V109.Runtime.RuntimeAdapter;
using RemoteObject = OpenQA.Selenium.DevTools.V109.Runtime.RemoteObject;
using ConsoleAPICalledEventArgs = OpenQA.Selenium.DevTools.V109.Runtime.ConsoleAPICalledEventArgs;

using Extensions;

namespace Test {

	// https://www.selenium.dev/documentation/webdriver/bidirectional/chrome_devtools/cdp_api/#console-logs
	[TestFixture]
	public class RuntimeConsoleApiCalledDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = false;
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
			// TODO: detect Windows 7 and abort the test otherwise
			// System.PlatformNotSupportedException:
			// The WebSocket protocol is not supported on this platform.
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();			
		}

		[Test]
		public void test() {
			runtimeAdapter = domains.Runtime;
			var enableCommandSettings = new Runtime.EnableCommandSettings();
			// Enables reporting of execution contexts creation by means of executionContextCreated event. When the reporting gets enabled the event will be sent immediately for each existing execution context
			runtimeAdapter.Enable(enableCommandSettings);
			runtimeAdapter.ConsoleAPICalled += ConsoleAPICalledProcessor;

			driver.Url = baseURL;
			element = driver.WaitUntilVisible(By.Id("consoleLog"));
			element.Click();
			session.Dispose();
		}

		private void ConsoleAPICalledProcessor(object sender, ConsoleAPICalledEventArgs e) {
			RemoteObject[] args = e.Args;
			System.Console.Error.WriteLine(String.Format(@"ConsoleAPICalled Args: Value : {0}" , args[0].Value ));
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


		private static IWebDriver CreateWebDriver(string browserPath, string driverPath) {
			var service = ChromeDriverService.CreateDefaultService(driverPath);
			service.EnableVerboseLogging = false;

			var options = new ChromeOptions { BinaryLocation = browserPath };
			options.AddArgument("incognito");

			return new ChromeDriver(service, options);
		}
	}
}
