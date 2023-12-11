using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */
using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;

using Extensions;

// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setExtraHTTPHeaders
// https://chromedevtools.github.io/devtools-protocol/tot/Network#method-enable

namespace Test {
	[TestFixture]
	public class AuthCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private const bool headless = false;
		private const String url = "https://jigsaw.w3.org/HTTP/Basic/";
		private IWebElement element;
		private ChromiumDriver chromiumDriver;
		private string command;
		// NOTE: the "params" is reserved in .Net
		private Dictionary<String, Object> arguments = new Dictionary<String, Object>();
		private Dictionary<String, String> headers = new Dictionary<String, String>();
		private Dictionary<String, Object> data = new Dictionary<String, Object>();
		private readonly String username = "guest";
		private readonly String password = "guest";
		private byte[] input = { };
		private Encoding enc = Encoding.UTF8;


		[SetUp]
		public void setUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);
			chromiumDriver = driver as ChromiumDriver;
			command = "Network.enable";
			chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
		}

		[TearDown]
		public void tearDown() {
			command = "Network.disable";
			chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}
		// TODO: add test with exception
		//  OpenQA.Selenium.WebDriverArgumentException : invalid argument: Invalid parameters (Session info: headless chrome=109.0.5414.168) at OpenQA.Selenium.WebDriver.UnpackAndThrowOnError(Response errorResponse, String commandToExecute)
		// arguments["Authorization"] = "Basic " + Convert.ToBase64String(input);

		[Test]
		public void test1() {
			command = "Network.setExtraHTTPHeaders";

			input = enc.GetBytes(String.Format("{0}:{1}", username, password));

			headers["authorization"] = "Basic " + Convert.ToBase64String(input);

			arguments["headers"] = headers;
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			driver.Navigate().GoToUrl(url); 
			element = driver.FindElement(By.XPath("//body"));
			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			Assert.AreEqual("Your browser made it!", element.Text);
			Console.Error.WriteLine("Page body: " + element.Text);
		}

		[Test]
		public void test2() {
			if (headless)
				return;
			driver.Navigate().GoToUrl(url); 
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
			driver.Navigate().GoToUrl(url); 
			element = driver.FindElement(By.XPath("//body"));

			Assert.IsTrue(element.Displayed);
			driver.Highlight(element);
			StringAssert.Contains("Unauthorized access", element.Text);
			StringAssert.Contains("You are denied access to this resource.", element.Text);
			Console.Error.WriteLine("Page body: " + element.Text);
		}

		// TODO: add test with exception
		//  OpenQA.Selenium.WebDriverArgumentException : invalid argument: Invalid parameters (Session info: headless chrome=109.0.5414.168) at OpenQA.Selenium.WebDriver.UnpackAndThrowOnError(Response errorResponse, String commandToExecute)
		// arguments["Authorization"] = "Basic " + Convert.ToBase64String(input);

		[Test]
		public void test4() {
			if (!headless)
				return;
			command = "Network.setExtraHTTPHeaders";

			input = enc.GetBytes(String.Format("{0}:{1}", username, password));

			arguments["authorization"] = "Basic " + Convert.ToBase64String(input);
			var e = Assert.Throws<WebDriverArgumentException>(() =>
			                                                   chromiumDriver.ExecuteCdpCommand(command, arguments));
			Assert.IsTrue(e.Message.Contains("invalid argument: Invalid parameters"));
			Console.WriteLine("test4 files with expected exception: " + e.GetType() + " " + e.Message);
		}
	}
}
