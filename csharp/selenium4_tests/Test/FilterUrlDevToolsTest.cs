using NUnit.Framework;

/**
 * Copyright 2024 Serguei Kouzmine
 */
	
using System;
using System.Text;
using System.Linq;
using System.Collections;

using System.Threading;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chromium;
using SeleniumExtras.WaitHelpers;


using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Network.EnableCommandSettings;
using SetBlockedURLsCommandSettings = OpenQA.Selenium.DevTools.V109.Network.SetBlockedURLsCommandSettings;
using Headers = OpenQA.Selenium.DevTools.V109.Network.Headers;
using Extensions;

// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setBlockedURLs
// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setCacheDisabled
// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-clearBrowserCache


namespace Test {
	[TestFixture]
	public class FilterUrlDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = false;
		private WebDriverWait wait;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const string tagName = "img";
		private const String url = "http://arngren.net";
		private IWebElement element;
		private readonly String username = "guest";
		private readonly String password = "guest";
		private byte[] input = { };

		[SetUp]
		public void setUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			
			wait = new WebDriverWait(driver, new TimeSpan(0, 0, 30));
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			// 'OpenQA.Selenium.ITimeouts' does not contain a definition for 'SetScriptTimeout'
			devTools = driver as IDevTools;
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
			domains.Network.Enable(new EnableCommandSettings());
		}

		[TearDown]
		public void tearDown() {
			try {
				domains.Network.Disable();
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		// see also:
  		// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V109.Network.SetExtraHTTPHeadersCommandSettings.html
		// if you get a 404, try replacing v109 with the latest released Chromium Tool version e.g. v126
		// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V109.Network.Headers.html
		// Windows 7:
		// Unexpected error creating WebSocket DevTools session.
  		// ----> System.PlatformNotSupportedException : The WebSocket protocol is not supported on this platform.
		[Test]
		[Platform(Include = "Windows8,Windows8.1,Windows10,Windows11,WindowsServer10")]
		public void test1() {
			var settings = new SetBlockedURLsCommandSettings();
			var urls = new ArrayList();

			urls.Add("*.css");
			urls.Add("*.png");
			urls.Add("*.jpg");
			urls.Add("*.gif");
			urls.Add("*favicon.ico");

			Console.Error.WriteLine("Set Blocked URLs: " );
			Action<String> print = url => Console.Error.WriteLine(url);
			foreach (var urle in urls) {
				print(url);
		    }
			settings.Urls =  (string[])urls.ToArray(typeof(string));
			domains.Network.SetBlockedURLs(settings);
			driver.Navigate().GoToUrl(url); 
			wait.Until(ExpectedConditions.ElementIsVisible(By.TagName(tagName)));
			foreach (var image in driver.FindElements(By.TagName(tagName)).Take(10)) { 
				IsImageBroken(image);
				driver.Highlight(image);

			}	
			Thread.Sleep(3000);
		}

		private void IsImageBroken(IWebElement image){
			if (image.GetAttribute("naturalWidth").Equals("0")) {
				Console.Error.WriteLine(String.Format("{0} is broken.", image.GetAttribute("src")));
			}
		}

	}
	
}
