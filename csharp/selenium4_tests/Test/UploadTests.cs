using NUnit.Framework;

using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium.DevTools;
using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using SeleniumExtras.WaitHelpers;

using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using Network = OpenQA.Selenium.DevTools.V109.Network;
using NetworkAdapter = OpenQA.Selenium.DevTools.V109.Network.NetworkAdapter;
using Request = OpenQA.Selenium.DevTools.V109.Network.Request;
using RequestWillBeSentEventArgs = OpenQA.Selenium.DevTools.V109.Network.RequestWillBeSentEventArgs;
using Headers = OpenQA.Selenium.DevTools.V109.Network.Headers;
using Fetch = OpenQA.Selenium.DevTools.V109.Fetch;

using Extensions;
using TestUtils;

namespace Test {
	
	[TestFixture]
	public class UploadTests {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private WebDriverWait wait;
		private IWebElement element;
		private bool headless = true;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String baseURL = "https://ps.uci.edu/~franklin/doc/file_upload.html";
		private const String uploadURL = "https://www.oac.uci.edu/indiv/franklin/cgi-bin/values";
		//  origin: https://png-pixel.com
		private const String filename = @"c:\temp\1x1.png";
		private NetworkAdapter networkAdaptor;
		private Dictionary<String, Headers> data = new Dictionary<String, Headers>();
		
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
			wait = new WebDriverWait(driver, new TimeSpan(0, 0, 30));
		}

		[Test]
		public void test() {
			networkAdaptor = domains.Network;
			var enableCommandSettings = new Network.EnableCommandSettings();
			networkAdaptor.Enable(enableCommandSettings);
			networkAdaptor.RequestWillBeSent += RequestIntercepted;
			driver.Url = baseURL;

			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);		
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.CssSelector("input[name='userfile']")));
			Assert.IsTrue(element.Displayed);

			driver.Highlight(element);

			element.SendKeys( filename);
			element = wait.Until(ExpectedConditions.ElementIsVisible(By.CssSelector("input[type='submit']")));
			Assert.IsTrue(element.Displayed);

			driver.Highlight(element);
			element.Click();
			Thread.Sleep(300);
			
			Assert.Contains(uploadURL, data.Keys);
			data.Keys.ToList().ForEach(	o => Console.Error.WriteLine(String.Format("url: {0} headers: {1}", o, data[o].PrettyPrint())));
			Assert.Contains("Content-Type", data[uploadURL].Keys);
			StringAssert.Contains("multipart/form-data", data[uploadURL]["Content-Type"]);
			Console.Error.WriteLine(String.Format("Content-Type: {0}", data[uploadURL]["Content-Type"]));
			
			session.Dispose();
		}
		
		private void RequestIntercepted(object sender, Network.RequestWillBeSentEventArgs e) {
			var url = e.Request.Url;
			var headers = e.Request.Headers;
			data.Add(url, headers);
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
