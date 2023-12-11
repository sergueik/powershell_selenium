using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Page.EnableCommandSettings;
using SetDeviceMetricsOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Emulation.SetDeviceMetricsOverrideCommandSettings;
using SetUserAgentOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Network.SetUserAgentOverrideCommandSettings;
using GetLayoutMetricsCommandResponse = OpenQA.Selenium.DevTools.V109.Page.GetLayoutMetricsCommandResponse;
using Extensions;

// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V109.Page.GetLayoutMetricsCommandResponse.html
// https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-getLayoutMetrics
// https://chromedevtools.github.io/devtools-protocol/tot/Emulation/#method-setDeviceMetricsOverride
// https://chromedevtools.github.io/devtools-protocol/tot/Page#method-captureScreenshot
// https://chromedevtools.github.io/devtools-protocol/tot/Emulation/#method-clearDeviceMetricsOverride

namespace Test {
	[TestFixture]
	public class SetDeviceMetricsOverrideDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private const bool headless = false;
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
			domains.Page.Enable(new EnableCommandSettings());
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

		[Test]
		public void test() {
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

				domains.Emulation.SetDeviceMetricsOverride(settings);
		
				Console.Error.WriteLine("Pretend Device Metric Settings Width: " + device_width);
				driver.Navigate().GoToUrl(url);

				driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
				// NOTE: browser needs to be visible for this element to be found
				element = driver.WaitUntilVisible(By.XPath("//*[@id=\"content-base\"]//table//th[contains(text(),\"VIEWPORT-WIDTH\")]/../td"));
				Assert.IsTrue(element.Displayed);
				driver.VerifyElementTextPresent(element, String.Format("{0}", viewport_width));
				Assert.AreEqual(String.Format("{0}", viewport_width), element.Text);
				driver.Highlight(element);
				// 480 VIEWPORT-WIDTH 384
				// 600 VIEWPORT-WIDTH 480
				var layoutMetrics = domains.Page.GetLayoutMetrics().Result;
				var visualViewport = layoutMetrics.VisualViewport;
				
				Console.Error.WriteLine("Viewport zoom: " + visualViewport.Zoom.ToString() + "," +
				"scale: " + visualViewport.Scale + "," +
				"ClientWidth: " + visualViewport.ClientWidth);
				Thread.Sleep(100);
				
			}
		}
	}
}
