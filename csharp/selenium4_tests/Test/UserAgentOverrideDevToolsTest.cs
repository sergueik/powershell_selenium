using NUnit.Framework;
/* Copyright 2023 Serguei Kouzmine */
using System;
using System.Text;
using System.Linq;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using SetUserAgentOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Network.SetUserAgentOverrideCommandSettings;
using Extensions;

// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setUserAgentOverride
namespace Test {
	[TestFixture]
	public class UserAgentOverrideDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private const bool headless = true;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String url = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private IWebElement element;
		
		[SetUp]
		public void setUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);
			// NOTE: not using the WebDriver Service
			// var service = ChromeDriverService.CreateDefaultService();
			// service.DriverServicePath = driverLocation;
			// IWebDriver driver = new ChromeDriver(service);	

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);
		
			devTools = driver as IDevTools;
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
		}

		// NOTE: ignoring the console logs:
		// ERROR: Couldn't read tbsCertificate as SEQUENCE
		// ERROR: Failed parsing Certificate
		// [5188:7540:0806/195815.500:ERROR:device_event_log_impl.cc(215)] [19:58:15.500] USB: usb_device_handle_win.cc:1046 Failed to read descriptor from node connection: A device attached to the system is not functioning. (0x1F)

		[TearDown]
		public void tearDown() {
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		// https://stackoverflow.com/questions/70912939/run-cdp-commands-on-selenium-c-sharp
		// see also: https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V109.Network.SetUserAgentOverrideCommandSettings.html
		// NOTE: With the version upgrade old documentation becomes unavailable on https://www.selenium.dev/selenium/docs/api/dotnet/ and
		// URL with specific Chrome version lime v109 above has become 404
		// the pinned old version is https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V85.Network.SetUserAgentOverrideCommandSettings.html
		// but there may be method argument signature differences between early and latest versions
		[Test]
		public void test() {
			Console.Error.WriteLine("Actual Browser User Agent: " + domains.Browser.GetVersion().Result.UserAgent);
			
			var settings = new SetUserAgentOverrideCommandSettings();
			const String userAgent = "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25";
			settings.UserAgent = userAgent;
			Console.Error.WriteLine("Set User Agent: " + userAgent);
			domains.Network.SetUserAgentOverride(settings);
		
			driver.Navigate().GoToUrl(url);

			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			element = driver.WaitUntilVisible(By.XPath("//*[@id=\"content-base\"]//table//th[contains(text(),\"USER-AGENT\")]/../td"));
			Assert.IsTrue(element.Displayed);
			Assert.AreEqual(userAgent, element.Text);
			driver.Highlight(element);
			Thread.Sleep(1000);
		}
	}
}

