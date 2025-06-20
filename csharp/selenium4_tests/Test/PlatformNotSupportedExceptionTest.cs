using System;

using OpenQA.Selenium;
using OpenQA.Selenium.Chromium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;

using NUnit.Framework;

using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
namespace Test {
	public class PlatformNotSupportedExceptionTest {
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = true;
		private IDevToolsSession session;

		[SetUp]
		// C# doesn't use the throws keyword in method signatures like Java to declare exceptions		
		public void setUp() {
			try {
				platformDependentApi();	
			} catch (PlatformNotSupportedException) {
				Assert.Ignore("Platform not supported — skipping tests.");				
				return;
			} catch (Exception ex) { // Catch all other exceptions
				Console.WriteLine(String.Format("An unexpected error occurred: {0}", ex.Message));
				return;
			}
		}
		
		

		[SetUp]
		public void platformCheck() {
			var options = new ChromeOptions();

			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options)  as ChromiumDriver;
			devTools = driver as IDevTools;

			try {
				session = devTools.GetDevToolsSession();
			} catch (WebDriverException e) {
				// Console.WriteLine("Got WebDriverEXception");
				if (e.InnerException is PlatformNotSupportedException) {
					Assert.Ignore("Platform not supported — skipping all tests.");
					return;
				}
			}
		}

		// Example of a platform-dependent API (for illustration purposes)
		public static void platformDependentApi() {
			throw new PlatformNotSupportedException("This feature is not available on this environmenr.");
		}

		[Test]
		public void test() {
			if (session == null)
				return;
		}

		[TearDown]
		public void tearDown() {
			try {
				if (driver != null)
					driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */

		}
	}
}
