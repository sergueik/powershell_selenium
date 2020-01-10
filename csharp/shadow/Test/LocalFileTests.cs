using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using System.Threading;

using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;

using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Support.UI;

using FluentAssertions;

namespace ShadowDriver.Test {

	[TestFixture]
	public class LocalFileTests {
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private ShadowWebDriver shadowDriver;
		private WebDriverWait wait;
		private Actions actions;
		private bool headless = true;
		private const int wait_seconds = 3;
		private const long wait_poll_milliseconds = 300;

		[TestFixtureSetUp]
		public void SetUp() {

			// initialize custom HttpListener subclass to host the local files
			// https://docs.microsoft.com/en-us/dotnet/api/system.net.httplistener?redirectedfrom=MSDN&view=netframework-4.7.2
			String filePath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", "");
			
			// initialize the Selenium driver
			// driver = new FirefoxDriver();
			// System.InvalidOperationException : Access to 'file:///...' from script denied (UnexpectedJavaScriptError)
			if (headless) { 
				var option = new ChromeOptions();
				option.AddArgument("--headless");
				driver = new ChromeDriver(option);
			} else {
				driver = new ChromeDriver();
			}
			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(60);

			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
			actions = new Actions(driver);
		}

		[TestFixtureTearDown]
		public void TearDown()
		{
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore whatsoever cleanup errors */
			Assert.IsEmpty(verificationErrors.ToString());
		}

		[Test]
		public void ShouldDo() {
		}
	}
}
