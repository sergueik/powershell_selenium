using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

using System;
using System.IO;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;

// https://chromedevtools.github.io/devtools-protocol/tot/Browser/#method-setDownloadBehavior

namespace Test {
	[TestFixture]
	public class BrowserDownloadCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		// NOTE: this test will fail when broswer is headless
		private const bool headless = false;
		private const String url = "https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx";
		private ChromiumDriver chromiumDriver;
		private string command;
		private string tempPath;
		private string filename = "samplepptx.pptx";

		// NOTE: the "params" is reserved in .Net
		private Dictionary<String, Object> arguments = new Dictionary<String, Object>();
		private Dictionary<String, Object> data = new Dictionary<string, object>();

		// NOTE: prior to NUnit 3.0, in particular with Nunit 2.6.4
		// annotations 'OneTimeSetUpAttribute' and 'OneTimeSetUp' did not exist
		// http://nunit.org/docs/2.6.4/docHome.html
		// https://docs.nunit.org/articles/nunit/writing-tests/setup-teardown/index.html
		// https://docs.nunit.org/articles/nunit/release-notes/breaking-changes.html
		// [OneTimeSetUp]
		[TestFixtureSetUp]
		public void testFixtureSetUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			if (headless) {
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);
			chromiumDriver = driver as ChromiumDriver;
			// NOTE: the trailing backslash is already returned by Path.GetTempPath()
			// double backslashes have special meaning
			tempPath = Path.GetTempPath() + "test";
			Directory.CreateDirectory(tempPath );
			Directory.CreateDirectory(tempPath );
			Console.WriteLine(tempPath);
		}

		[SetUp]
		public void setUp() {
			command = "Browser.setDownloadBehavior";
			arguments.Clear();
			arguments["behavior"] = "default";
			chromiumDriver.ExecuteCdpCommand(command, arguments);
		}

		// [OneTimeTearDown]
		[TestFixtureTearDown]
		public void testFixtureTearDown() {
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore all cleanup errors */
			// clean downloaded files
			Directory.GetFiles(tempPath).ToList().ForEach(f => File.Delete(f));
			// delete directory
			Directory.Delete(tempPath, true);
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void test1() {
			command = "Browser.setDownloadBehavior";
			arguments.Clear();
			arguments["behavior"] = "allow";
			arguments["downloadPath"] = tempPath;
			arguments["eventsEnabled"] = true;
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			driver.Navigate().GoToUrl(url);
			Thread.Sleep(3000);
			Assert.IsTrue(File.Exists(tempPath + @"\" + filename), "File does not exist: " + filename  );
			Directory.GetFiles(tempPath, filename).ToList().ForEach(f => Console.WriteLine(f.ToString()));
		}

		// [Ignore]
		[Test]
		public void test2() {

			command = "Browser.setDownloadBehavior";
			arguments.Clear();
			arguments["behavior"] = "allowAndName";
			arguments["downloadPath"] = tempPath;
			arguments["eventsEnabled"] = true;
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			driver.Navigate().GoToUrl(url);
			Thread.Sleep(3000);
			Assert.IsTrue(Directory.GetFiles(tempPath).ToList().Count > 0 , "No files downloaded");
			Directory.GetFiles(tempPath).ToList().ForEach(f => Console.WriteLine(f.ToString()));
		}
	}

}
