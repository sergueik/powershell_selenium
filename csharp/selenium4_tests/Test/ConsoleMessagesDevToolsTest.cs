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

// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V119.Console.ConsoleMessage.html

// NOTE: the Console domain is deprecated - using Runtime or Log instead is advised
using Console = OpenQA.Selenium.DevTools.V109.Console;
using ConsoleAdapter = OpenQA.Selenium.DevTools.V109.Console.ConsoleAdapter;
using ConsoleMessage = OpenQA.Selenium.DevTools.V109.Console.ConsoleMessage;
using MessageAddedEventArgs = OpenQA.Selenium.DevTools.V109.Console.MessageAddedEventArgs;

using Extensions;

namespace Test {
	
	[TestFixture]
	public class ConsoleMessagesDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = true;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String baseURL = "https://www.selenium.dev/selenium/web/bidi/logEntryAdded.html";
		private ConsoleAdapter consoleAdapter;
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
			consoleAdapter = domains.Console;
			var enableCommandSettings = new Console.EnableCommandSettings();
			consoleAdapter.Enable(enableCommandSettings);
			consoleAdapter.MessageAdded += MessageProcessor;

			driver.Url = baseURL;
			element = driver.WaitUntilVisible(By.Id("consoleLog"));
			element.Click();
			session.Dispose();
		
		}
		// NOTE: Warning CS1998: This async method lacks 'await' operators and will run synchronously. Consider using the 'await' operator to await non-blocking API calls, or 'await Task.Run(...)' to do CPU-bound work on a background thread.
		private void MessageProcessor(object sender, MessageAddedEventArgs e) {
			// Wait for message.
			// NOTE: Error CS4001: Cannot await 'OpenQA.Selenium.DevTools.V109.Console.ConsoleMessage'
			ConsoleMessage message = e.Message;
			System.Console.Error.WriteLine(String.Format(@"ConsoleMessage: Level: {0} Text: ""{1}"" Line: {2} Column: {3} Url: ""{4}""" , message.Level, message.Text, message.Line, message.Column, message.Url));
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
