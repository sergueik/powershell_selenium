using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

using System;
using System.IO;
using System.Text;
using System.Linq;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using OpenQA.Selenium.DevTools.V109.Browser;
using SetDownloadBehaviorCommandResponse  = OpenQA.Selenium.DevTools.V109.Browser.SetDownloadBehaviorCommandResponse;
using SetDownloadBehaviorCommandSettings  = OpenQA.Selenium.DevTools.V109.Browser.SetDownloadBehaviorCommandSettings;

// https://chromedevtools.github.io/devtools-protocol/tot/Browser/#method-setDownloadBehavior
namespace Test {
	[TestFixture]
	public class BrowserDownloadDevToolsTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		// NOTE: this test will fail when broswer is headless
		private const bool headless = false;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String url = "https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx";
		private string tempPath;
		private string filename = "samplepptx.pptx";

		// [OneTimeSetUp]
		[TestFixtureSetUp]
		public void testFixtureSetUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("-headless");
			}
			driver = new ChromeDriver(options);

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);
			// driver.Manage().Timeouts().SetScriptTimeout(TimeSpan.FromSeconds(5));
		
			devTools = driver as IDevTools;
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
			tempPath = Path.GetTempPath() + "test";
			Directory.CreateDirectory(tempPath );
			Console.WriteLine(tempPath);
		}

		[SetUp]
		public void setUp() {
			var command = new SetDownloadBehaviorCommandSettings();
			command.Behavior = "default";
			domains.Browser.SetDownloadBehavior(command);
		}

		// [OneTimeTearDown]
		[TestFixtureTearDown]
		public void tearDown() {
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			// clean downloaded files
			Directory.GetFiles(tempPath).ToList().ForEach(f => File.Delete(f));
			// delete directory
			Directory.Delete(tempPath, true);
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void test1() {
			var command = new SetDownloadBehaviorCommandSettings();
			command.Behavior = "allow";
			command.EventsEnabled = true;
			
			command.DownloadPath = tempPath;
			domains.Browser.SetDownloadBehavior(command);
			
			var searchPattern = filename;
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			driver.Navigate().GoToUrl(url);
			Thread.Sleep(3000);
			Assert.IsTrue(File.Exists(tempPath + @"\" + filename), "File does not exist: " + filename  );
			Directory.GetFiles(tempPath, searchPattern).ToList().ForEach(f => Console.WriteLine(f.ToString()));
		}
		[Test]
		public void test2() {
			var command = new SetDownloadBehaviorCommandSettings();
			command.Behavior = "allowAndName";
			command.EventsEnabled = true;
			
			command.DownloadPath = tempPath;
			domains.Browser.SetDownloadBehavior(command);
			driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
			driver.Navigate().GoToUrl(url);
			Thread.Sleep(3000);
			Assert.IsTrue(Directory.GetFiles(tempPath).ToList().Count > 0 , "No files downloaded");
			Directory.GetFiles(tempPath).ToList().ForEach(f => Console.WriteLine(f.ToString()));
		}
	}
}

