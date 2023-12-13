using NUnit.Framework;

/* Copyright 2023 Serguei Kouzmine */

using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Chromium;
using SeleniumExtras.WaitHelpers;

using Extensions;
using TestUtils;

// https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setUserAgentOverride
namespace Test {
	[TestFixture]
	public class PageNavigationHistoryCdpTest {
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private const bool headless = true;
		private const String url = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private WebDriverWait wait;
		private IWebElement element;
		private ChromiumDriver chromiumDriver;
		private string command;
		private string userAgent;
		
		// NOTE: the "params" is reserved in .Net
		private Dictionary<String, Object> arguments = new Dictionary<String, Object>();
		private Object result;
		private Dictionary<String, Object> data = new Dictionary<string, object>();
		private string[] urls = { "https://fr.wikipedia.org/wiki",
			"https://de.wikipedia.org/wiki", "https://es.wikipedia.org/wiki",
			"https://it.wikipedia.org/wiki", "https://ar.wikipedia.org/wiki",
			"https://en.wikipedia.org/wiki", "https://fi.wikipedia.org/wiki",
			"https://hu.wikipedia.org/wiki", "https://da.wikipedia.org/wiki",
			"https://pt.wikipedia.org/wiki"
		};
		private Object[] entries;
		private Dictionary<String, Object> entry;
		private string cssSelector = "#ca-nstab-main > a";

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
			wait = new WebDriverWait(driver, new TimeSpan(0, 0, 30));
			foreach (string url in Common.shuffle(urls)) {
				driver.Navigate().GoToUrl(url);
				Thread.Sleep(100);
			}
		}

		[TearDown]
		public void tearDown() {
			command = "Page.resetNavigationHistory";
			chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
			try {
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}

		[Test]
		public void test1() {
			command = "Page.getNavigationHistory";
			result = chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
			Assert.NotNull(result);
			data = result as Dictionary<String, Object>;
			
			Console.Error.WriteLine("result keys: " + data.PrettyPrint());
			entries = data["entries"] as Object[];
			Assert.NotNull(entries);
			entry = entries[0] as Dictionary<String, Object>;
			Assert.NotNull(entry);
			Console.Error.WriteLine("entry keys: " + entry.PrettyPrint());
		}

		[Test]
		public void test2() {
			command = "Page.getNavigationHistory";
			result = chromiumDriver.ExecuteCdpCommand(command, new Dictionary<String, Object>());
			Assert.NotNull(result);
			data = result as Dictionary<String, Object>;
			entries = data["entries"] as Object[];
			var result2 = entries.First((Object o) => { 
				var e = o as Dictionary<String, Object>;
				return e["url"].ToString().IndexOf("https://en.wikipedia.org/wiki") == 0;
			});
			Assert.NotNull(result2);
			entry = result2 as Dictionary<String, Object>;
			Assert.NotNull(entry);
			Console.Error.WriteLine("entry keys: " + entry.PrettyPrint());
			command = "Page.navigateToHistoryEntry";
			arguments.Clear();
			arguments["entryId"] = entry["id"];
			chromiumDriver.ExecuteCdpCommand(command, arguments);
			element = driver.WaitUntilVisible(By.CssSelector(cssSelector));
			Assert.IsTrue(element.Displayed);
			driver.VerifyElementTextPresent(element, "Main Page");
			Assert.AreEqual("Main Page", element.Text);
			Console.Error.WriteLine("page from hostory: " + element.Text);
		}
	}

}
