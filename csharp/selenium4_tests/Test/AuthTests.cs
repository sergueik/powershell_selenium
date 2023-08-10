using NUnit.Framework;

using System;
using System.Text;
using System.Linq;
using System.Management;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Network.EnableCommandSettings;
using SetExtraHTTPHeadersCommandSettings = OpenQA.Selenium.DevTools.V109.Network.SetExtraHTTPHeadersCommandSettings;
using Headers = OpenQA.Selenium.DevTools.V109.Network.Headers;
using System.IO;
using Extensions;
using TestUtils;

namespace Selenium4.Test {
	[TestFixture]
	public class AuthTests {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = true;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private static String baseURL = "https://jigsaw.w3.org/HTTP/Basic/";
		private IWebElement element;
		private readonly String username = "guest";
		private readonly String password = "guest";
		private byte[] input = { };
		[SetUp]
		public void SetUp()
		{
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
				// driver = new ChromeDriver(option);
			} else {
				// driver = new ChromeDriver();
			}
			driver = new ChromeDriver(options);

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
			// 'OpenQA.Selenium.ITimeouts' does not contain a definition for 'SetScriptTimeout'

		    
		
			devTools = driver as IDevTools;
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
			domains.Network.Enable(new EnableCommandSettings());
		}

		[TearDown]
		public void TearDown()
		{
			try {
				domains.Network.Disable();
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		// see also:
		// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V109.Network.SetExtraHTTPHeadersCommandSettings.html
		// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V109.Network.Headers.html
		[Test]
		public void test1() {
			var settings = new SetExtraHTTPHeadersCommandSettings();
			var headers = new Headers();
			headers["Authorization"] = "Basic " + Convert.ToBase64String(Encoding.UTF8.GetBytes(String.Format("{0}:{1}", username, password)));
			headers["Authorization"] = "Basic " + Encode(String.Format("{0}:{1}", username, password));
			Console.Error.WriteLine("Added Authorization headers: " + headers["Authorization"]);
			settings.Headers = headers;
			domains.Network.SetExtraHTTPHeaders(settings);
			driver.Navigate().GoToUrl(baseURL); 
			element = driver.FindElement(By.XPath("//body"));
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			Assert.AreEqual("Your browser made it!", element.Text);
		}

		[Test]
		public void test2() {
			if (headless)
				return;
			driver.Navigate().GoToUrl(baseURL); 
			element = driver.FindElement(By.XPath("//body"));
			// if the logon fails the stale element exception was seen here
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			Assert.IsEmpty(element.Text);
		}

		// [Ignore]
		[Test]
		// [ExpectedException(typeof(StaleElementReferenceException))]
		// if the logon fails the stale element exception was occasionally observed here
		public void test3() {
			if (!headless)
				return;
			driver.Navigate().GoToUrl(baseURL); 
			element = driver.FindElement(By.XPath("//body"));
			
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			StringAssert.Contains("Unauthorized access", element.Text);
			StringAssert.Contains("You are denied access to this resource.", element.Text);
		}

		// based on:
		// http://www.java2s.com/Code/CSharp/Development-Class/Base64encode.htm
		private String Encode(String payload){
			byte[] data = Encoding.UTF8.GetBytes(payload);
			return Convert.ToBase64String(data, 0, data.Length);
		}

		public static String Decode(string data) {
			return Encoding.UTF8.GetString(Convert.FromBase64String(data));

		}
		
	}
	
}
